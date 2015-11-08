function [P fftAxe] = periodogramme(signal, timeSampling)
n = size(signal,1);
[fftR,fftAxe] = FFTR(signal,timeSampling);
P = (fftR.^2); 
end