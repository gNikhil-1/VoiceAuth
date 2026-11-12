import CheckIcon from "./icons/CheckIcon";
import MicIcon from "./icons/MicIcon";
import SpinnerIcon from "./icons/SpinnerIcon";
import StopIcon from "./icons/StopIcon";

function ButtonIcon({ status }) {
  if (status === "connecting" || status === "sending") return <SpinnerIcon />;
  if (status === "recording") return <StopIcon />;
  if (status === "sent") return <CheckIcon />;
  return <MicIcon />;
}

// `ringRef` receives a --level CSS variable (0..1) from the audio meter.
export default function SpeakButton({ status, onToggle, ringRef }) {
  const recording = status === "recording";
  const busy = status === "connecting" || status === "sending";

  return (
    <div className="absolute inset-x-0 bottom-0 flex translate-y-1/2 justify-center">
      <div ref={ringRef} className="relative grid h-24 w-24 place-items-center" style={{ "--level": 0 }}>
        <span
          aria-hidden="true"
          className={`absolute inset-0 rounded-full bg-[#2D4BFF] ${recording ? "opacity-20" : "opacity-0"}`}
          style={{
            transform: "scale(calc(1 + var(--level) * 0.55))",
            transition: "transform 90ms linear, opacity 300ms",
          }}
        />
        <button
          type="button"
          onClick={onToggle}
          disabled={busy}
          aria-pressed={recording}
          aria-label={recording ? "Stop and send" : "Speak here"}
          className={`relative grid h-[4.5rem] w-[4.5rem] place-items-center rounded-full text-white
                      ring-[6px] ring-[#ECEEF1] transition-colors duration-200 active:scale-95
                      focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-[#2D4BFF]
                      disabled:cursor-wait
                      ${recording ? "bg-[#2D4BFF]" : "bg-[#161B24] hover:bg-[#2A3140]"}`}
        >
          <ButtonIcon status={status} />
        </button>
      </div>
    </div>
  );
}
