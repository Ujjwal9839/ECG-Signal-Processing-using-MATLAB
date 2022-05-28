clear all
close all
clc

Fs = 360; % Sampling Frequency
Fnotch = 0.67; % Notch Frequency
BW = 5; % Bandwidth
Apass = 1; % Bandwidth Attenuation
[b, a] = iirnotch (Fnotch/ (Fs/2), BW/(Fs/2), Apass);
Hd = dfilt.df2 (b, a);

load ('100m.mat');
ecgsig = val/200;
t = 0:length(ecgsig)-1;
tx = t./Fs;

subplot (4, 1, 1), plot(tx,ecgsig), title ('ECG Signal with baseline wander'), grid on
y0=filter (Hd, ecgsig);
subplot (4, 1, 2), plot(tx,y0), title ('ECG signal with low-frequency noise (baseline wander) Removed'), grid on

Fnotch = 50; % Notch Frequency
BW = 50; % Bandwidth
Apass = 1; % Bandwidth Attenuation
[b, a] = iirnotch (Fnotch/ (Fs/2), BW/ (Fs/2), Apass);
Hd1 = dfilt.df2 (b, a);
y1=filter (Hd1, y0);
subplot (4, 1, 3), plot (tx,y1), title ('ECG signal with power line noise Removed'), grid on

d = fdesign.lowpass('Fp,Fst,Ap,Ast',0.4,0.5,1,80);
Hd2 = design(d,'equiripple');
y2 = filter(Hd2,y1);
subplot(4,1,4)
plot(tx,y2),title('ECG Signal with high frequency noise removed'), grid on

wt = modwt(y2,4,'sym4');
wtrec = zeros(size(wt));
wtrec(3:4,:) = wt(3:4,:);

y3 = imodwt(wtrec,'sym4');
y3 = abs(y3).^2;
avg = mean(y3);
[Rpeaks,locs] = findpeaks(y3,t,'MinPeakHeight',8*avg,'MinPeakDist',50);
nohb = length(locs);
timelimit = length(ecgsig)/Fs;
hbpermin = (nohb*60)/timelimit;
disp(strcat('Heart Rate = ',num2str(hbpermin)))

figure
plot(t,y3)
grid on
xlim([0,length(ecgsig)])
hold on
plot(locs,Rpeaks,'^r');
xlabel('samples'), title(strcat('Rpeaks found and Heart Rate : ',num2str(hbpermin)))



