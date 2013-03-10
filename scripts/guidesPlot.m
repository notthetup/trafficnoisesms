function guidesPlot(guides)
% GUIDESPLOT Plots FGudies.

%% Debug

% Plot only long guides
onlyLongGuides = 0;


%% Constants
fMax = 20000;

%%


figure1 = figure;
axes1 = axes('Parent',figure1,'XMinorTick','on');
box(axes1,'on');
hold(axes1,'all');
grid on;

if (strcmp(class(guides),'FGuide'))
    for gIdx = 1:length(guides)
        cGuide = guides(gIdx);
        gPeaks = cell2mat({cGuide.peaks.sPeakFreq});
        if(((onlyLongGuides ~= 1) || (length(gPeaks) > 1)) && (cGuide.cFreq < fMax))
            gPeakVal = cell2mat({cGuide.peaks.peakValDB});
            gPeakVal = cell2mat({cGuide.peaks.peakVal});
            pIndex = cGuide.startPos+(0:length(gPeaks)-1)*cGuide.hopLength;
            plot3(pIndex(2:end),gPeaks(2:end),gPeakVal(2:end),'*-');
        end
    end
end

% Create xlabel
xlabel({'Hop Index [-]'});

% Create ylabel
ylabel({'Frequency [Hz]'});

% Create zlabel
zlabel({'Peak Amplitude [dB]'});

% Title
title ('Frequency Guides');

end