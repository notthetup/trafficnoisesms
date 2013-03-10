function [adjStream] = padStream(inStream, targetLength)
%PADSTREAM This function adjusts a stream size for targetLength padding or
%truncating if necessary.
%
%   This function adjusts a stream size for targetLength padding or
%   truncating if necessary.
%
%   inStream        - Input Vector of audio data.
%   targetLength    - Target length of the final outputStream
%
% Version : 0.1
% Date : 22/3/2011
% Author : Chinmay Pendharkar
% Notes : First hop function.

%% Debug

%%

[numStreams strmLength] = size(inStream);
adjStream = zeros(numStreams,targetLength);


for strIndex = 1 :numStreams
    
    if(strmLength>targetLength)
        adjStream(numStreams,:) = inStream(strIndex,1:targetLength);
    else
        adjStream(strIndex,1:strmLength) = inStream(strIndex,1:strmLength);
    end
    
end

end