#Generating target file for the COMPLETE DATA SET (=7)

#This file generates automatically input files and sizes
#translating EDF files from database (full dataset for patient = 1)
import pyedflib
import numpy as np
from matplotlib import pyplot as plt
import os
#import pandas as pd
import re 

#defining parameters
output = 1
#X=np.array(sigbufs)
dataset_size = 40
initial_file = 0



def target_gen(output, dataset_size, file):
    #target = np.zeros((dataset_size, batch_num, output))
    filepath = file
    dataset = 0
    with open(filepath) as fp:
      with open("onset_info.txt", 'w') as file1:
        for cnt, line in enumerate(fp): 
            if line.startswith('File Name:'):
                file_num = re.findall(r'\d+',line)
                dataset = int(file_num[1]) + initial_file 
            if dataset == dataset_size + initial_file +1:   #Finish when data set size is achieved
                break                                   
            if line.startswith('Number of Seizures in File: 1'):
                start_time = re.findall(r'\d+',fp.readline())
                end_time = re.findall(r'\d+',fp.readline())
                #batch_pos = int(abs((int(start_time[0]))*256/batch_size))
                file1.write('dataset '+str(dataset)+' ')
                file1.write('Start time '+str(start_time)+' ')
                file1.write('End time '+str(end_time)+'\n')
                initial_time = round(((int(start_time[0])*256)/100000)-0.5)*100000
                file1.write('Initial time '+str(initial_time)+'\n')
                print('INITIAL_TIME', start_time)
                print('END_TIME', end_time)
                #np.savetxt(file1, [start_time, end_time], delimiter="," )
                #np.savetxt(file1, end_time, delimiter="," )
      file1.close()



    return print('File generated')
    
file = 'chb02-summary.txt'
target_gen(output, dataset_size, file )
