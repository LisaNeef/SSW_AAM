function plot_wind_anomaly_composite(SSW_set,dtime,hostname,TT,lat_weighting,mass_weighting)
%
% Make a plot of the composite wind anomaly field over a set of SSW events, for 
% a given delta_time (in days) relative to the central date.
%
% Lisa Neef, 26 July 2012
% this is based on code from polar_anomgeopot_composit.m by Sophia Walther
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
%   TT: the string that we want to slap on this plot as a title.
%   lat_weighting = which AEF we want to weight the latitudes for ('X1','X2','X3', or 'none')
%
% MODS:
%  16 Aug 2012: add the option of also weighting the plots by mass (i.e. 
%    pressure per level)
%  17 Aug 2012: add settings for PJO events
%  31 Aug 2012: adding flexibility to the code to accomodate joint ERA-Interim/40 data
%
%
%---------------------------------------------------------------------------


% temporary inputs
%clear all;
%clc;
%SSW_set = 1;
%dtime = 0;
%hostname = 'blizzard';
%TT = 'test plot: wind anomalies!';
%lat_weighting = 'X3';
%mass_weighting = 1;
%figH = figure('visible','off');

%---------------------------------------------------------------------------

%% load the geopotential fields for this SSW event subset

[GG,lat0,lev0] = compute_wind_anomaly_composite(SSW_set,dtime,hostname);
Gm = mean(GG,3);

%% compute the bootstrap confidence intervals for each point

nlev = length(lev0);
nlat = length(lat0);
C = zeros(nlat,nlev,2);
nboot = 100;

for ilev = 1:nlev
  for ilat = 1:nlat
    C(ilat,ilev,:) = bootci(nboot,{@mean,GG(ilat,ilev,:)},'alpha',0.1);
  end 
end

% these are anomalies, so everything where the CI crosses zero is statistically insignificant.
% if there is a sign change, then the prdocut of the two CI bounds is negative; for no sign 
% change it has to be positive.
sign_change = C(:,:,1).*C(:,:,2);
mask_out = find(sign_change < 0);
Gm(mask_out) = 0;

%% define the grid and plot settings
[X,Y] = meshgrid(lat0,lev0./100);
%col = seq_yellow_green_blue9;
col = flipud(div_red_yellow_blue11);

% since we are setting everything that gets "masked out" to zero, it's 
% probably best to make the zero contour white (not yellow)
  col(6,:) = ones(1,3);


% define the contour lines, depending on which variable is plotted.
  w=10*[-1:1];

% retrieve the geographic weighting function for the desired AEF
W = eam_weights(lat0,0,lat_weighting,'U');
W2 = (ones(nlev,1)*W)';
if strcmp(lat_weighting,'none')
  Gm2 = Gm;
else
  Gm2 = W2.*Gm;
end

% mass weighting: if desired, retrieve pressure level info from the data file, and weight each
% vertical layer by the pressure difference covered in that layer.

if mass_weighting
  lev2 = ones(nlat,1)*flipud(lev0)';
  Gm3 = lev2.*Gm2;
else
  Gm3 = Gm2;
end

%% Plot! 


[ci,hi] = contourf(X,Y,Gm2','-','Color',1*ones(1,3));
%[ci,hi] = contourf(X,Y,Gm2',w,'-','Color',1*ones(1,3));

caxis([min(w) max(w)]);
colormap(col)
set(gca,'YScale','log')
set(gca,'YTick',[0.1,1,10,100,1000])
set(gca,'YDir','Reverse')
set(gca,'XTick',[-90,-60,-30,0,30,60,90]);
set(gca,'XGrid','on')
ylabel('hPa')
xlabel('Latitude')

%text_handle = clabelm(ci,hi,w);
%set(text_handle,'BackgroundColor','none','FontSize',12);
colorbar

text(-88,3,[num2str(dtime),' d'],'Color',[0 0 0])
if length(TT) > 0
  title(TT)
end

%---temp-------------
%fig_name = 'temp_windcomposite.png';
%pw = 10;
%ph = 6;
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%---temp-------------

