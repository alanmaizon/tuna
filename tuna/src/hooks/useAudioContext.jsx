// src/hooks/useAudioContext.jsx
import { useState, useEffect } from 'react';

export const useAudioContext = () => {
  const [audioContext, setAudioContext] = useState(null);
  const [analyzer, setAnalyzer] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    try {
      const context = new (window.AudioContext || window.webkitAudioContext)();
      const analyzerNode = context.createAnalyser();
      analyzerNode.fftSize = 2048;
      
      setAudioContext(context);
      setAnalyzer(analyzerNode);
    } catch (err) {
      setError('AudioContext not supported');
    }
  }, []);

  return { audioContext, analyzer, error };
};
