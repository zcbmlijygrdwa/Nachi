function newIdx = circularMinus(period,currentIdx, indexOffset)

if(indexOffset>=period)
    newIdx = circularMinus(period,currentIdx, indexOffset-period);
else
    if(currentIdx-indexOffset>0)
        newIdx = currentIdx-indexOffset;
    else
        newIdx = period - (indexOffset - currentIdx);
    end
end


end