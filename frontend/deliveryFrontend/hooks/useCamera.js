import { useEffect, useRef, useState } from "react";
import { describeMediaError } from "../lib/describeMediaError";

export function useCamera() {
  const videoRef = useRef(null);
  const [state, setState] = useState({ status: "loading", message: "" });

  useEffect(() => {
    let stream;
    let cancelled = false;

    (async () => {
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: "user", width: { ideal: 1920 }, height: { ideal: 1080 } },
          audio: false,
        });
        if (cancelled) return stream.getTracks().forEach((t) => t.stop());
        if (videoRef.current) videoRef.current.srcObject = stream;
        setState({ status: "live", message: "" });
      } catch (err) {
        if (!cancelled)
          setState({ status: "error", message: describeMediaError(err, "camera") });
      }
    })();

    return () => {
      cancelled = true;
      stream?.getTracks().forEach((t) => t.stop());
    };
  }, []);

  return { videoRef, ...state };
}
