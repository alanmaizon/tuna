// static/js/script.js
let audioContext;
let mediaRecorder;
let audioChunks = [];
let recordingDuration = 1000; // 1 second

function startRecording() {
    audioChunks = [];
    navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
        audioContext = new AudioContext();
        mediaRecorder = new MediaRecorder(stream);
        mediaRecorder.start();

        mediaRecorder.addEventListener("dataavailable", event => {
            audioChunks.push(event.data);
        });

        mediaRecorder.addEventListener("stop", () => {
            const audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
            sendAudioToServer(audioBlob);
        });

        // Automatically stop recording after 1 second
        setTimeout(() => {
            stopRecording();
        }, recordingDuration);
    });
}

function stopRecording() {
    if (mediaRecorder && mediaRecorder.state === "recording") {
        mediaRecorder.stop();
    }
}

function sendAudioToServer(audioBlob) {
    const formData = new FormData();
    formData.append('audio_data', audioBlob);

    fetch('/process_audio', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        updateDisplay(data);
    })
    .catch(error => console.error('Error:', error));
}

function updateDisplay(data) {
    const feedbackElement = document.getElementById('feedback');
    const closestNoteElement = document.getElementById('closest-note');
    const centsDifferenceElement = document.getElementById('cents-difference');
    const noteDisplay = document.querySelector('.note-display');

    // Update feedback and closest note
    feedbackElement.innerText = `Feedback: ${data.feedback}`;
    closestNoteElement.innerText = `Closest Note: ${data.closest_note}`;
    centsDifferenceElement.innerText = `Cents Difference: ${data.cents_difference.toFixed(2)} cents`;

    // Update color for note display based on tuning
    noteDisplay.innerText = data.closest_note;
    if (Math.abs(data.cents_difference) < 10) {
        noteDisplay.classList.add('in-tune');
        noteDisplay.classList.remove('out-of-tune');
    } else {
        noteDisplay.classList.add('out-of-tune');
        noteDisplay.classList.remove('in-tune');
    }

    // Update cent indicator colors based on sharp/flat
    const indicators = document.querySelectorAll('.cent-indicator');
    indicators.forEach((indicator, index) => {
        const relativeCents = (index - 5) * 20; // Each indicator represents 20 cents
        if (data.cents_difference > relativeCents) {
            indicator.classList.add('sharp');
            indicator.classList.remove('flat');
        } else if (data.cents_difference < relativeCents) {
            indicator.classList.add('flat');
            indicator.classList.remove('sharp');
        } else {
            indicator.classList.remove('flat', 'sharp');
        }
    });
}
