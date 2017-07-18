%% make_ssw_dT_U_plots.m
%
% cycle through a set of central dates and produce a catalog of plots 
% that show the turnaround in zonal wind and temp gradient around the
% central date for each event.
%
%
% lisa neef, 20 Aug 2012
%
%---------------------------------------------------------------


%% inputs
clear all;
clc;
hostname = 'blizzard';
cdate_file = 'major_date.txt';

switch hostname
  case 'blizzard'
    data_dir = '/work/bb0519/b325004/SSW/';
end

if exist([data_dir,cdate_file],'file')
  CD = importdata([data_dir,cdate_file],' ',0);
  nevents = size(CD,1);
else
  disp(['Cant find the central date file ',data_dir,cdate_file])
  return
end



%% cycle through the list and make a plot for each case

n = size(CD,1);

for ii = 1:n
  year = CD(ii,1);
  month = CD(ii,2);
  day = CD(ii,3);
  if year <= 1978, RA = 'ERA-40'; else RA = 'ERA-Interim'; end
  plot_ssws_dT_U(year,month,day,RA,hostname)

end


