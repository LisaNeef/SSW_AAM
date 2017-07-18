%function compute_composite_AEFs(comp,dtime,SSW_set,latband,hostname)
%% compute_composite_AEFs.m
%
%  Retrieve a set of AAM excitation functions corresponding to a set of SSW
%  events.  Save as a .mat file to be read by plot_composite_AEFs.
%
% INPUT:
%   comp: the AAM component to plot
%   dtime: radius of time around the central date to plot
%   all runs.
%   SSW_set: code for the set of events of which to retrieve the composite.
%       1: all major warming events.
%       2: ERA-Interim events only
%       3: a list of test central dates
%       4: vortex-displacement events
%       5: vortex-splitting events
%   latband: latitude band over which to integrate.
%
% MODS:
%   21 May 2012: expand code to include other subsets selected by Sophia
%   25 May 2012: make it possible to compute AEFs over only a specific
%   latitude region.
%   17 Aug 2012: add the option of computing AEFs for PJO events (Hitchcock
%   et al 2012) -- make this case 10 (formerly Sophia's "weak" events)
%   20 Aug 2012: update the central date list for the revised set of events
%   (see notes) selected with both wind and temp-gradient criterion
%   28 Aug 2012: instead of AEFs per region, do it per latitude band.
%   29 Aug 2012: make it possible to read in ERA-40 data for CDs before 1979
%    1 Sep 2012: for mass terms before 1979, read in precomputed ERA-40 AEFs from the IERS (this is provisional until we can get our grubby little mitts on ERA-40 surface pressure data)
%   11 Sep 2012: change it so that the precomputed data is retrieved by aef_per_warming.m instead of on this level.
%   12 Sep 2012: Also removing the seasonal cycles from these!
%   14 Sep 2012: change SSW set 2 to only the ERA-Interim events
%   20 Sep 2012: add the capability of testing arbitrary lists of central dates
%----------------------------------------------------------------------------

%% temp inputs
clear all;
clc;
comp = 'X2';
dtime = 100;
SSW_set = 1;
latband = [-90,90];
hostname = 'blizzard';

%% settings for this set.

switch SSW_set
    case 1
        cdate_file = 'major_date.txt';
        output_file_prefix = [comp,'_all_events'];
    case 2
        cdate_file = 'major_date_ERAinterim.txt';
        output_file_prefix = [comp,'_ERAinterim_events'];
    case 3
        cdate_file = 'major_date_test.txt';
        output_file_prefix = [comp,'_test_events'];
    case 10
        cdate_file = 'major_date_PJO.txt';
        output_file_prefix = [comp,'_PJO_events'];
end

%% read in the central dates
switch hostname
  case 'blizzard'
    datadir = '/work/bb0519/b325004/SSW/';
end


if exist([datadir,cdate_file],'file')
    disp(['opening central date file ',cdate_file]);
    CD = importdata([datadir,cdate_file],' ',0);
else
    disp(['cant find central date file ',cdate_file]);
    return
end
nf = size(CD,1);

%% set up some arrays

ntime=2*dtime+1;
XW = zeros(nf,ntime)+NaN;
XM = zeros(nf,ntime)+NaN;
t = -dtime:dtime;
TT = ones(nf,1)*t;

%% cycle through the central dates and retrieve the AEFs for each event.
for ii = 1:nf
   
    cdate = CD(ii,:);
    disp(cdate)

    [mjd,Xu] = aef_per_warming(comp,'U',cdate,dtime,latband,hostname) ;
    [~,Xv] = aef_per_warming(comp,'V',cdate,dtime,latband,hostname) ;
    [~,Xm] = aef_per_warming(comp,'PS',cdate,dtime,latband,hostname) ;

    % subtract out the climatological AEF for this day, to get rid of seasonal effects
    [XWseas,month,day] = compute_aef_seasonalcycle(comp,'w',hostname);
    [XMseas,month,day] = compute_aef_seasonalcycle(comp,'m',hostname);
    [y,m,d]=mjd2date(mjd);		% the year, month, day series of the SSW event
    for jj = 1:length(mjd)
      target = intersect(find(month == m(jj)),find(day == d(jj)));
      XW(ii,jj) = Xu(jj)+Xv(jj)-XWseas(target);
    end
   
    
end

%% save the output

if latband == [-90,90]
  output_file_suffix = '.mat';
else
  output_file_suffix = ['_',num2str(latband(1)),'_',num2str(latband(2)),'.mat'];
end

output_file = [output_file_prefix,output_file_suffix];

disp(['Saving output file   ',output_file])

save(output_file,'XW','XM','TT');





