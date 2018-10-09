function [output,dataSlice] = readNextFXCSVAtLine(fileName,lastOutput,dataSlice)
currentSecond = lastOutput.currentSecond;
readLine = lastOutput.readLine;


readLine = readLine+1;

 %readData = readFXCSVAtLine(fileName,readLine);
dataSlice = updateDataSlice(fileName,dataSlice,lastOutput);
 spl = split(dataSlice.b{mod(readLine,80000)+1},{':','.'});

readData = [str2double(dataSlice.c{mod(readLine,80000)+1});str2double(dataSlice.d{mod(readLine,80000)+1});str2double(spl{3})];

  output.readData = readData;
           output.currentSecond = readData(3);
           output.readLine = readLine;

%         if(isNextSecond(currentSecond,readData(3)))
%            output.readData = readData;
%            output.currentSecond = readData(3);
%            output.readLine = readLine;
%         else
%             if(currentSecond==readData(3))
%                 lastOutput.readLine = readLine;
%                 [output,dataSlice] = readNextFXCSVAtLine(fileName,lastOutput,dataSlice);
%             else
%                 %interpolation
%                 secondDifference = getSecondDifference(currentSecond,readData(3));
%                 secondDifference = double(secondDifference);
%                 lastSell = lastOutput.readData(1);
%                 lastBuy = lastOutput.readData(2);
%                 
%                 tempRadData(1) = lastSell+(readData(1)-lastSell)/secondDifference;
%                 tempRadData(2) = lastBuy+(readData(2)-lastBuy)/secondDifference;
%                 tempRadData(3) = increaseSecond(currentSecond);
%                 output.readData = tempRadData;
%                 output.currentSecond = tempRadData(3);
%                 output.readLine = lastOutput.readLine;
%             end
%         end

end