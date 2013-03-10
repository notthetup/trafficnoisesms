%% Init

currDateTime = datestr(now, 'dd-mmm-yyyy_HH-MM-SS');
configFile = mfilename;                 % Selfname

%% %Analysis Config.

%% Audio
audioFile = 'sig_deprop_iv_50';
%audioFile = 'chirp';
Fs = 44100;

truncFac = [0,100]/100;                       % Percentage boundary of the audio file to be used for analysis.

%% Constants
maxGuides = 200;
sleepTransFac = 512*128;

%% Params


% STFT Params'
winLengthTiny = 128;                           %  Window Length
fftLengthTiny = 4*winLengthTiny;               %  FFT Length
ovFacTiny = 75;                                %  Overlap factor (%).

hopLengthTiny = round((100-ovFacTiny)*winLengthTiny/100);   %Hop Length

winLengthSmall = winLengthTiny*4;                           %  Window Length
fftLengthSmall = 4*winLengthSmall;              %  FFT Length
ovFacSmall = 75;                                %  Overlap factor (%).

hopLengthSmall = round((100-ovFacSmall)*winLengthSmall/100);   %Hop Length

winLengthMid = winLengthSmall*4;                %  Window Length
fftLengthMid = 4*winLengthMid;                  %  FFT Length
ovFacMid = 75;                                  %  Overlap factor (%).

hopLengthMid = round((100-ovFacMid)*winLengthMid/100);   %Hop Length

winLengthLarge = winLengthMid*4;                %  Window Length
fftLengthLarge = 4*winLengthLarge;              %  FFT Length
ovFacLarge = 75;                                %  Overlap factor (%).

hopLengthLarge = round((100-ovFacLarge)*winLengthLarge/100);   %Hop Length

stftParams(4).winLength = winLengthTiny;
stftParams(4).hopLength = hopLengthTiny;
stftParams(4).fftLength = fftLengthTiny;

stftParams(3).winLength = winLengthSmall;
stftParams(3).hopLength = hopLengthSmall;
stftParams(3).fftLength = fftLengthSmall;

stftParams(2).winLength = winLengthMid;
stftParams(2).hopLength = hopLengthMid;
stftParams(2).fftLength = fftLengthMid;

stftParams(1).winLength = winLengthLarge;
stftParams(1).hopLength = hopLengthLarge;
stftParams(1).fftLength = fftLengthLarge;




%%
% Peak Detection Params
pFreqMax = 15000;          % Maximum frequency of peak considered.
pFreqMin = 15;             % Minumum frequency of peak considered.

nPeaks = 25;              % Max peaks captured per frame
pHThresDB = -95;          % Peak Height Treshold - Only peaks above this value are considered
pHThres = 10^(pHThresDB/20);
pWThresh = 20;             % Peak Width Treshold - The minimum width between peaks [Hz]

guideIncFactor = 0.005;       % Additional guides each pass.
minGuideEnergy = 0.001;        % Minimum energy each guide should have as a percent of total.

pdp.maxFreqDiff = 2;       % Max diff in peaks to be considered in same guides
pdp.nPeaks = nPeaks;
pdp.pHThres = pHThres;
pdp.pWThresh = pWThresh;
pdp.alpha = 0.2;            % Trajectory vs next peak ratio
pdp.pFreqMin = 20;
pdp.pFreqMax = 15000;
pdp.cBandsNormFac = 15;     % Normalization factor critical bands BW.
pdp.pRatio = 1/length(stftParams);


peakDetectParams(4) = pdp;
peakDetectParams(4).pFreqMin = 10000;
peakDetectParams(4).pFreqMax = 22050;
peakDetectParams(4).pRatio = 0.2;

peakDetectParams(3) = pdp;
peakDetectParams(3).pFreqMin = 4000;
peakDetectParams(3).pFreqMax = 10000;
%peakDetectParams(3).pFreqMax = 22050;
peakDetectParams(3).pRatio = 0.2;

peakDetectParams(2) = pdp;
peakDetectParams(2).pFreqMin = 300;
peakDetectParams(2).pFreqMax = 4000;
peakDetectParams(2).pRatio = 0.4;

peakDetectParams(1) = pdp;
peakDetectParams(1).pFreqMin = 20;
peakDetectParams(1).pFreqMax = 300;
peakDetectParams(1).pRatio = 0.2;


% residuals

passResParam = 1;            % 1 = Pass residual parameters; 0 = Pass residual audio.

erbNum = 40;                % Number of ERB Bands.

%% reverse anslysis
% tS = stftParams(3);
% stftParams(3) = stftParams(1);
% stftParams(1) = tS;

%stftParams(1) = stftParams(3);
%peakDetectParams(1) = peakDetectParams(3);

%% Saving
cAudioFileName = audioFile;
cAudioFileName(cAudioFileName == ':') = '-';
cAudioFileName(cAudioFileName == ' ') = '_';
cF.lFName = sprintf('./recordings/%s.wav',audioFile);
cF.sFName = sprintf('./synths/%s/%s_%s_%s.mat',cAudioFileName,currDateTime,cAudioFileName,'fGuidesResidue');

%% Packaging


cF.numPass = length(stftParams);
cF.sP = stftParams(1:cF.numPass);
cF.pD = peakDetectParams(1:cF.numPass);
cF.maxGuides = maxGuides;
cF.guidesPerPass = round(maxGuides/cF.numPass);
cF.guideIncFactor = guideIncFactor;
cF.truncFac = truncFac;
cF.sleepTransFac = sleepTransFac;
cF.erbNum = erbNum;
cF.passResParam = passResParam;
cF.minGuideEnergy = minGuideEnergy;


%% %ReSynth Config


cF.fGuideResiduefName = cF.sFName;

cF.normFac = 0.95;                 % Normalization Factor.

cF.rFileName = sprintf('./synths/%s/',cAudioFileName);
cF.rAudioDetfName = sprintf('./synths/%s/%s_%s_%s.wav',cAudioFileName,currDateTime,cAudioFileName,'reSynthDet');
cF.rAudiofName = sprintf('./synths/%s/%s_%s_%s.wav',cAudioFileName,currDateTime,cAudioFileName,'reSynth');
cF.configFile = sprintf('./synths/%s/%s_%s.mat',cAudioFileName,currDateTime,configFile);
cF.debugFile = sprintf('./synths/%s/%s_%s.mat',cAudioFileName,currDateTime,'debug');