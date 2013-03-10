clear all;
close all;
clc


%% find all audio file in recordings folder
listAll = dir('./recordings/*.wav');
%%
fNames = char(listAll.name);
nFiles = size(fNames,1);

%nFiles = 1;

%% for each file

for fIndex = 1:nFiles
    audioFile = fNames(fIndex,:);
    if(strcmp(audioFile,'buss_39_gear4_cal-trimmed.wav') == 1)
        continue;
    end
    dotIndex = find(audioFile == '.',1,'last');
    audioFile = audioFile(1:dotIndex-1);
    eval('default_config');
    runSMS(cF);
    pause;

end

