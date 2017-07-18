function [mjd_out,X_out] = aef_per_warming_precomputed(comp,term,cdate,dt,hostname)
%% function aef_per_warming.m: 
%   read in the timeseries for a given AAM excitation function (AEF) component
%   (i.e. X1, X2, X3) and term (wind or mass) and SSW central date,
%   from the "pre-computed" excitation functions provided by the IERS.
%   code based on erp_per_warming.m by Lisa neef
%   2 Sep 2012
%
%  INPUTS:
%   comp: the AAM component that we want (X1, X2, or X3)
%   term: 'm' for mass or 'w' for wind
%   var : the variable that we want to integrate
%   cdate: the central date of the warming that we are interested in
%           format: [YYYY,MM,DD] (numbers)
%   dt: the radius of time around the central date, in days
%
%  MODS:
%   20 Sept 2012: don't make the RA an input, but rather choose it based on the desire year.


%% ----temporary inputs
%clear all; clc;
%comp = 'X2';
%term = 'm';
%cdate = [1989,2,21];
%dt = 120;
%hostname = 'blizzard';
%figH = figure('visible','off');
%% ----temporary inputs


%% choose the reanalysis sset
year = cdate(1);
if year < 1989
  RA = 'ERA-40';
else
  RA = 'ERA-Interim';
end

%% read in the AEF timeseries
[Xw,Xm,mjd] = read_EFs('aam',RA,1,hostname);

%% pull out the appropriate interval for this event

% select the boundary dates 
cdate_mjd = date2mjd(cdate(1),cdate(2),cdate(3));
mjdf = cdate_mjd + dt;
mjd0 = cdate_mjd - dt;

% boundary indices
k0 = find(mjd >= mjd0, 1 );
kf = find(mjd <= mjdf, 1, 'last' );

% select whether we want mass or wind AEFs
switch term
  case 'w'
    XX = Xw;
  case 'm'
    XX = Xm;
end

% load constants needed to map to mas for X1 and X2, or to ms for LOD
aam_constants_gross

% select timeseries
switch comp
    case 'X1'
        X_out = rad2mas*XX(1,k0:kf);
    case 'X2'
        X_out = rad2mas*XX(2,k0:kf);
    case 'X3'
        X_out = LOD0_ms*XX(3,k0:kf);
end
mjd_out = mjd(k0:kf);

%---temporary plot------
%t = mjd_out*0;
%[y,m,d] = mjd2date(mjd_out);
%for ii = 1:length(t)
%  t(ii)=datenum([y(ii) m(ii) d(ii)]);
%end
%X_out_DT = detrend(X_out,'constant');
%plot(t,X_out_DT,'o-','LineWidth',3,'Color',rand(1,3))
%datetick('x','mmm-dd (ddd)')
%fig_name = 'test_X1m_IERS.png';
%pw = 10;
%ph = 6;
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%-------------------------
