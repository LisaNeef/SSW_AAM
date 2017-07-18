function [GG,tt,lev] = retrieve_p_time_U_single_event(cdate,dtime,hostname)
%% compute_composite_p_time_U
%
% This routine retrieves the zonal-mean wind at 60hPa, 
% over pressure and time, for a given SSW event, defined by its central date.
% Code by Lisa Neef, 14 Sep 2012
%
% INPUTS:
%   cdate: the central date of the warming, format [YYYY MM DD]
%   dtime: the positive or negative block of time (in days) relative to the CD, 
%          for which to make this plot.
%   hostname: so far only 'blizzard' supported.
%
% OUTPUT:
%  GG: pressure-time zonal-mean 60hPa wind field for the selected event.
%  time, lev: the corresponding time and pressure-level arrays.
%
% MODS:
%-----------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------
% temporary inputs:
clc;
clear all;
cdate = [1979 02 24];
dtime = 40;
hostname = 'blizzard';
%-----------------------------------------------------------------------------------


% some basic settings

switch hostname
  case {'blizzard','Blizzard'}
    data_dir = '/work/bb0519/b325004/SSW/';
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
nlev = length(lev);
GG = zeros(nt,nlev);

%% Select the field for the dtime of each central date in the list.


  cd_mjd = date2mjd(cdate(1),cdate(2),cdate(3));

  % find the time indices that this day corresponds to
  k = find(round(mjd) >= round(cd_mjd), 1 );
  % *** note that this only works for daily-resolved data.
  k1 = k-dtime;
  k2 = k+dtime;

  % store the field for this day
  GG(:,:) = U60(k1:k2,:);


