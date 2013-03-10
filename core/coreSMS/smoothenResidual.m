function [residualHops] = smoothenResidual(residualHops)
%SMOOTHENRESIDUAL This function smoothens the parameter stream of Residual Hops.
%   This function considers the a specific band parameters of the array of
%   Residual Hops and smoothen them using a Savitzky-Golay Filter, to
%   reduce harshness caused by fluctuating noise amplitude levels
%
%
%   residualHops - Array of Residual Hops.
%
% Version : 0.1
% Date : 22/3/2011
% Author : Chinmay Pendharkar
% Notes : First hop function.
%

%% Debug

debugPlot = 1;

%% Constants

% Savitzky-Golay Filtering coefficients
polOrd = 2;
filtOrd = 19;

% List of critical bands to be smoothened.
bandMask = [17500];

%% Init
if debugPlot == 1
    figure1 = figure;
    axes1 = axes('Parent',figure1,'XMinorTick','on');
    box(axes1,'on');
    hold(axes1,'all');
    xlabel('Time');
    yLabel('Amplitude');
    grid on;
end

%%

% Numbers for initialization
numHops = length(residualHops);
numBands = length(residualHops(1).residualEnvelope);

validIdx = [];

% Find valid hops. Ignore empty Hops.
for hIdx = 1:numHops
    if (length(residualHops(hIdx).residualEnvelope) > 1)
        validIdx(end+1) = hIdx;
    end
end

numValidHops = length(validIdx);

% Array of Valid Hop Parameters.
envParams = cell2mat({residualHops(validIdx).residualEnvelope});
envParamsMat = reshape(envParams,numBands,numValidHops);

% For each band
for bIdx = 1:numBands
    
    % If band is in the list
    if (any(bandMask == residualHops(1).envFreqVec(bIdx)))
        % generate smoothened parameters
        smoothenedParams = sgolayfilt(envParamsMat(bIdx,:),polOrd,filtOrd);
        
        % Update smoothened parameters to Hops.
        for hIdx = 1:numValidHops
            residualHops(hIdx).residualEnvelope(bIdx) = smoothenedParams(hIdx);
        end
        
        %%
        if debugPlot == 1
            cla(axes1);
            plot(axes1,envParamsMat(bIdx,:),'r','DisplayName','Orig');
            plot(axes1,smoothenedParams,'k','DisplayName','Smoothened');
            titStr = sprintf('Band #%d - %fHz',bIdx,residualHops(1).envFreqVec(bIdx));
            title(axes1,titStr);
            pause(0.5);
        end
        %%
    end
end




end