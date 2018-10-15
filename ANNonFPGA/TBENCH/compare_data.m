
fileDATA = fopen('data_in.txt', 'r');


q = quantizer('fixed', [NBITS,NB_FRAC]);
matlab_sn = textscan(fileDATA,'%s');
sn_th = zeros(NBSAMPLES*OUTPUTS,1);
for i=1:(NBSAMPLES*(OUTPUTS+INPUTS)+OUTPUTS*OUTPUTS*3+OUTPUTS*INPUTS*3+OUTPUTS*3+12)
    if strlength(matlab_sn{1}{i})==7 
        if matlab_sn{1}{i}=='outputs'
            for j=(i+1):(i+NBSAMPLES*OUTPUTS)
                sn_th(j-i) = bin2num(q, matlab_sn{1}{j});
            end;
        end;
    end;
end;
fclose(fileDATA);
string = 'sample';

fileHWOUT= fopen('data_out.txt', 'r');
hw_sn = textscan(fileDATA, '%s');
j=0;
sn_hw = zeros(NBSAMPLES*OUTPUTS, 1);
DEBUG_rdir_hw = zeros(NBSAMPLES*OUTPUTS, 1);
DEBUG_rrec_hw = zeros(NBSAMPLES*OUTPUTS, 1); 
DEBUG_rn_hw = zeros(NBSAMPLES*OUTPUTS, 1);
DEBUG_zdir_hw = zeros(NBSAMPLES*OUTPUTS, 1);
DEBUG_zrec_hw = zeros(NBSAMPLES*OUTPUTS, 1); 
DEBUG_zn_hw = zeros(NBSAMPLES*OUTPUTS, 1);
DEBUG_hdir_hw = zeros(NBSAMPLES*OUTPUTS, 1);
DEBUG_hrec_hw = zeros(NBSAMPLES*OUTPUTS, 1); 
DEBUG_hn_hw = zeros(NBSAMPLES*OUTPUTS, 1);


for i=1:(10*(NBSAMPLES*OUTPUTS)+1+NBSAMPLES*2)
    i;
    if strlength(hw_sn{1}{i})==6
        if hw_sn{1}{i} == 'sample'
            if hw_sn{1}{i+1} == num2str(j)
                j=j+1;
                for k=(i+2):(i+OUTPUTS+1)
                    sn_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+2});
                    DEBUG_rdir_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+3});
                    DEBUG_rrec_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+4});
                    DEBUG_rn_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+5});
                    DEBUG_zdir_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+6});
                    DEBUG_zrec_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+7});
                    DEBUG_zn_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+8});
                    DEBUG_hdir_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+9});
                    DEBUG_hrec_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+10});
                    DEBUG_hn_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{10*(k-i-2)+i+11});
                end;
            end;
        end;
    end;
            
end;
fclose(fileHWOUT);
sn_hwfinal = sn_hw(1:NBSAMPLES*OUTPUTS-OUTPUTS);
sn_thfinal = sn_th(1:NBSAMPLES*OUTPUTS-OUTPUTS);

abs_err = (sn_hwfinal - sn_thfinal);
sn_hwfinal-sn_thfinal
rel_err = abs_err./sn_thfinal*100.0;
mean_abs_err = mean(abs_err)
mean_rel_err = mean(rel_err)
max_abs_err = max(abs(abs_err))
max_rel_err = max(abs(rel_err))
std_dev_abs_err = std(abs_err)
std_dev_rel_err = std(rel_err)
figure;
sn_total = [sn_hwfinal, sn_thfinal, rel_err, abs_err];
plot(rel_err);
ylabel('relative error %');
xlabel('outputs x samples');
figure;
plot(abs_err);
ylabel('absolute error');
xlabel('outputs x samples');