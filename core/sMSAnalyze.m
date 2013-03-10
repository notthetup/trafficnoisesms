function [ fGuides residualHops Fs cF] = sMSAnalyze( cF )
%SMSANALYZE This function anazlyses the given audio.
%   Analyze the given audio using the SMS technique. Outputs an array of
%   Frequency Guides and Noise Hops

%% Debug
debugPlotGuides = 0;
debugCF = 1;
debugCalResSave = 0;

%% Load Config
% Loads the audio based on the Configuration Structure
[audio, Fs] = loadAudio(cF);


% Pads audio with zeros.
paddedLength = length(audio)+max([cF.sP.winLength]);
paddedAudio = padStream(audio',  paddedLength);

% Init
inputStream = paddedAudio;
aHArray = AnalysisHop.empty(0,genHopNum(cF.sP,length(inputStream)));
fGuides = FGuide.empty(0,1);

% Per pass
for passIdx = 1:cF.numPass
    passStr = sprintf('\nPass #%d\n',passIdx);
    disp(passStr);
    disp('Chopping');
    
    % Chop for STFT
    hArray = chop(inputStream,cF.sP(passIdx));
    aHArray(end+1:end+length(hArray)) = hArray;
    
    %% Peak Detection
    
    disp('Detecting Peaks');
    for index = 1:length(hArray)
        tHop = hArray(index);
        % Analyze each Hop
        tHop.peakAnalyze(Fs,cF.sP(passIdx).fftLength,cF.pD(passIdx));
    end
    
    %% Peak Tracking
    
    disp('Tracking Peaks');
    % Initalize Peak Track Parameters
    guideSleepLength = round(cF.sleepTransFac/cF.sP(passIdx).winLength);
    maxGuideFac = floor(cF.maxGuides*cF.pD(passIdx).pRatio);
    guideIncFac = cF.guideIncFactor/length(hArray);
    
    % Track Guides
    if(~exist('fGuides','var'))
        fGuides = peakTrack(hArray,cF.pD(passIdx),maxGuideFac,guideIncFac,guideSleepLength);
    else
        fGuides = [fGuides peakTrack(hArray,cF.pD(passIdx),maxGuideFac,guideIncFac,guideSleepLength)];
    end
    
    % Plot Guides
    if(debugPlotGuides == 1)
        guidesPlot(fGuides);
        pause(0.01);
    end
end

%Clean low energy guides
unTreshfGuides = fGuides;
fGuides = cleanGuides( fGuides, cF.minGuideEnergy);

if(debugPlotGuides == 1)
    guidesPlot(fGuides);
    pause(0.01);
end

%% Synth Deterministic
disp('Synthesizing Guides');

% Synthsize Deterministic Gudies
[synthStream synthPasses] = sMSSynthGuides(fGuides,cF.sP,Fs);
%Pad/Trim the Synthesized Passes and Audio
adjustedSynthStream = padStream(synthStream,paddedLength);
adjustedSynthPasses = padStream(synthPasses,paddedLength);

% Subtract Synth from Input.
residualStream = inputStream - adjustedSynthStream;

if(debugCalResSave == 1)
    save('calRes.mat','inputStream','adjustedSynthPasses', 'fGuides','cF');
end

% Save the input energy for normalization.
cF.inputEnergy = sumsqr(inputStream);

%% Calculate Residual

disp('Calculating Residuals');
% Generate Residual Hops from Input and Synthezied streams
residualHops = calcResidual(inputStream,adjustedSynthPasses((1:cF.numPass),:),cF.sP,cF.pD,Fs);

% Store extra information in CF structure for debug
if(debugCF == 1)
    cF.Fs = Fs;
    cF.debug.hArray = aHArray;
    cF.debug.unTreshfGuides = unTreshfGuides;
    cF.debug.fGuides = fGuides;
    cF.debug.residualStream = residualStream;
    cF.debug.residualHops = residualHops;
    cF.debug.inputStream = inputStream;
end

end
