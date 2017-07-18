%% make_composite_ERP_plots.m
%
% Make formatted plots showing composites of ERPs, for different sets of SSWs.
%
% Lisa Neef, 2 May 2012
%
% MODS:
%   21 May 2012: fixing and expanding the classification of event subsets
%   14 Sep 2012: various updates following the summer's code changes.
%
%

%% basic inputs

clear all;
clc;

hostname = 'blizzard';

% choose the plot type:
%plot_type = 1;       % 2: 1x2 plots comparing to AEF wind and mass terms
%plot_type = 2;       % 2: 1x2 plots comparing split versus displacement
plot_type = 3;       % 3: 1x2 plots comparing the all events and the PJO ones
%plot_type = 5;       % 5: 4x2 plots comparing all  subsets   
%plot_type = 6;        % 1x2 plot comparing NHET and Tropics
%plot_type = 7;        % compare to the wind and mass AEFs, but only for ERA-Interim events

dtime = 120;
comp = {'X2'};
compare_term = 'w';     % choose AEF to compare 'w' (wind), 'm' (mass), 'b' (both), or 'n' (none)
nfigs = 1;

%% make the plots

switch plot_type
    case 1
        % (wind vs. mass)
        nplots = 2;
        SSW_set =1;
        compare_term = {'w';'m'};
        latband = [-90,90];
    case 2
        nplots = 2;
        SSW_set = [4,5];
    case 3
        % all versus PJO
        nplots = 2;
        SSW_set = [1,10];
        latband = [-90,90];
    case 5
        nplots = 8;
        SSW_set = [1,1,4:9];
    case 6
        nplots = 2;
        SSW_set = 1;
    case 7
        % (wind vs. mass, ERA-Interim only)
        nplots = 2;
        SSW_set =2;
        compare_term = {'w';'m'};
        latband = [-90,90];
end 

h = zeros(1,nplots);


%% other settings
ncomp = length(comp);

switch plot_type 
    case {1,7}
        switch SSW_set
            case 1
                suff = 'all_events';
            case 2
                suff = 'ERAinterim_events';
            case 10
                suff = 'PJO_events';
         end
     case 3
        suff = 'comp_all_PJO';
end
%% loop over the inputs and make figures.

% export settings
LW = 2;
switch plot_type
    case {1,2,3,4,6,7}
        nrows = 1;
        ph = 4;
        pw = 10;
        fs = 18;        % fontsize
    case 5
        nrows = 4;
        ph = 3*nrows;        % paper height
        pw = ph;
        fs = 14;
end

for ifig = 1:nfigs
    
    figH = figure('visible','off');
    %figH = figure(1);
    
    for ii = 1:nplots
        
        % define the axes
        switch plot_type
            case 5
                h(ii) = subplot(4,2,ii);
            case 6
                h(ii) = subplot(1,3,ii);
            otherwise
                h(ii) = subplot(1,2,ii);
        end
        

        % make the plot of choice
        switch plot_type
            case {1,7}
                plot_composite_ERPs(char(comp(ifig)),SSW_set,dtime,hostname)
                if ~strcmp(compare_term(ii),'n')
                    hold on
                    [casestring,~] = plot_composite_AEFs(char(comp(ifig)),char(compare_term(ii)),SSW_set,latband,hostname,rand(1,3),0);
                end
            case {2,3,4,5}
                [casestring,~] = plot_composite_ERPs(char(comp(ifig)),SSW_set(ii),dtime,hostname);
                if ~strcmp(compare_term,'n')
                    hold on
                    [casestring,~] = plot_composite_AEFs(char(comp(ifig)),char(compare_term),SSW_set(ii),latband,hostname,rand(1,3),1);
                end
            case 6
                [casestring,~] = plot_composite_ERPs(char(comp(ifig)),SSW_set,dtime,hostname);
                if ~strcmp(compare_term,'n')
                    hold on
                    [casestring,~] = plot_composite_AEFs(char(comp(ifig)),char(compare_term),SSW_set,chalatband,hostname,rand(1,3),0);
                end                
        end

        % grab axis info, make y-axis symmetric
        xlim = get(gca,'Xlim');
        ylim = get(gca,'Ylim');
        ylim_max = max(ylim);
        set(gca,'Ylim',ylim_max*[-1,1])
        dxlim = xlim(2)-xlim(1);
        dylim = ylim(2)-ylim(1);
        


        % annotate the plot.
        switch plot_type
            case 1
                switch char(compare_term(ii))
                    case 'w'
                        %text(xlim(1)+.02*dxlim,ylim(1)+0.95*dylim,[char(comp), ' Motion Term'],'FontSize',16,'BackgroundColor',ones(1,3))  
                        title([char(comp), ' Motion Term'])
                    case 'm'
                        %text(xlim(1)+.02*dxlim,ylim(1)+0.95*dylim,[char(comp), ' Mass Term'],'FontSize',16,'BackgroundColor',ones(1,3))  
                        title([char(comp), ' Mass Term'])
                end
            case {2,3,4,5,6}
                %text(xlim(1)+.02*dxlim,ylim(1)+0.95*dylim,casestring,'FontSize',16) 
                title(casestring)
        end      
        
    end


    %% adjust the axes and stuff.

    linkaxes(h);
    
    x0 = 0.1;                  % left position
    if nrows > 1
        dy = 0.1;
    else
        dy = .2;
    end
    dw = .09;
    w = (1-2*dw-x0)/2;               % width per figure
    y0 = 0.90;
    ht = (y0-(nrows)*dy)/nrows;          % height per figure

    jj = 1;
    for k = 1:nrows         
       y = y0 - k*ht - (k-1)*dy;
       set(h(jj),'Position',[x0 y w ht])
       
       if jj+1 <= nplots
           set(h(jj+1),'Position',[x0+w+dw y w ht])
       end 
        
       jj = jj+2;
    end

disp('adjusting plot axes...')

    for iplot = 1:nplots
                
       set( h(iplot)              , ...
       'FontName'   , 'Helvetica' ,...
       'FontSize'   , 16         ,...
       'Box'         , 'on'     , ...
       'YGrid'       , 'on'      , ...
       'XGrid'       , 'on'      , ...
       'TickDir'     , 'in'     , ...
       'TickLength'  , [.02 .02] , ...
       'XColor'      , [.3 .3 .3], ...
       'YColor'      , [.3 .3 .3], ...
       'LineWidth'   , 1         );        
    end
    
    %% export!

disp('defining figure name...')

    % figure name also depends on plotting case
    if length(compare_term) == 1
        if strcmp(compare_term,'n')
            fig_name = ['composite_',char(comp(ifig)),'_obs_',suff,'.png']; 
        else
            fig_name = ['composite_',char(comp(ifig)),'_obs_',compare_term,'_',suff,'.png'];         
        end
    else
        fig_name = ['composite_',char(comp(ifig)),'_obs_',suff,'.png']; 
    end

disp(fig_name)
disp('just before export...')
   
    exportfig(figH,fig_name,'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');
    close(figH) ;

end

