function data = readFXCSVAtLine(fileName,readLine)
[a,b,c,d] = textread(fileName,'%s %s %s %s' ,1,'delimiter',',','headerlines',readLine - 1);
spl = split(b,{':','.'});

data = [str2num(c{1});str2num(d{1});str2num(spl{3})];
%[sell,buy,seconds]

end