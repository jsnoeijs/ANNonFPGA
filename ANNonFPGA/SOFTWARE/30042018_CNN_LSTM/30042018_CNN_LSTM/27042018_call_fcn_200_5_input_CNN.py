#translating EDF files from database (full dataset for patient = 1)
#This file reduces the input resolution 
# This combines CNN + LSTM algorithm for EEG sequence classification  
import pyedflib
import numpy as np
from matplotlib import pyplot as plt
from keras.models import Sequential
from keras.layers import Dense, Activation, LSTM
import os
#import pandas as pd
import re
import target_data_gen
from target_data_gen import get_sizes
from target_data_gen import target_gen
from keras.layers import Dense, Activation, LSTM, Dropout, Bidirectional, TimeDistributed, Conv2D, MaxPooling2D, Flatten

np.random.seed(0)
#defining parameters
output = 1
#X=np.array(sigbufs
batch_size = 100 #(length)
batch_mod = 10000
dataset_size = 16


X, Y = list(), list()




#**********************CALLLING DATA GENERATOR FUNCTION ***********************
X, input_size, length = get_sizes(X, dataset_size)
#******************************************************************************

#Defining sizes for input/target data
Y=np.zeros((dataset_size, batch_mod, output))
#yhat=np.zeros((dataset_size, batch_mod, output))


#***********************CALLING TARGET GENERATOR FUNCTION**********************
file = 'chb01-summary.txt'
Y = target_gen(output, batch_mod, dataset_size, batch_size, file)
#******************************************************************************




   
# #RESHAPING ACCORDING TO NEW DATASET SIZE AND DATA SET SELECTION
# #DEFINING NEW SHAPES

#inputs
input_size_new = 23
#elements of each frame
batch_size_new = 200
#time steps equivalent 
timesteps= 10 
#number of sequences
seq_number = 50
dataset_size = 5

file = 3

#Defining sizes for input/target data
X_new=np.zeros((seq_number*dataset_size, timesteps, input_size_new, batch_size_new, 1))
#yhat=np.zeros((dataset_size, batch_mod, output))
Y_new=np.zeros((seq_number*dataset_size, output))

initial_time = 700000

for i in range(0,seq_number):
 for j in range(0,timesteps):
  initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  X_new[i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0] #This will select file 3 in the period of 700000-800000
   
# Second_dataset (file 4)
file = 4
print('second datatets')
initial_time = 300000

for i in range(0,seq_number):
 for j in range(0,timesteps):
  initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  X_new[i+seq_number,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0] #This will select file 3 in the period of 700000-800000
  
#Third dataset
file = 5
print('third datatets')
initial_time = 0

for i in range(0,seq_number):
 for j in range(0,timesteps):
  initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  X_new[i+2*seq_number,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0] #This will select file 3 in the period of 700000-800000
  
#Fourth dataset
file = 6
print('third datatets')
initial_time = 0

for i in range(0,seq_number):
 for j in range(0,timesteps):
  initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  X_new[i+3*seq_number,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0] #This will select file 3 in the period of 700000-800000
  
#Fifth dataset
#Fourth dataset
file = 7
print('third datatets')
initial_time = 0

for i in range(0,seq_number):
 for j in range(0,timesteps):
  initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  X_new[i+4*seq_number,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0] #This will select file 3 in the period of 700000-800000
   
   
 
 
max_value = np.amax(abs(X_new))
min_value = np.amin(abs(X_new))
# print('MAX VALUE', max_value)
X_new = X_new/max_value

Y_new[33:39,output-1] = 1
Y_new[seq_number+37:seq_number+42,output-1] = 1


# plt.plot(X[2,0,0,0,:,0])
# plt.plot(X[2,0,0,1,:,0])
# plt.show()
# plt.plot(X[3,0,0,0,:,0])
# plt.plot(X[3,0,0,1,:,0])
# plt.show()
#Assigning targets (manually)
#Y[0,2,:] = 1
#Y[3,2,:] = 1


model = Sequential()
model.add(TimeDistributed(Conv2D(2,(2,2), activation = 'relu'), input_shape=(None,input_size_new,batch_size_new,1)))
model.add(TimeDistributed(MaxPooling2D(pool_size=(2,2))))
model.add(TimeDistributed(Conv2D(2,(2,2), activation = 'relu'))
model.add(TimeDistributed(MaxPooling2D(pool_size=(2,2))))
model.add(TimeDistributed(Flatten()))
model.add(LSTM(150))
model.add(Dense(output, activation='sigmoid'))
model.compile(loss='binary_crossentropy', optimizer='adam')

print(model.summary())

model.fit(X_new,Y_new, epochs=40)
#Trying model
yhat = model.predict(X_new, verbose=0)
file1 = open("CNN_LSTM_dataset_train.txt", 'ab')
np.savetxt(file1, yhat, delimiter="," )
file1.close()

#########################################################################################################
# #Generating data test
file = 15

# #Defining sizes for input/target data
X_test=np.zeros((seq_number, timesteps, input_size_new, batch_size_new, 1))
Y_test=np.zeros((seq_number, output))

initial_time = 400000

for i in range(0,seq_number):
 for j in range(0,timesteps):
  initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  X_test[i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0] #This will select file 3 in the period of 700000-800000
   

   
max_value = np.amax(abs(X_test))
min_value = np.amin(abs(X_test))
# print('MAX VALUE', max_value)
X_test = X_test/max_value


# plt.plot(X[14,0,0,0,:,0])
# plt.plot(X[14,0,0,1,:,0])
# plt.plot(X[14,0,0,2,:,0])
# plt.show()

Y_test[21:27,output-1] = 1
yhat_test = model.predict(X_test, verbose=0)
file2 = open("CNN_LSTM_dataset_test.txt", 'ab')
np.savetxt(file2, yhat_test, delimiter="," )
file2.close()
