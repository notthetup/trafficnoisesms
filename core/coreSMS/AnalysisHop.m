classdef AnalysisHop < Hop
    %ANALYIS HOP This class models of Analysis Hop of the SMS Algorithm.
    % This class extends the Hop class and adds the functionality for
    % Sinosoidal Analysis part of the SMS. It allows the hop data to
    % undergo peak detection outputs the peak data.
    
    properties(SetAccess=private)
        hRWindowFFT = 0;                    % Higher resolution Window FFT Data for derivated based peak detection.
        hRFVec = 0;                         % Frequency vector for Higher resolution Window FFT Data.
        normFFTMag = 0;                     % FFT Magnitude of the Hop used to calculate the residual.
        
        peaks = 0;                          % List of all peaks detected in this Hop
        
    end
    
    properties (Constant)
        
        hRFac = 128;                        % Multiplication factor for the Higher resolution Window FFT.
        
        useSimpleDet = 1;                   % Use the simple peak detection method.
        useDerivativeDet = 0;               % Use the derative peak detection method.
        
        plotWindow = 0;                     % Plots the audio stream data along with the window data.
        debugFullFFT = 0;                   % Plots entire FFT instead of the positive half.
        
    end
    
    methods
        
        function obj = AnalysisHop(inStream,stftParams, id)
            if  nargin ~= 3
                stftParams = [];
                id = [];
                warning('SMS:Hop','Uninitalized Analysis Hop.');
            end
            % Initialize the parent class.
            obj = obj@Hop(stftParams, id);
            
            if  nargin == 3
                obj.audioStream = inStream;
                obj.fftMag = 0;
                
                % Generate start and end positions in the total audio
                % stream
                obj.streamStartPos = (id-1)*length(inStream);
                obj.streamEndPos = id*length(inStream);
            end
            
        end
        
        % Generates high resolution FFT data of the window. This is used in
        % the derative peak detection algorithm.
        function wMag = windowFFTMag(obj,freq)
            
            hrfft = obj.hRFac*obj.fftLength;
            if (length(obj.hRWindowFFT) ~= hrfft)
                winFFT = fft(obj.windowData,hrfft);
                obj.hRWindowFFT = winFFT/length(obj.windowData);
                obj.hRFVec = (1:(hrfft/2))*obj.fs/hrfft;
            end
            [~, freqIdx] = min(abs(obj.hRFVec-freq));
            wMag = abs(obj.hRWindowFFT(freqIdx));
            
        end
        
        % This method yields the FFT Magnitude of this Hop
        function normFFTMag = getNormFFT(obj,fftLength)
            
            % FFT Magnitude Normalized with Window Power Gain.
            
            obj.window('Hamming',0);
            %obj.normFFTMag = abs(obj.doFFT(fftLength,obj.fs))/obj.incPwrGain;
            obj.normFFTMag = abs(obj.doFFT(fftLength,obj.fs));
            normFFTMag = obj.normFFTMag;
        end
        
        % This method analyzes the Hop audio stream using one of the two
        % methods and stores all the peaks it can find in the peaks Array.
        function peakAnalyze(obj,Fs,fftLength,peakDetectParams)
            
            if(obj.debugPrint == 1)
                dispStr = sprintf('Analysing Hop : %d',obj.id);
                disp(dispStr);
            end
            
            % Use a simple quadratic peak detetection algorithm.
            if(obj.useSimpleDet == 1)
                obj.window('kaiser',0.5);
                obj.doFFT(fftLength,Fs);
                obj.peaks = sMSPeakDetectSimple(obj,peakDetectParams);
            % Use a derivative based peak detection algorithm.
            elseif (obj.useDerivativeDet == 1)
                obj.window('hann',2.5);
                obj.doFFT(fftLength,Fs);
                obj.peaks = sMSPeakDetectDerivative(obj,peakDetectParams);
            end
            %%
            %             obj.window('kaiser',10);
            %             obj.doFFT(N,Fs);
            %             tPeaks = SMSPeakDetectSimple(obj,peakDetectParams);
            %             obj.peaks = tPeaks;
            %             obj.plot();
            %
            %             obj.window('hann',2.5);
            %             obj.doFFT(N,Fs);
            %             dPeaks = SMSPeakDetectDerivative(obj,peakDetectParams);
            %             obj.peaks = dPeaks;
            %             obj.plot();
            %             %obj.peaks = tPeaks;
            %
            %             oPeakFreq = cell2mat({dPeaks.peakFreq});
            %             nPeakFreq = cell2mat({tPeaks.peakFreq});
            %             oPeakVal = cell2mat({dPeaks.peakVal});
            %             nPeakVal = cell2mat({tPeaks.peakVal});
            %             dPeakFreq = oPeakFreq-nPeakFreq;
            %             dPeakVal = oPeakVal./nPeakVal;
            %
            %             for index = 1:length(dPeakVal)
            %                 dispStr = sprintf('Diff #%d: %fHz : %f',index,dPeakFreq(index),dPeakVal(index));
            %                 disp(dispStr);
            %             end
            %%
            if(obj.debugPlot == 1)
                obj.plot();
            end
            
        end
        
        % Plots the FFT Magnitude and the Peaks detected in the Hop.
        function []  = plot(obj)
            
            if(obj.plotWindow == 1)
                
                figure1 = figure;
                axes1 = axes('Parent',figure1,'XMinorTick','on');
                box(axes1,'on');
                hold(axes1,'all');
                grid on;
                
                
                plot1 = plot(obj.audioStream);
                set(plot1,'DisplayName','Original Stream','Color','Black');
                
                plot2 = plot(obj.windowData);
                set(plot2,'DisplayName','Window','Color','Cyan');
                
                plot3 = plot(obj.windowedStream);
                set(plot3,'DisplayName','Windowed Stream','Color','Blue');
                
                % Create xlabel
                xlabel({'Index [-]'});
                
                % Create ylabel
                ylabel({'Amplitude [-]'});
                
                % Title
                title ('Time Domain Streams');
                
                % Create legend
                legend1 = legend(axes1,'show');
                set(legend1,'FontSize',12,'Location','NorthWest');
                
                saveas(figure1,'hopTestStream.fig')
            end
            
            
            figure2 = figure(42);
            clf;
            axes2 = axes('Parent',figure2,'XScale','log','XMinorTick','on');
            box(axes2,'on');
            hold(axes2,'all');
            grid on;
            
            tFftMag = abs(obj.fftStream);
            
            if(obj.debugFullFFT == 1)
                oIndex = [obj.fVec(ceil(obj.fftLength/2):end), obj.fVec(1:floor(obj.fftLength/2)-1)];
                offtMag = [tFftMag(ceil(obj.fftLength/2):end) tFftMag(1:floor(obj.fftLength/2)-1)];
            else
                oIndex = obj.fVec(1:floor(obj.fftLength/2)-1);
                offtMag = tFftMag(1:floor(obj.fftLength/2)-1)*2;
                
            end
            
            plot(oIndex,20*log10(offtMag),'--k');
            
            
            if(~isempty(obj.peaks) && isobject(obj.peaks))
                for idx = 1:length(obj.peaks)
                    cPeak = obj.peaks(idx);
                    plot(cPeak.peakFreq,cPeak.peakValDB,'xb','LineWidth',2);
                end
            end
            
            % Create xlabel
            xlabel({'Frequency [Hz]'});
            
            % Create ylabel
            ylabel({'Amplitude [dB]'});
            
            xlim([20 22000]);
            
            % Title
            titleStr = sprintf('FFT for Hop #%d',obj.id);
            title (titleStr);
            
            % Create legend
            legend2 = legend('FFT of Windowed Stream','Peaks');
            set(legend2,'FontSize',12,'Location','NorthEast');
            
            saveas(figure2,'hopTestStream.fig')
            
        end
    end
    
end

