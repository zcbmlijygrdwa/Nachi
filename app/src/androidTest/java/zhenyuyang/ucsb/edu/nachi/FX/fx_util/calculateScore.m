

figure(2)

subplot(3,1,1)
plot(weeklyData_profit,'k');
title('weeklyData-profit')

subplot(3,1,2)
plot(weeklyData_orderNumberPerMo,'k');
title('weeklyData-orderNumberPerMo')

subplot(3,1,3)
plot(weeklyData_orderAverageTime,'k');
title('weeklyData-orderAverageTime')




BenefitRatioHistory(BenefitRatioHistory==0) = [];
figure(),hist(BenefitRatioHistory,[0.5:0.0001:1.05])
title('BenefitRatioHistory')


figure()
hist(traderLevelLeftHist);
title('traderLevelLeftHist')

figure(),hist(filteredDataDiff,[min(filteredDataDiff):0.00001:max(filteredDataDiff)])
[m,s] = normfit(filteredDataDiff);
y = normpdf(filteredDataDiff,m,s);
hold on;
plot(filteredDataDiff,y,'.');
hold off;
title(['filteredDataDiff, ml:' num2str(ml) ',mr:' num2str(mr)]);



minBR = min(BenefitRatioHistory);
tradingDurationHistory(tradingDurationHistory==0) = [];
if(sellHolds~=0||buyHolds~=0)
    tradingDurationHistory = [tradingDurationHistory (frameCount - tradingStart)];
end
% tradingDurationHistoryTop = sort(tradingDurationHistory);
% tradingDurationHistoryTopHours = tradingDurationHistoryTop(end-5:end)/3600
figure(),hist(tradingDurationHistory,[-5:1:20])

%score calculation
% if((abs(sellHolds)+abs(buyHolds))==0&&length(minBR)>0&&minBR>0.6&&int32(max(tradingDurationHistory)/3600)<48)
%     score = balance+minBR*10+double(10/(1+int32(max(tradingDurationHistory)/3600)));
% else
%     score = 0;
%     disp('0 score!');
% end

