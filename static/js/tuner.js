let mediaRecorder;
let audioChunks = [];

// Start recording from mic
function startRecording() {
    audioChunks = [];
    navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
        mediaRecorder = new MediaRecorder(stream);
        mediaRecorder.start();

        mediaRecorder.addEventListener("dataavailable", event => {
            audioChunks.push(event.data);
        });

        mediaRecorder.addEventListener("stop", () => {
            const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
            sendAudioToServer(audioBlob);
        });

        console.log("Recording started...");
    }).catch(err => {
        console.error("Microphone error:", err);
    });
}

// Stop recording
function stopRecording() {
    if (mediaRecorder && mediaRecorder.state === "recording") {
        mediaRecorder.stop();
        console.log("Recording stopped.");
    }
}

// Send the recorded audio to the Flask backend
function sendAudioToServer(audioBlob) {
    const formData = new FormData();
    formData.append('audio_data', audioBlob);

    fetch('/process_audio', {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (!response.ok) throw new Error("Server error");
        return response.json();
    })
    .then(data => {
        document.getElementById('feedback').innerText = `Feedback: ${data.feedback}`;
        document.getElementById('note').innerText = `Closest Note: ${data.note}`;
        document.getElementById('cents').innerText = `Cents Difference: ${data.cents_difference} cents`;
        document.getElementById('frequency').innerText = `Detected Frequency: ${data.predicted_frequency} Hz`;
    })
    .catch(error => {
        console.error("Processing error:", error);
        document.getElementById('feedback').innerText = "Feedback: Error processing audio.";
    });
}
