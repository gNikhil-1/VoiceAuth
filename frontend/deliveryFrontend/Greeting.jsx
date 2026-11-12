import { useState } from "react";
import { getGreeting } from "../lib/greeting";

export default function Greeting() {
  const [text] = useState(() => getGreeting());
  return (
    <h1 className="max-w-[16ch] text-[2.6rem] font-light leading-[1.05] tracking-[-0.03em] sm:text-6xl">
      {text}
    </h1>
  );
}
