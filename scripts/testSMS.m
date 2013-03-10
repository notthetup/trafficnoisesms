% Script used to test SMS Anslysis and Synthesis

%% Init
clc
close all;
clear all;
pause(1);

%% Debug
debugPlay = 0;
debugSpec = 0;

%%
cFileName = 'config_bus91gear8';
cd configs/
eval(cFileName);
cd ..
clearvars -except cF audioFile debugPlay

%%
tic;
[ fGuides, rParams, Fs, cF] = sMSAnalyze(cF);
toc;
%debug;

%%
savefGuidesResidue(fGuides,rParams,cF,Fs);

%%
tic;
[ reSynth, reSynthDet, reSynthNoise] = sMSSynth(cF,Fs);
toc;

%%
saveReSynth(reSynth, reSynthDet,reSynthNoise,  cF, Fs);

%%
pause;
reportSMS(reSynth, reSynthDet, reSynthNoise, cF)

%%

if(debugPlay == 1)
    %%
    playBackTest(cF);   
     
end
