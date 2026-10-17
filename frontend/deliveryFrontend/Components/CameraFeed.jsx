import { useCamera } from "../hooks/useCamera";

export default function CameraFeed({ children }) {
  const { videoRef, status, message } = useCamera();

  return (
    <div
      className="relative aspect-[4/3] overflow-hidden rounded-[2rem] bg-[#D9DDE3]
                 shadow-[0_1px_0_rgba(22,27,36,0.04),0_24px_48px_-28px_rgba(22,27,36,0.35)]
                 sm:aspect-[16/10]"
    >
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        className={`h-full w-full -scale-x-100 object-cover transition-opacity duration-700
                    ${status === "live" ? "opacity-100" : "opacity-0"}`}
      />

      {status !== "live" && (
        <div className="absolute inset-0 grid place-items-center px-8 text-center" role="status">
          <p className="max-w-[28ch] text-sm leading-relaxed text-[#5A6372]">
            {status === "loading" ? "Starting camera…" : message}
          </p>
        </div>
      )}

      {children}
    </div>
  );
}
