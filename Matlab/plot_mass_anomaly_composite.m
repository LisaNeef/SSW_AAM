function axis_handle = plot_mass_anomaly_composite(SSW_set,dtime,variable,level,hostname,TT)
%
% Make a plot of the composite geopotential anomaly field over a set of SSW events, for 
% a given detla_time (in days) relative to the central date.
%
% Lisa Neef, 26 July 2012
% this is based on code from polar_anomgeopot_composit.m by Sophia Walther
%
% INPUTS:
%   SSW_set: code for the set of events of which to retrieve the composite.
%   dtime: the positive or negative block of time (in days) relative to the CD,
%          for which to make this plot.
%   variable: the field to plot: either 'geopot' or 'slp'
%   level: the level we want to look at if ploting GPH - right now can only choose 50hPa, 200hPa, 1000hPa
%   hostname: so far only 'blizzard' supported.
%   TT: the string that we want to slap on this plot as a title.
%
% MODS:
%
%
%---------------------------------------------------------------------------


% temporary inputs
%clear all;
%clc;
%SSW_set = 1;
%dtime = 0;
%variable = 'geopot';
%level = 1000;
%hostname = 'blizzard';
%TT = 'test plot: GPH at the surface';
% figH = figure('visible','off');

%---------------------------------------------------------------------------

%% load the geopotential fields for this SSW event subset

[GG,lat0,lon0] = compute_mass_anomaly_composite(SSW_set,dtime,variable,level,hostname);
Gm = mean(GG,3);

%% compute the bootstrap confidence intervals for each point

nlon = length(lon0);
nlat = length(lat0);
C = zeros(nlon,nlat,2);
nboot = 100;

for ilon = 1:nlon
  for ilat = 1:nlat
    C(ilon,ilat,:) = bootci(nboot,{@mean,GG(ilon,ilat,:)},'alpha',0.1);
  end 
end

% these are anomalies, so everything where the CI crosses zero is statistically insignificant.
% if there is a sign change, then the prdocut of the two CI bounds is negative; for no sign 
% change it has to be positive.
sign_change = C(:,:,1).*C(:,:,2);
mask_out = find(sign_change < 0);
Gm(mask_out) = 0;

%% define the grid and plot settings
[X,Y] = meshgrid(lon0,lat0);
col = flipud(div_red_yellow_blue11);
% since we are setting everything that gets "masked out" to zero, it's
% probably best to make the zero contour white (not yellow)
  col(6,:) = ones(1,3);

load coast

% define the contour lines, depending on which variable is plotted.
switch variable
  case 'geopot'
    %w=[-120:25:120];
    switch level
      case 50
        w = [-250:50:250];
      case 250
        w = [-150:20:150];
      case 1000
        w = [-120:10:120];
    end
  case 'slp'
    w=[-10:2:10];
end

%% Plot! 


axis_handle = axesm('MapProjection','stereo','MapLatLimit',[20 90],'Origin',[ 90 0],'LabelUnits','degrees','grid','on');
colormap(col)
%[ci,hi] = contourfm(lat0,lon0,Gm',w,'-','Color',ones(1,3));
[ci,hi] = contourfm(lat0,lon0,Gm','-','Color',ones(1,3));
hold on
plotm(lat,long,'Color',zeros(1,3))
%cax = get(gca,'Clim')
%set(gca,'Clim',max(cax)*[-1,1]);
caxis([min(w),max(w)])
colorbar

axis off
box off
tightmap
set(gca,'color','none','box','off','visible','off');
%whitebg

text(-1.5,1.3,[num2str(dtime),' d'],'Color',[0 0 0])
%title([num2str(dtime),' d']);
if length(TT) > 0
  title(TT)
end

%---temp-------------
%fig_name = 'temp_slp_ERAInterim.png';
%pw = 10;
%ph = 6;
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%---temp-------------

