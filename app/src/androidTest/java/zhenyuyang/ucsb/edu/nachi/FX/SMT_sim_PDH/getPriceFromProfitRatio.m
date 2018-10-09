function price = getPriceFromProfitRatio(targetProfitRatio, currentPrice, balance, simTrade,simUnits)
error = 1;
if(strcmp(class(balance),'char'))
    balance = str2num(balance);
end
while(abs(error)>0.0001)
    if(simUnits(1)<0)
        if(error<0)
            currentPrice = currentPrice + 0.000001;
        else
            currentPrice = currentPrice - 0.000001;
        end
    else
        if(error<0)
            currentPrice = currentPrice - 0.000001;
        else
            currentPrice = currentPrice + 0.000001;
        end
    end
    
    tempProfit = 0;
    for ii = 1:length(simTrade)
        tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
    end
    tempProfitRatio = (balance+tempProfit) / balance;
    
    error = targetProfitRatio - tempProfitRatio;
    
end
price = currentPrice;
end