import { useCallback, useEffect, useRef, useState } from "react";
import {
  ACK_TIMEOUT_MS,
  AUDIO_SOCKET_URL,
  CHUNK_SAMPLES,
  CONNECT_TIMEOUT_MS,
  TARGET_SAMPLE_RATE,
} from "../config";
import { describeMediaError } from "../lib/describeMediaError";
import { openPcmSocket } from "../lib/openPcmSocket";

const WORKLET_URL = new URL("../audio/pcm-processor.js", import.meta.url);

/**
 * status: idle | connecting | recording | sending | sent | error
 *
 * Wire protocol (one connection per recording):
 *   text   {"type":"start","encoding":"pcm_s16le","sampleRate":16000,"channels":1}
 *   binary raw PCM frames, as captured
 *   text   {"type":"end"}
 * The service may reply with any message after "end" to confirm receipt.
 */
export function usePcmStreamer({ onLevel }) {
  const [status, setStatus] = useState("idle");
  const [message, setMessage] = useState("");

  const socketRef = useRef(null);
  const streamRef = useRef(null);
  const ctxRef = useRef(null);
  const nodeRef = useRef(null);
  const recordingRef = useRef(false);
  const resetRef = useRef(0);

  const teardownAudio = useCallback(() => {
    if (nodeRef.current) {
      nodeRef.current.port.onmessage = null;
      nodeRef.current.disconnect();
      nodeRef.current = null;
    }
    streamRef.current?.getTracks().forEach((t) => t.stop());
    streamRef.current = null;
    ctxRef.current?.close().catch(() => {});
    ctxRef.current = null;
    onLevel(0);
  }, [onLevel]);

  const closeSocket = useCallback(() => {
    const socket = socketRef.current;
    socketRef.current = null;
    if (socket) {
      socket.onmessage = socket.onclose = socket.onerror = null;
      socket.close();
    }
  }, []);

  const fail = useCallback(
    (text) => {
      recordingRef.current = false;
      teardownAudio();
      closeSocket();
      setStatus("error");
      setMessage(text);
    },
    [teardownAudio, closeSocket]
  );

  const start = useCallback(async () => {
    clearTimeout(resetRef.current);
    setMessage("");
    setStatus("connecting");

    let socket;
    try {
      socket = await openPcmSocket(AUDIO_SOCKET_URL, CONNECT_TIMEOUT_MS);
    } catch {
      return fail("Couldn't reach the local service. Check that it's running.");
    }
    socketRef.current = socket;
    socket.onclose = () => {
      if (recordingRef.current) fail("Lost the connection to the local service.");
    };

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          channelCount: 1,
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      });
      streamRef.current = stream;

      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      ctxRef.current = ctx;
      if (ctx.state === "suspended") await ctx.resume();
      await ctx.audioWorklet.addModule(WORKLET_URL);

      const node = new AudioWorkletNode(ctx, "pcm-processor", {
        numberOfOutputs: 1,
        outputChannelCount: [1],
        processorOptions: { targetRate: TARGET_SAMPLE_RATE, chunkSize: CHUNK_SAMPLES },
      });
      nodeRef.current = node;

      let smoothed = 0;
      node.port.onmessage = ({ data }) => {
        if (socket.readyState === WebSocket.OPEN) socket.send(data.pcm);
        smoothed = smoothed * 0.7 + Math.min(1, data.level * 4) * 0.3;
        onLevel(smoothed);
      };

      socket.send(
        JSON.stringify({
          type: "start",
          encoding: "pcm_s16le",
          sampleRate: TARGET_SAMPLE_RATE,
          channels: 1,
        })
      );

      // Muted tail keeps the worklet pulled by the audio graph without playing the mic back.
      const mute = ctx.createGain();
      mute.gain.value = 0;
      ctx.createMediaStreamSource(stream).connect(node).connect(mute).connect(ctx.destination);

      recordingRef.current = true;
      setStatus("recording");
    } catch (err) {
      fail(describeMediaError(err, "microphone"));
    }
  }, [fail, onLevel]);

  const stop = useCallback(() => {
    if (!recordingRef.current) return;
    recordingRef.current = false;
    teardownAudio();
    setStatus("sending");

    const socket = socketRef.current;
    let done = false;
    const finish = () => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      closeSocket();
      setStatus("sent");
      resetRef.current = setTimeout(() => setStatus("idle"), 2000);
    };
    const timer = setTimeout(finish, ACK_TIMEOUT_MS);
    socket.onmessage = finish;
    socket.onclose = finish;
    socket.send(JSON.stringify({ type: "end" }));
  }, [teardownAudio, closeSocket]);

  useEffect(
    () => () => {
      clearTimeout(resetRef.current);
      recordingRef.current = false;
      teardownAudio();
      closeSocket();
    },
    [teardownAudio, closeSocket]
  );

  return { status, message, start, stop };
}
