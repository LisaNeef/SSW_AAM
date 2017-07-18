%% make_wind_anomaly_composite_plots.m
%
%  Make plots comparing the wind anomaly composites for different times around 
%  the SSW central dates.
%
%
% MODS:
%  11 Sep 2012: add the option of making a horizontal plot (for talks)
%------------------------------------------

clc;
clear all;

%% Inputs:

% choose plot format, 'paper' or 'talk'
plot_format = 'talk';

% choose host
hostname = 'blizzard';

% choose SSW subset
SSW_set =  1; % all major warming events.
%SSW_set =  4; % vortex-displacement events
%SSW_set =  5; % vortex-splitting events
%SSW_set =  10; % PJO events


% choose whether to apply latitudinal weighting for AEFs
lat_weighting = 'X3';
mass_weighting = 1;

% define the days relative to the central date where we want to make plots.
days = [-40:20:40];

%-----------------------------------------------------------------------------

% define plot title based on SSW set
switch SSW_set
  case 1
    TT = 'ALL';
  case 4
    TT = 'Displacement';
  case 5
    TT = 'Split';
  case 10
    TT = 'STRONG';
end

% define the subplots we want in the figure.
switch plot_format
  case 'talk'
    pdim = [1,5];
    pw = 40;
    ph = 10;
    fs = 3;
  case 'paper'
    pdim = [5,1];
    pw = 10;
    ph = 35;
    fs = 4;
end



%% go through the days, call the plotting code, and add it to the plot.

figH = figure('visible','off');

ndays = length(days);
h = zeros(ndays,1);
for iday = 1:ndays

  % for vertical plots, define title based on whether it's the first plot or not.
  if strcmp(plot_format,'paper')
    if iday == 1
      TT2 = TT;
    else
      TT2 = [];
    end
  end

  if strcmp(plot_format,'talk')
    TT2 = num2str(days(iday));
  end

  h(iday) = subplot(pdim(1),pdim(2),iday);
  plot_wind_anomaly_composite(SSW_set,days(iday),hostname,TT2,lat_weighting,mass_weighting);

end

%% make the axes look nicer.
nplots = pdim(1)*pdim(2);
nrows = pdim(1);

x0 = 0.15;
dw = 0.12;
y0 = 0.95;
dy = 0.05;
if strcmp(plot_format,'talk')
  x0 = 0.04;
  dw = 0.06;
  y0 = 0.92;
  dy = 0.08;
end
w = (1-x0-pdim(2)*dw)/pdim(2);               % width per figure
ht = (y0-(nrows)*dy)/nrows;          % height per figure

for k = 1:pdim(1)*pdim(2)
  switch plot_format
    case 'paper'
      x = x0;
      y = y0 - k*ht - (k-1)*dy;
    case 'talk'
      x = x0+(k-1)*(dw+w);
      y = y0-ht;
  end
  set(h(k),'Position',[x y w ht])
end


%% export!

pref = ['wind_anom_'];
if strcmp(lat_weighting,'none')
  suff = '';
else
  suff = ['weight',lat_weighting];
end

if mass_weighting
  suff = [suff,'_mass_weighting'];
end

switch plot_format
  case 'paper'
    suff2 = '';
  case 'talk'
    suff2 = '_paper';
end

switch SSW_set
  case 1
    fig_mid = 'all_events';
  case 4
    fig_mid = 'disp_events';
  case 5
    fig_mid = 'split_events';
  case 10
    fig_mid = 'PJO_events';
end

fig_name = [pref,fig_mid,'_',num2str(min(days)),'_',num2str(max(days)),suff,suff2,'.png'];

exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)
close(figH)




