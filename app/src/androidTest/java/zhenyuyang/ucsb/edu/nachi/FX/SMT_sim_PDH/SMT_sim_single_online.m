clear all
close all

maxBalance = 0;

traderLevelMax= 1;

distrCut_arm = 2.5;
distrCut_valueCahne = 5.0;
p_ma_1 = 30;
p_ma_2 = 720;
maxPriod= p_ma_2*3;
profitCutOff= 1.01; %1.04
lossCutOff= 0.95; %0.6
orderTimeoutThres = 5;
filteredDataDiff_fallback_upper = 0.9;
filteredDataDiff_fallback_lower = 0.8;
backupThres = 5;
plotPeriodMain = 5000;

isFollowTrend = false;
isValueChangeTriggerable = true;

isTradingBanned = false;

specialWatchPoint = -1;

backup = 0;

ml_arm = -0.099;
mr_arm = 0.099;

ml2_arm = -0.099;
mr2_arm = 0.099;


isSim = true;

ifPlot = true;
if(~isSim)
    ifPlot = true;
end
ifSlowHolding = false;
ifLoss = false;

orderTimeoutState = false;

ifBackup = false;
%======= PID controller
PID_state.p = 0.0003;
PID_state.i = 0;
PID_state.d = 0;
PID_state.target =13000;
PID_state.initialized = false;


plotPeriod = plotPeriodMain;


numOfLoss = 0;
numOfWin = 0;

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
lastOrderFrame = 0;
%currentlossCutOff  = [0.97, 0.98, 0.99, 0.995, 1 ];
%currentlossCutOff  = [(1-(1-lossCutOff)/3^(0)),(1-(1-lossCutOff)/3^(1)),(1-(1-lossCutOff)/3^(2)), (1-(1-lossCutOff)/3^(3)), (1-(1-lossCutOff)/3^(4)) ];

%currentlossCutOff  = [(1-(1-lossCutOff)/2^(0)),(1-(1-lossCutOff)/2^(1)),(1-(1-lossCutOff)/2^(2)), (1-(1-lossCutOff)/2^(3)), (1-(1-lossCutOff)/2^(4)) ];

%currentlossCutOff = (1-(1-lossCutOff)/2^(traderLevelLeft));

addpath('../fx_util')
addpath(genpath('../OAPI-Bot'))
addpath('../../../../../../../../../../../matlabplugins')
addpath('../../../../../../../../../../../fx_EUR_USD_tick')



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
maBuffer = [];
maBuffer2 = [];

MA_state(1) = 0;
MA_state(2) = p_ma_1;

MA_state2(1) = 0;
MA_state2(2) = p_ma_2;


if(MA_state2(2)>maxPriod)
    disp('maxPriod too small, not enough data for MovingAverage filter 2')
    return;
end

% MA_state.period = p;
% MA_state.initialized = false;
%
% MA_state2.period = 10*p;
% MA_state2.initialized = false;


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
filteredData = zeros(maxPriod,1);
filteredDataDiff = zeros(maxPriod,1);
filteredDataDiff_pointer = 0;
filteredData2 = zeros(maxPriod,1);
filteredDataDiff2 = zeros(maxPriod,1);
filteredDataDiff2_pointer = 0;
maxAfterTriggered_filteredDataDiff = 0;
maxAfterTriggered_filteredDataDiff2 = 0;
%====== setup account ===========


%to get account information
if isSim
    account.balance = 10000;
    account.marginAvailable = 10000;
    account.NAV = account.balance;
    %ApiStart;
    %dataRaw = GetHistory('EUR_USD','S5','5000');
    
    %load filteredDataDiff data
    
else
    plotPeriodMain = 1;
    plotPeriod = plotPeriodMain;
    
    %load filteredDataDiff data
    load('filteredDataDiff.mat');
    load('filteredDataDiff2.mat');
    
    if(length(filteredDataDiff)>maxPriod)
        filteredDataDiff = filteredDataDiff(end-maxPriod+1:end);
        filteredDataDiff2 = filteredDataDiff2(end-maxPriod+1:end);
        filteredDataDiff_pointer = 0;
        filteredDataDiff2_pointer = 0;
        
    elseif(length(filteredDataDiff)<maxPriod)
        disp('filterDataDiff size not match maxPeriod')
        return;
    end
    
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

for yearIdx = 2018:2018
    
    if(yearIdx==2009)
        months = 5:12;
    elseif (yearIdx==2018)
        months = 1:7;
    else
        months = 1:12;
    end
    %months = 1:9;
    %months = months(randperm(length(months)))
    for monthIdx = months
        orderMinutesPerMo = 0;
        orderNumberPerMo = 0;
        
        balanceWeekStart = account.balance;
        
        %load data
        if isSim
            %[sellRaw,buyRaw] = textread(['../../../fxData/EURUSD-' num2str(yearIdx) '-' num2mon(monthIdx) '_converted.txt'],'%f %f');
            [sellRaw,buyRaw] = textread(['EURUSD-' num2str(yearIdx) '-' num2mon(monthIdx) '_converted.txt'],'%f %f');
        end
        
        while (~isSim||dataCount<length(sellRaw))
            
            frameCount = frameCount+1;
            
            
            if(isSim)
                
                dataCount = dataCount+1;
                tic;
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
                
                if(ifBackup&&length(simUnits)==0&&account.NAV>10000*backupThres)
                    backup = backup+(account.NAV-10000);
                    account.balance = 10000;
                    
                    balance = (account.balance);
                    account.NAV = balance;
                    
                    disp(['backup!'])
                    
                end
                
                
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
                    account = GetAccounts_oanda();
                    
                catch
                    warning('Problem in GetAccounts_oanda');
                    continue
                end
            end
            
            balance = (account.balance);
            if(balance>maxBalance)
                maxBalance = balance;
            end
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
            if(frameCount == 155000||frameCount==148000)
                a = 1;
            end
            
            MA_state = SMMA_fast(MA_state,newPrice);
            MA_state2 = SMMA_fast(MA_state2,newPrice);
            %[maBuffer,MA_state] = MAFilter_fast(maBuffer,MA_state,newPrice);
            %[maBuffer2,MA_state2] = MAFilter_fast(maBuffer2,MA_state2,newPrice);
            
            %MA_state = SMMA(MA_state,newPrice);
            %MA2_state = SMMA(MA2_state,newPrice);
            %MA_state = MAFilter(MA_state,newPrice);
            %MA_state2 = MAFilter(MA_state2,newPrice);
            
            if(ifPlot)
                if(length(filteredData)>=maxPriod)
                    filteredData = circshift(filteredData,-1);
                    filteredData(end) = MA_state(3);
                    
                    filteredData2 = circshift(filteredData2,-1);
                    filteredData2(end) = MA_state2(3);
                    
                    filteredDataDiff = circshift(filteredDataDiff,-1);
                    filteredDataDiff_current = newPrice - MA_state(3);
                    filteredDataDiff(end) = filteredDataDiff_current;
                    
                    filteredDataDiff2 = circshift(filteredDataDiff2,-1);
                    filteredDataDiff2_current = newPrice - MA_state2(3);
                    filteredDataDiff2(end) = filteredDataDiff2_current;
                    
                    
                    
                else
                    filteredData = [filteredData; MA_state(3)];
                    
                    filteredData2 = [filteredData2; MA_state2(3)];
                    
                    filteredDataDiff_current = newPrice - MA_state(3);
                    filteredDataDiff = [filteredDataDiff;filteredDataDiff_current];
                    
                    filteredDataDiff2_current = newPrice - MA_state2(3);
                    filteredDataDiff2 = [filteredDataDiff2;filteredDataDiff2_current];
                    
                    
                end
                
                
            else
                
                
                if(filteredDataDiff_pointer +1>maxPriod)
                    filteredDataDiff_pointer = 1;
                    filteredDataDiff2_pointer = 1;
                else
                    filteredDataDiff_pointer = filteredDataDiff_pointer +1;
                    filteredDataDiff2_pointer = filteredDataDiff2_pointer +1;
                end
                filteredDataDiff_current = newPrice - MA_state(3);
                filteredDataDiff(filteredDataDiff_pointer) =filteredDataDiff_current;
                
                filteredDataDiff2_current = newPrice - MA_state2(3);
                filteredDataDiff2(filteredDataDiff2_pointer) = filteredDataDiff2_current;
            end
            
            
            
            %filteredDataDiff_rescale = rescale(filteredDataDiff);
            %filteredDataDiff2_rescale = rescale(filteredDataDiff2);
            
            %     filteredDataDiff = abs(data - filteredData);
            %     filteredDataDiff = 1 - linearScale ./exp(expScale*filteredDataDiff);%sharpe
            
            
            %====== decision making ===========
            
            
            
            
            
            if(length(IP_idx)~=0&&length(data)>=maxPriod)
                IP_idx = IP_idx-1;
                IP_idx = IP_idx(IP_idx>0);
            end
            
            
            if(~isSim||mod(frameCount,30)==0)
                [m,s] = normfit(filteredDataDiff);
                ml_arm = m-distrCut_arm*s;
                mr_arm = m+distrCut_arm*s;
                
                ml_VC = m-distrCut_valueCahne*s;
                mr_VC = m+distrCut_valueCahne*s;
                
                [m2,s2] = normfit(filteredDataDiff2);
                ml2_arm = m2-distrCut_arm*s2;
                mr2_arm = m2+distrCut_arm*s2;
                
                ml2_VC = m2-distrCut_valueCahne*s2;
                mr2_VC = m2+distrCut_valueCahne*s2;
                
                
            end
            
            
            %             if(filteredDataDiff2_current<ml2_arm)
            %                 aa = 1;
            %             end
            
            %restore isRSIHit if both diffs go into peace region
            if((buyHolds==0&&sellHolds==0) ...
                    &&((filteredDataDiff_current>ml_arm&&filteredDataDiff2_current>ml2_arm)&&(filteredDataDiff_current<mr_arm&&filteredDataDiff2_current<mr2_arm)) ...
                    )
                isRSIHit = false;
                maxAfterTriggered_filteredDataDiff = 0;
            end
            
            if(buyHolds==0&&sellHolds==0&&isTradingBanned)
                if(filteredDataDiff_current>0.5*ml_arm&&filteredDataDiff_current<0.5*mr_arm)
                    if(filteredDataDiff2_current>0.5*ml2_arm&&filteredDataDiff2_current<0.5*mr2_arm)
                        disp("cancel TradingBanner");
                        isTradingBanned = false;
                    end
                end
            end
            
            
            if(buyHolds==0&&sellHolds==0&&(~isTradingBanned)&&frameCount>maxPriod)
                
                if(filteredDataDiff_current<ml_arm||filteredDataDiff_current>mr_arm)
                    if(maxAfterTriggered_filteredDataDiff==0)
                        maxAfterTriggered_filteredDataDiff = (filteredDataDiff_current);
                    else
                        %same sign check
                        if(maxAfterTriggered_filteredDataDiff*filteredDataDiff_current<0)
                            disp('same sign check on filteredDataDiff failed');
                            isRSIHit = false;
                            maxAfterTriggered_filteredDataDiff = 0;
                        end
                        %update max
                        if(abs(maxAfterTriggered_filteredDataDiff)<abs(filteredDataDiff_current))
                            maxAfterTriggered_filteredDataDiff = filteredDataDiff_current;
                        end
                    end
                    
                    if(filteredDataDiff2_current<ml2_arm||filteredDataDiff2_current>mr2_arm)
                        if((isSim&&frameCount>=3*maxPriod||~isSim)) &&((filteredDataDiff2_current>ml2_VC&&filteredDataDiff2_current<mr2_VC))
                            %                             lastHitFrame = frameCount;
                            %                             isRSIHit = true;
                            %                             maxAfterTriggered_filteredDataDiff2 = (filteredDataDiff2_current);
                        end
                        
                    else
                        if(~isValueChangeTriggerable)
                            isValueChangeTriggerable = true;
                        end
                    end
                    
                    if(filteredDataDiff2_current<ml_VC||filteredDataDiff2_current>mr_VC)
                        if(isValueChangeTriggerable&&(isSim&&frameCount>=3*maxPriod||~isSim))
                            slop = (data(end)-data(end-2))/data(end-2)
                            if(abs(slop)>5e-04)
                                disp('Value change point! Guess trend will keep going')
                                isValueChangeTriggerable = false;
                                isFollowTrend = true;
                                isTradingBanned = true;
                                isRSIHit = false;
                                isFire = true;
                                orderTimeoutState = false;
                                lastOrderFrame = frameCount;
                                if(ifPlot)
                                    IP_idx_current =  length(data);
                                    IP_idx = [IP_idx IP_idx_current];
                                end
                                if(ifSlowHolding)
                                    plotPeriod = 1;
                                    beep;
                                end
                            end
                        end
                        
                    end
                    
                    
                end
            end
            
            
            
            %             if((buyHolds==0&&sellHolds==0) ...
            %                 &&((filteredDataDiff_current<ml&&filteredDataDiff2_current<ml2)||(filteredDataDiff_current>mr&&filteredDataDiff2_current>mr2)) ...
            %                 &&(isSim&&frameCount>=3*maxPriod||~isSim) ...
            %                 )
            %                 lastHitFrame = frameCount;
            %                 isRSIHit = true;
            %                 maxAfterTriggered_filteredDataDiff = (filteredDataDiff_current);
            %                 maxAfterTriggered_filteredDataDiff2 = (filteredDataDiff2_current);
            %
            %             end
            
            
            
            
            if(isRSIHit)
                
                %same sign check
                if(maxAfterTriggered_filteredDataDiff2*filteredDataDiff2_current<0)
                    disp('same sign check on filteredDataDiff2 failed');
                    isRSIHit = false;
                end
                
                if(abs(maxAfterTriggered_filteredDataDiff2)<abs(filteredDataDiff2_current))
                    maxAfterTriggered_filteredDataDiff2 = filteredDataDiff2_current;
                end
                
                if(frameCount - lastHitFrame<100)
                    
                    %fall-back verification: verify if filteredDataDiff
                    %falls back to desired region from maxAfterTriggered_filteredDataDiff
                    
                    if(abs(filteredDataDiff_current)>filteredDataDiff_fallback_lower*abs(maxAfterTriggered_filteredDataDiff) ...
                            && abs(filteredDataDiff_current)<filteredDataDiff_fallback_upper*abs(maxAfterTriggered_filteredDataDiff))
                        %calculate slop of filteredData
                        %slop = filteredData(end) - filteredData(end-3);
                        %slop1 = data(end) - data(end-1);
                        if(true)
                            isRSIHit = false;
                            isFire = true;
                            orderTimeoutState = false;
                            lastOrderFrame = frameCount;
                            if(ifPlot)
                                IP_idx_current =  length(data);
                                IP_idx = [IP_idx IP_idx_current];
                            end
                            if(ifSlowHolding)
                                plotPeriod = 1;
                                beep;
                            end
                        end
                    end
                else
                    disp('Wait too long');
                    isRSIHit = false;
                end
            end
            
            
            if((buyHolds~=0||sellHolds~=0)&&BenefitRatio<1)
                if(frameCount - tradingStart>orderTimeoutThres)
                    orderTimeoutState = true;
                end
            end
            
            
            
            %====== trading ===========
            
            currentprofitCutOff = (1+(profitCutOff-1)/2^(traderLevelLeft));
            currentlossCutOff = (1-(1-lossCutOff)/2^(traderLevelLeft));
            
            
            %buy trading
            if(isFire&&buyHolds==0&&sellHolds==0&&(~isFollowTrend&&filteredDataDiff_current<0||(isFollowTrend&&filteredDataDiff_current>0)))
                isFollowTrend = false;
                isFire = false;
                buyCost = newPrice;
                
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
                %emailNotification('[PDH buy trading]')
                %disp(['open buy order at ',num2str(newPrice),' with amount ',num2str(buyHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                tradingStart = frameCount;
                traderLevelLeft = traderLevelLeft-1;
                continue;
            end
            
            
            
            
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
                        disp(['[PDH win - ' num2str(traderLevelLeft) '], tempProfit = ' num2str(tempProfit)]);
                        specialWatchPoint = frameCount;
                    else
                        OrderBook = NewOrder('EUR_USD',-buyHolds);
                        disp(['[PDH win - ' num2str(traderLevelLeft) ']']);
                        %emailNotification('[PDH win]')
                    end
                    %disp(['***[win]close buy order at ',num2str(newPrice),' with amount ',num2str(buyHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                    
                    traderLevelLeftHist = [traderLevelLeftHist;traderLevelLeft];
                    buyHolds = 0;
                    traderLevelLeft = traderLevelMax;
                    tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                    tradingDurationHistoryPointer = tradingDurationHistoryPointer +1 ;
                    orderNumberPerMo = orderNumberPerMo+1;
                    isRSIHit = false;
                    plotPeriod = plotPeriodMain;
                    numOfWin = numOfWin+1;
                    isTradingBanned = true;
                elseif(BenefitRatio<currentlossCutOff)%elseif(BenefitRatio<currentlossCutOff(traderLevelLeft+1))
                    %beep
                    %disp('-----------------------------------');
                    if(traderLevelLeft>0)
                        
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
                            %emailNotification('[PDH lose]')
                        end
                        disp('[PDH lose]');
                        %disp(['[lose]close buy order at ',num2str(newPrice),' with amount ',num2str(buyHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                        beep
                        numOfLoss = numOfLoss+1;
                        buyHolds = 0;
                        traderLevelLeft = traderLevelMax;
                        %tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                        %tradingDurationHistoryPointer = tradingDurationHistoryPointer +1 ;
                        plotPeriod = plotPeriodMain;
                    end
                end
                
                if(orderTimeoutState)
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
                        disp(['[PDH buy timeout], tempProfit = ' num2str(tempProfit)]);
                        if(tempProfit<-100)
                            specialWatchPoint = frameCount;
                        end
                    else
                        OrderBook = NewOrder('EUR_USD',-buyHolds);
                        disp(['[PDH buy timeout]']);
                        %emailNotification('[PDH lose]')
                    end
                    
                    
                    %disp(['[lose]close buy order at ',num2str(newPrice),' with amount ',num2str(buyHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                    beep
                    numOfLoss = numOfLoss+1;
                    buyHolds = 0;
                    traderLevelLeft = traderLevelMax;
                    %tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                    %tradingDurationHistoryPointer = tradingDurationHistoryPointer +1 ;
                    plotPeriod = plotPeriodMain;
                    isTradingBanned = true;
                end
            end
            
            
            
            %sell trading
            if(isFire&&buyHolds==0&&sellHolds==0&&(~isFollowTrend&&filteredDataDiff_current>0||(isFollowTrend&&filteredDataDiff_current<0)))
                isFollowTrend = false;
                
                sellHolds = int32((balance/newPrice)*(leverage-1));
                sellHolds = sellHolds/(2^(traderLevelLeft-1));
                sellHolds = -sellHolds;
                
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
                %emailNotification('[PDH sell trading]')
                %disp(['open sell order at ',num2str(newPrice),' with amount ',num2str(sellHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                tradingStart = frameCount;
                traderLevelLeft = traderLevelLeft-1;
                continue;
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
                        disp(['[PDH win - ' num2str(traderLevelLeft) '], tempProfit  =' num2str(tempProfit)]);
                        specialWatchPoint = frameCount;
                    else
                        OrderBook = NewOrder('EUR_USD',-sellHolds);
                        disp(['[PDH win - ' num2str(traderLevelLeft) ']']);
                        %emailNotification('[PDH win]')
                    end
                    
                    
                    
                    
                    
                    %disp(['[win]close sell order at ',num2str(newPrice),' with amount ',num2str(sellHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                    
                    traderLevelLeftHist = [traderLevelLeftHist;traderLevelLeft];
                    sellHolds = 0;
                    traderLevelLeft = traderLevelMax;
                    tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                    tradingDurationHistoryointer = tradingDurationHistoryPointer +1 ;
                    orderNumberPerMo = orderNumberPerMo+1;
                    isRSIHit = false;
                    plotPeriod = plotPeriodMain;
                    numOfWin = numOfWin+1;
                    isTradingBanned = true;
                elseif(BenefitRatio<currentlossCutOff)%elseif(BenefitRatio<currentlossCutOff(traderLevelLeft+1))
                    %beep
                    %disp('-----------------------------------');
                    if(traderLevelLeft>0)
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
                            %emailNotification('[PDH lose]')
                        end
                        disp('[PDH lose]');
                        %disp(['[lose]close sell order at ',num2str(newPrice),' with amount ',num2str(sellHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                        beep
                        numOfLoss = numOfLoss+1;
                        sellHolds = 0;
                        traderLevelLeft = traderLevelMax;
                        %tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                        %tradingDurationHistoryPointer = tradingDurationHistoryPointer +1 ;
                        plotPeriod = plotPeriodMain;
                    end
                end
                
                if(orderTimeoutState)
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
                        disp(['[PDH sell timeout],tempProfit = ' num2str(tempProfit)]);
                        if(tempProfit<0)
                            specialWatchPoint = frameCount;
                        end
                    else
                        OrderBook = NewOrder('EUR_USD',-sellHolds);
                        %emailNotification('[PDH lose]')
                        disp(['[PDH sell timeout]']);
                    end
                    
                    
                    
                    
                    %disp(['[lose]close sell order at ',num2str(newPrice),' with amount ',num2str(sellHolds),'BenefitRatio = ',num2str(BenefitRatio),', expScale = ',num2str(expScale)]);
                    beep
                    numOfLoss = numOfLoss+1;
                    sellHolds = 0;
                    traderLevelLeft = traderLevelMax;
                    %tradingDurationHistory(tradingDurationHistoryPointer) = frameCount - tradingStart;
                    %tradingDurationHistoryPointer = tradingDurationHistoryPointer +1 ;
                    plotPeriod = plotPeriodMain;
                    isTradingBanned = true;
                    
                end
            end
            
            
            
            
            
            %     ====== plots ==========
            
            if(isSim&&mod(frameCount,plotPeriod)==0)
                disp(['Y:' num2str(yearIdx) ', mo:' num2str(monthIdx) ', D:' num2str(days) ', H:' num2str(hours)  ', sec:' num2str(frameCount) ', balance:' num2str(account.balance)  ', holds:' num2str(sellHolds+buyHolds) ', fps:' num2str(1/timeUsed)  ', orderMinsPM:' num2str(orderMinutesPerMo) ', backup:' num2str(backup) ', traderLevelLeft:' num2str(traderLevelLeft)])
            end
            
            if((~isSim&&length(data)>1)||(ifPlot&&length(data)>1&&lastOrderFrame~=0&&(frameCount - lastOrderFrame==1000 || (frameCount -specialWatchPoint ==1000))))
                %if(ifPlot&&length(data)>1&&mod(frameCount,plotPeriod)==0)
                SMTPlot3;
                if isSim
                    pause(0.1);
                end
                
                if((frameCount -specialWatchPoint ==1000))
                    aaa = 1;
                end
            end
            
            if isSim
                timeUsed = toc;
                %pause(0.001);
            else
                pause(1);
            end
            
            if(frameCount==300000)
                aaa = 1;
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
