export function getGreeting(date = new Date()) {
  const h = date.getHours();
  if (h < 5) return "Still up? How can I help?";
  if (h < 12) return "Good morning. How can I help?";
  if (h < 18) return "Good afternoon. How can I help?";
  return "Good evening. How can I help?";
}
