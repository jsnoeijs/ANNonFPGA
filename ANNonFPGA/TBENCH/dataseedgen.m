mu = 0;
sigma = 1;
INPUTS = 23;
OUTPUTS = 50;
NB_SAMPLES = 50;


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