function [ bw ] = findCritBW( freq, normFac)
%FINDCRITBW Find the bandwidth of the critical band that the given
%frequency is in. 
% Find the bandwidth of the critical band that the given
% frequency is in. The normalization factor is used to give a factor of the
% crictical bandwith. The factor can be used as a number of allowed guides
% per band


[lFreq , ~, hFreq] = critBands(20, 20000);
bw = zeros(1,length(freq));
maxBW = 40;


bwVec = hFreq - lFreq;

sqBw = bwVec;

for fIdx = 1:length(freq)
    
    cbIdx = find(freq(fIdx)>lFreq(1:end) & freq(fIdx)<=hFreq(1:end));
    
    if(~isempty(cbIdx))
        bw(fIdx) = ceil(sqBw(cbIdx)/normFac);
    else
        if (freq(fIdx) <= min(lFreq))
            bw(fIdx) = 1;
        elseif(freq(fIdx) > max(hFreq))
            bw(fIdx) = ceil((sqBw(end))/normFac)+1;
            if bw(fIdx) > maxBW
                bw(fIdx) = maxBW;
            end
        else
            warning('MATLAB:FindCritBW','Couldnt find a band for %0.fHz',freq(fIdx));
        end
    end
end

end

