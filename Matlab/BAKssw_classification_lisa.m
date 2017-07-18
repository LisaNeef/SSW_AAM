function [DIST,MAJOR,MINOR,FINAL,MJD,gradient_6090,U] = ssw_classification_lisa(dataset,add_temp_criterion,hostname)
%% ssw_classification_lisa.m
%  Scan reanalysis datasets of zonal wind and temperature, and classify each day
%  in terms of stratsospheric warmings:
%	disturbed states
%	major warmings
%	minor warmings
%	final warmings
%
%
% Lisa Neef, 14 August 2012.
% code based on ssw_classification.m by Sophia Walther
%
% INPUTS:
%  dataset: choose 'ERA-Interim' or 'ERA-40'
%  add_temp_criterion: set to 1 to add the criterion that the temp gradient
%    between 60N and 90N is positive (for a warming to be Major), zero otherwise
%  hostname: the computer we're working on.  Currently only supporting Blizzard at 
%    DKRZ Hamburg.
% 
% OUTPUTS:
%  4 timeseries as long as the input dataset:
%    DIST: 1 for disturbed states, 0 for undisturbed
%    MAJOR: 1 for SSW events classified as major, 0 otherwise.
%    MINOR: 1 for SSW events classified as minor, 0 otherwise.
%    FINAL: 1 for SSW events classified as final warmings, 0 otherwise.
%    MJD: timeseries in modified julian date
%    gradient_6090: the temp difference between 90N and 60N, at 10hPa
%    U: the zonal wind anomaly (relative to daily climatology) at 10hPa and 60N
%
% TO-DO:
%
% MODS:
%  20 Aug 2012: also make the gradient and wind timeries output variables, so that this
%    code can be used to make plots as well.
%  24 Aug 2012: add the capability of reading ERA-40 data
%  17 Sep 2012: modify the criterion for final warmings: the state has to get beyond 5 m/s (westerly) for at least 10 days before 
%     April 30th to be considered a major (and not a final) warming.

%%----------------------------------------------------------------------------

%---temp inputs----
clc;
clear all;
dataset = 'ERA-40';
hostname = 'blizzard';
add_temp_criterion = 0;
%---temp inputs----


%% define some filepaths based on the hostname
switch hostname
  case 'blizzard'
    datadir = '/work/bb0519/b325004/SSW/';
  otherwise
    disp('the file paths for this machine still need to be written into the code!')
    return
end


%% Load the needed variables.
switch dataset
  case 'ERA-Interim'
    wind_file = [datadir,'ERA-Interim/','u_10hPa_60N.nc'];
    temp_anom_file = [datadir,'ERA-Interim/','pcap-temp-climatanom-19790101-20110531-T42-zm1.nc'];
    temp_climat_file = [datadir,'ERA-Interim/','pcap_temp_climatologylang.nc'];
    temp_6090N_file = [datadir,'ERA-Interim/','T_10hPa_60-90N.nc'];
  case 'ERA-40'
    wind_file = [datadir,'ERA-40/','era40_u_10hPa_60N.nc'];
    temp_anom_file = [datadir,'ERA-40/','pcap-temp-climatanom-1957_1978.nc'];
    temp_6090N_file = [datadir,'ERA-40/','era40_T_10hPa_60-90N.nc'];
  otherwise 
    disp(['The dataset ',dataset,' isnt yet supported.'])
    return
end

% load the polar cap temperature anomaly timeseries
switch dataset
  case 'ERA-Interim'
    DT = nc_varget(temp_anom_file,'var130');
  case 'ERA-40'
    DT = nc_varget(temp_anom_file,'t');
end
time_DT  = nc_varget(temp_anom_file,'time');

% load the wind timeseries
switch dataset
  case 'ERA-Interim'
    U = nc_varget(wind_file,'var131');
  case 'ERA-40'
    U = nc_varget(wind_file,'u');
end
time_U = nc_varget(wind_file,'time');

% check to make sure the tseries are the same lengths
if length(time_U) == length(time_DT)
  time = time_DT;
else
  disp('the lengths of the timseries do not agree.')
  return
end

% ----cut-----load the temperature seasonal climatology timeseries
%seasonal_cycle = nc_varget(temp_climat_file,'var130');
%seasonal_cycle_norm = seasonal_cycle-mean(seasonal_cycle);

% load 10hPa temp at 60N and 90N and compute the gradient
  switch dataset
    case 'ERA-Interim'
      temp6090 = nc_varget(temp_6090N_file,'var130');
      lat_6090 = nc_varget(temp_6090N_file,'lat');
    case 'ERA-40'
      temp6090 = nc_varget(temp_6090N_file,'t');
      lat_6090 = nc_varget(temp_6090N_file,'lat');
  end
  bot = size(temp6090,2);
  top = 1;
  gradient_6090 = temp6090(:,top)-temp6090(:,bot);

%% Convert time to modified julian day
switch dataset
  case 'ERA-Interim'
    % ERA-Interim files are in seconds since 01-01-1970
    time_days = time./(60*60*24);
    ref_day = date2mjd(1970,01,01);
  case 'ERA-40'
    % ERA-40 files are in hours since 1900-01-01
    time_days = time./24;
    ref_day = date2mjd(1900,01,01);
end
MJD = ref_day+time_days;

%% select disturbed / undisturbed states using temperature anomalies
% as in Blume et al., 2012, undisturbed states are chosen when PC1 of temp
% anomalies exceeds one standard deviation.
% normalize the temp timeseries and look for the days where the anomaly exceeds one standard
% deviation

sig = std(DT);
dist = find(abs(DT) > sig);

%% Initialize output arrays.
DIST = zeros(1,length(time));
MAJOR = zeros(1,length(time));
MINOR = zeros(1,length(time));
FINAL = zeros(1,length(time));
 
% we can already fill in where the disturbed states are.
DIST(dist) = 1;

%% (2) Determine final warmings

% Final warmings are where "the wind doesn't go back to westerly for at least 10 days before april 30"
% Loop through the states that are disturbed and meet the "major" criterion, and check whether they qualify as
% "final"

%dist_and_easterly = find((DIST' == 1) & (U < 0)  & (gradient_6090 > 0));
dist_and_easterly = find((U < 0));
nm = length(dist_and_easterly);

for im = 1:nm
  ii = dist_and_easterly(im);   % index of the disturbed state

  % (1) does this state happen after April 30 or before December?
  [y,m,d] = mjd2date(MJD(ii));
  if ((m >= 5) && (m < 12))
    FINAL(ii) = 1;
  else

    % if not, does the wind reveral last past 30 April

    % if not, does this state last more than 10 consecutive days?
    top = min(im+9,nm);
    next_10 = dist_and_easterly(im:top);    % the next 10 days that have easterly winds
    test = max(next_10)-next_10(1) ;         

    % (2) if those 10 days were consecutive, does the warming last past 30 April?
    if test <= 9
      k1 = ii+9;   % 10 days later
      k2 = ii+60;  % 60 days later
      k3 = min(k2,length(MJD));
      test_timespan = k1:k2;
      % where in this timespan do we cease to have a disturbed, warm state?
      kreturn = k3;
      kk = k1;
      while kk < k3;
        if (U(kk) > 0)     % undisturbed or westerly wind (cold) cases
          % in this case, stop searching - we've found the day that things go back to winter
          kreturn = kk;
          kk = k3;
        else
          kk = kk+1;
        end
      end
      % kk is either the day that things go back to a winter stratosphere, or 69 days after the warming.
      % if this day happens after 30 April, we count the warming as final.
      [~,mdum,~] = mjd2date(MJD(kreturn));
      mdum;
      if mdum >= 5  % select may and later
        FINAL(ii) = 1;
        %[y,m,d] = mjd2date(MJD(ii));
        %disp(['Final warming on ',num2str(y),'-',num2str(m),'-',num2str(d)])
      end  % events that go into May
    end  % events with 10 consecutive days
  end   % selection of events before may 
end  % loop over disturbed states


%--cut---Christian's final warming criterion
% Final warmings are disturbed states that happen at the transition from winter to summer
% It seems to be sufficient to just take all the disturbed states where the clim. 
% seasonal cycle is positive.
%final = find((DIST' == 1) & (seasonal_cycle_norm >= 0));
%FINAL(final) = 1;


%% (2) Determine major warmings:

% Criterion of C&P: If the zonal-mean wind at 60N and 10hPa anomaly is negative (i.e. easterly)
% additional criterium in the WMO definition: 10-hPa zonal mean temperature gradient between 60° and 90°N is positive

if add_temp_criterion
  major = find((DIST' == 1) & (FINAL' == 0) & (U < 0) & (gradient_6090 > 0));
else
  major = find((DIST' == 1) & (FINAL' == 0) & (U < 0));
end
MAJOR(major) = 1;

%% (4) Determine minor warmings

minor = find((DIST' == 1) & (FINAL' == 0) & (MAJOR' == 0));
MINOR(minor) = 1;



