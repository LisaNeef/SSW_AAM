%% make_composite_wind_temp_ERP_AEF.m
%
% Make a figure that compares major SSW composite wind anomalies,
% temp anomalies, LOD and X3.
% Two subsets of events are compared: (1) all events, and (2) PJO events
% (after Hitchcock et al, 2012)
%
% Lisa Neef, 23 Aug 2012
%
% MODS:
%  26 Sep 2012: cosmetic changes
%--------------------------------------------------------------------------------

clc;
clear all;

%% Inputs & settings
set1 = 1;     % (All events)
set2 = 10;    % (PJO events only)

dtime = 40;    % how many days before / after the CD
hostname = 'blizzard';
bootstrap = 0;

%% plot settings & figure initialization
figH = figure('visible','off');
ax = zeros(1,6);

%% 60N Wind anomaly composites

ax(1) = subplot(3,2,1);
  plot_composite_p_time_U(set1,dtime,hostname,'(a) ALL',bootstrap)
  xlim = get(gca,'XLim');
  ylim = get(gca,'YLim');
  text(0.9*xlim(2),0.2*ylim(2),'Wind','HorizontalAlignment','right')
ax(2) = subplot(3,2,2);
  plot_composite_p_time_U(set2,dtime,hostname,'(b) PJO',bootstrap)
  xlim = get(gca,'XLim');
  ylim = get(gca,'YLim');
  text(0.9*xlim(2),0.2*ylim(2),'Wind','HorizontalAlignment','right')
  

%% polar cap temp anomaly composites


ax(3) = subplot(3,2,3);
  plot_composite_p_time_DT(set1,dtime,hostname,'(c) ALL',bootstrap)
  xlim = get(gca,'XLim');
  ylim = get(gca,'YLim');
  text(0.9*xlim(2),0.2*ylim(2),'Temp','HorizontalAlignment','right')
ax(4) = subplot(3,2,4);
  plot_composite_p_time_DT(set2,dtime,hostname,'(d) STRONG',bootstrap)
  xlim = get(gca,'XLim');
  ylim = get(gca,'YLim');
  text(0.9*xlim(2),0.2*ylim(2),'Temp','HorizontalAlignment','right')
  

%% LOD and X3 composites
col = [0 0.4 1];
shading = 0;
latband = [-90,90];

ax(5) = subplot(3,2,5);
  h = zeros(1,2);
  [~,h(1)] = plot_composite_ERPs('X3',set1,dtime,hostname);
  hold on
  [~,h(2)] = plot_composite_AEFs('X3','w',set1,latband,hostname,col,shading);
  title('(e) ALL')
  legend(h,'\Delta LOD','\chi_3')
  legend('boxoff')

ax(6) = subplot(3,2,6);
  h = zeros(1,2);
  [~,h(1)] = plot_composite_ERPs('X3',set2,dtime,hostname);
  hold on
  [~,h(2)] = plot_composite_AEFs('X3','w',set2,latband,hostname,col,shading);
  title('(f) STRONG')
  legend(h,'\Delta LOD','\chi_3')
  legend('boxoff')

%% fix the axes
y0 = 0.95;
x0 = 0.1;
dx = 0.1;
dy = 0.12;
ht = (y0-3*dy)/3;
w = (1-x0-2*dx)/2;

y1 = y0-0*dy-ht;
y2 = y0-1*dy-2*ht;
y3 = y0-2*dy-3*ht;
x1 = x0;
x2 = x0+dx+w;

set(ax(1),'Position',[x1 y1 w ht])
set(ax(2),'Position',[x2 y1 w ht])
set(ax(3),'Position',[x1 y2 w ht])
set(ax(4),'Position',[x2 y2 w ht])
set(ax(5),'Position',[x1 y3 w ht])
set(ax(6),'Position',[x2 y3 w ht])


%% plot export

fig_name = 'composite_wind_temp_ERP_AEF.png';
pw = 20;
ph = 20;
exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
close(figH)

