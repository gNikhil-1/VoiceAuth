// AudioWorklet: downsamples the mic to targetRate (linear interpolation),
// converts to signed 16-bit PCM and posts fixed-size chunks with an RMS level.
class PcmProcessor extends AudioWorkletProcessor {
  constructor(options) {
    super();
    const { targetRate = 16000, chunkSize = 512 } = options.processorOptions ?? {};
    this.ratio = sampleRate / targetRate; // `sampleRate` is a worklet global
    this.chunkSize = chunkSize;
    this.out = new Int16Array(chunkSize);
    this.outLen = 0;
    this.pos = 0; // fractional read position; -1 refers to the previous block's last sample
    this.prev = 0;
    this.sumSq = 0;
  }

  process(inputs) {
    const input = inputs[0]?.[0];
    if (!input || input.length === 0) return true;

    while (this.pos < input.length - 1) {
      const i = Math.floor(this.pos);
      const frac = this.pos - i;
      const a = i < 0 ? this.prev : input[i];
      const b = input[i + 1];
      const s = Math.max(-1, Math.min(1, a + (b - a) * frac));

      this.out[this.outLen++] = s < 0 ? s * 0x8000 : s * 0x7fff;
      this.sumSq += s * s;
      this.pos += this.ratio;

      if (this.outLen === this.chunkSize) {
        const level = Math.sqrt(this.sumSq / this.chunkSize);
        const pcm = this.out.buffer;
        this.port.postMessage({ pcm, level }, [pcm]);
        this.out = new Int16Array(this.chunkSize);
        this.outLen = 0;
        this.sumSq = 0;
      }
    }

    this.pos -= input.length;
    this.prev = input[input.length - 1];
    return true;
  }
}

registerProcessor("pcm-processor", PcmProcessor);
