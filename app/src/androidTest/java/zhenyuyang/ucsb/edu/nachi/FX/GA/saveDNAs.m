for agentIdx = 1:length(agents)
fileID = fopen(['agent' num2str(agentIdx) '.txt'],'a');
fmt = '%6f\r\n';
fprintf(fileID,fmt,agents{agentIdx}.DNA.traderLevelMax);
fprintf(fileID,fmt,agents{agentIdx}.DNA.maxPriod);
fprintf(fileID,fmt,agents{agentIdx}.DNA.lowPassA);
fprintf(fileID,fmt,agents{agentIdx}.DNA.linearScale);
fprintf(fileID,fmt,agents{agentIdx}.DNA.expScaleNight);
fprintf(fileID,fmt,agents{agentIdx}.DNA.expScaleDay);
fprintf(fileID,fmt,agents{agentIdx}.DNA.lookBackSize);
fprintf(fileID,fmt,agents{agentIdx}.DNA.excitingRateThreshold);
fprintf(fileID,fmt,agents{agentIdx}.DNA.profitCutOff);
fprintf(fileID,fmt,agents{agentIdx}.DNA.lossCutOff);
fprintf(fileID,fmt,agents{agentIdx}.DNA.MAPeriod);
fclose(fileID);
end