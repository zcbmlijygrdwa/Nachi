function showConvertedData(fileName)
%fileName = 'convertedPrices.txt';

[sell,buy] = textread(fileName,'%f %f');


figure();

plot(sell);
hold on;
plot(buy);
hold off;

end