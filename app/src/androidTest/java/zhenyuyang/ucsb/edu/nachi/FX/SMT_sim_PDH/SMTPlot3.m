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
if(length(data)~=length(filteredData))
    plot(filteredData(end-length(data):end),'m')
    plot(filteredData2(end-length(data):end),'g')
else
    plot(filteredData,'m')
    plot(filteredData2,'g')
end

if(length(IP_idx)~=0&&length(IP)~=0)
    plot(IP_idx,IP,'or'); %plot IP
end
hold off
xlim([1,length(data)]);
if(max(data)- min(data)<0.0010)
ylim([mean(data)-0.0007,mean(data)+0.0007]);
end


subplot(6,2,5:6)

plot(zeros(length(data),1))
hold on
if(length(data)~=length(filteredDataDiff))
    plot(filteredDataDiff(end-length(data):end),'m')
    plot(filteredDataDiff2(end-length(data):end),'g')
else
    plot(filteredDataDiff,'m')
    plot(filteredDataDiff2,'g')
end
hold off
xlim([1,length(data)]);

minD = min([min(filteredDataDiff),ml_arm]) - 0.00001;
maxD = max([max(filteredDataDiff),mr_arm]) + 0.00001;


subplot(6,2,[7,9])
[m,s] = normfit(filteredDataDiff);
y = normpdf(filteredDataDiff,m,s);
h2 = histogram(filteredDataDiff,[minD:0.000001:maxD]);
hold on;
h1 = histogram([ones(int32(max(h2.BinCounts)),1)*ml_arm;ones(int32(max(h2.BinCounts)),1)*mr_arm],[minD:0.000002:maxD],'FaceColor','r','EdgeColor','r');
y = (y/max(y))*max(h2.BinCounts);
plot(filteredDataDiff,y,'.');
h3 = histogram([ones(int32(max(h2.BinCounts)),1)*filteredDataDiff(end)],[minD:0.000001:maxD],'FaceColor','b','EdgeColor','b');
hold off;
title(['Diff:' num2str(filteredDataDiff(end)) '  [' num2str(ml_arm) ', ' num2str(mr_arm) ']']);

minD = min([min(filteredDataDiff2),ml2_arm]) - 0.0005;
maxD = max([max(filteredDataDiff2),mr2_arm]) + 0.0005;

subplot(6,2,[8,10])
if(length(data)~=length(filteredDataDiff))
    plot(slopData(end-length(data):end))
else
    plot(slopData)
end

hold on;
plot(slopThres*ones(length(slopData),1));
plot(-slopThres*ones(length(slopData),1));
hold off;
title(['Diff2:' num2str(filteredDataDiff2(end)) '  [' num2str(ml2_arm) ', ' num2str(mr2_arm) ']']);
xlim([1,length(data)]);
ylim([-slopThres*1.4,slopThres*1.4]);

subplot(6,2,11)


if(sum(numOfWin)~=0&&sum(numOfLoss)~=0)
    X = [numOfWin numOfLoss];
    pie(X)
end