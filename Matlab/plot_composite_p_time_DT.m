%% plot_composite_p_time_DT.m
function plot_composite_p_time_DT(SSW_set,dtime,hostname,TT,bootstrap)
%
% Make a composite plot of zonal-mean 90N-60N average temp over pressure levels and time, 
% centered on the central date, over a given subset of SSW events.
%
% Lisa Neef, 22 Aug 2012
%
% INPUTS:
%  SSW_set: 
%  dtime: the number of days before and after the CD that we want to show
%  hosname: currently only supporting 'blizzard'
%  TT: the title we want on the plot
%  bootstrap: set to 1 to mask out everything that doesn't have a significant anomaly,
%   according to a stationary bootstrap algorithm.
%
% MODS:
%
%-------------------------------------------------------------------------------------------


%---temp inputs------
%clc;
%clear all;
%SSW_set = 10;
%dtime = 40;
%hostname = 'blizzard';
%TT = 'STRONG';
%---temp inputs------


%% load the polar cap temp fields for this subset
[GG,time,lev] = compute_composite_p_time_DT(SSW_set,dtime,hostname);
Gm = mean(GG,3);

%% compute the bootstrap confidence intervals for each point
if bootstrap

  nlev = length(lev);
  nt = length(time);
  C = zeros(nt,nlev,2);
  nboot = 100;

  for ilev = 1:nlev
    for ii = 1:nt
      C(ii,ilev,:) = bootci(nboot,@mean,GG(ii,ilev,:));
    end
  end

  % these are anomalies, so everything where the CI crosses zero is statistically insignificant.
  % if there is a sign change, then the prdocut of the two CI bounds is negative; for no sign
  % change it has to be positive.
  sign_change = C(:,:,1).*C(:,:,2);
  mask_out = find(sign_change < 0);
  Gm(mask_out) = 0;
end


%% define the grid and plot settings
[X,Y] = meshgrid(time,lev./100);
%col = seq_yellow_green_blue9;
col = flipud(div_red_yellow_blue11);

% since we are setting everything that gets "masked out" to zero, it's
% probably best to make the zero contour white (not yellow)
  col(6,:) = ones(1,3);

% define the contour lines, depending on which variable is plotted.
  w=[-3:0.5:3];


%% Plot!


%---temp-------------
%figH = figure('visible','off');
%---temp-------------

%[ci,hi] = contourf(X,Y,Gm','-','Color',1*ones(1,3));
[ci,hi] = contourf(X,Y,Gm',w,'-','Color',1*ones(1,3));

caxis([min(w) max(w)]);
colormap(col)
set(gca,'YScale','log')
set(gca,'YTick',[0.1,1,10,100,1000])
set(gca,'YDir','Reverse')
ylabel('hPa')
%xlabel('Days Relative to Central Date')

%text_handle = clabelm(ci,hi,w);
%set(text_handle,'BackgroundColor','none','FontSize',12);
colorbar('Location','SouthOutside')

if length(TT) > 0
  title(TT)
end

%---temp-------------
%fig_name = 'p_time_tempgrad_PJO.png';
%pw = 10;
%ph = 6;
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%---temp-------------






