%clean the workspace

clc
clear all;
close all;

%load the signal
[signal fe] = audioread('fluteircam.wav');

%add noise to it: 
type_noise = 'weak_pink_noise';
switch type_noise
    case 'noNoise'
        signal = signal;
    case 'weak_white_noise'
        signal = awgn(signal,30);

    case 'strong_white_noise'
        signal = awgn(signal,20);

    case 'weak_pink_noise'
        signal = signal + pinknoise(length(signal))';

    case 'strong_pink_noise'
        signal = signal + 3*pinknoise(length(signal))';

end


%%
%utilise le signal relissé

% pretraitementperso
 
[xx, tt] = pretraitementperso(signal,fe);

%compute the dsp estimate with levinson durbin
pp = 100;
[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin (xx', pp, fe);

% keep only the positive frequencies
mydsp = mydsp(find(ff>0)); 
ff = ff(find(ff>0));

%compare the results between the DSP estimation by the periodogram method
%(non-parametric), and the DSP estimate by levinson durbin algorithm
%(parametric).
plot(ff, mydsp/(trapz(ff, mydsp)),'r') 
hold on  
 [P fftAxe] = periodogramme(xx, mean(diff(tt)));
plot(fftAxe, P/(trapz(fftAxe, P)),'b')
legend('levinson', 'periodogramme')
xlabel('frequency (Hz)'), ylabel('normalized dsp')


% (on a normalisé par l'aire sous la courbe pour chaque signal)
