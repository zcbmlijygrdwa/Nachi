clear all;
close all;

addpath('..\fx_util')
addpath('..\SMT_sim_practice_MAFilter_continue')
addpath('..\SMT_cpp')
addpath('C:\Users\Zhenyu\Dropbox\matlabplugins')

%parameters
numOfAgent = 12;
surviveRatio = 0.3;
mutationRate = 0.3;

%Load initail DNA
loadParams_test;


traderLevelMax= 10
maxPriod= 3600
lowPassA= 0.0100
linearScale= 1
expScaleNight= 458
expScaleDay= 1411
lookBackSize= 100
excitingRateThreshold= 0.2000
profitCutOff= 1.111886
lossCutOff= 0.857939
MAPeriod= 250


%intialize agents
agents = cell(numOfAgent,1);
for i = 1:numOfAgent
    newAgent = [];
    newAgent.DNA.traderLevelMax = traderLevelMax;
    newAgent.DNA.maxPriod = maxPriod;
    newAgent.DNA.lowPassA = lowPassA;
    newAgent.DNA.linearScale = linearScale;
    newAgent.DNA.expScaleNight = expScaleNight;
    newAgent.DNA.expScaleDay = expScaleDay;
    newAgent.DNA.lookBackSize = lookBackSize;
    newAgent.DNA.excitingRateThreshold = excitingRateThreshold;
    newAgent.DNA.profitCutOff = profitCutOff;
    newAgent.DNA.lossCutOff = lossCutOff;
    newAgent.DNA.MAPeriod = MAPeriod;
    newAgent.result = [];
    newAgent.generation = 1;
    
    agents{i} = newAgent;
end


%evolution loop
for evo_iteration = 2:1000
    disp('===========================');
    disp(['Generation: ' num2str(evo_iteration-1)]);
    evo_iteration_time_start = tic;
    %put agents into environment, get scores
    
%     parfor i = 1:numOfAgent
%         agents{i}.result = SMT_sim_single(agents{i}.DNA);
%         disp(['agents{' num2str(i) '}: score:' num2str(agents{i}.result.score) ',balance:' num2str(agents{i}.result.balance)]);
%     end
    
    parfor i = 1:numOfAgent
        agents{i}.result = SMT_sim_single_test(agents{i}.DNA);
        %agents{i}.result = SMT_sim_allYears_cpp(agents{i}.DNA);
        if(agents{i}.result.longestHours>48)
           agents{i}.result.score = 0; 
        end
        disp(['agents{' num2str(i) '}: score:' num2str(agents{i}.result.score) ',balance:' num2str(agents{i}.result.balance)]);
    end
    
    
    
    
    %sort agents
    for i = 1:numOfAgent
        for j = i+1:numOfAgent
            if(agents{i}.result.score<=agents{j}.result.score)
                tempAgent = agents{i};
                agents{i} = agents{j};
                agents{j} = tempAgent;
            end
        end
    end
    
    %kill useless agents
    agents(uint32(length(agents)*surviveRatio):end) = [];
    
    
    
    %mate, produce next generation DNAs
    nextAgents = cell(numOfAgent,1);
    for i = 1:numOfAgent
        parentIdexs = randperm(length(agents),2);
        father = agents{parentIdexs(1)};
        mother = agents{parentIdexs(2)};
        
        mate;
        newAgent.result = [];
        newAgent.generation = evo_iteration;
        nextAgents{i} = newAgent;
    end
    agents = nextAgents;
    evo_iteration_time = toc(evo_iteration_time_start);
    disp(['Generation time: ' num2str(evo_iteration_time) 'seconds.']);
end