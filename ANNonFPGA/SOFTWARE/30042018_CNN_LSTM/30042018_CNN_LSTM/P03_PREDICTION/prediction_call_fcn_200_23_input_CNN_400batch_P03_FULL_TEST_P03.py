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
batch_size_new = 400
# #time steps equivalent 
timesteps= 5
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


########################################################################################################
#Adding extra training -
 # file = 17

 # initial_time = 200000

 # for i in range(0,seq_number):
  # for j in range(0,timesteps):
   # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
   # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
   # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
   # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
   # X_new[seq_number*19+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0]    
  
# initial_time = 300000

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*20+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0]  


# initial_time = 100000

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*21+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0]    
  
# initial_time = 0

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*22+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0]    

# ####################################################################################################
# ####################################################################################################
# ##### EXTENDED DATASET INTER ICTAL
# #datset 16
# file = 16  
# initial_time = 700000

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*20+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0]    
  
# #datset 16
# file = 16  
# initial_time = 700000

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*24+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0]      

# ####################################################################################################  
# ##### EXTENDED DATASET PRE-ICTAL

# #datset 16
# file = 16  
# initial_time = 0

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*25+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0]    
  
# #datset 15
# file = 15 
# initial_time = 400000

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*26+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0]      

 
# #datset 3
# file = 3 
# initial_time = 600000

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*27+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0] 
  
  # #datset 4
# file = 4 
# initial_time = 200000

# for i in range(0,seq_number):
 # for j in range(0,timesteps):
  # initial = initial_time+(i*batch_size_new*timesteps)+j*batch_size_new
  # final = initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+j*batch_size_new)
  # #print(initial_time+(i*batch_size_new*timesteps)+((j+1)*batch_size_new))
  # X_new[seq_number*28+i,j,:,0:batch_size_new,0] =  X[file-1,0,0,0:input_size_new,initial:final,0] 

#####################################################################################################
####################################################################################################
##### END OF DATASET EXTENSION   
 
max_value = np.amax(abs(X_new))
min_value = np.amin(abs(X_new))
# print('MAX VALUE', max_value)
X_new = X_new/max_value


   
#####################################################################################################
file = 'chb03-summary.txt'
Y_new = target_gen(output, batch_mod, dataset_size, batch_size_new, seq_number, timesteps, file)

#############################################$
##### Additional 

#Y_new[seq_number*19:seq_number*19+seq_number,2] = 1
#Y_new[seq_number*20:seq_number*20+seq_number,2] = 1
# Y_new[seq_number*21:seq_number*21+seq_number,2] = 1
# Y_new[seq_number*22:seq_number*22+seq_number,2] = 1


###################################################################################################
##### EXTENDED DATASET

#Y_new[seq_number*20:seq_number*23+seq_number,0] = 1
# Y_new[seq_number*24:seq_number*24+seq_number,0] = 1


# Y_new[seq_number*25:seq_number*25+seq_number,0] = 1
# Y_new[seq_number*26:seq_number*26+seq_number,0] = 1
# Y_new[seq_number*27:seq_number*27+seq_number,0] = 1
# Y_new[seq_number*28:seq_number*28+seq_number,0] = 1





#####################################################################################################


model = Sequential()
model.add(TimeDistributed(Conv2D(2,(2,2), activation = 'relu'), input_shape=(None,input_size_new,batch_size_new,1)))
model.add(TimeDistributed(MaxPooling2D(pool_size=(2,2))))
model.add(TimeDistributed(Conv2D(2,(2,2), activation = 'relu')))
model.add(TimeDistributed(MaxPooling2D(pool_size=(2,2))))
model.add(TimeDistributed(Flatten()))
model.add(LSTM(75))
model.add(Dense(output, activation='softmax'))
#adam = adam(lr=0.0005)
model.compile(loss='categorical_crossentropy', optimizer='adam')

print(model.summary())

model.fit(X_new,Y_new, epochs=33)
#Trying model
yhat = model.predict(X_new, verbose=0)
file1 = open("CNN_LSTM_dataset_train_100seq_NO_FILTER_gru.txt", 'ab')
np.savetxt(file1, yhat, delimiter="," )
file1.close()
model.layers[1].output

#################################################################################
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
   

   
   
max_value_2 = np.amax(abs(X_test))
min_value = np.amin(abs(X_test))
# print('MAX VALUE', max_value)
X_test = X_test/max_value_2


yhat_test = model.predict(X_test, verbose=0)
file2 = open("CNN_LSTM_dataset_test_dataset_onset_400batch_100_seq_P03_FILTER.txt", 'ab')
np.savetxt(file2, yhat_test, delimiter="," )
file2.close()



#################################################################################
# Arranging yhat
a,b = np.shape(yhat_test)

with open("final_data_test_400batch_100seq_P03_FILTER.txt", 'w') as file_1:
 for i in range(0,a):
    #file_1.write(' '+str(i)+' ')
    yhat_test[i,:] = np.round(yhat_test[i,:])
    if (yhat_test[i,:]== ([0, 1, 0])).all():
       file_1.write('Sequence'+str(i)+' status: ictal'+'\n')
    elif (yhat_test[i,:]== ([1, 0, 0])).all():
       file_1.write('Sequence'+str(i)+' status: pre-ictal'+'\n')
    elif (yhat_test[i,:]== ([0, 0, 1])).all():
       file_1.write('Sequence'+str(i)+' status: inter-ictal'+'\n')
    else:
       file_1.write('Sequence'+str(i)+' status: undetermined'+'\n')
        
    #np.savetxt(file_1, yhat[i,:],delimiter=' ' )
file_1.close()

# ########################################################################################################
# getting statistics

output_count(seq_number, test_files, yhat_test, '_50seq_NO_FILTER_25epochs_EXTENDED_DATASET_50LSTM_P03')

#file1.write('Initial time '+str(initial_time)+'\n')


# ########################################################################################################

