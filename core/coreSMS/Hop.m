classdef Hop < handle
    %HOP This class models of fundamental hop of the SMS Algorithm. It
    %encapsulates the handling of the audio stream and the STFT
    %calculations.
    %
    
    properties(SetAccess=protected)
        audioStream = 0;                    % Original Audio
        id = 42;                            % Hop ID.
        
        stftParams                          % Short Time Fourier Transform Parameters
        
        hopLength = 256;                    % Hop Length
        winLength = 1024;                   % Window Length
        fftLength = 2048;                   % FFT Length (>2*winLength)
        
        fs = 2048;                          % Sampling Freq
        df = 0;                             % Frequency resolution
        
        winType = 'kaiser';                 % Window Type
        winParam = 0;                       % Window Parameters
        windowData = 0;                     % Window Magnitude
        windowedStream = 0;                 % Windowed Stream
        
        incPwrGain = 0;                     % Incoherent Power gain of Window
        cohPwrGain = 0;                     % Coherent Power gain of Window
        
        fftStream = 0;                      % FFT Stream
        fftMag = 0;                         % FFT Magnitude
        fVec = 0;                           % Frequency Vector for FFT.
           
        streamStartPos = 0;                 % Start Position of hop in stream
        streamEndPos = 0;                   % End Position of hop in stream
        
        active = 0;                         % 0 - inactive, 1 - active;
    end
    
    %%Params
    properties (Constant)
     
        %debugPlot = 1                       % Enables plotting of debug information.
        debugPlot = 0;
        debugPrint = 0;                      % Enables the printing of debug information
                
    end
    
    methods
        function obj = Hop(stftParams, id)
            if  nargin == 2 && isstruct(stftParams) && isnumeric(id)
                
                obj.stftParams = stftParams;
                
                if(stftParams.winLength > 0)
                    obj.winLength = stftParams.winLength;
                else
                    warning('SMS:Hop','Unacceptable Window length, using 1024');
                end
                
                if(stftParams.hopLength > 0)
                    obj.hopLength = stftParams.hopLength;
                else
                    warning('SMS:Hop','Unacceptable Hop Size, using 256');
                end
                
                if(stftParams.fftLength > 0)
                    obj.fftLength = stftParams.fftLength;
                else
                    warning('SMS:Hop','Unacceptable FFT Size, using 2048');
                end
                
                if(id > 0)
                    obj.id = id;
                else
                    warning('SMS:Hop','Unacceptable Hop ID, using 42');
                end
                
                obj.active = 1;
            else
                warning('SMS:Hop','Uninitalized Hop.');
            end
            
            obj.df = obj.fs/obj.fftLength;
        end
        
        function aStream = get.audioStream(obj)
            aStream = obj.audioStream;
        end
        
        % Used to detect if the hop is actually being used or is an empty
        % unintialized hop.
        function act = isActive(obj)
            act = obj.active;
        end
        
        % Windows the audio stream data and saves the windowed data.
        function wStream = window(obj,wType,wParam)
            obj.winType = wType;
            obj.winParam = wParam;
            
            % Choose the types of windows.
            switch(obj.winType)
                case 'kaiser'
                    obj.windowData = kaiser(obj.winLength,obj.winParam(1));
                case 'blackman'
                    obj.windowData = blackmanharris(obj.winLength,'periodic');
                case 'Hamming'
                    obj.windowData = hamming(obj.winLength,'periodic');
                case 'hann'
                    obj.windowData = hann(obj.winLength,'periodic');
                case 'gauss'
                    obj.windowData = gausswin(obj.winLength);
                otherwise
                    warning('SMS:Hop:Windowing','Unknown Window Type, Kaiser used instead.');
                    obj.windowData = kaiser(obj.winLength,obj.winParam(1));
            end
            
            obj.windowedStream = obj.audioStream.*obj.windowData';
            % Generates Incoherent Power Gain for the window.
            obj.incPwrGain = mean(obj.windowData.^2);
            % Generates Coherent Power Gain for the window.
            obj.cohPwrGain = mean(obj.windowData)^2;
            wStream = obj.windowedStream;
        end
        
        % Performs an FFT on the audio stream.
        function fStream = doFFT(obj,N,Fs)
            
            obj.fftLength = N;
            obj.genFVec(Fs);
            
            % Normalized FFT to same level as input.
            obj.fftStream = fft(obj.windowedStream,N)/length(obj.windowedStream);
            obj.fftMag = abs(obj.fftStream);
            fStream = obj.fftStream;
        end
        
        % Performs an IFFT on the FFT Stream.
        function aStream = doIFFT(obj,Fs)
            
            obj.genFVec(Fs);
            
            % Normalized back to the original level based on the original
            % FFT normalization.
            obj.audioStream = ifft(obj.fftStream)*length(obj.windowedStream);
            aStream = obj.audioStream;
        end
        
        % Generates a Frequency Vector for the FFT data based on the STFT and Sampling
        % Frequency.
        function fVec = genFVec(obj,Fs)
            obj.fs = Fs;
            obj.df = Fs/obj.fftLength;
            obj.fVec = obj.df*(0:obj.fftLength-1);
            fVec = obj.fVec;
        end
        
        
    end
    
end

