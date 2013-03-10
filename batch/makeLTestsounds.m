clear all;
close all;
clc

%% Constants
dateStrLen = 22;
reSynthLength = length('_resynth');

prepausLength = 0.5;
midpauseLength = 0.5; % seconds
endpauseLength = 4;

Fs = 44100;

%% find all audio file in recordings folder
listAll = dir('./synths/*.wav');
%%
fNames = char(listAll.name);
nFiles = size(fNames,1);

%nFiles = 1;

%% for each file

midPausSamples = zeros(prepausLength*Fs,1);
prePausSamples = zeros(midpauseLength*Fs,1);
endPausSamples = zeros(endpauseLength*Fs,1);

for fIndex = 1:size(fNames,1)
    audioFileName = fNames(fIndex,:);
    disp(['Processing ' audioFileName]);
    dotIndex = find(audioFileName == '.',1,'last');

    synthFName = audioFileName(1:dotIndex-1);
    origFName = audioFileName(dateStrLen:dotIndex-1-reSynthLength);


    [origAudio origFs] = wavread(['./recordings/' origFName '.wav']);
    [synthAudio synthFs] = wavread(['./synths/' synthFName '.wav']);


    abCombo = [prePausSamples; origAudio;midPausSamples;synthAudio;endPausSamples];
    baCombo = [prePausSamples; synthAudio;midPausSamples;origAudio;endPausSamples];

    sFilename = ['./lTest/' audioFileName(1:dotIndex-1-reSynthLength) '_ltest'];

    %mkdir('./lTest');
    wavwrite(abCombo,Fs,24,[sFilename '_AB.wav']);
    wavwrite(baCombo,Fs,24,[sFilename '_BA.wav']);
end

