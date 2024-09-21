import tensorflow as tf
from fastai.vision.all import *
from fastaudio.all import *
import numpy as np
from torchvision import models

# Feature description for TFRecord parsing
feature_description = {
    'audio': tf.io.FixedLenFeature([], tf.string),
    'pitch': tf.io.FixedLenFeature([], tf.int64)
}

# Function to parse TFRecord files
def _parse_function(proto):
    # Parse the input tf.Example proto
    parsed_features = tf.io.parse_single_example(proto, feature_description)

    # Decode the 'audio' field (raw bytes)
    audio = tf.io.decode_raw(parsed_features['audio'], tf.float32)
    
    # Reshape the audio (we assume a fixed length for now, adjust if needed)
    audio = tf.reshape(audio, [-1])  # 1D raw audio signal
    
    # Return audio and pitch as a tuple
    return audio, parsed_features['pitch']

# Function to create a dataset from TFRecords using the _parse_function
def load_tfrecord_dataset(tfrecord_path, batch_size=32):
    # Create dataset from TFRecord files
    dataset = tf.data.TFRecordDataset(tfrecord_path)
    
    # Map dataset to parse each example
    dataset = dataset.map(_parse_function)
    
    # Batch and prefetch the dataset
    dataset = dataset.batch(batch_size).prefetch(tf.data.experimental.AUTOTUNE)
    
    return dataset

# Load datasets
train_dataset = load_tfrecord_dataset('nsynth-train.tfrecord', batch_size=32)
valid_dataset = load_tfrecord_dataset('nsynth-valid.tfrecord', batch_size=32)
test_dataset = load_tfrecord_dataset('nsynth-test.tfrecord', batch_size=32)

# Wrapper to convert the TensorFlow dataset to NumPy so that FastAI can handle it
def dataset_to_numpy(dataset):
    np_data = []
    for data, label in dataset:
        np_data.append((data.numpy(), label.numpy()))
    return np_data

# Convert TensorFlow datasets to NumPy arrays
train_data = dataset_to_numpy(train_dataset)
valid_data = dataset_to_numpy(valid_dataset)
test_data = dataset_to_numpy(test_dataset)

# Define a DataBlock for handling audio data in FastAI
dblock = DataBlock(blocks=(AudioBlock, CategoryBlock),
                   get_items=lambda x: x,  # Use a lambda to pass raw data
                   get_y=lambda x: x[1],  # Labels (pitch)
                   splitter=IndexSplitter(np.arange(len(train_data), len(train_data) + len(valid_data))),
                   item_tfms=ResizeSignal(1000),  # Resize audio to 1000 samples
                   batch_tfms=AudioMelSpectrogram())

# Create a DataLoader for train/validation
dls = dblock.dataloaders(train_data + valid_data, bs=32)

# Manually load test DataLoader
test_dl = dls.test_dl(test_data)

# Show a batch of spectrograms
dls.show_batch()

# Create a simple CNN model (ResNet18)
learn = cnn_learner(dls, resnet18, metrics=error_rate)

# Train the model for 1 epoch
learn.fine_tune(1)

# Evaluate the model on the test set
test_results = learn.validate(dl=test_dl)
print(f"Test set evaluation: {test_results}")

# Show test set results (if you want to visualize predictions)
learn.show_results(dl=test_dl)


# After training your model
learn.fine_tune(1)

# Save the trained model using FastAI's export method
learn.export('optimized_pitch_model.pkl')  # Save the entire learner object

# Load the model for inference at a later time
learn = load_learner('optimized_pitch_model.pkl')

# Evaluate the model on the test set
test_results = learn.validate(dl=test_dl)
print(f"Test set evaluation: {test_results}")
