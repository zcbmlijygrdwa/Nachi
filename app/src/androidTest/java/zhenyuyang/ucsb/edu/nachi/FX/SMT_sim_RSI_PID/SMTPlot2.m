clf


%disp(['Y:' num2str(yearIdx) ', mo:' num2str(monthIdx) ', D:' num2str(days) ', H:' num2str(hours)  ', sec:' num2str(frameCount) ', balance:' num2str(account.balance)  ', holds:' num2str(sellHolds+buyHolds) ', fps:' num2str(1/timeUsed)  ', lossNum:' num2str(numOfLoss)])
%figure(1)
subplot(5,1,1)
plot(balanceHistory)
xlim([1,length(data)]);
if(length(currentlossCutOff)>1)
    title(['practice: ' num2str(BenefitRatio) ': [' num2str(currentlossCutOff(traderLevelLeft+1)) ',' num2str(currentprofitCutOff) ']']);
end

subplot(5,1,2)
plot(data)
hold on
plot(filteredData)
if(length(IP_idx)~=0)
    plot(IP_idx,IP,'or'); %plot IP
end
hold off
xlim([1,length(data)]);

subplot(5,1,3)
plot(filteredData0Diff)
hold on
plot(filteredData1Diff)
plot(filteredData2Diff)
plot(filteredData3Diff)
plot(filteredData4Diff)
plot(ones(1,length(filteredData0Diff))*(1+RSI_threshold)*50,'k');
plot(ones(1,length(filteredData0Diff))*(1-RSI_threshold)*50,'k');
plot(ones(1,length(filteredData0Diff))*50,'k');
hold off
xlim([1,length(data)]);
ylim([0,100]);

subplot(5,1,4)
plot(RSIHitsPerWeekHist,'b');
hold on;
plot(ones(length(RSIHitsPerWeekHist),1)*PID_state.target,'k')
title('RSIHitsPerWeekHist')


subplot(5,1,5)
plot(PeriodHist,'k');
title('PeriodHist')


% figure(2),hist(filteredDataDiff,[min(filteredDataDiff):0.00001:max(filteredDataDiff)])
% [m,s] = normfit(filteredDataDiff);
% ml = m-1.96*s;
% mr = m+1.96*s;
% y = normpdf(filteredDataDiff,m,s);
% hold on;
% plot(filteredDataDiff,y,'.');
% hold off;
% title(['filteredDataDiff, ml:' num2str(ml) ',mr:' num2str(mr)]);
