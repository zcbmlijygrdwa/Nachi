
        
        
        newAgent = [];
        %traderLevelMax
        if rand>0.5
            newAgent.DNA.traderLevelMax = father.DNA.traderLevelMax;
        else
            newAgent.DNA.traderLevelMax = mother.DNA.traderLevelMax;
        end
        if rand<mutationRate
            newAgent.DNA.traderLevelMax = newAgent.DNA.traderLevelMax+randi([-2,2]);
        end
        
        %maxPriod
        if rand>0.5
            newAgent.DNA.maxPriod = father.DNA.maxPriod;
        else
            newAgent.DNA.maxPriod = mother.DNA.maxPriod;
        end
%         if rand<mutationRate
%             newAgent.DNA.maxPriod = newAgent.DNA.maxPriod+randi([-2,2]);
%         end
        
        %lowPassA
        if rand>0.5
            newAgent.DNA.lowPassA = father.DNA.lowPassA;
        else
            newAgent.DNA.lowPassA = mother.DNA.lowPassA;
        end
%         if rand<mutationRate
%             newAgent.DNA.lowPassA = newAgent.DNA.lowPassA+randi([-2,2]);
%         end
        
        %linearScale
        if rand>0.5
            newAgent.DNA.linearScale = father.DNA.linearScale;
        else
            newAgent.DNA.linearScale = mother.DNA.linearScale;
        end
%         if rand<mutationRate
%             newAgent.DNA.linearScale =
%             newAgent.DNA.linearScale+randi([-2,2]);
%         end
        
        %expScaleNight
        if rand>0.5
            newAgent.DNA.expScaleNight = father.DNA.expScaleNight;
        else
            newAgent.DNA.expScaleNight = mother.DNA.expScaleNight;
        end
        if rand<mutationRate
            newAgent.DNA.expScaleNight = newAgent.DNA.expScaleNight+randi([-100,100]);
        end
        
        %expScaleDay
        if rand>0.5
            newAgent.DNA.expScaleDay = father.DNA.expScaleDay;
        else
            newAgent.DNA.expScaleDay = mother.DNA.expScaleDay;
        end
        if rand<mutationRate
            newAgent.DNA.expScaleDay = newAgent.DNA.expScaleDay+randi([-100,100]);
        end
        
        %lookBackSize
        if rand>0.5
            newAgent.DNA.lookBackSize = father.DNA.lookBackSize;
        else
            newAgent.DNA.lookBackSize = mother.DNA.lookBackSize;
        end
%         if rand<mutationRate
%             newAgent.DNA.lookBackSize =
%             newAgent.DNA.lookBackSize+randi([-2,2]);
%         end
        
        %excitingRateThreshold
        if rand>0.5
            newAgent.DNA.excitingRateThreshold = father.DNA.excitingRateThreshold;
        else
            newAgent.DNA.excitingRateThreshold = mother.DNA.excitingRateThreshold;
        end
%         if rand<mutationRate
%             newAgent.DNA.excitingRateThreshold =
%             newAgent.DNA.excitingRateThreshold+randi([-2,2]);
%         end
        
        %profitCutOff
        if rand>0.5
            newAgent.DNA.profitCutOff = father.DNA.profitCutOff;
        else
            newAgent.DNA.profitCutOff = mother.DNA.profitCutOff;
        end
        if rand<mutationRate
            tempTry = (rand-0.5)*0.1;
            while ((newAgent.DNA.profitCutOff+tempTry)<=1)
                tempTry = (rand-0.5)*0.1;
            end
            newAgent.DNA.profitCutOff = newAgent.DNA.profitCutOff+tempTry;
        end
        
        %lossCutOff
        if rand>0.5
            newAgent.DNA.lossCutOff = father.DNA.lossCutOff;
        else
            newAgent.DNA.lossCutOff = mother.DNA.lossCutOff;
        end
        if rand<mutationRate
            tempTry = (rand-0.5)*0.1;
            while ((newAgent.DNA.lossCutOff+tempTry)>=1)
                tempTry = (rand-0.5)*0.1;
            end
            newAgent.DNA.lossCutOff = newAgent.DNA.lossCutOff+tempTry;
        end
        
        %MAPeriod
        if rand>0.5
            newAgent.DNA.MAPeriod = father.DNA.MAPeriod;
        else
            newAgent.DNA.MAPeriod = mother.DNA.MAPeriod;
        end
%         if rand<mutationRate
%             newAgent.DNA.MAPeriod = newAgent.DNA.MAPeriod+randi([-2,2]);
%         end