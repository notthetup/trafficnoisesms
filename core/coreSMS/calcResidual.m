function [residualHops] = calcResidual(inputStream,synthPasses,stftParams,pDParams,Fs)
%CALCRESIDUAL This function calculates the residuals from the synthesized
%deterministic stream and original audio stream.
%   This function takes the original audio and the synthesized
%   deterministic stream as inputs. The residue is calculated per hop for
%   each of the passes along the original stream. The residue is
%   encapsulated in ResidualHops and parameterized.
%
%   inputStream        - Input Vector of audio data.
%   synthPasses        - Array of Synthesized audio per pass.
%   stftParams         - Array of the Short Term Fourier Transform
%                         parameter per hop.
%   pDParams           - Array of the Peak Detection parameter per hop.
%   Fs                 - Sampling Frequency.
%   
%   residualHops       - Array of Residual Hops.
%
% Version : 0.1
% Date : 22/3/2011
% Author : Chinmay Pendharkar
% Notes : First hop function.

%% Debug
debugPlot = 0;
debugPrint = 0;

%% Init
% Max number of hops in all the passes
maxHops = floor(length(inputStream)/min(cell2mat({stftParams.hopLength})));
% Initialize the residualHops Array.
residualHops = ResidualHop.empty(0,maxHops);

%%
if(debugPlot == 1)
    figure1 = figure;
    axes1 = axes('Parent',figure1,'XScale','log','XMinorTick','on');
    box(axes1,'on');
    %xlim([0 5000]);
    %xlim([0 max(fVec)]);
    hold(axes1,'all');
    grid on;
    
    % Create xlabel
    xlabel(axes1,{'Frequency [Hz]'});
    % Create ylabel
    ylabel(axes1,{'Amplitude [-]'});
    
    figure2 = figure;
    axes2= axes('Parent',figure2,'XScale','log','XMinorTick','on');
    box(axes2,'on');
    xlim([0 5000]);
    %xlim([0 max(fVec)]);
    hold(axes2,'all');
    grid on;
    % Create xlabel
    xlabel({axes2,'Frequency [Hz]'});
    % Create ylabel
    ylabel(axes2,{'Amplitude [-]'});
    
    
    figure3 = figure;
    axes3= axes('Parent',figure3,'XMinorTick','on');
    box(axes3,'on');
    %xlim([0 5000]);
    %xlim([0 max(fVec)]);
    hold(axes3,'all');
    grid on;
    % Create xlabel
    xlabel({axes3,'Time [s]'});
    % Create ylabel
    ylabel(axes3,{'Amplitude [-]'});
    
end

%%
% Loop over each pass
for passIndex = 1:size(synthPasses,1)
    
    dispStr = sprintf('Calculating Residuals for pass #%d',passIndex);
    disp(dispStr);
    
    tStftParams = stftParams(passIndex);
    
    % Frequency limits for the pass.
    passLowFreq = pDParams(passIndex).pFreqMin;
    passHighFreq = pDParams(passIndex).pFreqMax;
    
    % Chop input and synth stream using the same STFT Parameters.
    hArray = chop(inputStream,tStftParams);
    sArray = chop(synthPasses(passIndex,:),tStftParams);
    
    
    % Per Hop
    for hIndex = 1:length(hArray)
        if(debugPrint == 1)
            dispStr = sprintf('Calculating Residuals for hop #%d',hIndex);
            disp(dispStr);
        end
        tStftParams = stftParams(passIndex);
        sHop = sArray(hIndex);
        tHop = hArray(hIndex);
        % Get FFT Magnitude of both (original and synth) the Hops
        tFFT = tHop.getNormFFT(tStftParams.fftLength);
        sFFT = sHop.getNormFFT(tStftParams.fftLength);
        
        % Subtract to get residual.
        rFFTMag = tFFT-sFFT;
        % Set negetive residual magnitude to 0.
        rFFTMag(rFFTMag<0) = 0;
        % Create Residual Hop.
        rHop = ResidualHop(rFFTMag,tStftParams,hIndex);
        % Parameterize Residual Hop.
        [evnParam evnFreq] = rHop.genEnvelope(passHighFreq,passLowFreq,Fs);
        residualHops(passIndex,hIndex) = rHop;
        
        %%
        if(debugPlot == 1)
            
            fVec = Fs/tStftParams.fftLength*(0:tStftParams.fftLength/2-1); % Real Spectrum
            iRParams = rHop.interpolateEnv(evnParam,evnFreq);
            
            %p1
            cla(axes2);
            plot(axes2,fVec,abs(sFFT(1:end/2)),'r','DisplayName','SynthDet');
            plot(axes2,fVec,abs(tFFT(1:end/2)),'k','DisplayName','Original');
            plot(axes2,fVec,rFFTMag(1:end/2),'g','DisplayName','Residual');
            % Title
            titleStr = sprintf('Residual Calc FFT for Hop #%d',hIndex);
            title (axes2,titleStr);
            %pause(0.2);
            
            
            %p4
            cla(axes1);
            plot(axes1,fVec,rFFTMag(1:end/2),'k','DisplayName','Residual FFT');
            plot(axes1,evnFreq,evnParam,'--xr','DisplayName','Residual Params');
            plot(axes1,fVec,iRParams(1:end/2),'b','DisplayName','Regen Residual Params');
            % Title
            titleStr = sprintf('Parameter Estimation for Hop #%d',hIndex);
            title (axes1,titleStr);
            
            %p4
            rndPhaseReal = [0, pi-(2*pi*rand(1,tStftParams.fftLength/2-1))];
            rndPhase = [rndPhaseReal 0 -fliplr(rndPhaseReal(2:end))];
            reIntNoiseSpec = iRParams.*exp(1i*rndPhase);
            reFFTIFFT = abs(fft((ifft(reIntNoiseSpec)*tStftParams.winLength),rHop.fftLength))/tStftParams.winLength;
            cla(axes3);
            plot(axes3,fVec,reFFTIFFT(1:end/2),'r','DisplayName','ReFFT');
            plot(axes3,fVec,rHop.bLimitedFFTMag,'b','DisplayName','Original Noise FFT');
            pause(0.01);
        end
        
        if(debugPrint == 1)
            iRParams = rHop.interpolateEnv(evnParam,evnFreq);
            enRParams = sum((iRParams(1:end/2)*2).^2);
            enResFFT = sum(rHop.bLimitedFFTMag.^2);
            %enRParams = sum(rHopMag.^2);
            dispStr = sprintf('Orig Energy : %f, Param Energy %f, Diff = %0.2f%%',enResFFT,enRParams,((enResFFT-enRParams)/enResFFT)*100);
            format short;
            disp(dispStr);
            
            
        end
        
    end
end

end