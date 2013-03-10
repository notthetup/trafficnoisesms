clear all;
close all;
clc

%% Constant

trimLength = 5;


%% find all audio file in recordings folder
listAll = dir('./orig_rec/buss_*.wav');
%listAll = dir('./orig_rec/_*.wav');
%%
fNames = char(listAll.name);
nFiles = size(fNames,1);

%nFiles = 1;

%% for each file

for fIndex = 1:nFiles
    tFile = fNames(fIndex,:);
%     if(isempty(strfind(tFile,'buss')))
%         continue;
%     end
    audioFile = strtrim(['./orig_rec/' tFile]);
    [audio Fs] = wavread(audioFile);
    aLength = length(audio(:,1));
    aTime = aLength/Fs;

    if aTime > trimLength
        trimSamples = floor((aTime-trimLength)*Fs);

        figure(1);plot(0:1/Fs:aTime-1/Fs,audio(:,1));
        [gIX gIY] = ginput(1);
        gIX = round(gIX*Fs);

        if gIX+(trimLength*Fs/2) < aLength && gIX-(trimLength*Fs/2) > 0
            trimAudio = audio(gIX-floor(trimLength*Fs/2):gIX+floor(trimLength*Fs/2),1);
        elseif gIX+(trimLength*Fs/2) > aLength
            trimAudio = audio(trimSamples:end,1);
        else
            trimAudio = audio(1:trimLength*Fs,1);
        end
        disp(['Removed ' num2str(trimSamples) ' samples from ' audioFile]);
        figure(2);plot(0:1/Fs:(length(trimAudio)-1)/Fs,trimAudio); axis tight
    end

    dotIndex = find(tFile == '.',1,'last');
    fName = tFile(1:dotIndex-1);
    sFilename = ['./recordings/' fName '-trimmed.wav'];

    wavwrite(trimAudio,Fs,24,sFilename);

end

