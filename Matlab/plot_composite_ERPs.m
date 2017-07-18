function [casestring,axhandle] = plot_composite_ERPs(comp,SSW_set,dtime,hostname)
% plot_composite_ERPs.m
% Make plots of composite ERPs over a given set of SSW
% events. 
% Based on plot_composite_AEFs by Lisa Neef
% 7 May 2012
%
% MODS: 
%   22 May 2012: changing the composite sets that we look at.
%
% INPUT:
%   comp: the AAM component to plot
%   dtime: radius of time around the central date to plot
%   SSW_set: code for which set of events to plot.
%
%   annotation_type:
%   1 = print the AEF and term
%   2 = print the type of event over which the composite is computed.


%% temp input
%clear all;
%clc;
%comp = 'X1';
%dtime = 70;
%hostname = 'blizzard';
%SSW_set = 1;
%annotation_type = 1;
%figH = figure('visible','off');
%--------------

%% key for the precomputed data
switch SSW_set
    case 1
        casestring = 'All Events';
    case 2
        casestring = 'ERA-Interim Events';
    case 3
        casestring = 'Weak Events';
    case 4
        casestring = 'Displacement';
    case 5
        casestring = 'Split';
    case 6
        casestring = '15 hPa Strong Anomaly Events';
    case 7
        casestring = '15 hPa Weak Anomaly Events';
    case 8
        casestring = 'Nakagawa Troposphere Warm Events';
    case 9
        casestring = 'Nakagawa Troposphere Cold Events';
    case 10
        casestring = 'PJO Events';
end

%% read in the ERPs for this set


[XX,TT] = compute_composite_ERPs(comp,dtime,SSW_set,hostname);
t = TT(1,:);

%% extra computations

% take out the mean of each timeseries
XX_dt = detrend(XX','constant')';

% compute the mean
XXmean = nanmean(XX_dt,1);

% compute 95% bootstrap confidence interval

nboot=1000;
C = zeros(2,length(t));

for ii =1:length(t)
    good = isfinite(XX_dt(:,ii));
    C(:,ii)=bootci(nboot,{@mean,XX_dt(good,ii)},'alpha',0.1);
end


%% some plot settings
col = 0.7*[1 1 1];

switch comp
    case {'X1','X2'}
        YL = 'millarcseconds';
        ylim = 30*[-1,1];
    case 'X3'
        YL = 'milliseconds';
        ylim = 0.2*[-1,1];
end

%% plots!

shadedplot(t,C(1,:),C(2,:),col,col);
hold on
axhandle = plot(t,XXmean,'Color',0.4*col,'LineWidth',2);

ylabel(YL)
xlabel('Days Relative to Central Date')
set(gca,'Ylim',ylim)

%---temp
%pw = 10; ph = 10;
%fig_name = 'test_ERPplot.png';
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%---temp

