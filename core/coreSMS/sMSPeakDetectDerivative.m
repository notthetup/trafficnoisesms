function peaks = sMSPeakDetectDerivative(zHop, peakDetectParams)

%% Init
detHop = 0;
useCritBWMax = 1;

%% Decode PeakParams

nPeaks = peakDetectParams.nPeaks;
peakHThres = peakDetectParams.pHThres;
pFreqMax = peakDetectParams.pFreqMax;
pFreqMin = peakDetectParams.pFreqMin;
peakWThres = peakDetectParams.peakWThres;

if(peakWThres <= 1)
    peakWThres = 1;
end

% Compute Derative of signal

sigDer = ([0, diff(zHop.audioStream)]*zHop.fs);
derHop = AnalysisHop(sigDer,zHop.stftParams,zHop.id,detHop);
derHop.window('hann',2.5);
derFFTUnSc = derHop.doFFT(zHop.fftLength,zHop.fs);
derOmega = derHop.fVec*2*pi/derHop.fs;
derScalingFac = derOmega./(2*sin(derOmega/2));
derFFT = derFFTUnSc.*derScalingFac;


%% Find all peaks

% Take only half of the spectrum. Magnitude of FFT of Real Signal is
% mirrored. To keep energy levels, we multiply the amplitude by two.
halfFFTStream = zHop.fftStream(1:end/2)*2;
halfDerFFTStream = derFFT(1:end/2)*2;
rFVec = zHop.fVec(1:end/2);

bLimitedIdx = rFVec < pFreqMax & rFVec > pFreqMin;

if(all(bLimitedIdx == 0))
    bLimitedFFTStream = halfFFTStream;
    bLimitedDerFFTStream = halfDerFFTStream;
    bLimitedfVec = rFVec;
else
    
    bLimitedDerFFTStream = halfDerFFTStream(bLimitedIdx);
    bLimitedFFTStream = halfFFTStream(bLimitedIdx);
    bLimitedfVec = rFVec(bLimitedIdx);
end


magStream = abs(bLimitedFFTStream);
magDerStream = abs(bLimitedDerFFTStream);

% Gradient of FFT Magnitude
gradStream = diff([magStream(1) , magStream]);

% Find all change of gradients
pLoc = find(gradStream(1:(end-1))>0 & gradStream(2:end) <=0);

%% Height Threshold

% Threshold the peaks. Anything below the Threshold is ignored.
% Useful if the noise level is known.
tPLoc =  pLoc(magStream(pLoc) > peakHThres);

%% Width Threshold and find max.

% If not enough peaks
if length(tPLoc) < nPeaks
    warning('SMS:Hop:PeakFinder','Hop %s: Found fewer peaks than expected. E:%d | F:%d ',num2str(zHop.id),nPeaks,length(tPLoc));
    nPeaks = length(tPLoc);
end

% Set all peaks locations as valid
validLoc = tPLoc;
validFreq = bLimitedfVec(tPLoc);
validVal = magStream(tPLoc);
validGrad = gradStream(tPLoc-1);
validDerVal = magDerStream(tPLoc);

cPeaks = peak.empty(0,nPeaks);

for pkIdx = 1:nPeaks
    
    if (isempty(validLoc))
        %warning('SMS:Hop:PeakFinder','Hop %s: Found fewer peaks than expected. E:%d | F:%d ',num2str(zHop.id),nPeaks,length(tPLoc));
        break                       % no more local peaks to pick
    end
    
    
    %[~, cMaxInd] = max(validGrad); % Order by gradient
    [~, cMaxInd] = max(validVal);   % Order by magnitude
    
    peakFreq = validFreq(cMaxInd);
    peakFreqDer = (validDerVal(cMaxInd)/validVal(cMaxInd))/(2*pi);
    
    %peakPhase = angle(bLimitedFFTStream(peakLoc));
    peakDiff = abs(peakFreqDer - peakFreq);
    if (peakDiff <= zHop.df*2)
        peakVal = validVal(cMaxInd)/(derHop.windowFFTMag(peakDiff));
        cPeaks(pkIdx) = Peak(peakFreqDer,peakVal,zHop.id);
        
        %disStr = sprintf('Moving Freq by %f; Moving mag by %f%%',peakDiff, (peakVal-maxVal)./maxVal);
        %disp(disStr);
        
    else
        %warning('SMS:Hop:PeakFinder','Unable to use derivative, using quad peak estimate');
        n3Loc = validLoc(cMaxInd)+(-1:1);
        
        if(n3Loc(1) < 1)
            n3Loc(1) = 1;
            %warning('MATLAB:PeakDetectDeriv','Peak at edge, forcing lLoc to 1');
        elseif (n3Loc(3) > length(magStream))
            n3Loc(3) = length(magStream);
            %warning('MATLAB:PeakDetectDeriv','Peak at edge, forcing rLoc to end');
        end
        
        n3Val = magStream(n3Loc)/zHop.cohPwrGain;
        
        freq.left = bLimitedfVec(n3Loc(1));
        val.left = n3Val(1);
        
        freq.bin = bLimitedfVec(n3Loc(2));
        val.bin = n3Val(2);
        
        freq.right = bLimitedfVec(n3Loc(3));
        val.right = n3Val(3);
        
        cPeaks(pkIdx) = Peak(freq,val,zHop.id,zHop.df);
        
        %cPeaks(pkIdx) = Peak(peakFreq,peakVal,zHop.id);
    end
    
    if (useCritBWMax == 1)
        peakWThres = findCritBW(validFreq(cMaxInd),peakDetectParams.cBandsNormFac);
    end
    vIdx = abs(validFreq(cMaxInd) - validFreq) > peakWThres;
    %vIdx = abs(validFreq(cMaxInd) - validFreq) > ceil(validFreq(cMaxInd)*peakWThres);
    
    validLoc = validLoc(vIdx);
    validFreq = validFreq(vIdx);
    validDerVal = validDerVal(vIdx);
    validVal = validVal(vIdx);
    validGrad = validGrad(vIdx);
    
end

peaks = cPeaks;

end