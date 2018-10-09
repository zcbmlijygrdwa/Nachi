clear all
close all
ApiStart;


%to get account information
GetAccounts;

%to get price information
GetPrices('EUR_USD')


% %create buy orders
% OrderBook = NewOrder('EUR_USD',40000);
% %create sell orders
% OrderBook = NewOrder('EUR_USD',-40000);
