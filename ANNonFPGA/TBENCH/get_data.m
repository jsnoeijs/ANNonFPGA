mu = 0;
sigma = 1;
INPUTS = 2;
OUTPUTS = 4;
NB_SAMPLES = 50;
NBITS=32;
NB_FRAC = 28;
NB_INT=3;
ur = normrnd(mu, sigma, INPUTS, OUTPUTS);
uz = normrnd(mu, sigma, INPUTS, OUTPUTS);
uh = normrnd(mu, sigma, INPUTS, OUTPUTS);
wr = normrnd(mu, sigma, OUTPUTS, OUTPUTS);
wz = normrnd(mu, sigma, OUTPUTS, OUTPUTS);
wh = normrnd(mu, sigma, OUTPUTS, OUTPUTS);
br = normrnd(mu, sigma, 1, OUTPUTS);
bz = normrnd(mu, sigma, 1, OUTPUTS);
bh = normrnd(mu, sigma, 1, OUTPUTS);
x = rand(NB_SAMPLES, INPUTS);
s = zeros(NB_SAMPLES+1, OUTPUTS);
r = zeros(NB_SAMPLES, OUTPUTS);
z = zeros(NB_SAMPLES, OUTPUTS);
h = zeros(NB_SAMPLES, OUTPUTS);

for n = 1:numel(x(:,1))
    n;
    r(n,:) = 1./(1+exp(-(x(n,:)*ur + s(n,:)*wr+ br)));
    z(n,:) = 1./(1+exp(-(x(n,:)*uz + s(n,:)*wz+ bz)));
    h(n,:) = 1-2./(1+exp(2.*(x(n,:)*uh + (r(n,:).*s(n,:))*wh+bh)));
    s(n+1,:) = (1-z(n,:)).*(s(n,:))+z(n,:).*h(n,:);
end;

r(1)
z(1)
h(1)
s(1)
s(2)
fileID = fopen('data_in.txt', 'w');
%change value here to NBITS
colfmt = '%.32s ';
fprintf(fileID, 'inputs \n');
for i=1:NB_SAMPLES
    for j=1:INPUTS
        fprintf(fileID, colfmt, bin(fi(x(i,j),1,NBITS,NB_FRAC)));
    end;
    fprintf(fileID, '\n');
end;
fprintf(fileID, 'outputs\n');
for i=1:NB_SAMPLES
    for j=1:OUTPUTS
        fprintf(fileID, colfmt, bin(fi(s(i+1,j),1,NBITS,NB_FRAC)));
    end;
    fprintf(fileID, '\n');
end;
fprintf(fileID, 'uz     \n');
for i=1:INPUTS
    for j=1:OUTPUTS
        fprintf(fileID, colfmt, bin(fi(uz(i,j),1,NBITS,NB_FRAC)));
    end;
    fprintf(fileID, '\n');
end;
fprintf(fileID, 'ur     \n');
for i=1:INPUTS
    for j=1:OUTPUTS
        fprintf(fileID, colfmt, bin(fi(ur(i,j),1,NBITS,NB_FRAC)));
    end;
    fprintf(fileID, '\n');
end;
fprintf(fileID, 'uh     \n');
for i=1:INPUTS
    for j=1:OUTPUTS
        fprintf(fileID, colfmt, bin(fi(uh(i,j),1,NBITS,NB_FRAC)));
    end;
    fprintf(fileID, '\n');
end;
fprintf(fileID, 'wz     \n');
for i=1:OUTPUTS
    for j=1:OUTPUTS
        fprintf(fileID, colfmt, bin(fi(wz(i,j),1,NBITS,NB_FRAC)));
    end;
    fprintf(fileID, '\n');
end;
fprintf(fileID, 'wr     \n');
for i=1:OUTPUTS
    for j=1:OUTPUTS
        fprintf(fileID, colfmt, bin(fi(wr(i,j),1,NBITS,NB_FRAC)));
    end;
    fprintf(fileID, '\n');
end;
fprintf(fileID, 'wh     \n');
for i=1:OUTPUTS
    for j=1:OUTPUTS
        fprintf(fileID, colfmt, bin(fi(wh(i,j),1,NBITS,NB_FRAC)));
    end;
    fprintf(fileID, '\n');
end;
fprintf(fileID, 'bz     \n');
for j=1:OUTPUTS
    fprintf(fileID, colfmt, bin(fi(bz(1,j),1,NBITS,NB_FRAC)));
end;
fprintf(fileID, '\n');
fprintf(fileID, 'br     \n');
for j=1:OUTPUTS
    fprintf(fileID, colfmt, bin(fi(br(1,j),1,NBITS, NB_FRAC)));
end; 
fprintf(fileID, '\n');
fprintf(fileID, 'bh     \n');
for j=1:OUTPUTS
    fprintf(fileID, colfmt, bin(fi(bh(1,j),1,NBITS, NB_FRAC)));
end;
fprintf(fileID, '\n');
fprintf(fileID, '*      ');
fclose(fileID);

fileVERIF = fopen('data_in_decimal.txt', 'w');
colfmt= '%f';
fprintf(fileVERIF, 'inputs \n');
fmt = [repmat([colfmt ' '], 1, INPUTS-1), colfmt, '\n'];

fprintf(fileVERIF, fmt, fi(x(1:NB_SAMPLES,:).',1,NBITS,NB_FRAC));
fprintf(fileVERIF,  'outputs\n');
fmt = [repmat([colfmt ' '], 1, OUTPUTS-1), colfmt, '\n'];
fprintf(fileVERIF, fmt, fi(s(2:NB_SAMPLES+1,:).',1,NBITS,NB_FRAC));
fprintf(fileVERIF, 'uz     \n');
fprintf(fileVERIF, fmt, fi(uz.', 1, NBITS, NB_FRAC));
fprintf(fileVERIF, 'ur     \n');
fprintf(fileVERIF, fmt, fi(ur.', 1, NBITS, NB_FRAC));
fprintf(fileVERIF, 'uh     \n');
fprintf(fileVERIF, fmt, fi(uh.', 1, NBITS, NB_FRAC));
fprintf(fileVERIF, 'wz     \n');
fprintf(fileVERIF, fmt, fi(wz.', 1, NBITS, NB_FRAC));
fprintf(fileVERIF, 'wr     \n');
fprintf(fileVERIF, fmt, fi(wr.', 1, NBITS, NB_FRAC));
fprintf(fileVERIF, 'wh     \n');
fprintf(fileVERIF, fmt, fi(wh.', 1, NBITS, NB_FRAC));
fprintf(fileVERIF, 'bz     \n');
fprintf(fileVERIF, fmt, fi(bz.', 1, NBITS, NB_FRAC));
fprintf(fileVERIF, 'br     \n');
fprintf(fileVERIF, fmt, fi(br.', 1, NBITS, NB_FRAC));
fprintf(fileVERIF, 'bh     \n');
fprintf(fileVERIF, fmt, fi(bh.', 1, NBITS, NB_FRAC));
fclose(fileVERIF);
