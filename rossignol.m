% Script d'ex�cution
close all
clear all


% Chargement du signal
[signal, frequence] = audioread('fluteircam.wav');
% Taille du signal
signal_size = size(signal);
signal_length = signal_size(1, 1);

% Affichage des informations du signal
fprintf('Signal de taille %d et de fr�quence %d Hz.\n', signal_length, frequence);

%taille de la fen�tre
T = 40; % en ms

% Nombre d'elements
points_by_sample = frequence * T / 1000;

% Affichage des informations de sampling
fprintf('En utilisant des �chantillons de %d ms, on a %d points par �chantillon.\n', T, points_by_sample);

% Combien d'�chantillons donc ? TODO : et les r�sidus ?
nb_samples = floor(signal_length / points_by_sample);
fprintf('Ce qui revient � %d �chantillons.\n', nb_samples);

% Cr�ation des �chantillons
samples = zeros(nb_samples, points_by_sample);
samples_times = zeros(nb_samples, points_by_sample);
for i = 1:nb_samples
    samples(i, :) = signal((i - 1) * points_by_sample + 1: i * points_by_sample);
    samples_times(i, :) = [(i - 1) * points_by_sample + 1: i * points_by_sample];
end
  
% -------------------------- FFT -------------------------
% FFT des �chantillons
ffts = zeros(nb_samples, points_by_sample);
for i = 1:nb_samples
    ffts(i, :) = abs(fft(samples(i, :)));
end
fft_axis = (1:(points_by_sample / 2));
fft_frequencies = frequence / 2 * linspace(0, 1, points_by_sample / 2);

% Plotting
figure
mesh(ffts(:, 1:points_by_sample / 2))
rotate3d on



D = pdist(ffts, 'euclidean');
Z = linkage(D);

figure
%clusters11 = cluster(Z, 'maxclust', 11);
axis = (1:nb_samples);
clusters15 = cluster(Z, 'maxclust', 15);
clusters30 = cluster(Z, 'maxclust', 30);

plot(axis, clusters15, axis, clusters30);

% Linearize
clusters_linear = clusters30;
prev = clusters_linear(1, 1);
for i = 1:(nb_samples - 1)
    current = clusters_linear(i);
    next = clusters_linear(i + 1);
    if prev ~= current && current ~= next
       clusters_linear(i) = prev;
    else
        prev = current;
    end 
end
figure
plot(axis, clusters_linear)

% Sound analysis
mysound = zeros(1, nb_samples * points_by_sample);

% Methode on regarde tous les points qui sont pareils et on reproduit
% le signal sur la dur�e correspondante avec uniquement les pics
prev = clusters_linear(1, 1);
sbegin = 1;
for i = 1:nb_samples
    current = clusters_linear(i, 1);
    % Rien � faire dans le premier cas
    if current == prev && i ~= nb_samples
        
    else
        % Fin de la zone
        send = i;
        
        % La on interpole sur la dur�e
        size_area = send - sbegin + 1;
        fprintf('On interpole le signal sur %d temps de %d � %d.\n', size_area, sbegin, send);
        
        avr_fft = mean(ffts(sbegin:send, fft_axis));

        
        [peaks, locations] = findpeaks(avr_fft, 'MinPeakHeight', 0.2, 'MinPeakDistance', 15);
        frequencies = locations * frequence / points_by_sample;
        
        sb = (sbegin - 1) * points_by_sample + 1;
        sf = send * points_by_sample;
        %for j = 1:size(peaks)
            j = 1;
            mysound(sb:sf) = mysound(sb:sf) + peaks(j) * sin((sb:sf) * T / 1000 / points_by_sample * frequencies(j));
        %end
        
        
        % On change le d�but de la nouvelle zone
        sbegin = i + 1;
    end
    prev = current;
end
% spectrogram(samples(300, :));
figure
plot(mysound);
% --------------------------------------------------------

%levinson durbin 
%for i=1:5
    
%    pp = 10*i;
%    [aa, sigma2, ref, ff, mydsp]= mylevinsondurbin(y, pp, Fs);
%end

