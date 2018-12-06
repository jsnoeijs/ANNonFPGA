#Measuring errors
import numpy as np

def output_count(seq_number, dataset_size, yhat, string):
    yhat[:,:] = np.round(yhat[:,:])
    with open('OUTPUT_COUNT_P03_'+string+'.txt', 'w') as file_out:
        file_out.write(string + '\n')
        file_out.write('data_set inter-ictal pre-ictal ictal \n')
        false_ictal = 0
        false_pre_ictal = 0
        dataset_count_ictal = 0
        dataset_count_pre_ictal = 0
        for i in range(0, dataset_size ):
            #varibles
            inter_ictal = 0
            pre_ictal = 0
            ictal = 0

            for j in range(0, seq_number):
               if (yhat[i*seq_number + j,:]== ([0, 1, 0])).all():
                   ictal+=1
                   if(i!=15 and i!=16 and i!=17):
                      false_ictal += 1
               elif (yhat[i*seq_number + j,:]== ([1, 0, 0])).all():
                   pre_ictal+=1
                   if(i!=15 and i!=16 and i!=17):
                     false_pre_ictal += 1
               elif (yhat[i*seq_number + j,:]== ([0, 0, 1])).all():
                   inter_ictal+=1

              
            if (ictal > 0 and i!=15 and i!=16 and i!=17):
                dataset_count_ictal+=1
            if (pre_ictal > 0 and i!=15 and i!=16 and i!=17):
                dataset_count_pre_ictal+=1

               
            file_out.write('     '+str(i)+'      '+str(inter_ictal)+'      '+str(pre_ictal)+'       '+str(ictal)+'\n')
            
        file_out.write('TOTAL FALSE ICTAL    '+str(false_ictal)+'\n')
        file_out.write('TOTAL FALSE PRE ICTAL '+str(false_pre_ictal)+'\n')
        file_out.write('TOTAL DATASET WITH FALSE ICTAL    '+str(dataset_count_ictal)+'\n')
        file_out.write('TOTAL DATASET WITH FALSE PRE ICTAL '+str(dataset_count_pre_ictal)+'\n')
        
            
#return print('Done Stats .. ')
                       

            
            
        
