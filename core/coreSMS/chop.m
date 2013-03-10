function [ hopArray paddedLength] = chop( inputStream, stftParams)
%CHOP This function chops the input audio into a series of hops and return
%an array of hops.
%   This function chops the input audio into a series of hops and returns
%   an array of hop objects.
%
%   inputStream - Input Vector of audio data.
%   winLength           - Window Length
%   hopLenghth  - Hop Length ( hopLength < N ).
%
% Version : 0.1
% Date : 22/3/2011
% Author : Chinmay Pendharkar
% Notes : First hop function.
%

%% Init
% Original Stream Length.
oStreamLength = length(inputStream);
% Number of Hops to generate.
numHops = ceil((oStreamLength-stftParams.winLength)/stftParams.hopLength)+1;
% Initialize Hop array.
hopArray = AnalysisHop.empty(0,numHops);

hopID = 1;
%%

for cIndex = 1:stftParams.hopLength:oStreamLength
    eIndex = cIndex+stftParams.winLength-1;
    if(eIndex > oStreamLength)
        % For the last hop, pad with the remaining with zeros.
        hopArray(hopID) = AnalysisHop([inputStream(cIndex:end) zeros(1,stftParams.winLength-(length(inputStream)-cIndex+1))],stftParams,hopID);
        break;
    else
        hopArray(hopID) = AnalysisHop(inputStream(cIndex:eIndex),stftParams,hopID);
        hopID = hopID + 1;
    end
end

paddedLength = ((length(hopArray)-1)*stftParams.hopLength)+stftParams.winLength;

end

