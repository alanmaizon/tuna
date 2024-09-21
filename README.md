# TUNA (Tuning Utility for Notes and Audio)

TUNA is a real-time tuning application that allows users to record audio and receive feedback on their pitch accuracy in relation to standard musical notes. Using advanced audio processing techniques, TUNA provides users with information about the closest note, frequency difference, and tuning accuracy in cents.

## Features

- Record audio directly from your microphone.
- Analyze the recorded audio to determine the fundamental frequency.
- Provide feedback on pitch accuracy, including:
  - Closest musical note.
  - Difference from the closest note in cents.
  - Overall tuning feedback.

## Technologies Used

- **Flask**: Backend framework for handling audio processing requests.
- **CREPE**: A deep learning model for pitch detection.
- **Pydub**: For audio file format conversion.
- **Soundfile**: For reading audio files.
- **HTML/CSS/JavaScript**: For the frontend interface.

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/alanmaizon/tuna.git
   cd tuna
   ```

2. **Set up a virtual environment (optional but recommended):**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. **Install the required packages:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Install FFmpeg** (required by Pydub):
   - [FFmpeg Installation Guide](https://ffmpeg.org/download.html)

## Usage

1. **Run the Flask server:**
   ```bash
   python app.py
   ```

2. **Open your web browser and go to** `http://127.0.0.1:5000`.

3. **Use the interface** to start recording audio. After stopping the recording, you will receive feedback on your pitch accuracy.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please open an issue or submit a pull request.
