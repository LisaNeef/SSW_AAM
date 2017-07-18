function [XX,TT] = compute_composite_ERPs(comp,dtime,SSW_set,hostname)
%% compute_composite_ERPs
% Given a certain subset of SSW events, read in the timeseries for a given
% ERP, and compute a composite timeseries and bootstrap confidence
% interval.
%
% Lisa Neef, 7 May 2012
% code loosely based on vgl_obs_composits.m by Sophia Walther and
% compute_composite_AEFs.m by Lisa Neef
%
% INPUT:
%   comp: the AAM component to plot
%   dtime: radius of time around the central date to plot
%   all runs.
%   SSW_set: code for the set of events of which to retrieve the composite.
%       1: all major warming events.
%       2: major warming events in ERA-Interim only
%       3: the remaining events after removing strong ones
%       4: vortex-displacement events
%       5: vortex-splitting events
%       6: events where the 50hPa u-anomaly is lower than -15 m/s
%       7: the remaining events after (6)
%	10: the PJO events from Hitchcock et al., 2012
%
% OUTPUT:
%   XX: array of selected ERP over the time interval and the nr of events
%   TT: corresponding matrix of times.
%
% MODS:
%  31 Aug 2012: add capability of reading PJO events (category 10)
%  12 Sep 2012: subtract out the seasonal cycle
%  18 Sep 2012: change SSW_set 2 to the ERA-Interim only events

%% temporary inputs
%clear all;
%clc;
%comp = 'X1';
%dtime = 70;
%SSW_set = 1;
%hostname = 'blizzard';

%% settings for this set.

switch SSW_set
    case 1
        cdate_file = 'major_date.txt';
        ssw_types_name = 'major_events';
    case 2
        cdate_file = 'major_date_ERAinterim.txt';
        ssw_types_name = 'strong_events';
    case 3
        cdate_file = 'major_date_schwach.txt';
        ssw_types_name = 'weak_events';
    case 4
        cdate_file = 'major_date_D.txt';
        ssw_types_name = 'displ_events';
    case 5
        cdate_file = 'major_date_S.txt';
        ssw_types_name = 'split_events';
    case 6
        cdate_file = 'major_date_uanom60N_50hPa_-15ms_stark.txt';
        ssw_types_name = 'uanom50hPa_-15ms_strong_events';
    case 7
        cdate_file = 'major_date_uanom60N_50hPa_-15ms_schwach.txt';
        ssw_types_name = 'uanom50hPa_-15ms_weak_events';
    case 8
        cdate_file = 'major_date_strong_nakagawa.txt';
        ssw_types_name = 'nakagawa_strong_events';
    case 9
        cdate_file = 'major_date_weak_nakagawa.txt';
        ssw_types_name = 'nakagawa_weak_events';
    case 10
        cdate_file = 'major_date_PJO.txt';
        ssw_types_name = 'PJO';
end

%% read in the central dates

switch hostname
  case 'blizzard'
    datadir = '/work/bb0519/b325004/SSW/';
end

if exist([datadir,cdate_file])
  CD = importdata([datadir,cdate_file],' ',0);
  nevents = size(CD,1);
else
  disp(['Cant find central date file ',cdate_file])
  return
end


%% set up some arrays

ntime=2*dtime+1;
XX = zeros(nevents,ntime);
t = -dtime:dtime;
TT = ones(nevents,1)*t;


%% cycle through the central dates and retrieve the AEFs for each event.


for ievent = 1:nevents
   
    cdate = CD(ievent,:);
    disp(cdate)
    [mjd,X] = erp_per_warming(comp,cdate,dtime,hostname) ;
   
    % subtract out the climatological AEF for this day, to get rid of seasonal effects
    [Xseas,month,day] = compute_erp_seasonalcycle(comp,hostname);
    [y,m,d]=mjd2date(mjd);              % the year, month, day series of the SSW event
    for jj = 1:length(mjd)
      target = intersect(find(month == m(jj)),find(day == d(jj)));
      XX(ievent,jj) = X(jj)-Xseas(target);
    end

end

%% sample 20 events and plot.

figH = figure('visible','off');
for ievent  = 1:min(20,nevents)
   subplot(4,5,ievent)
   plot(t,XX(ievent,:),'LineWidth',2,'Color',rand(1,3))
   hold on
   ylim = get(gca,'YLim');
   plot([0,0],[ylim(1),ylim(2)],'k-')
   title(num2str(CD(ievent,:)))
end

% export this plot
   LW = 2;
   ph = 10;        % paper height
   pw = 14;        % paper width
   fs = 14;        % fontsize
    switch hostname
      case 'blizzard'
        plot_dir = '/work/bb0519/b325004/SSW/Plots/';
    end
    fig_name = [ssw_types_name,'_',comp,'.png'];
    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');
close(figH)

