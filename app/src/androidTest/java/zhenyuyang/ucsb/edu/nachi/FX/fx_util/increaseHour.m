function [hour carry] = increaseHour(input)
    if(input+1<=23)
        hour = input+1;
        carry = 0;
    else
        hour = 0;
        carry = 1;
    end

end