

BenefitRatioHistory(BenefitRatioHistory==0) = [];
figure(),hist(BenefitRatioHistory,[0.5:0.001:1.6])
title('BenefitRatioHistory')


figure()
hist(traderLevelLeftHist);
title('traderLevelLeftHist')


tradingDurationHistory(tradingDurationHistory==0) = [];
figure(),hist(tradingDurationHistory,-5:1:20)
title('tradingDurationHistory')
