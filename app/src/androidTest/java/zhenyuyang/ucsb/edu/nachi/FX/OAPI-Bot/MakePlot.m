function MakePlot(History)
candle([History(:).highBid]',...
    [History(:).lowBid]',...
    [History(:).closeBid]',...
    [History(:).openBid]')
axis tight
end