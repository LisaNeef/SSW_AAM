%% make_composite_AEF_tropicsonly.m
%
% Make a plot comparing the AAM excutation function(s) over different tropical latitude bands.
%
% Lisa Neef, 14 Sp 2012
%
%
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
set2 = 10;

% set the figure axes, etc.
ax = [-70,70,-0.3,0.3];

% latitude band
l1 = [-90,90];	lh1 = 'GLOBAL';
l2 = [-30,0];	lh2 = '30S - 0';
l3 = [0,30];	lh3 = '0 - 30N';
R = [l1;l2;l3];
nbands = size(R,1);

%% figure settings
ph = 6;
pw = 18;
fs = 20;
CC = zeros(nbands,3);
  CC(2:(nbands-1)/2+1,:) = (autumn((nbands-1)/2));
  CC((nbands-1)/2+2:nbands,:) = flipud(winter((nbands-1)/2));


LW = 3;

%% loop over the latitude bands and plot the individual curves.

figH = figure('visible','off');

subplot(1,2,1)
h = zeros(1,nbands);
for ii = 1:nbands
  col = CC(ii,:);
  [casestring,h(ii)] = plot_composite_AEFs(comp,term,set1,R(ii,:),hostname,col,1);
end
title('(a) ALL')
legend(h,lh1,lh2,lh3)
legend('Orientation','Vertical')
legend('boxoff')
axis(ax)
grid on

subplot(1,2,2)
h = zeros(1,nbands);
for ii = 1:nbands
  col = CC(ii,:);
  [casestring,h(ii)] = plot_composite_AEFs(comp,term,set2,R(ii,:),hostname,col,1);
end
title('(b) STRONG')
legend(h,lh1,lh2,lh3)
legend('Orientation','Vertical')
legend('boxoff')
axis(ax)
grid on

switch hostname
  case 'blizzard'
    plot_dir = '/pf/b/b325004/Matlab/SSW/';
end 

fig_name = ['composite_',comp,term,'_tropicallatbands','.png'];


    
%% make the axis look better.

    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');
close(figH)


