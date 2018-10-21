[a,b,c,d] = textread(['C:\Users\zhenyu\Downloads\EURUSD-2014-10\EURUSD-2014-10.csv'],'%s %s %s %s','delimiter',',','headerlines',1);

lengthA = length(a);
sell = zeros(lengthA,1);
buy = zeros(lengthA,1);

dispPriod = 500;

for i = 1:lengthA
    if(mod(i,dispPriod)==0)
        disp(['1st stage: ' num2str(i*100/lengthA) '%']);
    end
    sell(i) = str2num(c{i}); %sell
    buy(i) = str2num(d{i}); %buy
end

plot(sell);
hold on;
plot(buy);