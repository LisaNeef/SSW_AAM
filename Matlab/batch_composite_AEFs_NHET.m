%% batch_composite_AEFs.m
%
% loop over a set of input parameters and compute composite sets of the AAM
% excitation functions over a set of SSW events.
%
% Lisa Neef, 4 April 2012.


clear all;
dtime = 40;


% choose which set of SSWs to compute the composite for
SSW_set = 1;        % case 1: all major warming events
%SSW_set = 2;        % case 2: the events classified as "strong"
%SSW_set = 3;        % case 3: the remaining events after removing strong ones
%SSW_set = 4;        % case 4: vortex-displacement events
%SSW_set = 5;        % case 5: vortex-splitting events
%SSW_set = 6;        % case 6: events where the u-anomaly at 50hPa gets past -15 m/s
%SSW_set = 7;        % case 7: events where the u-anomaly at 50hPa gets past -20 m/s
%SSW_set = 8;        % case 8: strong ("troposphere warm") events according to Nakagawa & Yamazaki (2006)
%SSW_set = 9;       % case 9: troposphere cold events, according to the above
%criterion.
%SSW_set = 10;       % case 10: events that are leftover ("weak") according to case 6.


% choose the latitude region
%region = 'G';
%region = 'TR';
region = 'NHET';

% loop over AAM components
comp = {'X1';'X2';'X3'};

for ii = 1:3
    compute_composite_AEFs(char(comp(ii)),dtime,SSW_set,region)
end
