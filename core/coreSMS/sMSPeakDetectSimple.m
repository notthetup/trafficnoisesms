function peaks = sMSPeakDetectSimple(zHop, peakDetectParams)
%SMSPEAKDETECTSIMPLE This detect all the peaks in a given hop based on some parameters.
%   This function takes an AnalysisHop and a structure of peakDetect Parameters and outputs an 
%   array of Peaks.
%
%   zHop   - Analysis hop which has undergone 'AnalysisHop.doFFT()'.
%   peakDetectParams     - Peak Detection Parameter structure.
%
%   peaks  - Array of Peaks found in the Hop.
%
% Version : 0.5
% Date : 09/10/2011
% Author : Chinmay Pendharkar
% Notes :


%% Init

% Use critical bandwidth theory to decide minimum peak seperation.
useCritBWMax = 1;

%% Decode PeakParams

% Peak Detection Parameters Structure.
nPeaks = peakDetectParams.nPeaks;
peakHThres = peakDetectParams.pHThres;
peakWThres = peakDetectParams.pWThresh;
pFreqMax = peakDetectParams.pFreqMax;
pFreqMin = peakDetectParams.pFreqMin;

%% Find all peaks

% Take only half of the spectrum. Magnitude of FFT of Real Signal is
% mirrored. To keep energy we multiply the aplitude by two.
halfFFTStream = zHop.fftStream(1:end/2)*2;
rFVec = zHop.fVec(1:end/2);

% Bandlimit for Peaks. Only peaks within this band are considered.
bLimitedIdx = rFVec < pFreqMax & rFVec > pFreqMin;

if(sum(bLimitedIdx) == 0)
    bLimitedFFTStream = halfFFTStream;
    bLimitedfVec = rFVec;
else
    bLimitedFFTStream = halfFFTStream(bLimitedIdx);
    bLimitedfVec = rFVec(bLimitedIdx);
end

% Only consider FFT Magnitude.
magStream = abs(bLimitedFFTStream);

% Gradient of FFT Magnitude
gradStream = diff([magStream(1) , magStream]);

% Find all change of gradients (as peaks)
pLoc = find(gradStream(1:(end-1))> 0 & gradStream(2:end) <= 0);

%% Height Threshold

% Threshold the peaks. Anything below the Threshold is ignored.
% Useful if the noise level is known.
tPLoc =  pLoc(magStream(pLoc) > peakHThres);

% Peak values of thresholded peaks
tPVal = magStream(tPLoc);


%% Width Threshold and find max.

% If not enough peaks
if length(tPLoc) < nPeaks
    warning('SMS:Hop:PeakFinder','Hop %s: Found fewer peaks than expected. E:%d | F:%d ',num2str(zHop.id),nPeaks,length(tPLoc));
    nPeaks = length(tPLoc);
end

% Set all peaks locations as valid
validLoc = tPLoc;
validVal = tPVal;
validGrad = gradStream(tPLoc-1);

% Initialize peak array
cPeaks = Peak.empty(0,nPeaks);

for pkIdx = 1:nPeaks
    
    % No more peaks left
    if (isempty(validLoc))
        %warning('SMS:Hop:PeakFinder','Hop %s: Found fewer peaks than expected.',num2str(zHop.id));
        break;                     % no more local peaks to pick
    end
    
    %[~, cMaxInd] = max(validVal); % Order peaks by magnitude
    [~, cMaxInd] = max(validGrad); % Order peaks by gradient
    
    % Get neighboring 2 location to the peak.
    n3Loc = validLoc(cMaxInd)+(-1:1);
    
    % Sanitize neighnouring locations.
    if(n3Loc(1) < 1)
        n3Loc(1) = 1;
        % TODO Warn
    elseif (n3Loc(3) > length(magStream))
        n3Loc(3) = length(magStream);
        % TODO Warn
    end
    
    % Get neighboring 2 values to the peak.
    n3Val = magStream(n3Loc)/zHop.cohPwrGain;
    %n3Phase = angle(bLimitedFFTStream(n3Loc));
    
    freq.left = bLimitedfVec(n3Loc(1));
    val.left = n3Val(1);
    
    freq.bin = bLimitedfVec(n3Loc(2));
    val.bin = n3Val(2);
    
    freq.right = bLimitedfVec(n3Loc(3));
    val.right = n3Val(3);
    
    % Initialize peak (does the peak interpolation as well)
    cPeaks(pkIdx) = Peak(freq,val,zHop.id,zHop.df);
    
    % Use the critical bandwidth of the current peak frequency to decide
    % minimum peak seperation.
    if (useCritBWMax == 1)
        peakWThres = findCritBW(bLimitedfVec(validLoc(cMaxInd)),peakDetectParams.cBandsNormFac);
    end
    
    % Find all peaks outside the minimum peak seperation bandwidth.
    vIdx = abs(validLoc(cMaxInd) - validLoc) > peakWThres;
    
    % Re-index valid peaks.
    validLoc = validLoc(vIdx);
    validGrad = validGrad(vIdx);
    validVal = validVal(vIdx);
    
end

peaks = cPeaks;

end