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

% choose the AAM component
comp = 'X3';

% choose the latitude regions over which to loop
l1 = [-90,90];
l2 = [-90,-60];
l3 = [-60,-30];
l4 = [-30,0];
l5 = [0,30];
l6 = [30,60];
l7 = [60,90];
R = [l1;l2;l3;l4;l5;l6;l7];
nbands = size(R,1);

for ii = 1:nbands
 disp(['-----computing composite AEFs for component',comp,'----'])
    compute_composite_AEFs(comp,dtime,SSW_set,R(ii,:),hostname)
end
