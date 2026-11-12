// Loopback WebSocket of the local service. Override with VITE_AUDIO_SOCKET_URL in .env
export const AUDIO_SOCKET_URL =
  import.meta.env?.VITE_AUDIO_SOCKET_URL ?? "ws://127.0.0.1:8765";

export const TARGET_SAMPLE_RATE = 16000; // Hz, mono, signed 16-bit little-endian
export const CHUNK_SAMPLES = 512; // ~32 ms per binary frame
export const CONNECT_TIMEOUT_MS = 2500;
export const ACK_TIMEOUT_MS = 3000;
