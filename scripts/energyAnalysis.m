inputEnergy = sum(cF.debug.inputStream.^2)

preThresoldTrajEnergy = sum(sMSSynthGuides(cF.debug.unTreshfGuides,cF.sP,Fs).^2)

postThresoldTrajEnergy = sum(sMSSynthGuides(cF.debug.fGuides,cF.sP,Fs).^2)

residualEnergy = sum(sMSSynthResidual(cF.debug.residualHops).^2)

pause; % enable env calculations

residualEvnEnergy = sum(sMSSynthResidual(cF.debug.residualHops).^2)

pause; % enable smoothing

residualEvnSmoothingEnergy = sum(sMSSynthResidual(cF.debug.residualHops).^2)

tonalEnergy = sum(reSynthDet.^2)

residualEnergy = sum(reSynthNoise.^2)

totalEnergy = sum(reSynth.^2)