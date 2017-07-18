%% plot_composite_p_time_U.m
function plot_composite_p_time_U(SSW_set,dtime,hostname,TT,bootstrap)
%
% Make a composite plot of zonal-mean zonal wind over pressure levels and time, 
% centered on the central date, over a given subset of SSW events.
%
% Lisa Neef, 21 Aug 2012
%
% INPUTS:
%
% MODS:
%   23 Aug 2012: make it option to apply the bootstrap significance estimate.
%-------------------------------------------------------------------------------------------


%---temp inputs------
%clc;
%clear all;
%SSW_set = 1;
%dtime = 40;
%hostname = 'blizzard';
%TT = 'ALL';
%bootstrap = 1;
%figH = figure('visible','off');
%---temp inputs------


%% load the 60hPa anomalous wind fields for this subset
[GG,time,lev] = compute_composite_p_time_U(SSW_set,dtime,hostname);
Gm = mean(GG,3);

if bootstrap
  %% compute the bootstrap confidence intervals for each point

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
% here level is put into hPa (instead of Pa)
[X,Y] = meshgrid(time,lev./100);
%col = seq_yellow_green_blue9;
col = flipud(div_red_yellow_blue11);

% since we are setting everything that gets "masked out" to zero, it's
% probably best to make the zero contour white (not yellow)
  col(6,:) = ones(1,3);

% define the contour lines, depending on which variable is plotted.
  w=[-45:5:45];

%% Plot!



[ci,hi] = contourf(X,Y,Gm','-','Color',1*ones(1,3));
[ci,hi] = contourf(X,Y,Gm',w,'-','Color',1*ones(1,3));

caxis([min(w) max(w)]);
colormap(col)
set(gca,'YScale','log')
%set(gca,'YTick',[1,10,100,1000])
set(gca,'YDir','Reverse')
ylabel('hPa')
%xlabel('Days Relative to Central Date')

%text_handle = clabelm(ci,hi,w);
%set(text_handle,'BackgroundColor','none','FontSize',12);

cbax = colorbar('Location','SouthOutside');
PP = get(cbax,'Position')
PP2 = PP;
PP2(2) = 0.99*PP(2);
set(cbax,'Position',PP2);
set(cbax,'xaxisloc','top');

if length(TT) > 0
  title(TT)
end

%---temp-------------
%fig_name = 'p_time_wind_all.png';
%pw = 10;
%ph = 6;
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%---temp-------------






