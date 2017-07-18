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
dtime = 70;
hostname = 'blizzard';

% choose which set of SSWs to compute the composite for
%SSW_set = 1;        % case 1: all major warming events
SSW_set = 10;       % case 10: PJO events


% choose the latitude region
latband = [-90,90];

% loop over AAM components
comp = {'X1';'X2';'X3'};



for ii = 1:3
 disp(['-----computing composite AEFs for component',char(comp(ii)),'----'])
    compute_composite_AEFs(char(comp(ii)),dtime,SSW_set,latband,hostname)
end
