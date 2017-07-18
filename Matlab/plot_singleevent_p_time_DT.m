%function plot_singleevent_p_time_DT(SSW_set,dtime,hostname,TT,bootstrap)
% plot_singleevent_p_time_DT.m
%
% Make a plot of zonal-mean 90N-60N average temp over pressure levels and time, 
% centered on the central date, for a given SSW event defined by its central date.
%
% Lisa Neef, 25 Sep 2012
%
% INPUTS:
%  cdate: the central date of the event we're interestd in, in format [YYYY,MM,DD]
%  dtime: the number of days before and after the CD that we want to show
%  hostname: currently only supporting 'blizzard'
%  TT: the title we want on the plot
%
% MODS:
%
%-------------------------------------------------------------------------------------------


%---temp inputs------
clc;
clear all;
cdate = [2009,1,24];
dtime = 40;
hostname = 'blizzard';
TT = 'SSW of Winter 2009 - Temperature Anomaly';
figH = figure('visible','off');
%---temp inputs------


%% load the polar cap temp fields for this event 
[GG,time,lev] = retrieve_p_time_DT_single_event(cdate,dtime,hostname);

% convert the array time to modified Julian dates
mjd_cdate = date2mjd(cdate(1),cdate(2),cdate(3));
mjd0 = mjd_cdate-dtime;
mjdf = mjd_cdate+dtime;
mjd = mjd0:mjdf;

% and then convert that timeseries to something matlab likes
tt = mjd*0;
nt = length(tt);
[y,m,d] = mjd2date(mjd);
for ii = 1:nt
   tt(ii)=datenum([y(ii) m(ii) d(ii)]);
end


%% define the grid and plot settings
[X,Y] = meshgrid(tt,lev./100);
%col = seq_yellow_green_blue9;
col = flipud(div_red_yellow_blue11);

% since we are setting everything that gets "masked out" to zero, it's
% probably best to make the zero contour white (not yellow)
  col(6,:) = ones(1,3);

% define the contour lines, depending on which variable is plotted.
  w=[-3:0.5:3];


%% Plot!



[ci,hi] = contourf(X,Y,GG','-','Color',1*ones(1,3));
%[ci,hi] = contourf(X,Y,GG',w,'-','Color',1*ones(1,3));

% even out the axis
cax = get(gca,'CLim')
set(gca,'CLim',max(cax)*[-1,1])
set(gca,'XLim',[min(tt),max(tt)])
colormap(col)
set(gca,'YScale','log')
set(gca,'YTick',[0.1,1,10,100,1000])
set(gca,'YDir','Reverse')
ylabel('hPa')
datetick('x','dd-mmm')
set(gca,'XLim',[min(tt),max(tt)])
%text_handle = clabelm(ci,hi,w);
%set(text_handle,'BackgroundColor','none','FontSize',12);
colorbar('Location','SouthOutside')

if length(TT) > 0
  title(TT)
end

%---temp-------------
fig_name = 'p_time_temp_single_event.png';
pw = 10;
ph = 6;
exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
close(figH)
%---temp-------------






