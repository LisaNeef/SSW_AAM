%% 
%
% Loop over the SSW events and compute X2 by latitude band.
% note that since we only have surface pressure data for Interim, we have to stick to that set
% for now.
% 
%
% Lisa Neef, 14 Sep 2012
%
%  MODS:

clc;
clear all;
dtime = 70;
hostname = 'blizzard';

% choose which set of SSWs to compute the composite for
SSW_set = 2;		% case 2: only the ERA-Interim events.

% choose the AAM component
comp = 'X2';

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
