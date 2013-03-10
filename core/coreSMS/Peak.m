classdef Peak < handle
    %PEAK This objects defines a peak by taking in three points near a
    %local maxima and interpolating to find the peak.
    %   Detailed explanation goes here
    
    properties
        
        binVal = 0;         %Value of the maxima point of UnNormalized FFT.
        binPhase = 0;       %Phase of the maxima point of UnNormalized FFT.
        binFreq = 0;        %Frequency of the maxima point.
        
        lVal = 0;           %Magnitude of the left neighbour maxima point of UnNormalized FFT.
        lPhase = 0;         %Phase of the left neighbour maxima point of UnNormalized FFT.
        lFreq = 0;          %Frequency of the left neighbout the maxima point.
        
        rVal = 0;           %Magnitude of the right neighbour maxima point of UnNormalized FFT.
        rPhase = 0;         %Phase of the right neighbour maxima point of UnNormalized FFT.
        rFreq = 0;          %Frequency of the right neighbout the maxima point.
        
        df   = 0;           %Frequency resolution.
        hopID = 0;          %HopID which this peak belongs to
        
        assigned = 0;       %Used to mark if a peak is already assigned to a guide.
        
        
        sPeakFreq = 0;      %Smoothened Peak Freq;  % TODO check set value
   
        peakLoc = 0;        %Interpolated peak location (index)
        peakFreq = 0;       %Interpolated peak frequency (Hz)
        peakValDB = 0;      %Interpolated peak amplitude in dB (db)
        peakVal = 0;        %Interpolated peak amplitude
     end
    
    methods
        function obj = Peak(freq,val,id,df)
            if (nargin == 4 && isstruct(freq))
                
                % Assuming peak needs to be interpolated
                
                obj.lFreq = freq.left;
                obj.lVal = val.left;
                
                obj.binFreq = freq.bin;
                obj.binVal = val.bin;
                
                obj.rFreq = freq.right;
                obj.rVal = val.right;
                 
                obj.df = df;
                
                % interpolate peak from data.
                [obj.peakFreq obj.peakValDB ~] = interpolatePeak(obj);
                obj.peakVal = 10^(obj.peakValDB/20);
                
                obj.hopID = id;
                % set the smoothened (using fguide) peak freq.
                obj.sPeakFreq = obj.peakFreq;
                
            elseif (nargin == 3 && ~isstruct(freq))
                
                % Assuming known peak is passed in (No df is passed-in).
                
                obj.binVal = val;
                %obj.binPhase = phase;
                
                obj.peakVal = obj.binVal;
                obj.peakValDB = 20*log10(obj.peakVal);
                obj.peakFreq = freq;      %Override Loc as Freq.
                
                obj.hopID = id;
                obj.sPeakFreq = obj.peakFreq;
                
            else
                
                warning('SMS:Peak','Uninitialized Peak');
                
            end
            
            if(obj.peakVal > 1)
                warning('SMS:Peak','Abnormaly High Peak Amplitude - %f',obj.peakVal);
            elseif (obj.peakVal < 0)
                warning('SMS:Peak','Abnormaly Low Peak Amplitude - %f',obj.peakVal);
            end
            
        end
        
        % Does quadratic interpolation on peak amplitude based on
        % neighbouring points
        function [peakLocV peakValV peakPhaseV] = interpolatePeak(obj)
            
            %TODO Input bounds check loc and phase.
            
            % interpolation is done in dBs. Quaratic interpolation on
            % kaiser windoed doesn't give perfect peak amplitudes, but
            % close enough.
            lValDB = 20*log10(obj.lVal);
            rValDB= 20*log10(obj.rVal);
            binValDB = 20*log10(obj.binVal);
            
            intLocDif = (lValDB - rValDB) ./ (2*(lValDB - 2*binValDB + rValDB));
            peakLocV = obj.binFreq + intLocDif*obj.df;
            peakValV = binValDB-((lValDB-rValDB).*intLocDif/4);
            
            %TODO Bound Check Output.
            
            diffphase = unwrap(obj.rPhase-obj.lPhase);
            peakPhaseV = obj.lPhase+intLocDif.*diffphase;
            
        end
        
        % setter function for peak value, does sanity checks.
        function set.peakVal(obj, peakVal)
            if peakVal>0 && peakVal<=1
                obj.peakVal = peakVal;
                obj.peakValDB =  20*log10(peakVal);
            end
        end
        
        % check if the peak is assigned.
        function isA = isAssigned(obj)
            isA = obj.assigned;
        end
        
        % assign the peak to a fGuide.
        function assign(obj)
            obj.assigned = 1;
        end
        
    end
    
end

