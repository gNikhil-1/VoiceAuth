const LABELS = {
  idle: "Speak here",
  connecting: "Connecting",
  recording: "Listening",
  sending: "Sending",
  sent: "Sent",
  error: "Speak here",
};

export default function StatusLabel({ status, message }) {
  const error = status === "error";
  const hint = error ? message : status === "recording" ? "Tap again when you're done." : "";

  return (
    <div className="mt-[3.75rem] flex flex-col items-center text-center sm:mt-16">
      <p className="text-lg font-medium tracking-[-0.01em]">{LABELS[status]}</p>
      <p
        role="status"
        aria-live="polite"
        className={`mt-2 min-h-[1.25rem] max-w-[34ch] text-sm leading-relaxed
                    ${error ? "text-[#B3261E]" : "text-[#5A6372]"}`}
      >
        {hint}
      </p>
    </div>
  );
}
