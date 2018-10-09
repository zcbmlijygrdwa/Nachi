        clf
        
        
        %disp(['Y:' num2str(yearIdx) ', mo:' num2str(monthIdx) ', D:' num2str(days) ', H:' num2str(hours)  ', sec:' num2str(frameCount) ', balance:' num2str(account.balance)  ', holds:' num2str(sellHolds+buyHolds) ', fps:' num2str(1/timeUsed)  ', lossNum:' num2str(numOfLoss)])
                        
        
        subplot(4,1,1)
        plot(balanceHistory)
        xlim([1,length(data)]);
        title(['practice: ' num2str(BenefitRatio) ': [' num2str(currentlossCutOff(traderLevelLeft+1)) ',' num2str(currentprofitCutOff) ']']);
        
        subplot(4,1,2)
        plot(data)
        hold on
        plot(filteredData)
        if(length(IP_idx)~=0)
            plot(IP_idx,IP,'or'); %plot IP
        end
        hold off
        xlim([1,length(data)]);
        
        subplot(4,1,3)
        plot(filteredDataDiff)
        hold on
        plot(ones(1,length(filteredDataDiff))*(1-(1-goldenRatio)));
        plot(ones(1,length(filteredDataDiff))*(1-(1-goldenRatio)^2));
        plot(ones(1,length(filteredDataDiff))*(1-(1-goldenRatio)^3));
        hold off
        xlim([1,length(data)]);
        ylim([0,1]);
        
        
%         subplot(4,1,4)
%         plot(excitingRateHistory)
%         hold on
%         plot(ones(1,length(filteredDataDiff))*excitingRateThreshold);
%         
%         hold off
%         xlim([1,length(excitingRateHistory)]);
%         ylim([0,1]);
%         title(num2str(excitingRate));


        subplot(4,1,4)
%         filteredV = MAFilter([0;dataN(2:end) - dataN(1:end-1)],30);
%         plot(filteredV);
%         hold on
%         plot(zeros(1,length(filteredDataDiff)));
%         plot(ones(1,length(filteredDataDiff))*(2e-5));
%         plot(ones(1,length(filteredDataDiff))*(-2e-5));
%         hold off
%         xlim([1,length(excitingRateHistory)]);
%         ylim([-0.0002,0.0002]);