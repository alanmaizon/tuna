from flask import Flask, render_template, request, jsonify, send_from_directory
from utils.tuner import generate_feedback
import crepe
import soundfile as sf
from pydub import AudioSegment
import numpy as np
import io
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/process_audio', methods=['POST'])
def process_audio():
    try:
        audio_file = request.files['audio_data']
        audio = AudioSegment.from_file(io.BytesIO(audio_file.read()))
        wav_audio = io.BytesIO()
        audio.export(wav_audio, format='wav')
        wav_audio.seek(0)

        audio_data, sr = sf.read(wav_audio)
        time, frequency, confidence, _ = crepe.predict(audio_data, sr, viterbi=True)
        predicted_freq = float(np.mean(frequency))

        return jsonify(generate_feedback(predicted_freq))
    except Exception as e:
        print("Error:", e)
        return jsonify({"error": str(e)}), 500

@app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory('static', filename)

if __name__ == "__main__":
    app.run(debug=True)
