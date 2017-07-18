%% make_mass_anomaly_composite_plots.m
%
%  Make plots comparing the geopotential anomaly composites for different times around 
%  the SSW central dates.
%
%------------------------------------------

clc;
clear all;

%% Inputs:

% choose host
hostname = 'blizzard';

% choose whether to plot geopotential height or SLP
variable = 'slp';
level = 1000;

% choose SSW subset
SSW_set =  1; % all major warming events.
%SSW_set =  10; % PJO events only

% define the days relative to the central date where we want to make plots.
days = [-40:20:40];

% define plot title based on SSW set
switch SSW_set
  case 1
    TT = 'ALL';
  case 4
    TT = 'Disp';
  case 5
    TT = 'Split';
  case 10
    TT = 'STRONG';
end

% define the subplots we want in the figure.
%pdim = [1,5];
%  pw = 30;
%  ph = 10;
pdim = [5,1];
  pw = 10;
  ph = 35;
  fs = 4;


%% go through the days, call the plotting code, and add it to the plot.

figH = figure('visible','off','Color','white');

ndays = length(days);
h = zeros(ndays,1);
for iday = 1:ndays

  % define title based on whether it's the first plot or not.
  if iday == 1
    TT2 = TT;
  else
    TT2 = [];
  end
  
  subplot(pdim(1),pdim(2),iday)
  h(iday) = plot_mass_anomaly_composite(SSW_set,days(iday),variable,level,hostname,TT2);

end

%% make the axes look nicer.
nplots = pdim(1)*pdim(2);
nrows = pdim(1);

x0 = 0;
y0 = 0.94;
dy = 0.02;
dw = 0;
w = (1-dw-x0)/pdim(2);               % width per figure
ht = (y0-(nrows)*dy)/nrows;          % height per figure

for k = 1:pdim(1)
  y = y0 - k*ht - (k-1)*dy;
  set(h(k),'Position',[x0 y w ht])
end


%% export!

pref = [variable,'_anom_'];

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

fig_name = [pref,num2str(level),'hPa_',fig_mid,'_',num2str(min(days)),'_',num2str(max(days)),'.png'];

exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)
close(figH)




