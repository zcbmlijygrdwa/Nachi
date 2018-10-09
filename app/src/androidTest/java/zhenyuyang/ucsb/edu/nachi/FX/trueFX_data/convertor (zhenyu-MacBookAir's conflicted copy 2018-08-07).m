clear all
close all
tic


for year = 2009:2013
for iii=1:12
    if(iii<10)
        fileName = ['EURUSD-' num2str(year) '-0' num2str(iii)];
    else
        fileName = ['EURUSD-' num2str(year) '-' num2str(iii)];
    end
    
    dispPriod = 200;
    try
    [a,b,c,d] = textread([fileName '.csv'],'%s %s %s %s','delimiter',',','headerlines',1);
    catch
        continue;
    end
    idxToBeRemoved = zeros(length(a),1);
    idxToBeRemovedPointer = 1;
    lengthA = length(a);
    data = cell(lengthA,3);
    i  =1;
    data{i,1} = b{i}; %time
    data{i,2} = c{i}; %sell
    data{i,3} = d{i}; %buy
    spl = split(b{i},{':','.'});
    second = str2num(spl{3});
    for i = 2:lengthA
        if(mod(i,dispPriod)==0)
            disp(['1st stage: ' num2str(i*100/lengthA) '%']);
        end
        data{i,1} = b{i}; %time
        data{i,2} = c{i}; %sell
        data{i,3} = d{i}; %buy
        spl = split(b{i},{':','.'});
        tempSecond = str2num(spl{3});
        if(second == tempSecond)
            idxToBeRemoved(idxToBeRemovedPointer) = i;
            idxToBeRemovedPointer = idxToBeRemovedPointer+1;
        else
            second = tempSecond;
        end
        
    end
    idxToBeRemoved(idxToBeRemoved==0) = [];
    data(idxToBeRemoved,:) = [];
    
    i = 1;
    count = i;
    lengthA = 2000000;
    dataComp = cell(lengthA,3);
    dataComp{count,1} = data{i,1};
    dataComp{count,2} = data{i,2};
    dataComp{count,3} = data{i,3};
    count = count+1;
    
    spl = split(data{i,1},{':','.'});
    second = str2num(spl{3});
    dataSellStart = str2num(data{i,2});
    dataBuyStart = str2num(data{i,3});
    
    i = i+1;
    lengthA = size(data,1);
    while i<=lengthA
        if(mod(i,dispPriod)==0)
            disp(['2nd stage: ' num2str(i*100/lengthA) '%']);
        end
        spl = split(data{i,1},{':','.'});
        tempSecond = str2num(spl{3});
        dataSellEnd = str2num(data{i,2});
        dataBuyEnd = str2num(data{i,3});
        if(tempSecond~=second+1)
            %dataSellEnd = str2num(data{i,2});
            %dataBuyEnd = str2num(data{i,3});
            secondDiff = getSecondDifference(second,tempSecond);
            
            avgSell = (dataSellEnd - dataSellStart)/secondDiff;
            avgBuy = (dataBuyEnd - dataBuyStart)/secondDiff;
            
            j = 1;
            while j<secondDiff
                %dataComp{count,1} = num2str(mod(second+j,60));
                %dataComp{count,2} = num2str(dataSellStart+avgSell*j,8);
                %dataComp{count,3} = num2str(dataBuyStart+avgBuy*j,8);
                dataComp{count,2} = (dataSellStart+avgSell*j);
                dataComp{count,3} = (dataBuyStart+avgBuy*j);
                count = count+1;
                j = j+1;
            end
        end
        second = tempSecond;
        dataComp{count,1} = data{i,1};
        dataComp{count,2} = str2num(data{i,2});
        dataComp{count,3} = str2num(data{i,3});
        count = count+1;
        
        
        %spl = split(data{i,1},{':','.'});
        %second = str2num(spl{3});
        %     dataSellStart = str2num(data{i,2});
        %     dataBuyStart = str2num(data{i,3});
        dataSellStart = dataSellEnd;
        dataBuyStart = dataBuyEnd;
        
        i = i+1;
        
    end
    
    dataComp(count:end,:) = [];
    %data
    %dataComp
    
    fileID = fopen([fileName '_converted.txt'],'a');
    lengthA = size(dataComp,1);
    for i = 1:size(dataComp,1)
        if(mod(i,dispPriod)==0)
            disp(['3rd stage: ' num2str(i*100/lengthA) '%']);
        end
        %record price
        fmt = '%s %s\r\n';
        fprintf(fileID,fmt,dataComp{i,2},dataComp{i,3});
    end
    fclose(fileID);
    
    toc
end
end
