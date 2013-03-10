classdef ResidualHop < Hop
    %RESIDUALHOP The Residual Hop extends the Hop class to add the
    %functionality of Residual Analysis.
    
    %   The Residual Hops encaplsuates the data for the Residual data in
    %   the SMS Analysis. It extends the Hop class and adds the
    %   functionality to extract parameters from Residual FFT data and also
    %   interpolate the parameters and generate a residual based noise
    %   data. Averaged critical band parameter scheme is used for
    %   parametrization
    
    properties
        
        residualEnvelope = 0;               % The parameterized FFT envelope of the residue
        envFreqVec = 0;                     % Frequency vectors corresponding to the envelope parameters
        
        intFFTMag = 0;                      % Interpolated FFT Magnitude calculated when interpolating the parameters for auralization.
        intFFTStream = 0;                   % The Interpolated FFT Stream with random phase attached to it.
        reGenNoise = 0;                     % Regeneated noise signal based on IFFT of the interpolated FFT Stream.
        
        bandLimitUp = 20000;                % Upper Bandlimit Frequency of the Residual Hop
        bandLimitLow = 20;                  % Upper Bandlimit Frequency of the Residual Hop
        
        bLimitedFFTMag = 0;                 % A bandlimited FFT Magnitude which only contains the FFT Data of the frequencies between the bandlimits
    end
    
    properties (SetAccess = private)
        
        % Used to decide if energy based scaling of output based on the
        % input is used.
        correctEnergy = 0;
        
    end
    
    methods
        
        function obj = ResidualHop(fftStream,stftParams,id)
            
            if  nargin ~= 3
                stftParams = 0;
                id = 0;
                warning('SMS:Hop','Uninitalized Residual Hop.');
            end
            % Initialize the parent.
            obj = obj@Hop(stftParams, id);
            
            if  nargin == 3
                obj.fftStream = fftStream;
                obj.fftMag = abs(fftStream);
            end
        end
        
        % Extract the envelope from the FFT Stream data based on the upper
        % and lower bandlimits.
        function [envParams envFreq] = genEnvelope(obj,bandLimitUp,bandLimitLow,Fs)
            
            obj.genFVec(Fs);
            obj.bandLimitUp = bandLimitUp;
            obj.bandLimitLow = bandLimitLow;
            
            % Only half of the spectrum as real signals have mirrored specturm. But
            % to keep the energy levels we multiply by sqrt two.
            halfFFTMag = obj.fftMag(1:end/2)*sqrt(2);
            
            % Band Limit the residual to the current passes freq limits.
            bLimitedIdx = obj.fVec(1:end/2)>obj.bandLimitLow & obj.fVec(1:end/2)<=obj.bandLimitUp;
            
            %Init
            obj.bLimitedFFTMag = zeros(1,obj.fftLength/2);
            obj.bLimitedFFTMag(bLimitedIdx) = halfFFTMag(bLimitedIdx);
            
            % Extract the envelope parameters from the bandlimited FFT
            % Stream.
            [obj.residualEnvelope, obj.envFreqVec] = obj.extractResParam(obj.bLimitedFFTMag);
            envParams = obj.residualEnvelope;
            envFreq = obj.envFreqVec;
            
        end
        
        % Extract the envelope parameters from the bandlimited FFT
        % Stream.
        function [resEnv, resFVec] = extractResParam(obj,residualFFT)
            
            fcMin = obj.fVec(1);
            fcMax = obj.fVec(end);
            
            % Generate critical band limits for frequency range of
            % interest.
            [lFreq , resFVec, hFreq] = critBands(fcMin, fcMax);
            
            resEnv = zeros(1,length(lFreq));
            
            % For each band, find the rms of FFT Magnitude
            for bIndex = 1:length(lFreq)
                validIdx = obj.fVec>lFreq(bIndex) & obj.fVec<=hFreq(bIndex);
                resEnv(bIndex) = sqrt(mean(residualFFT(validIdx).^2));
            end
        end
        
        % Generates noise from the parametertized residual envelope.
        function reGenNoise = generateNoise(obj, useEnv)
            
            if (useEnv == 1)
                % Interpolates the parameterized residual evelopes.
                obj.intFFTMag = obj.interpolateEnv(obj.residualEnvelope,obj.envFreqVec);
            elseif (useEnv == 0)
                obj.intFFTMag = [obj.bLimitedFFTMag obj.bLimitedFFTMag(1) fliplr(obj.bLimitedFFTMag(2:end))]/sqrt(2);
            end
            
            % Generates random phase to create the FFT Stream.
            rndPhaseReal = [0, pi-(2*pi*rand(1,obj.fftLength/2-1))];
            
            % Conjugate phase to mirror the FFT (targetting real signal)
            rndPhase = [rndPhaseReal 0 -fliplr(rndPhaseReal(2:end))];
            
            % Generate complex FFT data.
            obj.intFFTStream = obj.intFFTMag.*exp(1i*rndPhase);
            
            % IFFT on complex FFT data
            genNoise = ifft(obj.intFFTStream)*obj.winLength;
            
            if(~isreal(genNoise))
                warning('MATLAB:Hop','Unreal IFFT');
            end
            
            % Only output the 1st winLength data scaled to have equal
            % energy
            genNoise = genNoise(1:obj.winLength)*obj.fftLength/obj.winLength/2;
            
            % Do energy correction to match input and output energy by
            % scaling optput.
            if (obj.correctEnergy == 1)
                noiseEnergy = sumsqr(genNoise);
                if (noiseEnergy > 0)
                    fftEnergy = sumsqr(obj.bLimitedFFTMag*obj.winLength/sqrt(obj.fftLength));
                    energyRatio = sqrt(fftEnergy/noiseEnergy);
                    obj.reGenNoise = genNoise*energyRatio;
                    if(obj.debugPrint == 1)
                        dispStr = sprintf('Energy Ratio for Hop %d = %f',obj.id, energyRatio);
                        disp(dispStr);
                    end
                end
            else
                obj.reGenNoise = genNoise;
            end
            
            if(any(obj.audioStream > 1))
                warning('MATLAB:Hop','Unusually high IFFT result: Clipping');
                obj.audioStream(obj.audioStream > 1) = 1;
            end
            
            reGenNoise = obj.reGenNoise;
            
        end
        
        % Interpolates the parameter envelope of residuals.
        function [intFFTMag] = interpolateEnv(obj,resEnv,resFVec)
            
            % Init
            halfIntFFTMag = zeros(1,obj.fftLength/2);
            
            % Generate the critical band frequency vectors.
            fcMin = resFVec(1);
            fcMax = resFVec(end);
            [lFreq , cFreq, hFreq] = critBands(fcMin, fcMax);
            
            % Debug - mask synthesis of some bands.
            %critBandSpace =  [10,30,50,80,120,160,250,350,450,570,700,840,1000,1170,1370,1600,1850,2150,2500,2900,3400,4000,4800,5800,7000,8500,10500,13500,17500];
            bandMask =  [1,  1, 1, 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,   1,   1,   1,  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,    1,    1];
            mask = bandMask(cFreq == resFVec);
            resEnv = mask.*resEnv;
            
            % For each parameter
            for vecIndex = 1:length(hFreq);
                fIdx = find(obj.fVec >lFreq(vecIndex) & obj.fVec <= hFreq(vecIndex));
                if (~isempty(fIdx))
                    % Set all the FFT magnitudes in that critical band to
                    % the parameter value (assuming equal energy across critical band)
                    halfIntFFTMag(fIdx) = resEnv(vecIndex);
                end
            end
            
            % No zero gain.
            halfIntFFTMag(1) = 0;
            
            % Flip, mirror and scale (sqrt(2)) FFT magnitude to make it generate a
            % real signal.
            intFFTMag = [halfIntFFTMag halfIntFFTMag(1) fliplr(halfIntFFTMag(2:end))]/sqrt(2);
            
        end
        
        % Generates a hamming window scaled to a overlap and add window factor
        % to be used in overlap and add synthesis of the residuals.
        function windowMag = genNormWindow(obj,winLength)
            
            hamWin = sqrt(hamming(winLength,'periodic'))';
            overlapWinFac = mean(hamWin.^2)*2;
            windowMag = overlapWinFac*hamWin;
        end
        
    end
    
    
    
end