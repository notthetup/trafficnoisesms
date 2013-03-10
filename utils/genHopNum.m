function numHops = genHopNum( stftParams,streamLength)

numHops = 0;

for pIndex = 1:length(stftParams)
    numHops = numHops + ceil(streamLength/stftParams(pIndex).hopLength);
end

end