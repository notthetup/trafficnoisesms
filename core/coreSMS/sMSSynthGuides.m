function [synthStream synthPasses] = sMSSynthGuides(guides,sP,Fs)
%SMSSYNTHRESIDUAL This synthesizes the frequency guides into an audio stream.
%   This function takes an array of frequency guides and generates the
%   deterministic audio stream from them using smooth phase estimation and
%   amplitude smoothing.
%
%   guides - An array of all frequency guides.
%   sP     - STFT Parameter structure.
%   Fs     - Sampling Frequency.
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

%%

% End stream index for guide which runs till the end (used to initialize
% arrays).
[lastGuideEPos ~]= max(cell2mat({guides.endPos}));

synthStream = zeros(1,lastGuideEPos);
synthPasses = zeros(length(sP),lastGuideEPos);
%gSynthStore = zeros(length(guides),lastHop*maxHLength);

%%
if(debugPlot == 1)
    figure1 = figure(22);
    clf(figure1);
    axes1 = axes('Parent',figure1,'XMinorTick','on');
    box(axes1,'on');
    hold(axes1,'all');
    grid on;
    
    
    figure2 = figure(23);
    clf(figure2);
    axes2 = axes('Parent',figure2,'XMinorTick','on');
    box(axes2,'on');
    hold(axes2,'all');
    grid on;
end
%%

if (strcmp(class(guides),'FGuide'))
    for gIdx = 1:length(guides)
        %%
        if(debugPrint == 1)
            dispStr = sprintf('Synthesizing Guide : %d',gIdx);
            disp(dispStr);
        end
        %%
        cGuide = guides(gIdx);
        % Synthesize this guide.
        gSynth = cGuide.synth(Fs);
        % Global start index of synthesized stream.
        sIndex = cGuide.startPos;
        % Global end index of synthesized stream.
        eIndex = cGuide.endPos;
        % Overlap and add to the final combined stream.
        synthStream(sIndex:eIndex) =  synthStream(sIndex:eIndex) + gSynth;
        % Add to the individual pass audio stream.
        for passIndex = 1:length(sP)
            if(cGuide.hopLength == sP(passIndex).hopLength)
                synthPasses(passIndex,sIndex:eIndex) =  synthPasses(passIndex,sIndex:eIndex) + gSynth;
                break;
            end
        end
%%        
        if(debugPlot == 1)
            cla(axes2);
            plot(axes1,synthStream,'k');
            plot(axes2,gSynth,'r');
            titleStr = sprintf('Synth fGuide #%d',gIdx);
            title(axes2,titleStr);
            pause(0.5);
        end
    end
end


end