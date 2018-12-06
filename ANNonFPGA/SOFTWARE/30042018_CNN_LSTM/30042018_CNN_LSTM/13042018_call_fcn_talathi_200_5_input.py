#translating EDF files from database (full dataset for patient = 1)
#This file reduces the input resolution 
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


#defining parameters
output = 1
#X=np.array(sigbufs
batch_size = 100 #(length)
batch_mod = 10000
dataset_size = 7


X, Y = list(), list()




#**********************CALLLING DATA GENERATOR FUNCTION ***********************
X, length, input_size = get_sizes(X, dataset_size)
#******************************************************************************

#Defining sizes for input/target data
Y=np.zeros((dataset_size, batch_mod, output))
#yhat=np.zeros((dataset_size, batch_mod, output))


#***********************CALLING TARGET GENERATOR FUNCTION**********************
file = 'chb01-summary.txt'
Y = target_gen(output, batch_mod, dataset_size, batch_size, file)
#******************************************************************************
print(Y)



   
#RESHAPING ACCORDING TO NEW DATASET SIZE AND DATA SET SELECTION
#DEFINING NEW SHAPES

#inputs
input_size_new = 5
#elements of each frame
batch_size_new = 200
#time steps equivalent 
timesteps= 10 
#number of sequences
seq_number = 50

file = 3

#Defining sizes for input/target data
X_new=np.zeros((seq_number, timesteps, input_size_new, batch_size_new, 1))
#yhat=np.zeros((dataset_size, batch_mod, output))
Y_new=np.zeros((seq_number, output))

initial_time = 700000

for i in range(0,seq_number):
 for j in range(0,timesteps):
  X_new[i,j,:,0:batch_size_new,0] =  X[file-1,initial_time+(i*batch_size_new*timesteps):initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new),0:input_size] #This will select file 3 in the period of 700000-800000
   
   
# max_value = np.amax(abs(X_new))
# print('MAX VALUE', max_value)
# X_new = X_new/max_value

# Y_new[0,135:186,output-1] = 1

#plt.plot(X_new[0,:,:])
#plt.show()
#Assigning targets (manually)
#Y[0,2,:] = 1
#Y[3,2,:] = 1


#pre-processing data
#normalizing

# model = Sequential()
# model.add(LSTM(100,input_shape=(batch_size_new,input_size)))
# model.add(Dense(100))
# #model.add(LSTM(100))
# model.add(Dense(output, activation='sigmoid'))
# model.compile(loss='binary_crossentropy', optimizer='adam')
# print(model.summary())

# #plt.plot(X[0,600000:800000,0])
# #plt.show()

# for i in range (0,batch_mod_new-1):
    # print('FIRST EPOCH',i)
    # print('batch is', batch_size_new*i)
    # print(Y_new[:,i,:])
    # model.fit(X_new[:,batch_size_new*i:batch_size_new*(i+1),:],Y_new[:,i,:], epochs=100)



# with open("17042018_Talathi_100batches_40000_length_5_inputs.txt", 'ab') as file1:
  # for i in range (0,batch_mod_new):
    # yhat = model.predict(X_new[:,batch_size_new*i:batch_size_new*(i+1),:], verbose=0)
    # print(yhat)
    # np.savetxt(file1, yhat, delimiter="," )
# file1.close()
    
# print('Finish')
