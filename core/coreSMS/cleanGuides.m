function [ guides ] = cleanGuides( guides, minPercentEnergy)
%CLEANGUIDES This function removes guides with low 'energy' level.
%   This function looks through all guides and removes those that
%   contribute less than a certain percentage of total 'energy'.
%   This function also forces all guides to sleep. In this function energy
%   is considered as the sumsquare of all peak amplitudes
% 
%   guides              - Array of FGuides.
%   minPercentEnergy    - Minimum percentage of total energy of guides allowed.
%   
%   guides              - Array of cleaned FGuides.
%
% Version : 0.1
% Date : 22/3/2011
% Author : Chinmay Pendharkar
% Notes : First hop function.

guideEnergy = zeros(1,length(guides));
%% Clean and Sleep all guides at the end.
for gIdx = 1:length(guides)
	cGuide = guides(gIdx);
    
    % TODO Add Bias with window length.
    % calculateb'energy' for each guide based on sum square of peak
    % amplitudes
	guideEnergy(gIdx) = sum(cell2mat({cGuide.peaks.peakVal}).^2);
    % Sleep all guides at the end.
	cGuide.sleep();
end

totalEnergy = sum(guideEnergy);
% Mark gudies which have low energy.
remVec = guideEnergy<totalEnergy*minPercentEnergy;
warning ('SMS:PeakTrack','Removing %d low energy guides out of %d guides',sum(remVec),length(guides));
% Remove marked guides.
guides(remVec) = [];

end

