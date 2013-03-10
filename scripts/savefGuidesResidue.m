function savefGuidesResidue(fGuides,residualHops,configFile,Fs) %#ok<INUSD,INUSL>
% Saves fGuides and Residue structures to a file defined by the cF
% Structure

disp(['Saving Guides and Residue hops to file :' configFile.sFName]);

mkdir(configFile.rFileName);

% Remove debug information before saving.
cF = configFile;
cF.debug = [];
save(cF.configFile,'cF');
save(configFile.sFName,'fGuides','residualHops','Fs','cF', '-v7.3');
end