% Script d'exécution
close all
clear all


% Chargement du signal
[signal, frequence] = audioread('fluteircam.wav');
type_noise = 'noNoise';
estimate_type = 'levinson';
window_type = 'blackman';




%----------------AJOUT DE BRUIT-------------
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
%----------------------

% Taille du signal
signal_size = size(signal);
signal_length = signal_size(1, 1);

% Affichage des informations du signal
fprintf('Signal de taille %d et de fréquence %d Hz.\n', signal_length, frequence);

%taille de la fenêtre
T = 40; % en ms

% Nombre d'elements
points_by_sample = frequence * T / 1000;

% Affichage des informations de sampling
fprintf('En utilisant des échantillons de %d ms, on a %d points par échantillon.\n', T, points_by_sample);

% Combien d'échantillons donc ? TODO : et les résidus ?
nb_samples = floor(signal_length / points_by_sample);
fprintf('Ce qui revient à %d échantillons.\n', nb_samples);

% Création des échantillons
samples = zeros(nb_samples, points_by_sample);
samples_times = zeros(nb_samples, points_by_sample);
for i = 1:nb_samples
    samples(i, :) = signal((i - 1) * points_by_sample + 1: i * points_by_sample);
    samples_times(i, :) = [(i - 1) * points_by_sample + 1: i * points_by_sample];
end
 
% méthode alternative: fenêtrage et lissage des échantillons


switch window_type
    case 'blackman'
window = blackman(points_by_sample); %%%ici tu règels la fenêtre
    case 'hamming'
        window = hamming(points_by_sample); %%%ici tu règels la fenêtre
    case 'hanning'
        window = hanning(points_by_sample); %%%ici tu règels la fenêtre
    case 'bartlett'
        window = bartlett(points_by_sample); %%%ici tu règels la fenêtre

for i = 1:nb_samples
    samples(i, :) = samples(i, :) .* window';
end 
 

switch estimate_type
    case 'fft'

% -------------------------- FFT -------------------------
% FFT des échantillons
ffts = zeros(nb_samples, points_by_sample);
for i = 1:nb_samples
    ffts(i, :) = abs(fft(samples(i, :)));
end
fft_axis = (1:(points_by_sample / 2));
fft_frequencies = frequence / 2 * linspace(0, 1, points_by_sample / 2);

%taking only the positive frequencies of the fft
ffts = ffts(:, 1:points_by_sample / 2);

% Plotting
figure
mesh(log(ffts)) % ecrit par will:j'ai rajouté le log ici, je ne sais pas si tu l'avais enlevé ou mis à un autre endroit ? 
figure
imagesc(log(ffts)); % ecrit par will:j'ai rajouté le log ici, je ne sais pas si tu l'avais enlevé ou mis à un autre endroit ?
rotate3d on

% le vecteur des fréquences est fft_frequencies
%pour plotter juste pour un échantillon, faire
%plot(fft_frequencies,ffts(100, :)/trapz(fft_frequencies,ffts(100, :))), (on normalise par l'aire) par exemple pour le 100è échantillon




%-------------------------------WITH LEVINSONDURBIN------------------------------------------
    case 'levinson'
pp = 100;
for i = 1:nb_samples
[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin (samples(i, :), pp, frequence);
if i == 1
    levinson = zeros(nb_samples, length(find(ff>0)));
end
levinson(i, :) = mydsp(find(ff>0));
% keep only the positive frequencies
levinson_frequencies  = ff(find(ff>0));    
end
% Plotting
figure
mesh(log(levinson))
figure
imagesc(log(levinson));
rotate3d on

% le vecteur des fréquences est levinson_frequencies
%pour plotter juste pour un échantillon, faire
%plot(levinson_frequencies,levinson(100, :)/trapz(levinson_frequencies,levinson(100, :))), (on normalise par l'aire) par exemple pour le 100è échantillon
%pour plotter sur le même plan qu'un autre faire subplot et bien garder les
%vecteurs XXX_frequencies en abscisse de chaque plot

%--------------------------WITH PERIODOGRAM---------------------------------------------
    case 'periodogram'
% FFT des échantillons
perio = zeros(nb_samples, points_by_sample);
for i = 1:nb_samples
    perio(i, :) = abs(fft(samples(i, :))).^2;
end
perio_axis = (1:(points_by_sample / 2));
perio_frequencies = frequence / 2 * linspace(0, 1, points_by_sample / 2);

% Plotting
figure
mesh(log(ffts(:, 1:points_by_sample / 2))) % ecrit par will:j'ai rajouté le log ici, je ne sais pas si tu l'avais enlevé ou mis à un autre endroit ? 
figure
imagesc(log(ffts(:, 1:points_by_sample / 2))); % ecrit par will:j'ai rajouté le log ici, je ne sais pas si tu l'avais enlevé ou mis à un autre endroit ?
rotate3d on

end










%%
%clustering



%ici changer ffts en ce qu'on veut (levinson, periodogram)
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
% le signal sur la durée correspondante avec uniquement les pics
prev = clusters_linear(1, 1);
sbegin = 1;
for i = 1:nb_samples
    current = clusters_linear(i, 1);
    % Rien à faire dans le premier cas
    if current == prev && i ~= nb_samples
        
    else
        % Fin de la zone
        send = i;
        
        % La on interpole sur la durée
        size_area = send - sbegin + 1;
        fprintf('On interpole le signal sur %d temps de %d à %d.\n', size_area, sbegin, send);
        
        avr_fft = mean(ffts(sbegin:send, fft_axis));

        
        [peaks, locations] = findpeaks(avr_fft, 'MinPeakHeight', 0.2, 'MinPeakDistance', 15);
        frequencies = locations * frequence / points_by_sample * 2 * pi;
        fprintf('Fréquence : %d.\n', frequencies(1));
        peaks = sqrt(peaks);
        sb = (sbegin - 1) * points_by_sample + 1;
        sf = send * points_by_sample;
        nb_peaks = size(peaks);
        nb_peaks = nb_peaks(2);
        for j = 1:nb_peaks
           
            mysound(sb:sf) = mysound(sb:sf) + peaks(j) * sin((sb:sf) * T / 1000 / points_by_sample * frequencies(j));
        end
        
        
        % On change le début de la nouvelle zone
        sbegin = i + 1;
    end
    prev = current;
end
% spectrogram(samples(300, :));
figure
plot(mysound/max(mysound), 'r');
hold on
plot(signal/max(signal), 'b');
% --------------------------------------------------------

%levinson durbin 
%for i=1:5
    
%    pp = 10*i;
%    [aa, sigma2, ref, ff, mydsp]= mylevinsondurbin(y, pp, Fs);
%end






%aide pour le tracé des bonnes courbes: 




