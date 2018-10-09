
clear all
close all

p = 30;

RSI_threshold = 0.6;

traderLevelMax= 4;
maxPriod= 3600;
profitCutOff= 1.01;%1.005697
lossCutOff= 0.5; %0.6
MAPeriod= 150;

period_mult = 2; %1.618

%extrem case
period_mult = 1.2;
maxPriod= 360;
p = 5;
RSI_threshold = 0.1;

isSim = false;
isPeriodControlled = false;
ifPlot = false;
if(~isSim)
    ifPlot = true;
end
ifSlowHolding = false;
ifLoss = false;

%======= PID controller
PID_state.p = 0.5;
PID_state.i = 0;
PID_state.d = 0.02;
PID_state.target =5;
PID_state.initialized = false;

plotPeriodMain = 1;
plotPeriod = plotPeriodMain;


numOfLoss = 0;
numOfLossDay = 0;
numOfLossNight = 0;

orderMinutesPerMo = 0;
orderNumberPerMo = 0;

RSIHitsPerWeek = 0;
RSIHitsPerWeekHist = [];
traderLevelLeftHist = [];
PeriodHist = [];
weeklyData_profit = [];
weeklyData_orderNumberPerMo = [];
weeklyData_orderAverageTime = [];

lastHitFrame = 0;

currentlossCutOff  = [0.5, 0.75, 0.9, 0.97, 1 ];
%currentlossCutOff  = [(1-(1-lossCutOff)/3^(0)),(1-(1-lossCutOff)/3^(1)),(1-(1-lossCutOff)/3^(2)), (1-(1-lossCutOff)/3^(3)), (1-(1-lossCutOff)/3^(4)) ];

%currentlossCutOff  = [(1-(1-lossCutOff)/2^(0)),(1-(1-lossCutOff)/2^(1)),(1-(1-lossCutOff)/2^(2)), (1-(1-lossCutOff)/2^(3)), (1-(1-lossCutOff)/2^(4)) ];

%currentlossCutOff = (1-(1-lossCutOff)/2^(traderLevelLeft));

addpath('../fx_util')
addpath(genpath('../OAPI-Bot'))
addpath('E:/fx_EUR_USD_tick')
addpath('../../matlabplugins')
addpath('../trueFX_data')
addpath('../../../fx_EUR_USD_tick')



isRSIHit = false;
isFire = false;



simPrice = 1.180;
simTrade = [];
simUnits = [];





%=========================
%key parameters
%=========================

goldenRatio = .61803398875;
leverage = 50; %50:1
% %loadParams
% loadParams_test;

globalStartTime = tic;


%=========MA Filter




RSI0_state(1) = 0; %RSI1_state.initialized = false;
RSI0_state(2) = p; %RSI1_state.period = 200;

RSI1_state(1) = 0; %RSI1_state.initialized = false;
RSI1_state(2) = double(int32(RSI0_state(2)*period_mult)); %RSI1_state.period = 200;

RSI2_state(1) = 0; %RSI1_state.initialized = false;
RSI2_state(2) = double(int32(RSI1_state(2)*period_mult)); %RSI1_state.period = 200;

RSI3_state(1) = 0; %RSI1_state.initialized = false;
RSI3_state(2) = double(int32(RSI2_state(2)*period_mult)); %RSI1_state.period = 200;

RSI4_state(1) = 0; %RSI1_state.initialized = false;
RSI4_state(2) = double(int32(RSI3_state(2)*period_mult)); %RSI1_state.period = 200;



MA_state.period = RSI4_state(2);
MA_state.initialized = false;

maBuffer = zeros(MAPeriod,1);
MASum = 0;
MACounter = 1;
maIsFull = false;

traderLevelLeft = traderLevelMax;
%=========================

dataS = [];
dataB = [];
dataN = [];

jmDiff = [];

triggerTime_prev = 0;
triggerTime = 0;

dataBInit = 0;
dataSInit = 0;


% maObject = MAFilter_continue(MAPeriod);
filteredMAData = [];
filteredData = [];
filteredData0Diff = [];
filteredData1Diff = [];
filteredData2Diff = [];
filteredData3Diff = [];
filteredData4Diff = [];

%====== setup account ===========


%to get account information
if isSim
    account.balance = 10000;
    account.marginAvailable = 10000;
    account.NAV = account.balance;
    %ApiStart;
    %dataRaw = GetHistory('EUR_USD','S5','5000');
    
else
    plotPeriodMain = 1;
    plotPeriod = plotPeriodMain;
    
    ApiStart;
    try
        account = GetAccounts_oanda;
    catch
        warning('Problem in GetAccounts_oanda');
        return
    end
    
end

%histories

historyBufferSize = 5000000;

balance = (account.balance);
balanceHistory = [];


BenefitRatioHistory = zeros(1,historyBufferSize);
BenefitRatioHistoryPointer = 1;

tradingStart = 0;
tradingDurationHistory = zeros(1,historyBufferSize);
tradingDurationHistoryPointer = 1;
tradingDurationHistoryMax = 0;

tradingLevelHistory = zeros(1,historyBufferSize);
tradingLevelHistoryPointer = 1;

excitingRate = 0;
excitingRateHistory = [];
BenefitRatio = 0;

buyCost = 0;
buyInvestment = 0;
buyHolds = 0;

sellCost = 0;
sellInvestment = 0;
sellHolds = 0;

dataCount = 0;
frameCount = 0;
days = 0;
hours = 15;%23-7; %Greenwich Mean Time is 7 hours ahead of Los Angeles, CA
timeUsed = 1;


IP_idx = [];
IP_idx_hist = [];

if ifPlot
    figure(1)
end

for yearIdx = 2014:2018
    
    if(yearIdx==2009)
        months = 5:12;
    elseif (yearIdx==2018)
        months = 1:7;
    else
        months = 1:12;
    end
    %months = months(randperm(length(months)))
     months = 9:12;
    for monthIdx = months
        orderMinutesPerMo = 0;
        orderNumberPerMo = 0;
        
        balanceWeekStart = account.balance;
        
        %load data
        if isSim
            %[sellRaw,buyRaw] = textread(['../../../fxData/EURUSD-' num2str(yearIdx) '-' num2mon(monthIdx) '_converted.txt'],'%f %f');
            [sellRaw,buyRaw] = textread(['EURUSD-' num2str(yearIdx) '-' num2mon(monthIdx) '_converted.txt'],'%f %f');
        end
%         plot(sellRaw)
%         break;
        while (~isSim||dataCount<length(sellRaw))
            
            frameCount = frameCount+1;
            
            if(isSim)
            
            dataCount = dataCount+1;
            tic;
            if (mod(frameCount,4000)==0)%if (mod(frameCount,432000)==0)
                
                %update RSI parameter everyweek
                PID_state = pidController(PID_state,RSIHitsPerWeek);
                [RSI0_state(2),RSIHitsPerWeek]
                newP = abs(RSI0_state(2) - PID_state.result);
                newP = double(int32(newP))
                
                if(ifPlot)
                    if(length(PeriodHist)>=maxPriod)
                        %balanceHistory = balanceHistory(2:end);
                        PeriodHist = circshift(PeriodHist,-1);
                        PeriodHist(end) = RSI0_state(2);
                    else
                        PeriodHist = [PeriodHist;RSI0_state(2)];
                    end
                end
                
                
                %change period
                
                
                if(isPeriodControlled)
                RSI0_state(2) = newP;
                RSI1_state(2) = double(int32(RSI0_state(2)*period_mult));
                RSI2_state(2) = double(int32(RSI1_state(2)*period_mult));
                RSI3_state(2) = double(int32(RSI2_state(2)*period_mult));
                RSI4_state(2) = double(int32(RSI3_state(2)*period_mult));
                
                MA_state.period = RSI4_state(2);
                
                end
                
                if(ifPlot)
                    if(length(RSIHitsPerWeekHist)>=maxPriod)
                        %balanceHistory = balanceHistory(2:end);
                        RSIHitsPerWeekHist = circshift(RSIHitsPerWeekHist,-1);
                        RSIHitsPerWeekHist(end) = RSIHitsPerWeek;
                    else
                        RSIHitsPerWeekHist = [RSIHitsPerWeekHist;RSIHitsPerWeek];
                    end
                end
                
                
                
                
                weeklyData_profit = [weeklyData_profit;account.balance-balanceWeekStart];
                weeklyData_orderNumberPerMo = [weeklyData_orderNumberPerMo;orderNumberPerMo];
                if(orderNumberPerMo==0)
                    weeklyData_orderAverageTime = [weeklyData_orderAverageTime;0];
                else
                    weeklyData_orderAverageTime = [weeklyData_orderAverageTime;orderMinutesPerMo/orderNumberPerMo];
                end
                
                
                RSIHitsPerWeek =  0;
                
            end
            
            
            
            if mod(frameCount,60)==0
                if(length(simTrade)~=0)
                    orderMinutesPerMo =  orderMinutesPerMo+1;
                end
            end
            
            
            if mod(frameCount,3600)==0
                [hours hourCarry] = increaseHour(hours);
                if hourCarry==1
                    days = days+1;
                end
            end
            end
            
            
            %to get price information
            if isSim
                price.closeoutBid = (sellRaw(dataCount));
                price.closeoutAsk = (buyRaw(dataCount));
                newPrice = (price.closeoutBid+price.closeoutAsk)/2;
            else
                try
                    price_oanda = GetPrices('EUR_USD');
                    price.closeoutBid = str2num(price_oanda.closeoutBid);
                    price.closeoutAsk = str2num(price_oanda.closeoutAsk);
                    newPrice = (price.closeoutBid+price.closeoutAsk)/2;
                catch
                    warning('Problem inGetPrices');
                    continue;
                end
            end
            

            
            if(ifPlot)
                if(length(dataN)>=maxPriod)
                    %dataN = dataN(2:end);
                    dataN = circshift(dataN,-1);
                    dataN(end) = newPrice;
                else
                    dataN = [dataN;newPrice];
                end
            end
            

            data = dataN;
            
            %====== update account ===========
            if isSim
                if(buyHolds~=0)
                    currentPrice = newPrice;
                    currentBuyPrice = (price.closeoutAsk);
                    %simTrade = [simTrade;currentBuyPrice];
                    %simUnits = [simUnits;buyHolds];
                    tempProfit = 0;
                    for ii = 1:length(simTrade)
                        tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                    end
                    balance = (account.balance);
                    tempMarginUsed = 0;
                    for ii = 1:length(simTrade)
                        tempMarginUsed = tempMarginUsed + (currentPrice)*(double(abs(simUnits(ii))))/leverage;
                    end
                    %https://oanda.secure.force.com/AnswersSupport?urlName=How-to-Calculate-a-Margin-Closeout-1436196462931&language=en_US
                    account.NAV = balance+tempProfit;
                    account.marginUsed = tempMarginUsed;
                    account.marginAvailable = max(0,account.NAV - account.marginUsed);
                end
                if(sellHolds~=0)
                    currentPrice = newPrice;
                    currentSellPrice = (price.closeoutBid);
                    %simTrade = [simTrade;currentSellPrice];
                    %simUnits = [simUnits;buyHolds];
                    tempProfit = 0;
                    for ii = 1:length(simTrade)
                        tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                    end
                    balance = (account.balance);
                    tempMarginUsed = 0;
                    for ii = 1:length(simTrade)
                        tempMarginUsed = tempMarginUsed + (currentPrice)*(double(abs(simUnits(ii))))/leverage;
                    end
                    account.NAV = balance+tempProfit;
                    account.marginUsed = tempMarginUsed;
                    account.marginAvailable = max(0,account.NAV - account.marginUsed);
                end
                
            else
                
                try
                    account = GetAccounts_oanda;
                catch
                    warning('Problem in GetAccounts_oanda');
                    continue
                end
            end
            
            balance = (account.balance);
            %                 if(frameCount==240000)
            %                    testt = 1;
            %                 end
            
            if(buyHolds~=0||sellHolds~=0)
                
                BenefitRatio = (account.NAV)/balance;
                if(account.NAV<0.5*account.marginUsed)
                    disp('closeOut!!!');
                    globaltime = toc(globalStartTime)
                    return;
                    testt = 1;
                end
                BenefitRatioHistory(BenefitRatioHistoryPointer) = BenefitRatio;
                BenefitRatioHistoryPointer = BenefitRatioHistoryPointer +1 ;
                
                if(ifPlot)
                    if(length(balanceHistory)>=maxPriod)
                        %balanceHistory = balanceHistory(2:end);
                        balanceHistory = circshift(balanceHistory,-1);
                        balanceHistory(end) = account.NAV;
                    else
                        balanceHistory = [balanceHistory account.NAV];
                    end
                end
                
                
                tempDur = frameCount - tradingStart;
                if(tradingDurationHistoryMax<tempDur)
                    tradingDurationHistoryMax = tempDur;
                end
                
                
            else
                if(ifPlot)
                    if(length(balanceHistory)>=maxPriod)
                        %balanceHistory = balanceHistory(2:end);
                        balanceHistory = circshift(balanceHistory,-1);
                        balanceHistory(end) = balance;
                    else
                        balanceHistory = [balanceHistory balance];
                    end
                end
            end
            
            
            
            
            %====== data processing ===========
            if(frameCount == 2030240)
               a = 1; 
            end
            MA_state = SMMA(MA_state,newPrice);
            %MA_state = MAFilter(MA_state,newPrice);
            
            RSI0_state = RSI_fast(RSI0_state,newPrice);
            RSI1_state = RSI_fast(RSI1_state,newPrice);
            RSI2_state = RSI_fast(RSI2_state,newPrice);
            RSI3_state = RSI_fast(RSI3_state,newPrice);
            RSI4_state = RSI_fast(RSI4_state,newPrice);
            
            
            if(ifPlot)
                if(length(filteredData0Diff)>=maxPriod)
                    filteredData = circshift(filteredData,-1);
                    filteredData(end) = MA_state.result;
                    
                    filteredData0Diff = circshift(filteredData0Diff,-1);
                    filteredData0Diff(end) = RSI0_state(11);
                    
                    filteredData1Diff = circshift(filteredData1Diff,-1);
                    filteredData1Diff(end) = RSI1_state(11);
                    
                    filteredData2Diff = circshift(filteredData2Diff,-1);
                    filteredData2Diff(end) = RSI2_state(11);
                    
                    filteredData3Diff = circshift(filteredData3Diff,-1);
                    filteredData3Diff(end) = RSI3_state(11);
                    
                    filteredData4Diff = circshift(filteredData4Diff,-1);
                    filteredData4Diff(end) = RSI4_state(11);
                    
                    
                    
                    
                else
                    filteredData = [filteredData; MA_state.result];
                    
                    filteredData0Diff = [filteredData0Diff; RSI0_state(11)];
                    filteredData1Diff = [filteredData1Diff; RSI1_state(11)];
                    filteredData2Diff = [filteredData2Diff; RSI2_state(11)];
                    filteredData3Diff = [filteredData3Diff; RSI3_state(11)];
                    filteredData4Diff = [filteredData4Diff; RSI4_state(11)];
                end
            end
            
            %     filteredDataDiff = abs(data - filteredData);
            %     filteredDataDiff = 1 - linearScale ./exp(expScale*filteredDataDiff);%sharpe
            
            
            %====== decision making ===========
            
            
            IP = [];
            
            
            if(length(IP_idx)~=0&&length(filteredData0Diff)>=maxPriod)
                IP_idx = IP_idx-1;
                IP_idx = IP_idx(IP_idx>0);
            end
            
            if(frameCount==965175)
                aaa = 2;
                %ifPlot = true;
                %plotPeriod = 10
            end
            
            
            %             if(~isRSIHit&&((RSI0_state(11)>50+RSI_threshold*50&&RSI4_state(11)>50+RSI_threshold*50)||...
            %                     (RSI0_state(11)<50-RSI_threshold*50&&RSI4_state(11)<50-RSI_threshold*50)))
            %                 IP_idx_current =  length(filteredDataDiff);
            %                 IP_idx = [IP_idx IP_idx_current];
            %             end
            
            
            
            
            if(buyHolds==0&&sellHolds==0&&((RSI0_state(11)>50+RSI_threshold*50&&RSI1_state(11)>50+RSI_threshold*50&&RSI2_state(11)>50+RSI_threshold*50&&RSI3_state(11)>50+RSI_threshold*50&&RSI4_state(11)>50+RSI_threshold*50)||...
                    (RSI0_state(11)<50-RSI_threshold*50&&RSI1_state(11)<50-RSI_threshold*50&&RSI2_state(11)<50-RSI_threshold*50&&RSI3_state(11)<50-RSI_threshold*50&&RSI4_state(11)<50-RSI_threshold*50)))
                isRSIHit = true;
                lastHitFrame = frameCount;
            end
            
            if(isRSIHit...
                    &&(RSI4_state(12)>RSI3_state(12)...
                    &&RSI3_state(12)>RSI2_state(12)...
                    &&RSI2_state(12)>RSI1_state(12)...
                    &&RSI1_state(12)>RSI0_state(12))...
                    )
                lastHitFrame = lastHitFrame
                hitSince = frameCount - lastHitFrame
                if(ifPlot)
                IP_idx_current =  length(filteredData0Diff);
                IP_idx = [IP_idx IP_idx_current];
                end
                isFire = true;
                isRSIHit = false;
                RSIHitsPerWeek = RSIHitsPerWeek +1;
                if(ifSlowHolding)
                    plotPeriod = 300;
                    beep;
                end
            end
            
            RSIHitTimeout = 100;
            if(isRSIHit&&(frameCount - lastHitFrame>RSIHitTimeout))
                isRSIHit = false;
                disp(['RSI hit but wait too long ' num2str(frameCount - lastHitFrame) '.'])
            end
            
            
            %interested points
            if(ifPlot&&length(IP_idx)~=0)
                IP = data(IP_idx);
            end
            %====== trading ===========
            
            
            
            
            %buy trading
            if(isFire&&buyHolds==0&&sellHolds==0&&RSI4_state(11)<50)
                isFire = false;
                buyCost = newPrice;
                
                emailNotification('[buy trade]')
                
                buyHolds = int32((balance/newPrice)*(leverage-1));
                buyHolds = buyHolds/(2^(traderLevelLeft-1));
                if isSim
                    currentPrice = newPrice;
                    currentBuyPrice = (price.closeoutAsk);
                    simTrade = [simTrade;currentBuyPrice];
                    simUnits = [simUnits;buyHolds];
                    tempProfit = 0;
                    for ii = 1:length(simTrade)
                        tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                    end
                    balance = (account.balance);
                    %account.marginAvailable = (account.marginAvailable-(currentBuyPrice*double(buyHolds))/leverage);
                    account.NAV = balance+tempProfit;
                else
                    OrderBook = NewOrder('EUR_USD',buyHolds);
                    account = GetAccounts_oanda;
                end
                
                
                balance = (account.balance);
                BenefitRatio = (account.NAV)/balance;
                %disp('-----------------------------------');
                %disp(['open buy order at ',num2str(newPrice),' with amount ',num2str(buyHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                tradingStart = frameCount;
                traderLevelLeft = traderLevelLeft-1;
            end
            
            
            currentprofitCutOff = (1+(profitCutOff-1)/2^(traderLevelLeft));
            
            
            if(buyHolds~=0)
                
                if(BenefitRatio>currentprofitCutOff)
                    %beep
                    %disp('-----------------------------------');
                    if isSim
                        currentPrice = newPrice;
                        currentBuyPrice = (price.closeoutAsk);
                        tempProfit = 0;
                        for ii = 1:length(simTrade)
                            tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                        end
                        balance = (account.balance);
                        account.balance = balance+tempProfit;
                        account.marginAvailable = account.balance;
                        account.NAV = account.balance;
                        simTrade = [];
                        simUnits = [];
                    else
                        OrderBook = NewOrder('EUR_USD',-buyHolds);
                        
                        emailNotification('[win]')
                    end
                    %disp(['***[win]close buy order at ',num2str(newPrice),' with amount ',num2str(buyHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                    disp(['[win - ' num2str(traderLevelLeft) ']']);
                    traderLevelLeftHist = [traderLevelLeftHist;traderLevelLeft];
                    buyHolds = 0;
                    traderLevelLeft = traderLevelMax;
                    tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                    tradingDurationHistoryPointer = tradingDurationHistoryPointer +1 ;
                    orderNumberPerMo = orderNumberPerMo+1;
                    isRSIHit = false;
                    plotPeriod = plotPeriodMain;
                elseif(BenefitRatio<currentlossCutOff(traderLevelLeft+1))
                    %beep
                    %disp('-----------------------------------');
                    if(traderLevelLeft>0)
                        
                        if(traderLevelLeft==1)
                            
                            
                            if isSim
                                currentPrice = newPrice;
                                currentBuyPrice = (price.closeoutAsk);
                                simTrade = [simTrade;currentBuyPrice];
                                simUnits = [simUnits;buyHolds*0.9];
                                tempProfit = 0;
                                for ii = 1:length(simTrade)
                                    tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                                end
                                balance = (account.balance);
                                %account.marginAvailable = (account.marginAvailable-(currentBuyPrice*double(buyHolds*0.9))/leverage);
                                account.NAV = balance+tempProfit;
                            else
                                OrderBook = NewOrder('EUR_USD',int32(buyHolds*0.9));
                                account = GetAccounts_oanda;
                            end
                            
                            balance = (account.balance);
                            BenefitRatio = (account.NAV)/balance;
                            %disp(['final increse buy order at ',num2str(newPrice),' with amount ',num2str(int32(buyHolds*0.9)),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                            buyHolds = buyHolds + int32(buyHolds*0.9);
                            traderLevelLeft = traderLevelLeft-1;
                        else
                            
                            
                            if isSim
                                currentPrice = newPrice;
                                currentBuyPrice = (price.closeoutAsk);
                                simTrade = [simTrade;currentBuyPrice];
                                simUnits = [simUnits;buyHolds];
                                tempProfit = 0;
                                for ii = 1:length(simTrade)
                                    tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                                end
                                balance = (account.balance);
                                %account.marginAvailable = (account.marginAvailable-(currentBuyPrice*double(buyHolds))/leverage);
                                account.NAV = balance+tempProfit;
                            else
                                OrderBook = NewOrder('EUR_USD',buyHolds);
                                account = GetAccounts_oanda;
                            end
                            
                            
                            
                            
                            
                            
                            balance = (account.balance);
                            BenefitRatio = (account.NAV)/balance;
                            %disp(['increse buy order at ',num2str(newPrice),' with amount ',num2str(buyHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                            buyHolds = buyHolds*2;
                            traderLevelLeft = traderLevelLeft-1;
                        end
                        
                    elseif ifLoss
                        
                        %time = clock;
                        %saveas(gcf,['C:\Users\Zhenyu\Desktop\fx_debug\dubug-' num2str(time(3)) '-' num2str(time(2)) '-' num2str(time(3)) '-' num2str(time(4)) '-' num2str(time(5)) '-' num2str(100*(time(6))) '.png'])
                        if isSim
                            currentPrice = newPrice;
                            currentBuyPrice = (price.closeoutAsk);
                            tempProfit = 0;
                            for ii = 1:length(simTrade)
                                tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                            end
                            balance = (account.balance);
                            account.balance = balance+tempProfit;
                            account.marginAvailable = account.balance;
                            account.NAV = account.balance;
                            simTrade = [];
                            simUnits = [];
                        else
                            OrderBook = NewOrder('EUR_USD',-buyHolds);
                            emailNotification('[lose]')
                        end
                        
                        %disp(['[lose]close buy order at ',num2str(newPrice),' with amount ',num2str(buyHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                        beep
                        numOfLoss = numOfLoss+1;
                        if(expScale==expScaleDay)
                            numOfLossDay = numOfLossDay+1;
                        else
                            numOfLossNight = numOfLossNight+1;
                        end
                        buyHolds = 0;
                        traderLevelLeft = traderLevelMax;
                        tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                        tradingDurationHistoryPointer = tradingDurationHistoryPointer +1 ;
                    end
                end
            end
            
            
            
            %sell trading
            if(isFire&&buyHolds==0&&sellHolds==0&&RSI4_state(11)>50)%&&excitingRate<excitingRateThreshold)
                sellHolds = int32((balance/newPrice)*(leverage-1));
                sellHolds = sellHolds/(2^(traderLevelLeft-1));
                sellHolds = -sellHolds;
                
                emailNotification('[sell trade]')
                
                isFire = false;
                
                if isSim
                    currentPrice = newPrice;
                    currentSellPrice = (price.closeoutBid);
                    simTrade = [simTrade;currentSellPrice];
                    simUnits = [simUnits;sellHolds];
                    tempProfit = 0;
                    for ii = 1:length(simTrade)
                        tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                    end
                    balance = (account.balance);
                    %account.marginAvailable = (account.marginAvailable-(currentSellPrice*double(-sellHolds))/leverage);
                    account.NAV = balance+tempProfit;
                else
                    OrderBook = NewOrder('EUR_USD',sellHolds);
                    account = GetAccounts_oanda;
                end
                
                balance = (account.balance);
                BenefitRatio = (account.NAV)/balance;
                %disp(['open sell order at ',num2str(newPrice),' with amount ',num2str(sellHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                tradingStart = frameCount;
                traderLevelLeft = traderLevelLeft-1;
            end
            
            if(sellHolds~=0)
                
                if(BenefitRatio>currentprofitCutOff)
                    %beep
                    %disp('-----------------------------------');
                    
                    
                    
                    if isSim
                        currentPrice = newPrice;
                        currentSellPrice = (price.closeoutBid);
                        tempProfit = 0;
                        for ii = 1:length(simTrade)
                            tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                        end
                        balance = (account.balance);
                        account.balance = balance+tempProfit;
                        account.marginAvailable = account.balance;
                        account.NAV = account.balance;
                        simTrade = [];
                        simUnits = [];
                    else
                        OrderBook = NewOrder('EUR_USD',-sellHolds);
                        emailNotification('[win]')
                    end
                    
                    
                    
                    
                    
                    %disp(['[win]close sell order at ',num2str(newPrice),' with amount ',num2str(sellHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                    disp(['[win - ' num2str(traderLevelLeft) ']']);
                    traderLevelLeftHist = [traderLevelLeftHist;traderLevelLeft];
                    sellHolds = 0;
                    traderLevelLeft = traderLevelMax;
                    tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                    tradingDurationHistoryointer = tradingDurationHistoryPointer +1 ;
                    orderNumberPerMo = orderNumberPerMo+1;
                    isRSIHit = false;
                    plotPeriod = plotPeriodMain;
                elseif(BenefitRatio<currentlossCutOff(traderLevelLeft+1))
                    %beep
                    %disp('-----------------------------------');
                    if(traderLevelLeft>0)
                        if(traderLevelLeft==1)
                            
                            if isSim
                                currentPrice = newPrice;
                                currentSellPrice = (price.closeoutBid);
                                simTrade = [simTrade;currentSellPrice];
                                simUnits = [simUnits;sellHolds*0.9];
                                tempProfit = 0;
                                for ii = 1:length(simTrade)
                                    tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                                end
                                balance = (account.balance);
                                %account.marginAvailable = (account.marginAvailable-(currentSellPrice*double(-sellHolds*0.9))/leverage);
                                account.NAV = balance+tempProfit;
                            else
                                OrderBook = NewOrder('EUR_USD',int32(sellHolds*0.9));
                                account = GetAccounts_oanda;
                            end
                            
                            
                            
                            balance = (account.balance);
                            BenefitRatio = (account.NAV)/balance;
                            %disp(['final increse sell order at ',num2str(newPrice),' with amount ',num2str(int32(sellHolds*0.9)),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                            sellHolds = sellHolds+int32(sellHolds*0.9);
                            traderLevelLeft = traderLevelLeft-1;
                        else
                            
                            
                            if isSim
                                currentPrice = newPrice;
                                currentSellPrice = (price.closeoutBid);
                                simTrade = [simTrade;currentSellPrice];
                                simUnits = [simUnits;sellHolds];
                                tempProfit = 0;
                                for ii = 1:length(simTrade)
                                    tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                                end
                                balance = (account.balance);
                                %account.marginAvailable = (account.marginAvailable-(currentSellPrice*double(-sellHolds))/leverage);
                                account.NAV = balance+tempProfit;
                            else
                                OrderBook = NewOrder('EUR_USD',sellHolds);
                                account = GetAccounts_oanda;
                            end
                            
                            
                            
                            
                            
                            
                            
                            balance = (account.balance);
                            BenefitRatio = (account.NAV)/balance;
                            %disp(['increse sell order at ',num2str(newPrice),' with amount ',num2str(sellHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                            sellHolds = sellHolds*2;
                            traderLevelLeft = traderLevelLeft-1;
                        end
                    elseif ifLoss
                        %time = clock;
                        %                saveas(gcf,['C:\Users\Zhenyu\Desktop\fx_debug\dubug-' num2str(time(3)) '-' num2str(time(2)) '-' num2str(time(3)) '-' num2str(time(4)) '-' num2str(time(5)) '-' num2str(100*(time(6))) '.png'])
                        if isSim
                            currentPrice = newPrice;
                            currentSellPrice = (price.closeoutBid);
                            tempProfit = 0;
                            for ii = 1:length(simTrade)
                                tempProfit = tempProfit + (currentPrice-simTrade(ii))*(double(simUnits(ii)));
                            end
                            balance = (account.balance);
                            account.balance = balance+tempProfit;
                            account.marginAvailable = account.balance;
                            account.NAV = account.balance;
                            simTrade = [];
                            simUnits = [];
                        else
                            OrderBook = NewOrder('EUR_USD',-sellHolds);
                            emailNotification('[lose]')
                        end
                        %disp(['[lose]close sell order at ',num2str(newPrice),' with amount ',num2str(sellHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                        beep
                        numOfLoss = numOfLoss+1;
                        if(expScale==expScaleDay)
                            numOfLossDay = numOfLossDay+1;
                        else
                            numOfLossNight = numOfLossNight+1;
                        end
                        sellHolds = 0;
                        traderLevelLeft = traderLevelMax;
                        tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                        tradingDurationHistoryPointer = tradingDurationHistoryPointer +1 ;
                    end
                end
            end
            
            
            
            
            
            %     ====== plots ==========
            
            if(isSim&&mod(frameCount,plotPeriod)==0)
                disp(['Y:' num2str(yearIdx) ', mo:' num2str(monthIdx) ', D:' num2str(days) ', H:' num2str(hours)  ', sec:' num2str(frameCount) ', balance:' num2str(account.balance)  ', holds:' num2str(sellHolds+buyHolds) ', fps:' num2str(1/timeUsed)  ', orderMinsPM:' num2str(orderMinutesPerMo) ', RSIHPW:' num2str(RSIHitsPerWeek)])
            end
            
            if(ifPlot&&length(data)>1&&mod(frameCount,plotPeriod)==0)
                SMTPlot2;
                if isSim
                    pause(0.00001);
                end
            end
            
            if isSim
                timeUsed = toc;
            else
                pause(1);
            end
            
            
        end
        
        dataCount = 0;
        
        
        if(yearIdx==2018&&monthIdx==7)
            break;
        end
        
        
        
        
    end
    
    
    
end
globaltime = toc(globalStartTime)
calculateScore;
