function data = readFXCSVDataSec(fileName)

    
[a,b,c,d] = textread(fileName,'%s %s %s %s' ,1,'delimiter',',','headerlines',readLine - 1);

data = [str2num(c{1});str2num(d{1})];

end