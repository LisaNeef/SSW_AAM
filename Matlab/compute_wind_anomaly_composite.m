function [GG,lat,lev] = compute_wind_anomaly_composite(SSW_set,dtime,hostname)
%% compute_wind_anomaly_composite.m
%
% This routine creates composites of the zonal-mean wind field, 
% over pressure and latitude.
% Code by Lisa Neef, 2 Aug 2012, but based on lat_lev_anom_u_temp_composit.m by 
% Sophia Walther
%
% INPUTS:
%   SSW_set: code for the set of events of which to retrieve the composite.
%       1: all major warming events.
%       2: the events classified as "strong"
%       3: the remaining events after removing strong ones
%       4: vortex-displacement events
%       5: vortex-splitting events
%   dtime: the positive or negative block of time (in days) relative to the CD, 
%          for which to make this plot.
%   hostname: so far only 'blizzard' supported.
%
% OUTPUT:
%  GG: pressure-lat zonal-mean wind fields for the selected day and set of events.
%      this array has dimensions lon x lat x event index
%  lat, lev: the corresponding lat and pressure-level arrays.
%
% MODS:
%  17 Aug 2012: add settings for PJO event central dates
%  31 Aug 2012: change filepaths so that the joint ERA-Interim/ERA-40 file is read.
%-----------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------
% temporary inputs:
%clc;
%clear all;
%SSW_set = 1;
%dtime = -40;
%hostname = 'blizzard';
%-----------------------------------------------------------------------------------

%% settings for this set of warmings.

switch SSW_set
    case 1
        cdate_file = 'major_date.txt';
    case 2
        cdate_file = 'major_date_stark.txt';
    case 3
        cdate_file = 'major_date_schwach.txt';
    case 4
        cdate_file = 'major_date_D.txt';
    case 5
        cdate_file = 'major_date_S.txt';
    case 6
        cdate_file = 'major_date_uanom60N_50hPa_-15ms_stark.txt';
    case 7
        cdate_file = 'major_date_uanom60N_50hPa_-20ms_stark.txt';
    case 8
        cdate_file = 'major_date_strong_nakagawa.txt';
    case 9
        cdate_file = 'major_date_weak_nakagawa.txt';
    case 10
        cdate_file = 'major_date_PJO.txt';
end

%% read in the central dates


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

% read in the wind anomaly file

wind_file = [data_dir,'era_1957_2010_wind_temp_anom.nc'];

if exist(wind_file)
  u = nc_varget(wind_file,'u');
  lat = nc_varget(wind_file,'lat');
  lev = nc_varget(wind_file,'lev');
  time = nc_varget(wind_file,'time');
else
  disp(['Cant find the needed wind file ',wind_file,'  ...make sure the file path is right.'])
end

ref_mjd = date2mjd(1970,1,1);
mjd = time/(60*60*24)+ref_mjd;

% ...and define some dimensions
nlat = length(lat);
nlev = length(lev);

% time in this file is defined relative to 01-01-1970, and in 
% seconds, so convert to days and then to MJD

%% Select the field for the dtime of each central date in the list.

GG = zeros(nlat,nlev,nevents);
disp('Retrieving wind fields for the following warming events...')

for ievent = 1:nevents

  cdate = CD(ievent,:);
  cd_mjd = date2mjd(cdate(1),cdate(2),cdate(3));
  dt_mjd = cd_mjd+dtime;

  % find the time index that this day corresponds to
  k = find(round(mjd) >= round(dt_mjd), 1 );

  % store the field for this day
  GG(:,:,ievent) = squeeze(u(k,:,:))';

end



