%% Init

currDateTime = datestr(now, 'dd-mmm-yyyy HH:MM:SS');
configFile = mfilename;                 % Selfname

%% %Analysis Config.

%% Audio
audioFile = 'idling 65 dB newer';
truncFac = 5/100;                       % Percentage factor of the audio file to be used for analysis.

%% Constants
maxGuides = 1000;

%% Params

% STFT Params
winLengthSmall = 128;                       %  Window Length
fftLengthSmall = 2*winLengthSmall;              %  FFT Length
ovFacSmall = 75;                                %  Overlap factor (%).

hopLengthSmall = round((100-ovFacSmall)*winLengthSmall/100);   %Hop Length

winLengthLarge = winLengthSmall*4;             %  Window Length
fftLengthLarge = 2*winLengthLarge;              %  FFT Length
ovFacLarge = 75;                                %  Overlap factor (%).

hopLengthLarge = round((100-ovFacLarge)*winLengthLarge/100);   %Hop Length

stftParams(1).winLength = winLengthSmall;
stftParams(1).hopLength = hopLengthSmall;
stftParams(1).fftLength = fftLengthSmall;

stftParams(2).winLength = winLengthLarge;
stftParams(2).hopLength = hopLengthLarge;
stftParams(2).fftLength = fftLengthLarge;

% Peak Detection Params
pFreqMax = 15000;          % Maximum frequency of peak considered.

nPeaks = 10;               % Max peaks captured per frame
pHThres = 0.0001;          % Peak Height Treshold - Only peaks above this value are considered
pWThresh = 5;              % Peak Width Treshold - The minimum width between peaks [Hz]

peakDetectParams.maxFreqDiff = pWThresh;    % Min diff in peaks to be considered in different guides
peakDetectParams.nPeaks = nPeaks;
peakDetectParams.pHThres = pHThres;
peakDetectParams.pWThresh = pWThresh;
peakDetectParams.pFreqMax = pFreqMax;
peakDetectParams.alpha = 0.5;            % Trajectory vs next peak ratio

guideIncFactor = 2;       % Additional guides per hop.


%% Saving
cAudioFileName = audioFile;
cAudioFileName(cAudioFileName == ':') = '-';
cAudioFileName(cAudioFileName == ' ') = '_';
cF.lFName = audioFile;
cF.sFName = sprintf('%s_%s.mat',cAudioFileName,'fGuidesResidue');

%% Packaging

cF.sP = stftParams;
cF.numPass = length(stftParams);
cF.pD = peakDetectParams;
cF.maxGuides = maxGuides;
cF.guideIncFactor = guideIncFactor;
cF.truncFac = truncFac;



%% %ReSynth Config


cF.fGuideResiduefName = cF.sFName;

cF.normFac = 0.95;                 % Normalization Factor.

cF.rAudioDetfName = sprintf('%s_%s_%s.wav',currDateTime,cAudioFileName,'reSynthDet');
cF.rAudiofName = sprintf('%s_%s_%s.wav',currDateTime,cAudioFileName,'reSynth');
cF.configFile = sprintf('%s_%s.mat',currDateTime,configFile);