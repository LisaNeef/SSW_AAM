%function [casestring,axhandle] = plot_singleevent_ERPs(comp,cdate,dtime,hostname,TT)
% plot_singleevent_ERPs.m
% Make plots of ERPs over a given SSW event, defined by its central date
% events. 
% Lisa Neef, 26 September 2012
%
% MODS: 
%   22 May 2012: changing the composite sets that we look at.
%
% INPUT:
%   comp: the AAM component to plot
%   dtime: radius of time around the central date to plot
%   cdate: the central date of the event we are interested in (format [YYYY,MM,DD])
%
%   annotation_type:
%   1 = print the AEF and term
%   2 = print the type of event over which the composite is computed.


%% temp input
clear all;
clc;
comp = 'X3';
dtime = 40;
hostname = 'blizzard';
cdate = [2009,1,24];
TT = 'Observed Length-of-day';
figH = figure('visible','off');
%--------------

%% read in the ERPs for this set
[mjd,X] = erp_per_warming(comp,cdate,dtime,hostname) ;

%% define a time axis that matlab likes
tt = mjd*0;
nt = length(tt);
[y,m,d] = mjd2date(mjd);
for ii = 1:nt
   tt(ii)=datenum([y(ii) m(ii) d(ii)]);
end

t_cd = datenum(cdate);



%% take out the mean of each timeseries
%XX_dt = detrend(XX','constant')';

%% some plot settings
col = 0.7*[1 1 1];

switch comp
    case 'X1'
        YL = 'p_1 (millarcseconds)';
    case 'X1'
        YL = 'p_2 (millarcseconds)';
        ylim = 30*[-1,1];
    case 'X3'
        YL = 'LOD (milliseconds)';
        ylim = 0.2*[-1,1];
end

%% plots!

axhandle = plot(tt,X,'Color',0.4*col,'LineWidth',2);
hold on
ylim = get(gca,'YLim');
plot([t_cd,t_cd],ylim,'Color',0.5*ones(1,3),'LineWidth',3);
grid on 
xticks = min(tt):10:max(tt);
set(gca,'XTick',xticks);
datetick('x','dd-mmm','keepticks')
set(gca,'XLim',[min(tt),max(tt)])
ylabel(YL)
%set(gca,'Ylim',ylim)
title(TT);


%---temp
pw = 10; ph = 10;
fig_name = 'test_ERPplot_singleevent.png';
exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
close(figH)
%---temp

