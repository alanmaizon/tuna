// src/helpers/noteHelpers.js
const NOTE_STRINGS = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

export const noteFromPitch = (frequency) => {
  const noteNum = 12 * (Math.log(frequency / 440) / Math.log(2));
  const note = Math.round(noteNum) + 69;
  return NOTE_STRINGS[note % 12];
};

export const getCentsOffPitch = (frequency, note) => {
  // Calculate cents off from perfect pitch
  // Implementation depends on your specific needs
};

export const autoCorrelate = (buffer, sampleRate) => {
  // Implementation of autocorrelation algorithm
  // This is a simplified version
  let SIZE = buffer.length;
  let sumOfSquares = 0;
  
  for (let i = 0; i < SIZE; i++) {
    const val = buffer[i];
    sumOfSquares += val * val;
  }
  
  const rootMeanSquare = Math.sqrt(sumOfSquares / SIZE);
  if (rootMeanSquare < 0.01) {
    return -1; // Not enough signal
  }

  // Actual autocorrelation algorithm would go here
  // This is just a placeholder
  return 440; // Returns 440Hz as an example
};
