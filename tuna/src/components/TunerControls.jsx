
// src/components/TunerControls.jsx
export const TunerControls = ({ isListening, onStart, onStop }) => {
  return (
    <div className="tuner-controls">
      <button 
        onClick={isListening ? onStop : onStart}
        className={`control-button ${isListening ? 'active' : ''}`}
      >
        {isListening ? 'Stop' : 'Start'}
      </button>
    </div>
  );
};
