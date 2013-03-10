function [ reSynthAudio reSynthDet reSynthNoise] = sMSSynth(cF,Fs )
%SMSSYNTH Synthesizes a given SMS Model.
%   Synthesizes the audio for a SMS Model given by an array of Frequency
%   Guides and an array of Hops.

%% Constants
normalize = 0;

%% Load Config

disp('Re-Auralizing');

% Loads the FGuides and ResidualHops from the database based on the
% Configuration File
[fGuides, residualHops] = loadfGuidesrHops(cF);

%% Synthesize fGuides

disp('Synthesizing Guides');

% Synthesize the Deterministic Part
[reSynthDet synthDetPasses] = sMSSynthGuides(fGuides,cF.sP,Fs);


%% Synthesize Noise

% Synthesize the Residual Part
disp('Synthesizing Noise');
[reSynthNoise synthNoisePasses] = sMSSynthResidual(residualHops);
% Pad/Trim the Residual
reSynthNoise = padStream(reSynthNoise,length(reSynthDet));
%%

% Combine the Deterministic and Residual.
reSynthAudio = reSynthNoise+reSynthDet;

disp('Done');

%Normalize based on total energy.
if(normalize == 1)
    reSynthEnergy = sumsqr(reSynthAudio);
    reSynthAudio = sqrt(cF.inputEnergy/reSynthEnergy)*reSynthAudio;
end


end