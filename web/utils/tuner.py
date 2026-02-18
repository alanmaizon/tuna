import numpy as np

A4_FREQ = 440.0

NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

def freq_to_note(freq):
    """Convert frequency to closest note, return name, ideal freq, and cent diff."""
    if freq <= 0:
        return 'N/A', 0, 0

    # MIDI note number
    midi = int(round(69 + 12 * np.log2(freq / A4_FREQ)))
    note_index = midi % 12
    note_name = NOTE_NAMES[note_index]

    # Calculate ideal frequency of this MIDI note
    ideal_freq = A4_FREQ * (2 ** ((midi - 69) / 12))

    # Cents difference from ideal note
    cents = 1200 * np.log2(freq / ideal_freq)

    return note_name, ideal_freq, cents

def generate_feedback(freq):
    """Generate a detailed tuning feedback object from a frequency in Hz."""
    note, target_freq, cents = freq_to_note(freq)

    if note == 'N/A':
        status = "No pitch detected."
    elif abs(cents) < 10:
        status = f"In tune with {note} ({freq:.2f} Hz)"
    elif cents > 0:
        status = f"Sharp by {cents:.2f} cents from {note}"
    else:
        status = f"Flat by {abs(cents):.2f} cents from {note}"

    return {
        "note": note,
        "predicted_frequency": round(freq, 2),
        "cents_difference": round(cents, 2),
        "feedback": status
    }
