N = 1024*4;


wav = wavread('buss_91_gear8_left.wav');
x = wav((end/2)+(1:N));
wind = ones(1,N)';
x_wind = x.*wind;


%figure; plot(x_wind);
figure;

x_padded = [x_wind;zeros(1,N)'];

subplot(2,2,1); plot(x_padded,'k');
xlabel('Time Index','FontSize',12);
ylabel('Amplitude','FontSize',12);
title('Padded Signal','FontSize',14);
%%

X = fft(x_padded)/N;

subplot(2,2,2); semilogx(abs(X(1:end/2)),'k');
xlabel('Frequency Index','FontSize',12);
ylabel('Amplitude','FontSize',12);
title('Magnitude Spectrum of the Padded Signal','FontSize',14);
%%

x_r = ifft(X*N);

subplot(2,2,3); plot(x_r,'k');
xlabel('Time Index','FontSize',12);
ylabel('Amplitude','FontSize',12);
title('Inverse Fourier Transform of the Spectrum','FontSize',14);
%%

rndPhaseReal = [0, pi-(2*pi*rand(1,(2*N)/2-1))];
rndPhase = [rndPhaseReal 0 -fliplr(rndPhaseReal(2:end))]';

X_r =abs(X).*exp(1i*rndPhase);

%figure; semilogx(abs(X_r(1:end/2)));

x_rr = ifft(X_r*N);

subplot(2,2,4); plot(x_rr,'k');
xlabel('Time Index','FontSize',12);
ylabel('Amplitude','FontSize',12);
title('Inverse Fourier Transform of the Spectrum with randomized phase','FontSize',14);



clear all