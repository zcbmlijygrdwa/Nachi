classdef api
       properties (Constant)
%% Customize these options as necessary
           accountId = '101-011-7880280-001';
           %The account you want to access
           %token = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
           token = '1eff5457cf127fb687de2c27d3d89203-ae358019b150883ab891f0ff277dbee6'
           %Oandas security token/API key
           server = 'https://api-fxpractice.oanda.com/';
           %the URL to which the requests will be ammended
           %live    : 'https://api-fxtrade.oanda.com/'
           %practice: 'https://api-fxpractice.oanda.com/'
           %sandbox : 'https://api-sandbox.oanda.com/'
%% You probably shouldn't edit these:
           Content_Header = http_createHeader('Content-Type','application/json');
           Auth_Header = http_createHeader('Authorization',['Bearer ',api.token]);
           Patch_Header = http_createHeader('X-HTTP-Method-Override','PATCH');
           Delete_Header = http_createHeader('X-HTTP-Method-Override','DELETE');
       end
       methods
%% GetAccounts        return the accounts associated with the supplied token
           function RawAccounts = GetAccounts(api)
            Request = ['v3/accounts/',api.accountId];
            %RawAccounts = loadjson(urlread2([api.server,Request],'GET','',api.Auth_Header));
            RawAccounts = loadjson(urlread2([api.server,Request],'GET','',[api.Content_Header api.Auth_Header]));
           end
%% GetAccountInfo     return the information associated with the selected account
            function RawAccountInfo = GetAccountInfo(api,accountId)
                Request = ['v3/accounts/',accountId];
                RawAccountInfo = loadjson(urlread2([api.server,Request],'GET','',api.Auth_Header));
            end
%% GetTransactionHistory
            function RawTransactionHistory = GetTransactionHistory(api,instrument)
                if nargin ==2
                    Request = ['v3/accounts/',api.accountId,'/transactions?instrument=',instrument];
                else
                    Request = ['v3/accounts/',api.accountId,'/transactions'];
                end
                RawTransactionHistory = loadjson(urlread2([api.server,Request],'GET','',api.Auth_Header));
            end
%% GetTransactionInfo
            function RawTransactionInfo = GetTransactionInfo(api,id)
                Request = ['v3/accounts/',api.accountId,'/transactions/',id];
                RawTransactionInfo = loadjson(urlread2([api.server,Request],'GET','',api.Auth_Header));
            end
%% GetInstruments         return the tradable pairs for a particular account
            function RawInstrumentData = GetInstruments(api,accountId)
                Request = ['v3/instruments?accountId=',accountId];
                RawInstrumentData = loadjson(urlread2([api.server,Request],'GET','',api.Auth_Header));
            end
%% GetOrders
            function RawOrders = GetOrders(api,accountId)
                Request = ['v3/accounts/',accountId,'/orders'];
                RawOrders = loadjson(urlread2([api.server,Request],'Get','',api.Auth_Header));
            end
%% GetTrades         
            function RawTrades = GetTrades(api,accountId)
                Request = ['v3/accounts/',accountId,'/trades'];
                RawTrades = loadjson(urlread2([api.server,Request],'GET','',api.Auth_Header));
                if isempty(RawTrades.trades)
                    fprintf('There are no open trades to return\n')
                end
            end
%% GetHistory
            function RawHistory = GetHistory(api,PairString,granularity,count)
                Request = ['v3/candles?instrument=',PairString,'&count=',count,'&granularity=',granularity];
                RawHistory = loadjson(urlread2([api.server,Request],'GET','',api.Auth_Header));
            end
%% StreamPrices, doesn't work, the StreamPrices function uses GetPrices above
            function SPrices = StreamPrices(api,PairString)
                Request = ['v3/prices?accountId=',api.accountId,'&instruments=',PairString];
                SPrices = loadjson(urlread2([api.stream,Request],'GET','',api.Auth_Header));
            end
%% GetPrices        return the current prices for a particular pair, e.g EUR_USD
            function RawPrices = GetPrices(api,PairString)
               Request = ['v3/accounts/',api.accountId,'/pricing?instruments=',PairString];
               RawPrices = loadjson(urlread2([api.server,Request],'GET','',api.Auth_Header));
           end
%% NewOrder      Only supports market orders
            function RawOrderInfo = NewOrder(api,PairString,units)
                Request = ['v3/accounts/',api.accountId,'/orders'];
%                 Body = ['instrument=',PairString,'&units=',units,'&side=',side,'&type=market', ...
%                     '&stopLoss=',stopLoss,'&takeProfit=',takeProfit,'&trailingStop=',trailingStop];
                
                Body = ['{"order": {"units": "',num2str(units),'", "instrument": "',PairString,'", "type": "MARKET", "positionFill": "DEFAULT"}}'];
                RawOrderInfo = loadjson(urlread2([api.server,Request],'POST',Body,[api.Content_Header api.Auth_Header]));
            end
%% ModifyTrade
            function RawTradeInfo = ModifyTrade(api,id,stopLoss,takeProfit,trailingStop)
                Request = ['v3/accounts/',api.accountId,'/trades/',id];
                Body_Exists = 0;
                Body = [];
                if ~ischar(stopLoss)
                    stopLoss = num2str(stopLoss);
                end
                if ~ischar(takeProfit)
                    takeProfit = num2str(takeProfit);
                end
                if ~ischar(trailingStop)
                    trailingStop = num2str(trailingStop);
                end
                if ~strcmp(stopLoss,'0')
                    Body = ['stopLoss=',stopLoss];
                    Body_Exists = 1;
                end
                if ~strcmp(takeProfit,'0')
                    if Body_Exists == 1
                        Body = [Body,'&'];
                    end
                    Body = [Body,'takeProfit=',takeProfit];
                    Body_Exists = 1;
                end
                if ~strcmp(trailingStop,'0')
                    if Body_Exists == 1
                        Body = [Body,'&'];
                    end
                    Body = [Body,'trailingStop=',trailingStop];
                end
                Headers = [api.Auth_Header;api.Patch_Header];
                RawTradeInfo = loadjson(urlread2([api.server,Request],'POST',Body,Headers));
            end
%% CloseTrade
            function RawTradeInfo = CloseTrade(api,id)
                Request = ['v3/accounts/',api.accountId,'/trades/',id];
                Headers = [api.Auth_Header;api.Delete_Header];
                RawTradeInfo = loadjson(urlread2([api.server,Request],'DELETE','',Headers));
            end
       end
end
       