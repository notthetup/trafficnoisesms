clear all;
close all;
clc

%% constants
datestrlen = 22;

repeatfactor = 2;

outfolder = './ltestplay/';

fs = 44100;

%% categories

catFName(1,1:4) = 'otto';
catFName(2,1:2) = 'vd';
catFName(3,1:2) = 'iv';
catFName(4,1:4) = 'buss';


catSize = size(catFName,1);



%% find all audio file in recordings folder
listall = dir('./ltest/*.wav');
%%
fnames = char(listall.name);
[nfiles fnamesize] = size(fnames);

totalplays = nfiles*repeatfactor;
catFile = zeros(1,nfiles);

for fIndex = 1:nfiles
    for catIndex = 1:catSize
        if (~isempty(strfind(fnames(fIndex,:),deblank(catFName(catIndex,:)))))
            catFile(fIndex) = catIndex;
            break;
        end
    end
end

%init
soundplayorder(1:totalplays,:) = ' ';

%nfiles = 1;

%% for each file randomize play location.
for catIndex = 1:catSize
    thisCatFiles = sum(catFile == catIndex);
    thisCatPlays = thisCatFiles*repeatfactor;
    thisCatfNames = fnames(catFile == catIndex,:);
    if (catIndex == 1)
        thisCatStart = 0;
    else
        thisCatStart = lastCatEnd;
    end
    lastCatEnd = thisCatStart + thisCatPlays;
    for rindex = 1:repeatfactor
        for findex = 1:thisCatFiles

            randtry = 0;
            playindex = thisCatStart+round(rand(1)*(thisCatPlays-1))+1;

            while (strcmp(soundplayorder(playindex),' ') == 0)
                playindex = thisCatStart+round(rand(1)*(thisCatPlays-1))+1;
                randtry = randtry + 1;
                if (randtry > thisCatPlays*2)
                    warning('sms:maketestfile','too many tries. check file numbers');
                    break;
                end
            end

            soundplayorder(playindex,1:fnamesize) = thisCatfNames(findex,:);

        end
    end
end

%% rename files and save key.
mkdir(outfolder);

save([outfolder datestr(now,'dd-mmm-yyyy_HH-MM-SS') '_filenamekey.mat'],'soundplayorder');


for playindex = 1:size(soundplayorder,1)
    %for playindex = 1:1
    copyfile(['./ltest/' strtrim(soundplayorder(playindex,:))],[outfolder 'ltestfile' num2str(playindex,'%02d') '.wav']);

    if(playindex == size(soundplayorder,1))
        disp('done');
    end
end



