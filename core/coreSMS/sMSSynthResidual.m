function [synthStream synthPasses] = sMSSynthResidual(residualHops)
%SMSSYNTHRESIDUAL This synthesizes the residualHops into an audio stream.
%   This function takes an array of ResidualHops and generates the residual
%   audio stream from them using parametric interpolation and overlap and
%   add methods.
%
%   residualHops - 2-D Array of Residual Hops, (numPass x numHops).
%
%   synthStream  - Combined final audio stream.
%   synthPasses  - Audio stream of individual passes (analysis bands).
%
% Version : 0.5
% Date : 09/10/2011
% Author : Chinmay Pendharkar
% Notes :

%% Debug

debugPrint = 0;
debugPlot = 0;


%% Constants
% Array of pass index to smoothen before synthesizing.
smoothenPassIdx = [2,3];
% Enable Smoothening
smoothen = 1;
% Use envelope parameters to generate noise.
useEnv = 1;

%%
if(debugPlot == 1)
    figure1 = figure;
    axes1 = axes('Parent',figure1,'XMinorTick','on');
    box(axes1,'on');
    hold(axes1,'all');
    grid on;
    
    figure2 = figure;
    axes2 = axes('Parent',figure2,'XMinorTick','on');
    box(axes2,'on');
    hold(axes2,'all');
    grid on;
    
    figure3 = figure;
    axes3 = axes('Parent',figure3,'XMinorTick','on');
    box(axes3,'on');
    hold(axes3,'all');
    grid on;
end
%%
[numPasses numHops] = size(residualHops);
minPHLength = zeros(1,numPasses);
maxPFFTLength = zeros(1,numPasses);

% Generate the max/min number of hops and fft magnitude per pass.
for pIndex = 1:numPasses
    tPHops = residualHops(pIndex,:);
    tPAHops = tPHops(cell2mat({tPHops.active}) == 1);
    [minPHLength(pIndex) ~] = min(cell2mat({tPAHops.hopLength}));
    maxPFFTLength(pIndex) = max(cell2mat({tPAHops.fftLength}));
end

% Global minima and maxima (used for initialization of arrays).
minHLength = min(minPHLength);
maxFFTLength = max(maxPFFTLength);

synthStream = zeros(1,(numHops*minHLength)+maxFFTLength);
synthPasses = zeros(numPasses,(numHops*minHLength)+maxFFTLength);

for pIndex = 1:numPasses
    
    if(debugPrint == 1)
        dispStr = sprintf('Synthesizing Pass : %d',pIndex);
        disp(dispStr);
    end
    
    if(smoothen == 1 && any(pIndex == smoothenPassIdx))
        %Smoothen the pass.
        residualHops(pIndex,:) = smoothenResidual(residualHops(pIndex,:));
    end
    for hIdx = 1:numHops
        if(debugPrint == 1)
            dispStr = sprintf('Synthesizing Residual : %d',hIdx);
            disp(dispStr);
        end
        rHop = residualHops(pIndex,hIdx);
        % Only synthesize non empty hops.
        if(~rHop.isActive)
            continue;
        end
        % Synthezise noise from hop.
        noiseSig = rHop.generateNoise(useEnv);
        % Generate window function.
        normWindow = rHop.genNormWindow(rHop.winLength);
        % Window the Synth noise.
        windowedNoise = normWindow.*noiseSig;
     
        if(any(isnan(windowedNoise)))
            warning('SMS:SyntheResidual','NaN window value at in Pass %d, Frame %d',pIndex,hIdx);
        end
        
        % Overlap and add.
        sIndex = (hIdx-1)*rHop.hopLength;
        synthStream(sIndex+1:sIndex+rHop.winLength) = synthStream(sIndex+1:sIndex+rHop.winLength) + windowedNoise;
        synthPasses(pIndex,sIndex+1:sIndex+rHop.winLength) = synthPasses(pIndex,sIndex+1:sIndex+rHop.winLength) + windowedNoise;
        
        
        
        %%
        if(debugPrint == 1)
            pFFT = sumsqr(rHop.intFFTMag*rHop.winLength/sqrt(rHop.fftLength));
            aFFT = sumsqr(noiseSig);
            aFFTWin = sumsqr(windowedNoise);
            dispStr = sprintf('Energy Before IFFT : %f, After IFFT : %f, After Window : %f',pFFT,aFFT,aFFTWin);
            disp(dispStr);
        end
        if(debugPlot == 1)
            cla(axes1);
            plot(axes1,windowedNoise,'k','DisplayName','Windowed Noise');
            
            cla(axes2);
            plot(axes2,synthStream,'k','DisplayName','Total Synthesized Noise');
            
            cla(axes3);
            xlim(axes3,[floor(rHop.bandLimitLow),ceil(rHop.bandLimitUp)]);
            plot(axes3,rHop.fVec,rHop.intFFTMag,'k','DisplayName','FFT from Params');
            plot(axes3,rHop.fVec,abs(fft(noiseSig,rHop.fftLength))/rHop.winLength,'r','DisplayName','FFT of Noise signal');
            plot(axes3,rHop.fVec,rHop.fftMag,'b','DisplayName','Original Noise FFT');
            pause(0.01);
        end
    end
end
%%
% if(debugPlot == 1)
%     disp('Showing Noise Pass 3');
%     
%     figure3 = figure;
%     axes3 = axes('Parent',figure3,'XMinorTick','on');
%     box(axes3,'on');
%     hold(axes3,'all');
%     grid on;
%     
%     nArray = chop(synthPasses(3,:),residualHops(3,1).stftParams);
%     
%     for hIdx = 1:numHops
%         rHop = residualHops(3,hIdx);
%         nHop = nArray(hIdx);
%         nHop.window('Hamming',0);
%         nFFT = nHop.doFFT(rHop.fftLength,rHop.fs);
%         cla(axes3);
%         xlim(axes3,[floor(rHop.bandLimitLow),ceil(rHop.bandLimitUp)]);
%         plot(axes3,rHop.fVec,rHop.intFFTMag,'k','DisplayName','FFT from Params');
%         plot(axes3,rHop.fVec,abs(nFFT()),'r','DisplayName','FFT of Noise signal');
%         plot(axes3,rHop.fVec,rHop.fftMag,'b','DisplayName','Original Noise FFT');
%         pause(0.2);
%     end
%     
% end
%%
end