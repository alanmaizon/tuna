import soundfile as sf
import crepe
import numpy as np

audio_file = 'test.wav'  # Use a known good .wav file
audio_data, samplerate = sf.read(audio_file)
time, frequency, confidence, activation = crepe.predict(audio_data, samplerate, viterbi=True)
predicted_frequency = np.mean(frequency)
print(f"Predicted frequency: {predicted_frequency}")
