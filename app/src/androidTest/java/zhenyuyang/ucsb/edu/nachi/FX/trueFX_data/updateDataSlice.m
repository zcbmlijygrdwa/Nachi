function dataSlice = updateDataSlice(fileName, dataSlice,lastReadOutput)
%fileName = 'EURUSD-2018-01.csv'
       if(lastReadOutput.readLine>=dataSlice.startIdx)
           [a,b,c,d] = textread(fileName,'%s %s %s %s' ,80000,'delimiter',',','headerlines',dataSlice.startIdx);
           dataSlice.startIdx = dataSlice.startIdx+80000;
           dataSlice.a = a;
           dataSlice.b = b;
           dataSlice.c = c;
           dataSlice.d = d;
       end
end