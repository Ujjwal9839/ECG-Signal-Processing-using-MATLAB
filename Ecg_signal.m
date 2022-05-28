clear all
close all
clc

load ('100m.mat');
Ecgsignal = val/200;
Fs = 360;
t = (0:length(Ecgsignal)-1)/Fs;
subplot(2,1,1)
plot(t,Ecgsignal)


wt = modwt(Ecgsignal,4,'sym4');
wtrec = zeros(size(wt));
wtrec(3:5,:) = wt(3:5,:);

y3 = imodwt(wtrec,'sym4');

subplot(2,1,2)
plot(t,y3)