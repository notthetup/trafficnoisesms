function runSMS( cF )
% Runs SMS Anaslysis, Synthesis and Reporting for a given cF structure

%% Init
clc
close all;

%% Debug
debugPlay = 0;
debugSpec = 0;

%%
[ fGuides, rParams, Fs, cF] = sMSAnalyze(cF);
%debug;

%%
savefGuidesResidue(fGuides,rParams,cF,Fs);

%%
[ reSynth, reSynthDet, reSynthNoise] = sMSSynth(cF,Fs);

%%
saveReSynth(reSynth, reSynthDet, cF, Fs);

%%
if (debugSpec == 1)
	reportSMS(reSynth, reSynthDet, reSynthNoise, cF)
end

%%

if(debugPlay == 1)
    %%
    playBackTest(cF); 
    
end

end

