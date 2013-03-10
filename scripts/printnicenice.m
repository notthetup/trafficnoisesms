view([90 80]);
set(gca,'ztick',[]);
colorbar('off'); 
colorbar('WestOutside')

h = get(gca, 'title');
set(h,'FontSize',16);
h = get(gca, 'xlabel');
set(h,'FontSize',14);
h = get(gca, 'ylabel');
set(h,'FontSize',14);

set(gcf,'PaperPositionMode','auto')
print('-dpng','-r300','picture1')