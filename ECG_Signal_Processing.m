clear all
close all
clc

Fs = 360; % Sampling Frequency

load ('100m.mat');
ecgsig = val/200;
t = 0:length(ecgsig)-1;
tx = t./Fs;

subplot (4, 1, 1), plot(tx,ecgsig), title ('ECG Signal with artifacts'), grid on

[C, L] = wavedec (ecgsig,9,'bior3.7'); % Decomposition 
a9 = wrcoef ('a', C, L,'bior3.7',9); % Approximate Component
d9 = wrcoef ('d', C, L,'bior3.7',9); % Detailed components
d8 = wrcoef ('d', C, L,'bior3.7',8);
d7 = wrcoef ('d', C, L,'bior3.7',7);
d6 = wrcoef ('d', C, L,'bior3.7',6);
d5 = wrcoef ('d', C, L,'bior3.7',5);
d4 = wrcoef ('d', C, L,'bior3.7',4);
d3 = wrcoef ('d', C, L,'bior3.7',3);
d2 = wrcoef ('d', C, L,'bior3.7',2);
d1 = wrcoef ('d', C, L,'bior3.7',1);
y0= d9+d8+d7+d6+d5+d4+d3+d2+d1;
subplot (4,1,2), plot(tx,y0), title ('ECG Signal after baseline wander REMOVED'), grid on

Fnotch = 50; % Notch Frequency
BW = 100; % Bandwidth
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
wtrec(3:5,:) = wt(3:5,:);

y3 = imodwt(wtrec,'sym4');
avg = abs(mean(y3));
[Rpeaks,locs_r] = findpeaks(y3,t,'MinPeakHeight',0.2,'MinPeakDist',50);
nohb_r = length(locs_r);
    
for i = 1:nohb_r
    Speaks(i) = min(y3(locs_r(i):locs_r(i)+15));
    locs_s(i) = find(y3==Speaks(i))-1;
end

for i = 1:nohb_r
    Qpeaks(i) = min(y3(locs_r(i)-15:locs_r(i)));
    locs_q(i) = find(y3==Qpeaks(i));
end

for i = 1:nohb_r
    Ppeaks(i) = max(y3(locs_q(i)-60:locs_q(i)));
    locs_p(i) = find(y3==Ppeaks(i));
end

for i = 1:nohb_r
    if locs_s(i) + 130 <= 3600
        Tpeaks(i) = max(y3(locs_s(i):locs_s(i)+130));
        locs_t(i) = find(y3==Tpeaks(i));
    else
        break
    end
end

timelimit = length(ecgsig)/Fs;
hbpermin = (nohb_r*60)/timelimit;
disp(strcat('Heart Rate = ',num2str(hbpermin)))

figure
plot(t,y3)
grid on
xlim([0,length(ecgsig)])
hold on
plot(locs_r,Rpeaks,'^r');
plot(locs_s,Speaks,'xm')
plot(locs_q,Qpeaks,'*g')
plot(locs_p,Ppeaks,'om')
plot(locs_t,Tpeaks,'pk')
xlabel('samples')
legend('','Rpeaks','Speaks','Qpeaks','Ppeaks','Tpeaks')
title(strcat('PQRST Detection and Heart Rate : ',num2str(hbpermin)))

