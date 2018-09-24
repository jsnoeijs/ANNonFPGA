
OUTPUTS = 16;
NBSAMPLES = 20;
INPUTS =8;
NBITS=32;
NB_FRAC = 28;
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
for i=1:(NBSAMPLES*OUTPUTS+1+NBSAMPLES*2)
    if strlength(hw_sn{1}{i})==6
        if hw_sn{1}{i} == 'sample'
            if hw_sn{1}{i+1} == num2str(j)
                j=j+1;
                for k=(i+2):(i+OUTPUTS+1)
                    sn_hw((j-1)*OUTPUTS+k-i-1)=bin2num(q, hw_sn{1}{k});
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
figure;
sn_total = [sn_hwfinal,sn_thfinal, rel_err, abs_err];
plot(rel_err);
ylabel('relative error %');
xlabel('outputs x samples');
figure;
plot(abs_err);
ylabel('absolute error');
xlabel('outputs x samples');