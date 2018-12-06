#translating EDF files from database (full dataset for patient = 1)
#This file reduces the input resolution 
# This combines CNN + LSTM algorithm for EEG sequence classification  
import pyedflib
import numpy as np
from matplotlib import pyplot as plt
from keras.models import Sequential
from keras.layers import Dense, Activation, LSTM
from keras.optimizers import adam
import os
import stats_
#import pandas as pd
import re
#############################################################################
#import test_data_gen
import target_data_gen_100seq_P03
#from test_data_gen import get_sizes
from target_data_gen_100seq_P03 import get_sizes_train
from target_data_gen_100seq_P03 import target_gen
from target_data_gen_100seq_P03 import get_sizes_test
#############################################################################

from keras.layers import Dense, Activation, LSTM, Dropout, Bidirectional, TimeDistributed, Conv2D, MaxPooling2D, Flatten, GRU
from stats_ import output_count
from keras import backend as K

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
batch_size_new = 200
# #time steps equivalent 
timesteps= 10
# #number of sequences
seq_number = 50
# #Re-defining dataset size for training
dataset_size = 18
extra_data_set = 0
dataset_size = dataset_size + extra_data_set


#Defining sizes for input/target data
X_new=np.zeros((seq_number*dataset_size, timesteps, input_size_new, batch_size_new, 1))
#yhat=np.zeros((dataset_size, batch_mod, output))
Y_new=np.zeros((seq_number*dataset_size, output))



for m in range(0,dataset_size-extra_data_set):
 if (m == 1-1 or  m == 2-1 or m == 3-1 or m == 4-1):
  if m == 1-1:
   initial_time = 0
  if m == 2-1:
   initial_time = 100000
  if m == 3-1:
   initial_time = 100000
  if m == 4-1:
   initial_time = 500000
 else:
  initial_time = 0
 print('initial time:', initial_time)
 for i in range(0,seq_number):
  for j in range(0,timesteps):
   initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
   final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
   #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
   #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
   X_new[seq_number*m+i,j,:,0:batch_size_new,0] =  X[m,0,0,0:input_size_new,initial:final,0] 



#####################################################################################################
#####################################################################################################
##### END OF DATASET EXTENSION   
 
max_value = np.amax(abs(X_new))
min_value = np.amin(abs(X_new))
# print('MAX VALUE', max_value)
X_new = X_new/max_value


   
#####################################################################################################
file = 'chb03-summary.txt'
Y_new = target_gen(output, batch_mod, dataset_size, batch_size_new, seq_number, timesteps, file)

#####################################################################################################

#This is only for debug --
# [1] comments :
# convolutions are equivalent to filters in frequency domain
# Deep convolutions are equivalent to linear combinations
# CNN learns what informative & discriminative spectra are regarding the problem 
# Pooling is equivalent to down-sampling operation 
# ReLU is equivalent to a half-wave rectifier 
# It may be bad to include pooling for signal processing (different from image processing)
# [1] anonymous authors -  How do deep constitutional neural networks learn from raw audio waveforms



model = Sequential()
model.add(TimeDistributed(Conv2D(1,(2,2), strides = 2, activation = 'relu'), input_shape=(None,input_size_new,batch_size_new,1)))
model.add(TimeDistributed(MaxPooling2D(pool_size=(2,2))))
model.add(TimeDistributed(Conv2D(1,(2,2), strides = 2, activation = 'relu')))
model.add(TimeDistributed(MaxPooling2D(pool_size=(2,2))))
model.add(TimeDistributed(Flatten()))
model.add(LSTM(25))
model.add(Dense(output, activation='softmax'))
model.compile(loss='categorical_crossentropy', optimizer='adam')

print(model.summary())

model.fit(X_new,Y_new, epochs=20)

# get_layer_output = K.function([model.layers[0].input],
                              # [model.layers[0].output])

# layer_output_1 = get_layer_output([X_new])[0]


# a,b,c,d,e = np.shape(layer_output_1)
# file_0 = open("layer_0.txt", 'w') 
# debug_batch = np.zeros((c,d*b*5))
# for i in range(0,5):
  # for j in range(0,b):
    # initial = 397*i*5 + 397*(j) 
    # ending = 397*i*5 + 397*(j+1)
    # #print("VALUES INITIAL", initial)
    # #print("VALUES IÊND", ending)
    # if (i == 0 and j == 0):
      # debug_batch[:,initial: ending ] = layer_output_1[45+i,j,:,:,0]
      # #print("initial")
    # else : 
      # #print("next")
      # debug_batch[:,initial: ending ] = layer_output_1[45+i,j,:,:,0]
# np.savetxt(file_0, debug_batch, delimiter=" ")
# file_0.close()

# ######################################################################################################
# #Debug of MAXPOOLING 


# get_layer_output_1 = K.function([model.layers[0].input],
                              # [model.layers[1].output])

# layer_output_2 = get_layer_output_1([X_new])[0]


# a,b,c,d,e = np.shape(layer_output_2)
# file_1 = open("layer_1.txt", 'w') 
# debug_batch_1 = np.zeros((c,d*b*5))
# for i in range(0,5):
  # for j in range(0,b):
    # initial = 198*i*5 + 198*(j) 
    # ending = 198*i*5 + 198*(j+1)
    # #print("VALUES INITIAL", initial)
    # #print("VALUES IÊND", ending)
    # if (i == 0 and j == 0):
      # debug_batch_1[:,initial: ending ] = layer_output_2[45+i,j,:,:,0]
      # #print("initial")
    # else : 
      # #print("next")
      # debug_batch_1[:,initial: ending ] = layer_output_2[45+i,j,:,:,0]
# np.savetxt(file_1, debug_batch_1, delimiter=" ")
# file_1.close()


# #########################################################################
# ##Debug of second filter


# get_layer_output_2 = K.function([model.layers[0].input],
                              # [model.layers[2].output])

# layer_output_3 = get_layer_output_2([X_new])[0]


# a,b,c,d,e = np.shape(layer_output_3)
# file_2 = open("layer_2.txt", 'w') 
# debug_batch_2 = np.zeros((c,d*b*5))
# for i in range(0,5):
  # for j in range(0,b):
    # initial = 194*i*5 + 194*(j) 
    # ending = 194*i*5 + 194*(j+1)
    # #print("VALUES INITIAL", initial)
    # #print("VALUES IÊND", ending)
    # if (i == 0 and j == 0):
      # debug_batch_2[:,initial: ending ] = layer_output_3[45+i,j,:,:,0]
      # #print("initial")
    # else : 
      # #print("next")
      # debug_batch_2[:,initial: ending ] = layer_output_3[45+i,j,:,:,0]
# np.savetxt(file_2, debug_batch_2, delimiter=" ")
# file_2.close()


# #########################################################################
# ##Debug of second maxpooling


# get_layer_output_3 = K.function([model.layers[0].input],
                              # [model.layers[3].output])

# layer_output_4 = get_layer_output_3([X_new])[0]


# a,b,c,d,e = np.shape(layer_output_4)
# file_3 = open("layer_3.txt", 'w') 
# debug_batch_3 = np.zeros((c,d*b*5))
# for i in range(0,5):
  # for j in range(0,b):
    # initial = 97*i*5 + 97*(j) 
    # ending = 97*i*5 + 97*(j+1)
    # #print("VALUES INITIAL", initial)
    # #print("VALUES IÊND", ending)
    # if (i == 0 and j == 0):
      # debug_batch_3[:,initial: ending ] = layer_output_4[45+i,j,:,:,0]
      # #print("initial")
    # else : 
      # #print("next")
      # debug_batch_3[:,initial: ending ] = layer_output_4[45+i,j,:,:,0]
# np.savetxt(file_3, debug_batch_3, delimiter=" ")
# file_3.close()

##############################################################################

#Trying model
yhat = model.predict(X_new, verbose=0)
file1 = open("CNN_LSTM_dataset_train_100seq_NO_FILTER_gru.txt", 'ab')
np.savetxt(file1, yhat, delimiter="," )
file1.close()


######################################################################################################
# Arranging yhat - train
a,b = np.shape(yhat)

with open("final_data_train_50seq_NO_FILTER_EXTENDED_DATASET_gru.txt", 'w') as file_1:
 for i in range(0,a):
    #file_1.write(' '+str(i)+' ')
    yhat[i,:] = np.round(yhat[i,:])
    if (yhat[i,:]== ([0, 1, 0])).all():
       file_1.write('Sequence'+str(i)+' status: ictal'+'\n')
    elif (yhat[i,:]== ([1, 0, 0])).all():
       file_1.write('Sequence'+str(i)+' status: pre-ictal'+'\n')
    elif (yhat[i,:]== ([0, 0, 1])).all():
       file_1.write('Sequence'+str(i)+' status: inter-ictal'+'\n')
    else:
       file_1.write('Sequence'+str(i)+' status: undetermined'+'\n')
        
    #np.savetxt(file_1, yhat[i,:],delimiter=' ' )
file_1.close()

#########################################################################################################
#########################################################################################################

# #Generating data test 1
test_files = 20

initial_file = 19
#Loading data test
X, input_size, length = get_sizes_test(X, test_files, initial_file)

# #Defining sizes for input/target data
X_test=np.zeros((seq_number*test_files, timesteps, input_size_new, batch_size_new, 1))


for m in range(0,test_files):
 if (m == 15 or  m == 16 or m == 17):
  if m == 15:
   initial_time = 500000
  if m == 16:
   initial_time = 600000
  if m == 17:
   initial_time = 400000
 else:
  initial_time = 0
 print('initial time:', initial_time)
#initial_time = 400000
 for i in range(0,seq_number):
  for j in range(0,timesteps):
   initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
   final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
   #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
   #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
   X_test[seq_number*m+i,j,:,0:batch_size_new,0] =  X[m,0,0,0:input_size_new,initial:final,0] 
   #if  (m == 0 and i == 0):
   

#plt.plot(X_test¨[])   
   
max_value_2 = np.amax(abs(X_test))
min_value = np.amin(abs(X_test))
# print('MAX VALUE', max_value)
X_test = X_test/max_value_2


yhat_test = model.predict(X_test, verbose=0)
file2 = open("CNN_LSTM_dataset_test_dataset_onset_400batch_100_seq_P03_FILTER.txt", 'ab')
np.savetxt(file2, yhat_test, delimiter="," )
file2.close()

# #########################################################################
# ##Debug of second filter for testing


# get_layer_output_2 = K.function(X_test,
                              # [model.layers[2].output])

# layer_output_3 = get_layer_output_2([X_new])[0]


# a,b,c,d,e = np.shape(layer_output_3)
# file_2 = open("layer_2_testing.txt", 'w') 
# debug_batch_2 = np.zeros((c,d*b*5))
# for i in range(0,5):
  # for j in range(0,b):
    # initial = 198*i*5 + 198*(j) 
    # ending = 198*i*5 + 198*(j+1)
    # #print("VALUES INITIAL", initial)
    # #print("VALUES IÊND", ending)
    # if (i == 0 and j == 0):
      # debug_batch_2[:,initial: ending ] = layer_output_3[755+i,j,:,:,0]
      # #print("initial")
    # else : 
      # #print("next")
      # debug_batch_2[:,initial: ending ] = layer_output_3[755+i,j,:,:,0]
# np.savetxt(file_2, debug_batch_2, delimiter=" ")
# file_2.close()


# #################################################################################

# ##Debug of second maxpooling


# get_layer_output_3 = K.function(X_test,
                              # [model.layers[3].output])

# layer_output_4 = get_layer_output_3([X_new])[0]


# a,b,c,d,e = np.shape(layer_output_4)
# file_3 = open("layer_3_testing.txt", 'w') 
# debug_batch_3 = np.zeros((c,d*b*5))
# for i in range(0,5):
  # for j in range(0,b):
    # initial = 99*i*5 + 99*(j) 
    # ending = 99*i*5 + 99*(j+1)
    # #print("VALUES INITIAL", initial)
    # #print("VALUES IÊND", ending)
    # if (i == 0 and j == 0):
      # debug_batch_3[:,initial: ending ] = layer_output_4[755+i,j,:,:,0]
      # #print("initial")
    # else : 
      # #print("next")
      # debug_batch_3[:,initial: ending ] = layer_output_4[755+i,j,:,:,0]
# np.savetxt(file_3, debug_batch_3, delimiter=" ")
# file_3.close()


# #################################################################################
# # Arranging yhat
# a,b = np.shape(yhat_test)

# with open("final_data_test_400batch_100seq_P03_FILTER.txt", 'w') as file_1:
 # for i in range(0,a):
    # #file_1.write(' '+str(i)+' ')
    # yhat_test[i,:] = np.round(yhat_test[i,:])
    # if (yhat_test[i,:]== ([0, 1, 0])).all():
       # file_1.write('Sequence'+str(i)+' status: ictal'+'\n')
    # elif (yhat_test[i,:]== ([1, 0, 0])).all():
       # file_1.write('Sequence'+str(i)+' status: pre-ictal'+'\n')
    # elif (yhat_test[i,:]== ([0, 0, 1])).all():
       # file_1.write('Sequence'+str(i)+' status: inter-ictal'+'\n')
    # else:
       # file_1.write('Sequence'+str(i)+' status: undetermined'+'\n')
        
    # #np.savetxt(file_1, yhat[i,:],delimiter=' ' )
# file_1.close()

# ########################################################################################################
# getting statistics

output_count(seq_number, test_files, yhat_test, '_50seq_NO_FILTER_25epochs_EXTENDED_DATASET_50LSTM_P03')

#file1.write('Initial time '+str(initial_time)+'\n')


# ########################################################################################################

