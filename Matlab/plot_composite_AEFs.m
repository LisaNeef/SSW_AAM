function [casestring,axhandle] = plot_composite_AEFs(comp,term,SSW_set,latband,hostname,col,shading)
% plot_composite_AEFs.m
% Make plots of composite AAM excitation functions over a given set of SSW
% events.  Based on plot_integration_neu.m by Sophia Walther
% Code version overhauled by Lisa Neef, starting 3 April 2012.
%
% INPUT:
%   comp: the AAM component to plot
%   term: 'w','m', or 't' for their total
%   SSW_set: code for which set of events to plot.
%   composite: set to 1 to show the mean and bootstrap interval, 0 to show
%   all runs.
%   latband: 1x2 array denoting the latitude limits over which we are computing this composite.
%
%   annotation_type:
%   1 = print the AEF and term
%   2 = print the type of event over which the composite is computed.
%
% MODS:
%   8 May 2012: making the shading neater.
%   9 May 2012: make the shading include transparancy using jbfill (note
%   that jbfill doesn't work well for eps files, so I've left the commands
%   for shadedplot to use later, if needed.)
%   25 May 2012: add the possibility of plotting AEFs integrated over only
%   a certain latitude region 
%   17 Aug 2012: add the option of plotting AEFs for PJO events (Hitchcock
%   et al 2012)
%   28 Aug 2012: instead of plotting AEFs by a given region, do it by latitude band.
%   30 Aug 2012: more organized about where the AEF data are - you have to get them off storage.
%   30 Aug 2012: make it possible to specify the color of the curve & shading externally.
%   30 Aug 2012: make it optional to have the shading for the significance bounds.
%   14 Sep 2012: change "SSW_set 2" to the ERA-Interim events only.

%------ temp inputs:
%clc;
%clear all;
%comp = 'X2';
%term = 'w';
%SSW_set = 2;
%latband = [-90,90];
%figH = figure('visible','off');
%hostname = 'blizzard';
%col= rand(1,3);
%shading = 1;
%------ temp inputs:

%% key for the precomputed data
switch SSW_set
    case 1
        aef_file_prefix = [comp,'_all_events'];
        casestring = 'All Events';
    case 2
        aef_file_prefix = [comp,'_ERAinterim_events'];
        casestring = 'ERA-Interim Only';
    case 10
        aef_file_prefix = [comp,'_PJO_events'];
        casestring = 'Troposphere Events';
end

%% retrieve the precomputed AEFs for this set
switch hostname
  case 'blizzard'
    datadir = '/work/bb0519/b325004/SSW/';
  otherwise
    disp(['hostname ',hostname,' is not yet supported in this code.']);
end

if latband == [-90,90]
  aef_file_suffix = '.mat';
else 
  aef_file_suffix = ['_',num2str(latband(1)),'_',num2str(latband(2)),'.mat'];
end

aef_file = [datadir,aef_file_prefix,aef_file_suffix];

load(aef_file)
t = TT(1,:);


%% extra computations

% take out the average of each AEF
XW_dt = detrend(XW','constant')';
XM_dt = detrend(XM','constant')';

% compute the means

XWmean = nanmean(XW_dt,1);
XMmean = nanmean(XM_dt,1);


% compute 95% bootstrap confidence interval

nboot=1000;
CW=zeros(2,length(t));
CM=zeros(2,length(t));

for ii =1:length(t)
    good = isfinite(XW_dt(:,ii));
    CW(:,ii)=bootci(nboot,@mean,XW_dt(good,ii));
    CM(:,ii)=bootci(nboot,@mean,XM_dt(good,ii));
end


%% some plot settings

switch comp
    case {'X1','X2'}
        YL = 'milliarcseconds';
        ylim = 30*[-1,1];
    case 'X3'
        YL = 'milliseconds';
        ylim = 0.2*[-1,1];
end

%% plots!

switch term
    case 'w'
        x = XWmean;
        xtop = CW(2,:);
        xbot = CW(1,:);
    case 'm'
        x = XMmean;
        xtop = CM(2,:);
        xbot = CM(1,:);
    case 't'
        x = XMmean + Xwmean;
        xtop = CM(2,:);
        xbot = CM(1,:);
end

transparency = 0.5;
if shading
  shadedplot(t,xbot,xtop,col,col);
  %jbfill(t,xbot,xtop,col,col,1,transparency)
  hold on
end
axhandle = plot(t,x,'Color',0.8*col,'LineWidth',3);
hold on
ylabel(YL)
xlabel('Days Relative to Central Date')
set(gca,'YLim',ylim)
   
%----temp-------
%fig_name = 'temp_AEFcomposite.png';
%pw = 15;
%ph = 6;
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%----temp-------


