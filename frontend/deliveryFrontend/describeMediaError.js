export function describeMediaError(err, device) {
  switch (err?.name) {
    case "NotAllowedError":
      return `Allow ${device} access in your browser settings, then try again.`;
    case "NotFoundError":
      return `No ${device} found. Connect one and try again.`;
    case "NotReadableError":
      return `The ${device} is in use by another app. Close it and try again.`;
    default:
      return `Couldn't start the ${device}. Reload the page and try again.`;
  }
}
