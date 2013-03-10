function saveReSynth(reSynth, reSynthDet, reSynthNoise,  cF, Fs)
% Saves Resynthesized Audio Stream to a file defined by the cF
% Structure

saveDebug = 0;

%% Time Stamp

wavwrite(reSynthDet,Fs,cF.rAudioDetfName);
wavwrite(reSynth,Fs,cF.rAudiofName);
wavwrite(reSynthNoise,Fs,cF.rAudioNoisefName);

if saveDebug == 1
    save(cF.debugFile,'cF');
end

end