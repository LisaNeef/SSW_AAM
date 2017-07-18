function plot_ssws_dT_U(year,month,day,hostname)
%% plot_ssws_dT_U.m: make plot(s) of the evolution of the temp gradient and zonal wind anomaly
%  that define the SSW event(s) in a given year.
%  This helps us understand what each particular event looked like.
%
% Lisa Neef 20 Aug 2012
%
% INPUTS:
%  year,month,date: the "central date" around which we make this plot.
%    this could be anything, but of course it's only useful if it's a real 
%    central date (i.e. 1st day of wind turnaround).
%  hostname: currently only supporting 'Blizzard'
%
% MODS:
%  26 Aug 2012: add ability to read in ERA-40 data
%  17 Sep 2012: make it choose ERA-40 vs Interim based on the year.
%------------------------------------------------------------------------------------------------


%---temp inputs------

%clear all;
%%clc;
%hostname = 'blizzard';
%year = 1985;
%month = 3; 
%day = 24;

%---temp inputs------

% choose the reanalysis set based on the year
if year < 1979
  dataset = 'ERA-40';
else
  dataset = 'ERA-Interim';
end

%% Go through the data and retrieve the wind anomaly and gradient
[DIST,MAJOR,MINOR,FINAL,MJD,gradient_6090,U] = ssw_classification_lisa(dataset,0,hostname);

%% Find the date we want, and select a +/- 40 day radius around it.

[y,m,d] = mjd2date(MJD);
target = find((y == year) & (m == month) & (d == day));

k1 = target-40;
k2 = target+40;

% now define shortened timeseries:

g = gradient_6090(k1:k2);
u = U(k1:k2);
y2 = y(k1:k2);
m2 = m(k1:k2);
d2 = d(k1:k2);
nt = length(u);
t = zeros(1,nt);

for ii = 1:nt 
  t(ii)=datenum([y2(ii) m2(ii) d2(ii)]);
end

t_cd = datenum(year,month,day);

%% initialize the figure and set plot settings

figH = figure('visible','off');
pw = 15;
ph = 15;
fs = 3;

fig_name = ['ssw_event_',num2str(year),'_',num2str(month),'_',num2str(day),'.png'];



%% make plots!

lh = zeros(1,2);
lh(1) = plot(t,u,'k','LineWidth',2);
hold on
lh(2) = plot(t,g,'k--','LineWidth',2);
plot(t,t*0,'k')
ylim = get(gca,'YLim');
plot([t_cd,t_cd],ylim,'Color',0.7*ones(1,3),'LineWidth',3)
title(['Central Date ',num2str(year),' ',num2str(month),' ',num2str(day)])
legend(lh,'Wind 10hPa, 60N','\Delta T_{60N,90N}, 10hPa')
datetick('x','dd-mmm')
%set(gca,'XTick',[min(t):10:max(t)])
%set(gca,'XTickLabelMode','auto')
set(gca,'Xlim',[min(t),max(t)])
grid minor

%% export.

exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk','FontSize',fs)
%close(figH)
