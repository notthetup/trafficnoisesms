classdef FGuide < handle
    %TRAJECTORY This class defines a frequency guide
    %   The class encapsulates a Frequency guide. It handles the creation,
    %   advancement and synthesis of a Frequency Guide for SMS.
    
    
    properties(SetAccess=private)
        
        peaks;                  % List of peaks in this tracjectory
        
        status = 'uninit';      % 'uninit','active','sleeping','expired', 'stale';
        
        sleepTimer = 0;         % counter to keep a count of how long the guide has been sleeping
        
        cFreq = 0;              % Current Freq
        nFreq = 0;              % Next Freq
        
        cMag = 0;               % Current Mag
        
        startHop = 0;           % Starting HopID
        lastHop = 0;            % Last known HopID.
        
        hopLength = 0;          % Hop Length;
        
        alpha = 0.5             % Trajectory Weight 1 = Use Peak; 0 = use trajectory.
        
        startPos = 0;           % Absolute Position of the start of the fGuide.
        endPos = 0;             % Absolute Position of the end of the fGuide.
        
        maxSleep = 20;          % Default Maximum Sleep value.
        
        sleepyPeaks = 0;        % Number of 'peaks' where the guide is in sleep state
        activePeaks = 0;        % Numver of 'peaks' where the guide is in active state.
        
    end
    
    %%Params
    properties(Constant)
        minMaxSleep = 2;
    end
    
    methods
        
        % Creates a FGuide object.
        function obj = FGuide(alpha,hopLength,maxSleep)
            if nargin == 2
                obj.alpha = alpha;
                obj.hopLength = hopLength;
            elseif nargin == 3
                obj.alpha = alpha;
                obj.hopLength = hopLength;
            end
            
            % Atleast sleep for minMaxSleep;
            if maxSleep >= obj.minMaxSleep
                obj.maxSleep = maxSleep;
            else
                obj.maxSleep = obj.minMaxSleep;
            end
            
        end
        
        % State transition for advancing the guide with the peakP
        function advance(obj, peakP)
            % Depending on current status, decide on action
            switch(obj.status)
                % if uninit, initialize the peak.
                case 'uninit'
                    obj.addPeak(peakP);
                    obj.activePeaks = obj.activePeaks +1;
                    obj.status = 'active';
                    % if active, add the new peak
                case 'active'
                    obj.addPeak(peakP);
                    obj.activePeaks = obj.activePeaks +1;
                    % if asleep, wake up and add new peak
                case 'sleeping'
                    obj.status = 'active';
                    obj.sleepTimer = 0;
                    obj.addPeak(peakP);
                    obj.activePeaks = obj.activePeaks +1;
                    % Interpolate magnitude of sleepy 'peaks'.
                    obj.interpolatePrevious();
                case 'expired'
                    %TODO Warn
                otherwise
                    %TODO Warn
                    
            end
        end
        
        % State transition for sleeping guide.
        function sleep(obj)
            % Depending on current status, decide on action
            switch(obj.status)
                case 'uninit'
                    %TODO Warn
                % if active, put it to sleep.
                case 'active'
                    obj.sleepTimer = 0;
                    obj.status = 'sleeping';
                    obj.addPeak(Peak(obj.cFreq,0,obj.lastHop+1));
                    obj.sleepyPeaks= obj.sleepyPeaks +1;
                % if asleep, keep sleeping or expire.
                case 'sleeping'
                    if(obj.sleepTimer >= obj.maxSleep)
                        obj.status = 'expired';
                        obj.removeEndSleep();
                    else
                        obj.sleepTimer = obj.sleepTimer + 1;
                        obj.addPeak(Peak(obj.cFreq,0,obj.lastHop+1));
                        obj.sleepyPeaks= obj.sleepyPeaks +1;
                    end
                case 'expired'
                    %TODO Warn
                otherwise
                    %TODO Warn
                    
            end
        end
        
        % add new peak to peak array
        function addPeak(obj, peakP)
            % for first peak
            if(isempty(obj.peaks))
                obj.peaks = peakP;
                pFreq = peakP.peakFreq;
                obj.cFreq = peakP.peakFreq;
                
                obj.startHop = peakP.hopID;
                obj.lastHop = peakP.hopID;
                
                obj.startPos = ((obj.startHop-1)*obj.hopLength)+1;
                obj.endPos = (obj.lastHop*obj.hopLength);
            else
                obj.peaks(end+1) = peakP;
                if(peakP.hopID > obj.lastHop)
                    obj.lastHop = peakP.hopID;
                    obj.endPos = (obj.lastHop*obj.hopLength);
                end
                %Trajectory calculation
                pFreq = obj.cFreq;
                obj.cFreq = obj.alpha*(peakP.peakFreq-obj.nFreq)+obj.nFreq;
                peakP.sPeakFreq = obj.cFreq;
                
            end
            obj.cMag = peakP.peakVal;
            obj.nFreq = obj.cFreq + (obj.cFreq-pFreq);
            if(obj.cMag > 1)
                warning('MATLAB:fGuides','Unusually high peak magnitude for Hop:%d, f=%fHz',peakP.hopID,obj.cFreq);
            end
        end
        
        % removes the last few sleeping 'peaks' to make guides shorter
        function removeEndSleep(obj)
            for idx = length(obj.peaks):-1:1
                if (obj.peaks(idx).peakVal ~=0)
                    break;
                end
            end
            obj.peaks = obj.peaks(1:idx+1);
            obj.lastHop = obj.peaks(end).hopID;
            obj.endPos = (obj.lastHop*obj.hopLength);
        end
        
        % synthezie the guide
        function gSynthStream = synth(obj,Fs)
            % expire the guide.
            obj.status = 'expired';
            % remove the last few sleeping guides
            removeEndSleep(obj);
            % if empty, set the synthezied stream to zero.
            if(isempty(obj.peaks) || length(obj.peaks) < 2)
                gSynthStream = 0;
            else
                % Interpolate all the peak magnitudes
                magInt = obj.interpolateMag(cell2mat({obj.peaks.peakVal}));
                if(magInt(end)> 0.001)
                    warning('MATLAB:fGuide','fGuide Final Mag not zero');
                end
                % Interpolate all the phases based on peak frequencies
                [phaseInt ~] = obj.interpolatePhase(2*pi*cell2mat({obj.peaks.sPeakFreq}),Fs);
                % Generate stream by making tones based on calculated magnitude and
                % phase
                gSynthStream = magInt.*cos(phaseInt);
            end
            
        end
        
        % This function interpolates the magnitude of all the peaks for
        % synthsis and gives an array of magtinute stream
        function intMag = interpolateMag(obj, peakMag)
            % Init
            intMag = zeros(1,length(peakMag)*obj.hopLength);
            
            for pIdx = 1:length(peakMag) % per peak
                for mIdx = 1:obj.hopLength      % per sample
                    cIdx = (pIdx-1)*obj.hopLength+mIdx;
                    % first peak: ramp up from 0
                    if(pIdx == 1)
                        intMag(cIdx) = ((peakMag(pIdx)))*mIdx/obj.hopLength;
                    % next peaks: liner interpolation from previous to current
                    else
                        intMag(cIdx) = peakMag(pIdx-1) + ((peakMag(pIdx)-peakMag(pIdx-1)))*mIdx/obj.hopLength;
                    end
                end
            end
        end
        
         % This function interpolates the frequency of all the peaks for
        % synthesis and gives an array of phase stream
        function [intPhase intFreq] = interpolatePhase(obj, peakFreq,Fs)
            
            intFreq = zeros(1,length(peakFreq)*obj.hopLength);
            
            for pIdx = 1:length(peakFreq) % per peak
                for mIdx = 1:obj.hopLength      % per sample
                    cIdx = (pIdx-1)*obj.hopLength+mIdx;
                    % first peak: ramp up from 0
                    if(pIdx == 1)
                        intFreq(cIdx) = ((peakFreq(pIdx)))*mIdx/obj.hopLength;
                    % next peaks: liner interpolation from previous to current
                    else
                        intFreq(cIdx) = peakFreq(pIdx-1) + ((peakFreq(pIdx)-peakFreq(pIdx-1)))*mIdx/obj.hopLength;
                    end
                end
            end
            
            intPhase = cumsum(intFreq)/Fs;
            
        end
        
        %This function interpolates the magnitude of peaks when the guide
        %just wakes up. This ensure that if the guide sleeps for a short
        %time, the magnitude doesn't have to go to 0 and then back up. This
        %is done to smoothen out artifacts.
        function interpolatePrevious(obj)
            
            % Step back and look for start of sleep
            for idx = 1:length(obj.peaks)-1
                if (obj.peaks(end-idx).peakVal ~=0)
                    break;
                end
            end
            
            % If only sleeping for small number of 'peaks', interpolate
            % magnitude between last active sleep and current peak.
            if(idx < 6)
                intLength = idx-1;
                intInc = (obj.peaks(end).peakVal - obj.peaks(end-idx).peakVal)/intLength;
                for pIndex = intLength:-1:1
                    obj.peaks(end-pIndex).peakVal = obj.peaks(end-idx).peakVal+(intLength-pIndex)*intInc;
                end
            end
            
        end
        
    end
    
end
