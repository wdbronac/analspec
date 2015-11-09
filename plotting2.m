

% Script d'exécution
close all
clear all


[signal, frequence] = audioread('fluteircam.wav');

type_noise = 'noNoise';
%'noNoise'
%'weak_white_noise'
%'strong_white_noise'
%'weak_pink_noise'
%'strong_pink_noise'

estimate_type = 'burg';
%fft
%levinson
%periodogram
%burg
window_type = 'blackman';
%blackman
%hamming
%hanning
%bartlett




plotting1(signal, frequence, type_noise , estimate_type, window_type)
saveas(gcf, strcat('figures/',type_noise,estimate_type,window_type,'.jpg'))