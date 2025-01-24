// src/components/PitchMeter.jsx
export const PitchMeter = ({ cents }) => {
  return (
    <div className="pitch-meter">
      <div 
        className="meter-indicator"
        style={{ transform: `translateX(${cents}%)` }}
      />
    </div>
  );
};
