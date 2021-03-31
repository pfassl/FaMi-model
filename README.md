# Matlab app for fitting with the FaMi-model

Dear community, the Matlap app will be available soon, there are still a few things to be fixed/improved..! :)

# Monte Carlo simulations
This repisitory contains the code for the Monte Carlo simulations for the paper *Revealing the internal luminescence quantum efficiency of perovskite films via
accurate quantification of photon recycling* in the journal Matter: https://authors.elsevier.com/a/1cbg49CyxcxO47.

It generates 'externally-observed' photoluminescence spectra with the internal PL and absorption coefficient spectra (obtained from confocal PL microsopy) as input. More information can be found in the Supplemental Information Note S6 and Fig. S19 of the paper.

The files require the software Matlab to be executed.

The file 'MonteCarlo_code.m' contains the code itself.

The file 'Example-data.mat' contains the internal PL and absorption coefficient spectra used as input for the simulations.

The file 'run_MonteCarlo.m' allows changing the input parameters, runs the simulation, plots the data and saves the results as txt-file.


