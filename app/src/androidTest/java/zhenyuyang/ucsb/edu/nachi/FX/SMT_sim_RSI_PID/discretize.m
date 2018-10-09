function output = discretize(data,minSeparationInterval)

output = data(1);
lastPutIndex = data(1);
for i = 2:size(data)
    if data(i)>=(lastPutIndex+minSeparationInterval)
        output = [output data(i)];
        lastPutIndex = data(i);
    end
end
output = output';
end