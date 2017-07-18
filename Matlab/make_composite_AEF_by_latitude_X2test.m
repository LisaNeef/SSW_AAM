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
comp = 'X2';
term = 'm';

% subsets of events: all events versus the strong (PJO ones)
set1 = 1;
if strcmp(term,'m')
  set1 = 2;
end
set2 = 10;

% set the figure axes, etc.
xlim = [-70,70];

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
pw = 6;
fs = 20;
CC = zeros(nbands,3);
  CC(2:(nbands-1)/2+1,:) = (autumn((nbands-1)/2));
  CC((nbands-1)/2+2:nbands,:) = flipud(winter((nbands-1)/2));

LW = 3;

%% loop over the latitude bands and plot the individual curves.

figH = figure('visible','off');

h = zeros(1,nbands);
for ii = 1:nbands
  col = CC(ii,:);
  [casestring,h(ii)] = plot_composite_AEFs(comp,term,set1,R(ii,:),hostname,col,0);
end
title('(a) ALL')
text(-40,25,lh2,'Color',CC(2,:),'VerticalAlignment','top')
text(-40,20,lh3,'Color',CC(3,:),'VerticalAlignment','top')
text(-40,15,lh4,'Color',CC(4,:),'VerticalAlignment','top')
text(0,-15,lh5,'Color',CC(5,:),'VerticalAlignment','top')
text(0,-20,lh6,'Color',CC(6,:),'VerticalAlignment','top')
text(0,-25,lh7,'Color',CC(7,:),'VerticalAlignment','top')
text(20,-0.13,lh1,'Color',CC(1,:),'VerticalAlignment','top')
set(gca,'XLim',xlim)
grid on

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


