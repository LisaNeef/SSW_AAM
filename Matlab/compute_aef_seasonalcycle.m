function [X_out,month,day] = compute_aef_seasonalcycle(comp,term,hostname)
%% compute_aef_seasonalcycle.m
%
%  Go through the IERS-provided atmospheric excitation functions and compute the 
%  climatological seasonal cycle, so that it can be subtracted from AEFs computed
%  for SSWs.
%
%  12 September 2012
%
%  INPUTS:
%
%  OUTPUTS:
%    X_out: the desired AEF, in equivalend polar motion or LOD (so, in mas or ms)
%  MODS:
%
%-------------------------------------------------------------------------------------

%% Temporary inputs
%clear all;
%clc;
%comp = 'X2';
%term = 'm';
%hostname = 'blizzard';


%% Read in the data - combine ERA-40 and ERA-Interim
[Xw_40,Xm_40,mjd_40] = read_EFs('aam','ERA-40',1,hostname);
[Xw_int,Xm_int,mjd_int] = read_EFs('aam','ERA-Interim',1,hostname);
switch term
  case 'w'
    X_dimensionless = [Xw_40,Xw_int];
  case 'm'
    X_dimensionless = [Xm_40,Xm_int];
end
mjd = [mjd_40,mjd_int];

%% convert to equivalent polar motion of LOD anomaly
aam_constants_gross
switch comp
  case 'X1'
    X = rad2mas*X_dimensionless(1,:);
  case 'X2'
    X = rad2mas*X_dimensionless(2,:);
  case 'X3'
    X = LOD0_ms*X_dimensionless(3,:);
end

%% Make a generic year, with a leap day
mjd0_1988 = date2mjd(1988,01,01);    	% start day of sample leap year.
mjdf_1988 = date2mjd(1988,12,31);    	% start day of sample leap year.
mjd_leap_year = mjd0_1988:1:mjdf_1988;

[~,month,day] = mjd2date(mjd_leap_year);

%% compute the average excitation function for each day

% matrix of AEFs for each year
[Y,M,D] = mjd2date(mjd);
y0 = Y(1);
yf = max(Y);
years = y0:yf;
ny = length(years);
nd = 366;

XX = zeros(nd,ny)+NaN;

% cycle through years
for iyear = 1:ny
  target = find(Y == years(iyear));
  X_this_year = X(target);
  X_seasonal = detrend(X_this_year,'constant');
  if isleapyear(years(iyear))
    XX(:,iyear) = X_seasonal;
  else
    % Feb 29th is day 60, so leave that day out
    XX([1:59,61:366],iyear) = X_seasonal;
  end
end

% compute the climatological daily mean.
X_out= nanmean(XX,2);

%% test plot
%figH = figure('visible','off');
%plot(1:183,XX(1:183,:),'Color',0.7*ones(1,3));
%hold on
%plot(1:183,X_out(1:183),'o-','Color',rand(1,3))
%axis([1 183 -60 60])
%fig_name = ['test_seasonalcycle_',comp,'.png'];
%pw = 10;
%ph = 10;
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)

