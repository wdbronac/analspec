

% Script d'exécution
close all
clear all


[signal, frequence] = audioread('fluteircam.wav');

type_noise = 'noNoise';
estimate_type = 'levinson';
window_type = 'hanning';




plotting1(signal, frequence, type_noise , estimate_type, window_type)
saveas(gcf, strcat('figures/',type_noise,estimate_type,window_type,'.jpg'))