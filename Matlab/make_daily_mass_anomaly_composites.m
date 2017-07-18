%% make_daily_mass_anomaly_composites.m
%
% Make a big pile of daily plots of mass anomaly associated with SSWs.
%
% Lisa Neef, 25 September 2012
%-------------------------------------------------------------------------------------------------------


%% plot settings

SSW_set = 10;
T = -40:2:40;	% day steps around the central date.
variable = 'slp';
level = 0;
hostname = 'blizzard';

pw = 10;
ph = 10;


%% cycle through the plotting code and create and export plots
nplots = length(T);
switch SSW_set
  case 1
    suffix = '_all_events';
  case 10
    suffix = '_PJO_events';
end

for ii = 1:nplots

  % initialize figure
  figH = figure('visible','off');

  % make the plot
  TT = [variable,' ,day',num2str(T(ii))];
  plot_mass_anomaly_composite(SSW_set,T(ii),variable,level,hostname,TT)

  % export the figure
  if T(ii) < 0
    short = 2;
    if length(T(ii)) == short
      num_label = ['-0',num2str(abs(T(ii)))];
    else
      num_label = num2str(T(ii));
    end
  else
    short = 1;
    if length(T(ii)) == short
      num_label = ['0',num2str(abs(T(ii)))];
    else
      num_label = num2str(T(ii));
    end
  end
  fig_name = ['mass_anom_',variable,'_day',num_label,suffix,'.png']

  % close the figure
  exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
  close(figH)

end




