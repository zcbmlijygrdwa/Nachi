close all
clear all


addpath('../fx_util')
addpath('../../../../../../../../../../../matlabplugins')
addpath('../../../../../../../../../../../fx_EUR_USD_tick')



yearIdx = 2015;
monthIdx = 2;
[sellRaw,buyRaw] = textread(['EURUSD-' num2str(yearIdx) '-' num2mon(monthIdx) '_converted.txt'],'%f %f');


plot(sellRaw);
hold on;
plot(buyRaw);