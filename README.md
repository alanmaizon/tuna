# TUNA (Tuning Utility for Now and Always)

TUNA is a real-time tuning application that helps users check their pitch accuracy against standard musical notes. It is available as a **legacy web app** (Flask/Python) and a **native iOS app** (SwiftUI).

## Repository Structure

```
tuna/
├── web/          # Legacy web application (Flask + CREPE)
│   ├── app.py
│   ├── requirements.txt
│   ├── utils/
│   ├── static/
│   └── templates/
├── ios/          # Native iOS application (SwiftUI)
│   ├── Tuna/
│   └── Tuna.xcodeproj/
└── README.md
```

---

## Web App (`web/`)

A Flask-based web application that records audio from the microphone and uses the CREPE deep-learning model for pitch detection.

### Features

- Record audio directly from your microphone.
- Analyze the recorded audio to determine the fundamental frequency.
- Provide feedback on pitch accuracy, including:
  - Closest musical note.
  - Difference from the closest note in cents.
  - Overall tuning feedback.
- Progressive Web App (PWA) support for offline use.

### Technologies

- **Flask** – Backend framework for handling audio processing requests.
- **CREPE** – A deep learning model for pitch detection.
- **Pydub** – Audio file format conversion.
- **Soundfile** – Reading audio files.
- **HTML/CSS/JavaScript** – Frontend interface.

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/alanmaizon/tuna.git
   cd tuna/web
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

5. **Run the Flask server:**
   ```bash
   python app.py
   ```

6. **Open your web browser and go to** `http://127.0.0.1:5000`.

---

## iOS App (`ios/`)

A native SwiftUI application that performs real-time pitch detection on-device using the FastYIN algorithm — no network connection required.

### Features

- Real-time audio pitch detection via the device microphone.
- Displays the detected note, frequency in Hz, and tuning accuracy in cents.
- Visual mercury-bar indicator showing how sharp or flat the pitch is.
- Runs entirely on-device with low latency.

### Technologies

- **SwiftUI** – Declarative UI framework.
- **AVFoundation** – Audio capture and session management.
- **Accelerate** – High-performance DSP via vDSP.
- **FastYIN** – Custom YIN pitch-detection implementation.

### Getting Started

1. Open `ios/Tuna.xcodeproj` in Xcode.
2. Select a target device or simulator.
3. Build and run (⌘R).

> **Note:** Microphone access is required. The app will prompt for permission on first launch.

---

## Contributing

Contributions are welcome! If you have suggestions or improvements, please open an issue or submit a pull request.

