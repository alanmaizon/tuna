// src/App.jsx
import { useAudioContext } from './hooks/useAudioContext';
import { usePitchDetection } from './hooks/usePitchDetection';
import { TunerDisplay } from './components/TunerDisplay';
import { TunerControls } from './components/TunerControls';
import { PitchMeter } from './components/PitchMeter';
import './App.css';

function App() {
  const { audioContext, analyzer, error } = useAudioContext();
  const { 
    pitch, 
    note, 
    isListening, 
    startListening, 
    stopListening 
  } = usePitchDetection(audioContext, analyzer);

  if (error) {
    return <div className="error">{error}</div>;
  }

  return (
    <div className="tuner-app">
      <TunerDisplay note={note} frequency={pitch} />
      <PitchMeter cents={0} /> {/* Implement cents calculation */}
      <TunerControls 
        isListening={isListening}
        onStart={startListening}
        onStop={stopListening}
      />
    </div>
  );
}

export default App;
