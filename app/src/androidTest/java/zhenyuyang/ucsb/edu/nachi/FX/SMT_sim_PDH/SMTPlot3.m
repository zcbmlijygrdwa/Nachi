clf


%disp(['Y:' num2str(yearIdx) ', mo:' num2str(monthIdx) ', D:' num2str(days) ', H:' num2str(hours)  ', sec:' num2str(frameCount) ', balance:' num2str(account.balance)  ', holds:' num2str(sellHolds+buyHolds) ', fps:' num2str(1/timeUsed)  ', lossNum:' num2str(numOfLoss)])
%figure(1)
subplot(6,2,1:2)
plot(balanceHistory)
%if(length(currentlossCutOff)>1)
title(['practice: ' num2str(BenefitRatio) ': [' num2str(currentlossCutOff) ',' num2str(currentprofitCutOff) ']']);
%end
xlim([1,length(data)]);

subplot(6,2,3:4)
%interested points
IP = [];
if(ifPlot&&length(IP_idx)~=0)
    IP = data(IP_idx);
end
plot(data)
hold on
plot(filteredData)
plot(filteredData2)
if(length(IP_idx)~=0&&length(IP)~=0)
    plot(IP_idx,IP,'or'); %plot IP
end
hold off
xlim([1,length(data)]);

subplot(6,2,5:6)
plot(filteredDataDiff)
hold on
plot(filteredDataDiff2)
hold off
xlim([1,length(filteredDataDiff2)]);

minD = min([min(filteredDataDiff),ml]) - 0.00001;
maxD = max([max(filteredDataDiff),mr]) + 0.00001;


subplot(6,2,[7,9])
[m,s] = normfit(filteredDataDiff);
y = normpdf(filteredDataDiff,m,s);
h2 = histogram(filteredDataDiff,[minD:0.000001:maxD]);
hold on;
h1 = histogram([ones(int32(max(h2.BinCounts)),1)*ml;ones(int32(max(h2.BinCounts)),1)*mr],[minD:0.000002:maxD],'FaceColor','r','EdgeColor','r');
y = (y/max(y))*max(h2.BinCounts);
plot(filteredDataDiff,y,'.');
h3 = histogram([ones(int32(max(h2.BinCounts)),1)*filteredDataDiff(end)],[minD:0.000001:maxD],'FaceColor','b','EdgeColor','b');
hold off;
title(['Diff:' num2str(filteredDataDiff(end)) '  [' num2str(ml) ', ' num2str(mr) ']']);

minD = min([min(filteredDataDiff2),ml2]) - 0.0005;
maxD = max([max(filteredDataDiff2),mr2]) + 0.0005;

subplot(6,2,[8,10])
[m2,s2] = normfit(filteredDataDiff2);
y2 = normpdf(filteredDataDiff2,m2,s2);
h22 = histogram(filteredDataDiff2,[minD:0.00001:maxD]);
hold on;
h12 = histogram([ones(int32(max(h22.BinCounts)),1)*ml2;ones(int32(max(h22.BinCounts)),1)*mr2],[minD:0.00002:maxD],'FaceColor','r','EdgeColor','r');
y2 = (y2/max(y2))*max(h22.BinCounts);
plot(filteredDataDiff2,y2,'.');
h32 = histogram([ones(int32(max(h22.BinCounts)),1)*filteredDataDiff2(end)],[minD:0.00001:maxD],'FaceColor','b','EdgeColor','b');
hold off;
title(['Diff2:' num2str(filteredDataDiff2(end)) '  [' num2str(ml2) ', ' num2str(mr2) ']']);

subplot(6,2,11)


if(sum(numOfWin)~=0&&sum(numOfLoss)~=0)
    X = [numOfWin numOfLoss];
    pie(X)
end