function out = myCircleftshift(input,k)
if(k<0)  %left
    k = -k;
    out = input([ k+1:end 1:k ]);
else  %right
    out = input([ end-k+1:end 1:end-k ]);
    
end