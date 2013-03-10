function [audioT Fs] = loadAudio( cF )
% LOADAUDIO Loads audio based on the cF Structure

%% Debug
debugPrint = 1;
debugCF = 1;

%% Load Audio
[audio, Fs] = wavread(cF.lFName);
% Trucate
audioT = audio(ceil(length(audio)*cF.truncFac(1))+1:floor(length(audio)*cF.truncFac(2)),1);
% Normlalize
%audioT = 0.90*(audioT/max(audioT));

if(debugPrint == 1)
    disp(['Loading... ' cF.lFName]);
    dispStr = sprintf('Length of audio is %.2fs',length(audioT)/Fs);
    format shortg;
    disp(dispStr);
end

cF.Fs = Fs;

if(debugCF == 1)
    cF.audio = audioT;
    cF.Fs = Fs;
end


end