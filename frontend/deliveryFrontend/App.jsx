import { useCallback, useRef } from "react";
import CameraFeed from "./components/CameraFeed";
import Greeting from "./components/Greeting";
import RecordingBadge from "./components/RecordingBadge";
import SpeakButton from "./components/SpeakButton";
import StatusLabel from "./components/StatusLabel";
import { usePcmStreamer } from "./hooks/usePcmStreamer";

export default function App() {
  const ringRef = useRef(null);

  // Written straight to a CSS variable so the meter never re-renders React.
  const onLevel = useCallback((level) => {
    ringRef.current?.style.setProperty("--level", level.toFixed(3));
  }, []);

  const { status, message, start, stop } = usePcmStreamer({ onLevel });
  const recording = status === "recording";

  return (
    <main
      className="min-h-dvh bg-[#ECEEF1] text-[#161B24] antialiased
                 font-['Bricolage_Grotesque',ui-sans-serif,system-ui,sans-serif]"
    >
      <div className="mx-auto flex min-h-dvh w-full max-w-3xl flex-col px-6 pb-14 pt-12 sm:px-10 sm:pt-16">
        <Greeting />

        <section aria-label="Camera feed" className="relative mt-10 sm:mt-14">
          <CameraFeed>{recording && <RecordingBadge />}</CameraFeed>
          <SpeakButton status={status} ringRef={ringRef} onToggle={recording ? stop : start} />
        </section>

        <StatusLabel status={status} message={message} />
      </div>
    </main>
  );
}
