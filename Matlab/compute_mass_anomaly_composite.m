function [GG,lat,lon] = compute_mass_anomaly_composite(SSW_set,dtime,variable,level,hostname)
%% compute_mass_anomaly_composite.m
%
% Compute composites for geopotential anomaly (relative to climatology)
% at a given vertical level and for a given set of SSW events.
%
% Presently this has to use climatological ERA-Interim data over only
% 20-90N. 
%
% Lisa Neef, 25 July 2012
% This code is based on Sophia Walther's polar_anomgeopot_composit
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
%   variable: the field to plot: either 'geopot' or 'slp'
%   level: the PL (in hPa) where we want to plot GPH - right only only can do 250hPa, 1000hPa, 50hPa
%   hostname: so far only 'blizzard' supported.
%
% OUTPUTS:
%  GG: array of either geopotential height or sea-level pressure, 
%      for the selected day and set of events.
%      this array has dimensions lon x lat x event index
%  lat, lon: the corresponding lat and lon arrays.
%
% MODS: 
%   3 Sept 2012: add support for ERA-40 data, PJO events 
%   5 Sept 2012: more flexibility about the levels at which we plot GPH
%  10 Sept 2012: updated the SLP file to the an ERA-Interim file I made (not Sophia)
%
% TODO:
%  instead of ERA-Inerim GPH data, load the joint GPH data
%  figure out whether it's better to show GPH at 500hPa or at the surface
%-------------------------------------------------------------------------------------
%%% temporary inputs:
%clc;
%clear all;
%SSW_set = 1;
%dtime = -40;
%variable = 'slp';
%hostname = 'blizzard';
%level = 50;
%-------------------------------------------------------------------------------------

%% settings for this set of warmings.

switch SSW_set
    case 1
        cdate_file = 'major_date.txt';
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

%% read in the geopotential anomaly file

switch variable
  case 'geopot'
    mass_file = [data_dir,'ERA-Interim/','eraint_1979_2010_T42_gph_NHonly_anom.nc'];
    varname_in_nc = 'var156';
  case 'slp'
    mass_file = [data_dir,'ERA-Interim/','eraint_1979_2010_T42_slp_NHonly_anom.nc'];
    varname_in_nc = 'var134';
end


if exist(mass_file)
  lon = nc_varget(mass_file,'lon');
  lat = nc_varget(mass_file,'lat');
  if strcmp(variable,'geopot')
    lev = nc_varget(mass_file,'lev');
  else
    lev = NaN;
  end
  time = nc_varget(mass_file,'time');
  mass = nc_varget(mass_file,varname_in_nc');
else
  disp(['Cant find the needed file ',mass_file,'  ...make sure the file path is right.'])
end

% if we're doing GPH, select the desired vertical level
if strcmp(variable,'geopot')
  level_Pa = level*100;
  ilev = find(lev == level_Pa);
  M = squeeze(mass(:,ilev,:,:));
else
  M = mass;
end


% ...and define some dimensions
nlon = length(lon);
nlat = length(lat);

% time in this file is defined relative to 01-01-1979, so convert to MJD
ref_mjd = date2mjd(1979,1,1);
mjd = time+ref_mjd;

%% Select the field for the dtime of each central date in the list.

GG = zeros(nlon,nlat,nevents);

disp('Retrieving geopotential fields for the following warming events...')

for ievent = 1:nevents

  cdate = CD(ievent,:);
  disp(cdate)
  cd_mjd = date2mjd(cdate(1),cdate(2),cdate(3));
  dt_mjd = cd_mjd+dtime;

  % find the time index that this day corresponds to
  k = find(round(mjd) >= round(dt_mjd), 1 );

  % store the field for this day
  switch variable
    case 'geopot'
      GG(:,:,ievent) = squeeze(M(k,:,:))';
    case 'slp'
      % SLP data are in Pascal - convert to hPa to make it more intuitive.
      GG(:,:,ievent) = squeeze(M(k,:,:))'/100;
  end

end
