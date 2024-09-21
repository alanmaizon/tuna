from flask import Flask, request, jsonify, render_template
import numpy as np
import crepe
import io
import soundfile as sf
from pydub import AudioSegment

NOTE_FREQUENCIES = {
    'C4': 261.63, 'C#4': 277.18, 'D4': 293.66, 'D#4': 311.13, 'E4': 329.63,
    'F4': 349.23, 'F#4': 369.99, 'G4': 392.00, 'G#4': 415.30, 'A4': 440.00,
    'A#4': 466.16, 'B4': 493.88, 'C5': 523.25, 'C#5': 554.37, 'D5': 587.33,
    'D#5': 622.25, 'E5': 659.25, 'F5': 698.46, 'F#5': 739.99, 'G5': 783.99,
    'G#5': 830.61, 'A5': 880.00, 'A#5': 932.33, 'B5': 987.77, 'C6': 1046.50
}

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/process_audio', methods=['POST'])
def process_audio():
    try:
        if 'audio_data' not in request.files:
            return jsonify({'error': 'No audio file provided'}), 400

        # Read the audio data from the request
        audio_file = request.files['audio_data']

        # Convert audio file to WAV using pydub
        audio = AudioSegment.from_file(io.BytesIO(audio_file.read()), format='webm')  # or 'ogg'
        
        # Force resampling to 16 kHz for consistent processing
        audio = audio.set_frame_rate(16000)  # Resample to 16 kHz
        wav_audio = io.BytesIO()
        audio.export(wav_audio, format='wav')
        wav_audio.seek(0)

        # Read the resampled audio data with soundfile
        audio_data, samplerate = sf.read(wav_audio)

        # Use the CREPE model to predict pitch
        time, frequency, confidence, activation = crepe.predict(audio_data, samplerate, viterbi=True)
        predicted_frequency = np.mean(frequency)

        feedback, closest_note, cents_difference = get_tuning_feedback(predicted_frequency)

        return jsonify({
            'predicted_frequency': float(predicted_frequency),
            'feedback': feedback,
            'closest_note': closest_note,
            'cents_difference': cents_difference
        })

    except Exception as e:
        print(f"Error processing audio: {str(e)}")
        return jsonify({'error': 'Internal Server Error', 'message': str(e)}), 500

# Function to find the closest note and give tuning feedback including cents
def get_tuning_feedback(predicted_frequency):
    closest_note = None
    min_difference = float('inf')
    
    # Find the closest note by comparing the predicted frequency with standard frequencies
    for note, frequency in NOTE_FREQUENCIES.items():
        difference = abs(predicted_frequency - frequency)
        if difference < min_difference:
            min_difference = difference
            closest_note = note
            closest_frequency = frequency
    
    # Calculate cents difference
    cents_difference = 1200 * np.log2(predicted_frequency / closest_frequency)
    
    # Provide feedback based on how far the predicted frequency is from the closest note
    if abs(cents_difference) < 10:  # Consider it in tune if less than 10 cents off
        feedback = f"In tune with {closest_note} ({predicted_frequency:.2f} Hz)"
    elif cents_difference > 0:
        feedback = f"Sharp by {cents_difference:.2f} cents from {closest_note}"
    else:
        feedback = f"Flat by {abs(cents_difference):.2f} cents from {closest_note}"
    
    return feedback, closest_note, cents_difference

if __name__ == '__main__':
    app.run(debug=True)
