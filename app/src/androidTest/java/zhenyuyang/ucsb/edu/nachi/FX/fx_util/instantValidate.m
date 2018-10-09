if(BenefitRatio<0.8||tradingDurationHistoryMax/3600>12||account.NAV<=0)
    instantValidateResult = true;
else
    instantValidateResult = false;
end