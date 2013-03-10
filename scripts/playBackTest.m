function playBackTest(cF)
% PLAYBACKTEST Plays back the original and synthesized audio based on the
% cF structure

%% Debug

debugPlayInit = 1;
debugPlaySynthDet = 1;
debugPlaySynth = 1;

debugPlayBackDeprop = 1;

%% Init
index = 1;

disp('Playing back Synthesis');

%% Playback Audio
if(debugPlayInit == 1)
    [audio, Fs] = wavread(cF.lFName);
    audio = audio(floor(end*cF.truncFac(1))+1:floor(end*cF.truncFac(2)),1);
    nAudio = audio;
    p{index} = audioplayer(nAudio, Fs);
    tM(index) = (length(nAudio)/Fs);
    index = index+1;
end

%% Test ReSynth
if(debugPlaySynthDet == 1)
    [reSynthDet, Fs] = wavread(cF.rAudioDetfName);
    nReSynthDet = reSynthDet;
    p{index} = audioplayer(nReSynthDet, Fs);
    tM(index) = length(nReSynthDet)/Fs;
    index = index+1;
end

%% Test ReSynth
if(debugPlaySynth == 1)
    [reSynth, Fs] = wavread(cF.rAudiofName);
    nReSynth = reSynth;
    p{index} = audioplayer(nReSynth, Fs);
    tM(index) = length(nReSynth)/Fs;
end


if(debugPlaySynth == 1 || debugPlaySynthDet == 1 || debugPlayInit == 1)
    for pId = 1:index
        play(p{pId});
        pause(tM(pId));
        stop(p{pId});
    end
end

%% Test ReSynth
if(debugPlayBackDeprop == 1)
    
    [audio, Fs] = wavread(cF.lFName);
    audio = audio(floor(end*cF.truncFac(1))+1:floor(end*cF.truncFac(2)),1);
    nAudio = audio;
    
    [reSynth, Fs] = wavread(cF.rAudiofName);
    nReSynth = reSynth;
    
    pc = audioplayer([nAudio(1:9*end/10); nReSynth(end/10:end)], Fs);
    tM = length([nAudio; nReSynth])/Fs;
    play(pc);
    pause(tM);
end


end