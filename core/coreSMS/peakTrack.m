function [guides] = peakTrack(hArray,peakTrackParams,maxGuides,guideIncFactor,guideSleepLength)
%PEAKTRACK This function tracks peaks through an array of hops.
%   This functio takes in an arry of peaks and assigns them to FGuides
%   according to the peak tracking algorithm.
%
%   hArray          - Array of Analyzed Hops.
%   peakTrackParams - Structure of Peak Tracking Parameter.
%   maxGuides       - Maximum Number of Guides allowed.
%   guideIncFactor  - Factor to increase the number of guides by through
%                       the peak tracking.
%   guideSleepLength - Amount of Hops, a guide is allowed to sleep.
%
%   guides          - Array of FGuides
%
% Version : 0.1
% Date : 22/3/2011
% Author : Chinmay Pendharkar
% Notes : First hop function.
%

%% Debug

debugPrint = 0;
% Switch to use Critical Band based Maximum Subsequent Peak Seperation or a constant.
useCritBWMax = 1;


%%
%incGuides = 0.1;    % Add slowly increase the number of guides.
incGuides = guideIncFactor;

%Init Guides
guides = FGuide.empty(0,maxGuides);

% Maximum Seperation between subsequent Peaks
maxDiff = floor(((peakTrackParams.pFreqMax)-(peakTrackParams.pFreqMin))/peakTrackParams.nPeaks/2);

% Alpha smoothing factor for FGuide advancement
alpha = peakTrackParams.alpha;

% Initial Maximum guid value.
iMaxGuides = maxGuides;

% For each Hop
for index = 1:length(hArray)
    
    if(debugPrint == 1)
        dispStr = sprintf('Tracking Hop : %d',index);
        disp(dispStr);
    end
    
    tHop = hArray(index);
    
    % Capture Peak data of each Hop
    tPeaks = [1:length(cell2mat({tHop.peaks.peakFreq})); cell2mat({tHop.peaks.peakFreq}); cell2mat({tHop.peaks.peakValDB})]';
    
    % for each frame
    % go through list of all fguides
    if (strcmp(class(guides),'FGuide'))
        % for each guide
        
        % reorder guides by amplitude.
        
        %[~, oIdx] = sort(cell2mat({guides.cMag}));
        oIdx = 1:length(guides);
        
        for gIdx = 1:length(oIdx)
            % if no peaks left, sleep guide and continue.
            if(size(tPeaks,1) <= 0)
                guides(oIdx(gIdx)).sleep();
                continue;
            end
            cGuide = guides(oIdx(gIdx));
            
            % define Maximum Seperation between subsequent Peaks
            if(useCritBWMax == 1)
                tMaxDiff = findCritBW(cGuide.nFreq,peakTrackParams.cBandsNormFac);
            else
                
                tMaxDiff = maxDiff;
            end
            
            % only if guide is active or sleeping
            if (strcmp(cGuide.status,'active') || strcmp(cGuide.status,'sleeping'))

                % Sort all valid guides by amplitude
                validPeaks = tPeaks(abs(tPeaks(:,2)-cGuide.nFreq)<=tMaxDiff,:);
                
                
                % if none found, sleep the guide and continue to next guide
                if length(validPeaks) <= 0
                    cGuide.sleep();
                    continue;
                end
                
                [sortPeakDiff, sortPeakIdx ] = sort(validPeaks(:,3),'ascend');
                
                %find guides within tMaxDiff and assign the tallest peak to
                %the guide (tallest = least dB)
                for pIndex = 1:length(sortPeakIdx)
                    cloPeakIdx = sortPeakIdx(pIndex);
                    cloPeakDiff = sortPeakDiff(pIndex);
                    if(cloPeakDiff <= tMaxDiff)
                        if(~tHop.peaks(validPeaks(cloPeakIdx,1)).isAssigned())
                            % Found unassigned close peak
                            cGuide.advance(tHop.peaks(validPeaks(cloPeakIdx,1)));
                            tHop.peaks(validPeaks(cloPeakIdx,1)).assign();
                            % Delete Peak from the list.
                            tPeaks(tPeaks(:,1) == validPeaks(cloPeakIdx,1),:) = [];
                            break;
                        end
                    else
                        % if not found within tMaxDiff, sleep guide
                        cGuide.sleep();
                        break;
                    end
                end
                % if no peak found at the end of the loop
                if pIndex == length(sortPeakIdx) && (cGuide.lastHop ~= index)
                    cGuide.sleep();
                end
            end
        end
    end
    
    % Add to max guides as number of hops increases. Add all by 3/4 total
    % hop length
    if (index < 3*length(hArray)/4)
        iMaxGuides = iMaxGuides + 4*incGuides/3;
    end
    
    %% Start new guides with rest of peaks.
    if (length(guides) <= iMaxGuides)
        for pIdx = 1:length(tHop.peaks)
            cPeak = tHop.peaks(pIdx);
            % if peak not assigned and still space for more guides
            if(~cPeak.isAssigned() && length(guides) <= iMaxGuides)
                nGuide = FGuide(alpha,tHop.hopLength,guideSleepLength);
                nGuide.advance(cPeak);
                guides(end+1) = nGuide;
            end
        end
    end
    
end


end


