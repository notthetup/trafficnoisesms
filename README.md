# Traffic Noise Auralization using Spectral Modeling Synthesis #

<hr>

### Masters Thesis Information###

__Auralization of road vehicles using spectral modeling synthesis__

Master's Thesis in the Master's Program in Sound and Vibration

Department of Civil and Environmental Engineering

Division of Applied Acoustics

Chalmers University of Technology


### Source code ###

Almost all of the code used to investigate the use of Spectral Modeling Synthesis (SMS) for Traffic Noise Auralization for this Masters Thesis work is in this repository.

The entire codebase is for __MATLAB__ but I am sure you should be able to run most of it in __octave__.

### Structure ###

1. `core` contains the main SMS model and the core Analysis/Synthesis code.
2. `configs` contains config files which are used to setup the Analysis/Synthesis parameters and various other things like file locations etc.
3. `batch` contains support for batch processing a large number of source files with some support for AB testing.
4. `script` contains scripts which you can run to do the SMS Analysis/Synthsis.
5. `utils` contains random utilities which may or may not be used in other parts of the code.


### Notes ###

1. The main focus is to be able to generate SMS parameters from given recordings of traffic noise and use those to recreate the similar sounds.

2. The source files were unavalible for uploading. Any 5-6s recording of a vehicle driving past the recording location of good quality would be a good source for SMS.

3. The code might not work as is mainly due to restructring of the folder structure. Beyond that it should work.

4. A good SMS Analysis of a source requires significant analysis parameter tweaking. Atleast in the current iteration of the this work. Don't be alarmed if the re-synth is totally off. Use the various other tools to help you figure out why it doesn't work.

### Thesis Report ###

The thesis report can be found here. [https://github.com/notthetup/mastersthesis](https://github.com/notthetup/mastersthesis)