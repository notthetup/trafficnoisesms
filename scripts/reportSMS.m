function reportSMS(reSynth, reSynthDet,reSynthNoise, cF)
%This function analyzes and plots the difference between the input audio
%and the reSynthe audio.

%% Debug
debugPlotRandomHop = 0;

%% Init
stftIndex = 1;


%%

hArrayOrig = chop(cF.debug.inputStream,cF.sP(stftIndex));
hArrayReSynthNoise = chop(reSynthNoise,cF.sP(stftIndex));
hArrayReSynthDet = chop(reSynthDet,cF.sP(stftIndex));
hArrayReSynth =  chop(reSynth,cF.sP(stftIndex));

hopID = floor(rand*length(hArrayReSynthNoise));

%%

if(debugPlotRandomHop == 1)
    
    figure2 = figure();
    clf;
    axes2 = axes('Parent',figure2,'XScale','log','XMinorTick','on');
    box(axes2,'on');
    hold(axes2,'all');
    grid on;
    
    fftLength = cF.sP(stftIndex).fftLength;
    Fs = cF.Fs;
    hFFTIndex = floor(fftLength/2)-1;
    
    origHop = hArrayOrig(hopID);
    noiseHop = hArrayReSynthNoise(hopID);
    detHop = hArrayReSynthDet(hopID);
    synthHop = hArrayReSynth(hopID);
    
    origHop.window('kaiser',0.5);
    origHopMag = abs(origHop.doFFT(fftLength,Fs));
    origHopEnergy = sum(origHopMag.^2);
    
    fVec = origHop.fVec(1:hFFTIndex);
    
    noiseHop.window('kaiser',0.5);
    noiseHopMag = abs(noiseHop.doFFT(fftLength,Fs));
    noiseHopEnergy = sum(noiseHopMag.^2);
    
    detHop.window('kaiser',0.5);
    detHopMag = abs(detHop.doFFT(fftLength,Fs));
    detHopEnergy = sum(detHopMag.^2);
    
    synthHop.window('kaiser',0.5);
    synthHopMag = abs(synthHop.doFFT(fftLength,Fs));
    synthHopEnergy = sum(synthHopMag.^2);
    
    plot(fVec,origHopMag(1:hFFTIndex),'r');hold on;
    plot(fVec,noiseHopMag(1:hFFTIndex),'k')
    plot(fVec,detHopMag(1:hFFTIndex),'b')
    plot(fVec,synthHopMag(1:hFFTIndex),'g')
    
    dispEnergy = sprintf('Orig Energy = %f; \n Noise Energy = %f; \n Det Energy = %f; \n Synth Energy = %f',origHopEnergy,noiseHopEnergy,detHopEnergy,synthHopEnergy);
    disp(dispEnergy);
    
    % Create xlabel
    xlabel({'Frequency Index [-]'});
    
    % Create ylabel
    ylabel({'Amplitude [dB]'});
    
    % Title
    titleStr = sprintf('FFT for Hop #%d',hopID);
    title (titleStr);
    
    %ylim([0, 1000]);
    
    % Create legend
    legend2 = legend('Original Stream','ReSynth Noise','ReSynth Det','ReSynth Final');
    set(legend2,'FontSize',12);
    
    %saveas(figure2,'hopTestStream.fig')
    
end


%% plot spectrograms.

winSize = 4096*8;
ovLap = round(winSize*0.75);
nFFT = winSize*8;
%%
figure1 = figure();
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
axes1 = axes('Parent',figure1,'YScale','log','CLim',[-250 -60]);
%view(270,115);
hold(axes1,'all');
ylim([20 20000]);
[y,f,t,p] = spectrogram(cF.debug.inputStream,winSize,ovLap,nFFT,cF.Fs);
%spectrogram(cF.inputStream(:,1),8192,7000,8192*16,cF.Fs);
surf(axes1,t,f,20*log10(abs(p)),'EdgeColor','none');
colorbar('peer',axes1);
%axis xy; axis tight; colormap(jet); %view(0,90);
colormap('gray');
view(90,85);
title('Original Audio');
ylabel('Frequency [Hz]');
xlabel('Time [s]');
h = get(gca, 'title');
set(h,'FontSize',16);
h = get(gca, 'xlabel');
set(h,'FontSize',14);
h = get(gca, 'ylabel');
set(h,'FontSize',14);
colorbar('off'); 
colorbar('WestOutside');
set(gca,'ztick',[]);
saveas(gcf,'spec_orig','png');
pause(1);
%%
figure1 = figure();
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
axes1 = axes('Parent',figure1,'YScale','log','CLim',[-250 -60]);
%view(270,115);
hold(axes1,'all');
ylim([20 20000]);
[y,f,t,p] = spectrogram(reSynth,winSize,ovLap,nFFT,cF.Fs);
surf(axes1,t,f,20*log10(abs(p)),'EdgeColor','none');
colorbar('peer',axes1);
%axis xy; axis tight;
colormap('gray');
view(90,85);
title('ReSynth Final Audio');
ylabel('Frequency [Hz]');
xlabel('Time [s]');
h = get(gca, 'title');
set(h,'FontSize',16);
h = get(gca, 'xlabel');
set(h,'FontSize',14);
h = get(gca, 'ylabel');
set(h,'FontSize',14);
colorbar('off'); 
colorbar('WestOutside');
set(gca,'ztick',[]);
saveas(gcf,'spec_resynth','png');
pause(1);
%%
% figure1 = figure();
% axes1 = axes('Parent',figure1,'YScale','linear','CLim',[-300 -60]);
% hold(axes1,'all');
% [y,f,t,p] = spectrogram(reSynthDet,winSize,ovLap,nFFT,cF.Fs);
% surf(axes1,t,f,20*log10(abs(p)),'EdgeColor','none');
% colorbar('peer',axes1);
% axis xy; axis tight; colormap(jet); %view(0,90);
% title('ReSynth Deterministic Audio');
% ylabel('Frequency [Hz]');
% xlabel('Time [s]');
% view(270,115);
% pause(1);
% %%
% figure1 = figure();
% axes1 = axes('Parent',figure1,'YScale','log','CLim',[-300 -60]);
% hold(axes1,'all');
% [y,f,t,p] = spectrogram(reSynthNoise,winSize,ovLap,nFFT,cF.Fs);
% surf(axes1,t,f,20*log10(abs(p)),'EdgeColor','none');
% colorbar('peer',axes1);
% axis xy; axis tight; colormap(jet); %view(90,90);
% title('ReSynth Noise Audio');
% ylabel('Frequency [Hz]');
% xlabel('Time [s]');
% view(270,115);
% pause(0.5);



end