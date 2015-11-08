function [signal_lisse, tt] = pretraitementperso(signal,fe, time_offset,timeSize_window)
%[signal fe] = audioread('fluteircam.wav');
% in argument we can put the position of the time offset for the
% beginning of the window

%prend en argument le signal et fe, et renvoie le signal lissé sur la
%fenêtre spécifiée dans le code: Gabu tu pourrais la mettre en argument de
%la fonction pour l'appliquer sur toutes les fenêtres 


%tt is the time vector, that will be used for the periodogram

 tt = 1:size(signal,1);
 tt = tt./fe;

%choix de la fenêtre
windowtype = 'hamming';

nSize_window = timeSize_window*fe;

switch windowtype
    case 'hamming'
        w = hamming(nSize_window);
    case 'rectangular'
        w = ones(nSize_window, 1);
    case 'bartlett'
        w = bartlett(nSize_window);
end

n_offset = time_offset*fe;
w = [zeros(n_offset, 1); w];
pad = zeros(size(signal,1)-size(w,1),1);
w = [w; pad];

xx = signal.*w;


%% Filtrage
% Definition des criteres du filtre de lissage (butterworth)
timeSampling =1/fe;
filter_width = 20;
cutoff_f = 0.1;
[num, dem] = butter(filter_width, cutoff_f);
signal_lisse=filter(num,dem,xx);

%% Rephasage du signal filtré

% recuperation de la phase
signal_phase  = xcorr(signal_lisse,xx);
X = (-size(xx,1)+1):1:(size(xx,1)-1);

% on cherche le maximum de la correlation
[C I] = max(signal_phase);
offset = I-size(xx,1)+1;
signal_lisse = signal_lisse(offset:end);
pad = zeros(size(xx,1)-size(signal_lisse,1),1);
signal_lisse = [signal_lisse; pad];


end
