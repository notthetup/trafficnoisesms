[ lFreq cFreq hFreq  ] = critBands(0,20000);

xdata = [[lFreq;hFreq(end)],[lFreq;hFreq(end)]];

fig = figure;hold on;
for xIndex=1:length(lFreq)+1
    line(xdata(xIndex,:),[0,length(lFreq)+1],'Color','k');
end

