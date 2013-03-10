function [ lFreq cFreq hFreq  ] = critBands(lowFreq, highFreq)
%CRITBANDS This function generates the center and cutoff frequencies for ERB
%Bands
%
%   Detailed explanation goes here


%critBandSpace =  [50,150,250,350,450,570,700,840,1000,1170,1370,1600,1850,2150,2500,2900,3400,4000,4800,5800,7000,8500,10500,13500,17500];
%cutOffFreq = [20,100,200,300,400,510,630,770,920,1080,1270,1480,1720,2000,2320,2700,3150,3700,4400,5300,6400,7700,9500,12000,15500,20000];
%critBandSpace =  [10,50,150,250,350,450,570,700,840,1000,1170,1370,1600,1850,2150,2500,2900,3400,4000,4800,5800,7000,8500,10500,13500];
%cutOffFreq = [1,20,100,200,300,400,510,630,770,920,1080,1270,1480,1720,2000,2320,2700,3150,3700,4400,5300,6400,7700,9500,12000,15500];
%critBandSpace =  [10,30,50,80,120,160,250,350,450,570,700,840,1000,1170,1370,1600,1850,2150,2500,2900,3400,4000,4800,5800,7000,8500,10500];
%cutOffFreq =    [0,20,40,65,100,140,200,300,400,510,630,770,920,1080,1270,1480,1720,2000,2320,2700,3150,3700,4400,5300,6400,7700,9500,12000];
critBandSpace =  [10,30,50,80,120,160,250,350,450,570,700,840,1000,1170,1370,1600,1850,2150,2500,2900,3400,4000,4800,5800,7000,8500,10500,13500,17500];
cutOffFreq =    [0,20,40,65,100,140,200,300,400,510,630,770,920,1080,1270,1480,1720,2000,2320,2700,3150,3700,4400,5300,6400,7700,9500,12000,15500,20000];
%critBandSpace =  [30,80,150,250,350,450,570,700,840,1000,1170,1370,1600,1850,2150,2500,2900,3400,4000,4800,5800,7000,8500];
%cutOffFreq = [20,50,100,200,300,400,510,630,770,920,1080,1270,1480,1720,2000,2320,2700,3150,3700,4400,5300,6400,7700,9500];


cFreqIdx = find(critBandSpace>=lowFreq & critBandSpace<=highFreq);

cFreq = critBandSpace(cFreqIdx)';
lFreq = cutOffFreq(cFreqIdx)';
hFreq = cutOffFreq(cFreqIdx+1)';

end

