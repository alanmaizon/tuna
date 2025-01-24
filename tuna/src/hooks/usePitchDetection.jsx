// src/hooks/usePitchDetection.jsx
import { useState, useEffect } from 'react';
import { noteFromPitch } from '../helpers/noteHelpers';

export const usePitchDetection = (audioContext, analyzer) => {
  const [pitch, setPitch] = useState(null);
  const [note, setNote] = useState(null);
  const [isListening, setIsListening] = useState(false);

  const startListening = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const source = audioContext.createMediaStreamSource(stream);
      source.connect(analyzer);
      setIsListening(true);
      detectPitch();
    } catch (err) {
      console.error('Error accessing microphone:', err);
    }
  };

  const detectPitch = () => {
    const bufferLength = analyzer.frequencyBinCount;
    const dataArray = new Float32Array(bufferLength);
    
    const updatePitch = () => {
      analyzer.getFloatTimeDomainData(dataArray);
      const currentPitch = autoCorrelate(dataArray, audioContext.sampleRate);
      
      if (currentPitch !== -1) {
        setPitch(currentPitch);
        setNote(noteFromPitch(currentPitch));
      }

      if (isListening) {
        requestAnimationFrame(updatePitch);
      }
    };

    updatePitch();
  };

  const stopListening = () => {
    setIsListening(false);
  };

  return { pitch, note, isListening, startListening, stopListening };
};
