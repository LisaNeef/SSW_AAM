%% make_composite_AEF_plots.m
%
% Make a plot comparing the AAM excutation function(s) over different latitude bands.
%
% Lisa Neef, 30 Aug 2012
%
%
% MODS:
%-------------------------------------------------

%% basic inputs

clear all;
clc;

% choose the computer you're on
hostname = 'blizzard';

% AAM component 
comp = 'X3';
term = 'w';

% subsets of events: all events versus the strong (PJO ones)
set1 = 1;
if strcmp(term,'m')
  set1 = 2;
end
set2 = 10;

% set the figure axes, etc.
ax = [-50,50,-0.3,0.3];

% latitude band
l1 = [-90,90];	lh1 = 'GLOBAL';
l2 = [-90,-60];	lh2 = '90S - 60S';
l3 = [-60,-30];	lh3 = '60S - 30S';
l4 = [-30,0];	lh4 = '30S - 0';
l5 = [0,30];	lh5 = '0 - 30N';
l6 = [30,60];	lh6 = '30N - 60N';
l7 = [60,90];	lh7 = '60N - 90N';
R = [l1;l2;l3;l4;l5;l6;l7];
nbands = size(R,1);

%% figure settings
ph = 6;
pw = 18;
fs = 20;
CC = zeros(nbands,3);
  CC(2:(nbands-1)/2+1,:) = (autumn((nbands-1)/2));
  CC((nbands-1)/2+2:nbands,:) = flipud(winter((nbands-1)/2));
%   CC(1,:) = 0.7*ones(1,3);
%   CC(2,:) = [206,18,86];
%   CC(3,:) = [223,101,176];
%   CC(4,:) = [215,181,216];
%   CC(5,:) = [189,201,225];
%   CC(6,:) = [116,164,207];
%   CC(7,:) = [5,11,176];
%for ii = 2:7
%  CC(ii,:) = CC(ii,:)/sum(CC(ii,:));
%end
LW = 3;

%% loop over the latitude bands and plot the individual curves.

figH = figure('visible','off');

subplot(1,2,1)
h = zeros(1,nbands);
for ii = 1:nbands
  col = CC(ii,:);
  [casestring,h(ii)] = plot_composite_AEFs(comp,term,set1,R(ii,:),hostname,col,0);
end
title('(a) ALL')
text(-30,-0.2,lh2,'Color',CC(2,:),'VerticalAlignment','top')
text(-30,-0.23,lh3,'Color',CC(3,:),'VerticalAlignment','top')
text(-30,-0.26,lh4,'Color',CC(4,:),'VerticalAlignment','top')
text(0,-0.2,lh5,'Color',CC(5,:),'VerticalAlignment','top')
text(0,-0.23,lh6,'Color',CC(6,:),'VerticalAlignment','top')
text(0,-0.26,lh7,'Color',CC(7,:),'VerticalAlignment','top')
text(30,-0.23,lh1,'Color',CC(1,:),'VerticalAlignment','top')
axis(ax)
set(gca,'XTick',[-50:10:50])      
grid on 

subplot(1,2,2)
h = zeros(1,nbands);
for ii = 1:nbands
  col = CC(ii,:);
  [casestring,h(ii)] = plot_composite_AEFs(comp,term,set2,R(ii,:),hostname,col,0);
end
title('(b) STRONG')
text(-30,-0.2,lh2,'Color',CC(2,:),'VerticalAlignment','top')
text(-30,-0.23,lh3,'Color',CC(3,:),'VerticalAlignment','top')
text(-30,-0.26,lh4,'Color',CC(4,:),'VerticalAlignment','top')
text(0,-0.2,lh5,'Color',CC(5,:),'VerticalAlignment','top')
text(0,-0.23,lh6,'Color',CC(6,:),'VerticalAlignment','top')
text(0,-0.26,lh7,'Color',CC(7,:),'VerticalAlignment','top')
text(30,-0.23,lh1,'Color',CC(1,:),'VerticalAlignment','top')
axis(ax)
set(gca,'XTick',[-50:10:50])      
grid on 
        
%% Plot export

switch hostname
  case 'blizzard'
    plot_dir = '/pf/b/b325004/Matlab/SSW/';
end 

fig_name = ['composite_',comp,term,'_latbands','.png'];
disp(['Producing figure  ',fig_name]);

    
%% make the axis look better.

    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');
close(figH)


