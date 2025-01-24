// src/components/TunerDisplay.jsx
import { useState, useEffect } from 'react';

export const TunerDisplay = ({ note, frequency }) => {
  return (
    <div className="tuner-display">
      <div className="note">{note || '-'}</div>
      <div className="frequency">
        {frequency ? `${frequency.toFixed(2)} Hz` : '-'}
      </div>
    </div>
  );
};
