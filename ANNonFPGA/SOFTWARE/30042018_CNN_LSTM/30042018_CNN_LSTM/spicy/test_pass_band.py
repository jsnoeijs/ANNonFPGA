#Testing the spicy functions
import pyedflib
import numpy as np
from matplotlib import pyplot as plt
from keras.models import Sequential
from keras.layers import Dense, Activation, LSTM
import os
import scipy
#import pandas as pd
import re
#import test_data_gen
import target_data_gen_100seq
#from test_data_gen import get_sizes
from target_data_gen_100seq import get_sizes_train
from target_data_gen_100seq import target_gen
from target_data_gen_100seq import get_sizes_test
from scipy.signal import butter, lfilter

#############################################################################
#TRAINING SET

np.random.seed(0)
#defining parameters
output = 3
#X=np.array(sigbufs
batch_size = 100 #(length)
batch_mod = 10000
dataset_size = 18
initial_file = 1

X, Y = list(), list()




#**********************CALLLING DATA GENERATOR FUNCTION ***********************
X, input_size, length = get_sizes_train(X, dataset_size, initial_file)
#******************************************************************************


   
# #RESHAPING ACCORDING TO NEW DATASET SIZE AND DATA SET SELECTION
# #DEFINING NEW SHAPES

# #inputs
input_size_new = 23
# #elements of each frame
batch_size_new = 400
# #time steps equivalent 
timesteps= 5
# #number of sequences
seq_number = 100
# #Re-defining dataset size for training
dataset_size = 18


#Defining sizes for input/target data
X_new=np.zeros((seq_number*dataset_size, timesteps, input_size_new, batch_size_new, 1))
#yhat=np.zeros((dataset_size, batch_mod, output))
Y_new=np.zeros((seq_number*dataset_size, output))

def butter_bandpass(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a

def butter_bandpass_filter(data, lowcut, highcut, fs, order=6):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = lfilter(b, a, data)
    return y

fs = 256
lowcut = 3
highcut = 29
y = butter_bandpass_filter(X[0,0,0,0,:,0], lowcut, highcut, fs, order=6)
plt.plot(X[0,0,0,0,0:100,0])
plt.plot(y[0:100])
plt.show()
    


