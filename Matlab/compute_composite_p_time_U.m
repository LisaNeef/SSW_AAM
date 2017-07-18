function [GG,tt,lev] = compute_composite_p_time_U(SSW_set,dtime,hostname)
%% compute_composite_p_time_U
%
% This routine creates composites of the zonal-mean wind at 60hPa, 
% over pressure and time, centered on the central date for each event.
% Code by Lisa Neef, 21 Aug 2012
%
% INPUTS:
%   SSW_set: code for the set of events of which to retrieve the composite.
%       1: all major warming events.
%       2: the events classified as "strong"
%       3: the remaining events after removing strong ones
%       4: vortex-displacement events
%       5: vortex-splitting events
%       10: events that correspond to PJO events in Hitchcock et al 2012
%
%   dtime: the positive or negative block of time (in days) relative to the CD, 
%          for which to make this plot.
%   hostname: so far only 'blizzard' supported.
%
% OUTPUT:
%  GG: pressure-time zonal-mean i60hPa wind field for the selected set of events.
%      this array has dimensions lon x lat x event index
%  time, lev: the corresponding time and pressure-level arrays.
%
% MODS:
%  31 Aug 2012: change file settings for the new merged ERA-Interim and ERA-40 data.
%-----------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------
% temporary inputs:
%clc;
%clear all;
%SSW_set = 1;
%dtime = 40;
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
  case {'blizzard','Blizzard'}
    data_dir = '/work/bb0519/b325004/SSW/';
end

if exist([data_dir,cdate_file],'file')
  CD = importdata([data_dir,cdate_file],' ',0);
else
  disp(['Cant find the central date file ',data_dir,cdate_file])
  return
end

% read in the file that holds wind and temperature
ff = [data_dir,'era_1957_2010_wind_temp_anom.nc'];

if exist(ff)
  U = nc_varget(ff,'u');
  time = nc_varget(ff,'time');
  lev = nc_varget(ff,'lev');
  lat = nc_varget(ff,'lat');
else
  disp(['Cant find the needed wind file ',ff,'  ...make sure the file path is right.'])
  return
end

% isolate the 60 hPa winds
lat60 = find(round(lat) == 60);
U60 = squeeze(U(:,:,lat60));

% convert the time array to MJD.  
% Note different time definitions in ERA-Interim and ERA-40.
ref_mjd = date2mjd(1970,1,1);
mjd = time./(60*60*24)+ref_mjd;   

% define some dimensions
tt = -dtime:1:dtime;
nt = length(tt);
nevents = size(CD,1);
nlev = length(lev);
GG = zeros(nt,nlev,nevents);

%% Select the field for the dtime of each central date in the list.

disp('Retrieving wind fields for SSW events...')

for ievent = 1:nevents

  cdate = CD(ievent,:);
  cd_mjd = date2mjd(cdate(1),cdate(2),cdate(3));

  % find the time indices that this day corresponds to
  k = find(round(mjd) >= round(cd_mjd), 1 );
  % *** note that this only works for daily-resolved data.
  k1 = k-dtime;
  k2 = k+dtime;

  % store the field for this day
  GG(:,:,ievent) = U60(k1:k2,:);

end



