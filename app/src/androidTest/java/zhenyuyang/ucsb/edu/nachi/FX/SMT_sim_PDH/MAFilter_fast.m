%moving average - fast

%state(1) = 0;   %state.initialized = false;
%state(2) = ???; %state.period = ???;
function [maBuffer,state] = MAFilter_fast( maBuffer, state,newData )

%initialization check
if(state(1)==0)%if(~state.initialized)
    state(1) = 1; %state.initialized = true;
    
    %state.maBuffer = [];
    state(3) = 0; %state.result = 0;
    state(4) = 1; %state.MACounter = 1;
    state(5) = 0; %state.maIsFull = false;
    state(6) = 0; %state.MASum = 0;
end

if(state(4)<=state(2)) %if(state.MACounter<=state.period)
    if(state(5)==1) %if(state.maIsFull)
        state(6) = state(6) - maBuffer(state(4)); %state.MASum = state.MASum - state.maBuffer(state.MACounter);
    end
    
    maBuffer(state(4)) = newData; %state.maBuffer(state.MACounter) = newData;
    state(4) = state(4)+1; %state.MACounter = state.MACounter + 1;
    state(6) = state(6) + newData; %state.MASum = state.MASum + newData;
else
    
    if(state(5)==0) %if(~state.maIsFull)
        state(5) = 1; %state.maIsFull = true;
    end
    
    state(4) = 1; %state.MACounter = 1;
    state(6) = state(6) - maBuffer(state(4)); %state.MASum = state.MASum - state.maBuffer(state.MACounter);
    maBuffer(state(4)) = newData; %state.maBuffer(state.MACounter) = newData;
    state(4) = state(4) + 1; %state.MACounter = state.MACounter + 1;
    state(6) = state(6) + newData; %state.MASum = state.MASum + newData;
end
if(state(5)==0) %if(~state.maIsFull)
    state(3) = state(6)/(state(4)-1); %state.result = state.MASum/(state.MACounter-1);
else
    state(3) = state(6)/state(2); %state.result = state.MASum/state.period;
end




end

