%% make_composite_PM_eqAEFs.m
%
% Make a figure comparing the composite polar motion signals across all ERA-40/ERA-Interim
% SSWs, along with their corresponding mass excitation functions, 
% and comparing all events to only the "strong"/PJO events.
%
% Lisa Neef, 3 September 2012
%----------------------------------------------------------------------

clc;
clear all;



%% Inputs & settings
set1 = 1;     % (All events)
set2 = 10;    % (PJO events only)

dtime = 50;    % how many days before / after the CD
hostname = 'blizzard';
col = [0 0.4 1];
shading = 0;
latband = [-90,90];

%% plot settings & figure initialization
figH = figure('visible','off');


%% make four plots

subplot(2,2,1)
  h = zeros(1,2);
  [~,h(1)] = plot_composite_ERPs('X1',set1,dtime,hostname);
  hold on
  [~,h(2)] = plot_composite_AEFs('X1','m',set1,latband,hostname,col,shading);
  title('(a) ALL')
  legend(h,'p_1','\chi_1','Location','NorthWest')
  legend('boxoff')
  set(gca,'XTick',[-50:10:50])

subplot(2,2,2)
  h = zeros(1,2);
  [~,h(1)] = plot_composite_ERPs('X1',set2,dtime,hostname);
  hold on
  [~,h(2)] = plot_composite_AEFs('X1','m',set2,latband,hostname,col,shading);
  title('(b) STRONG')
  legend(h,'p_1','\chi_1','Location','NorthWest')
  legend('boxoff')
  set(gca,'XTick',[-50:10:50])

subplot(2,2,3)
  h = zeros(1,2);
  [~,h(1)] = plot_composite_ERPs('X2',set1,dtime,hostname);
  hold on
  [~,h(2)] = plot_composite_AEFs('X2','m',set1,latband,hostname,col,shading);
  title('(c) ALL')
  legend(h,'p_2','\chi_2','Location','NorthWest')
  legend('boxoff')
  set(gca,'XTick',[-50:10:50])

subplot(2,2,4)
  h = zeros(1,2);
  [~,h(1)] = plot_composite_ERPs('X2',set2,dtime,hostname);
  hold on
  [~,h(2)] = plot_composite_AEFs('X2','m',set2,latband,hostname,col,shading);
  title('(d) STRONG')
  legend(h,'p_2','\chi_2','Location','NorthWest')
  legend('boxoff')
  set(gca,'XTick',[-50:10:50])

%% plot export

fig_name = 'composite_PM_AEF.png';
pw = 10;
ph = 10;
exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
close(figH)



