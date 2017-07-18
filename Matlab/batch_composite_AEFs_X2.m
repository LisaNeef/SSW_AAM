%% batch_composite_AEFs.m
%
% loop over a set of input parameters and compute composite sets of the AAM
% excitation functions over a set of SSW events.
%
% Lisa Neef, 4 April 2012.
%
%  MODS:
%   16 Aug 2012: change ssw set 10 to the PJO events (Hitchcock et al 2012)

clc;
clear all;
dtime = 100;
hostname = 'blizzard';


% choose the latitude region
latband = [-90,90];

% loop over AAM components
comp = 'X2';
    compute_composite_AEFs(comp,dtime,1,latband,hostname)
