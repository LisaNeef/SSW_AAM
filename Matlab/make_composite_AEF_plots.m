%% make_composite_AEF_plots.m
%
% Make formatted plots showing composites of wind and mass AAM excitation
% functions, for different sets of SSWs.
%
% Lisa Neef, 5 April 2012
%
%
% MODS:
%   25 May 2012: making all the plot settings way more flexible.
%   17 Aug 2012: instead of looking at "strong" events, plot type 4 looks
%   at PJO events.

% INFO ON SETTINGS:
%SSW_set = 1;        % case 1: all major warming events
%SSW_set = 2;        % case 2: the events classified as "strong" by eye
%SSW_set = 3;        % case 3: the remaining events after removing strong ones
%SSW_set = 4;        % case 4: vortex-displacement events
%SSW_set = 5;        % case 5: vortex-splitting events
%SSW_set = 6;        % case 6: events where the zonal wind anomaly goes below -15 m/s at 50 hPa.
%SSW_set = 7;        % case 7: events where the zonal wind anomaly doesn't go below 15 m/s at 50 hPa.
%SSW_set = 9;        % case 9: "troposphere cold" according to the above criterion
%SSW_set = 10;       % case 10: PJO events from Peter Hitchcock

%% basic inputs

clear all;
clc;

% choose the plot type:
%plot_type = 1;       % 1: 1x2 plots comparing the wind and mass terms
%plot_type = 2;       % 2: 1x2 plots comparing split versus displacement
%plot_type = 3;       % 3: 1x2 plots comparing the strong vs. weak events
plot_type = 4;       % 4: 1x2 plots comparing all events vs. PJO events
%plot_type = 5;       % 5: 4x2 plots comparing all  subsets   
%plot_type = 6;       % 6: 1x2 plots comparing Nakagawa & Yamazaki "warm" and "cold" events
%plot_type = 7;       % 7: 1x2 plots comparing tropics and NHET

%% make the plots

region = 'G';


switch plot_type
    case 1
        h = zeros(1,2);
        nplots = 2;
        comp = {'X1';'X2';'X3'};
        terms = {'w';'m'};
        SSW_set = 9;
        nfigs = 3;
    case 2
        nplots = 2;
        comp = {'X1'};
        terms = {'m'};
        SSW_set = [4,5];
        nfigs = 1;
    case 3
        nplots = 2;
        comp = {'X3'};
        terms = {'w'};
        SSW_set = [6,7];
        nfigs = 1;
    case 4
        nplots = 2;
        comp = {'X3'};
        terms = {'w'};
        SSW_set = [1,10];
        nfigs = 1;
    case 5        
        nplots = 8;
        SSW_set = [1,1,4:9];
        comp = {'X3'};
        terms = {'w'};
        nfigs = 1;
    case 6
        nplots = 2;
        comp = {'X3'};
        terms = {'w'};
        SSW_set = [8,9];
        nfigs = 1;
    case 7
        nplots = 2;
        comp = {'X3'};
        terms = {'w'};
        SSW_set = 1;
        region = {'TR','NHET'};
        nfigs = 1;
end           

h = zeros(1,nplots);

%% other settings
ncomp = length(comp);

switch plot_type 
    case 1
        switch SSW_set
            case 1
                suff = 'all_events';
            case 2
                suff = 'strong_events';
            case 3
                suff = 'weak_events';
            case 4
                 suff = 'displ_events';
            case 5
                  suff = 'split_events';
            case 6
                suff = 'uanom_-15ms_events';
            case 7
                suff = 'uanom_-20ms_events';
            case 8
                suff = 'Nakagawa_strong_events';
            case 9
                suff = 'Nakagawa_weak_events';
        end
     
    case 2
        suff = 'split_vs_disp';
    case 3
        suff = 'strong_vs_weak';
    case 4
        suff = 'all_vs_pjo';
    case 5
        suff = 'compare_subsets';
    case 6
        suff = 'nakagawa_warm_vs_cold';
    case 7
        suff = 'compare_regions';
end
        
    

%% loop over the inputs and make figures.

% export settings
nrows = ceil(nplots/2);
LW = 2;
switch plot_type
    case {1,2,3,4,6,7}
        ph = 4;
        pw = 10;
        fs = 18;        % fontsize
    case 5
        ph = 3*nrows;        % paper height
        pw = ph;
        fs = 14;
end

for ifig = 1:nfigs
    
    figH = figure('visible','off');
    
    for ii = 1:nplots
        
        % define the axes
        switch plot_type
            case 5
                h(ii) = subplot(4,2,ii);
            otherwise
                h(ii) = subplot(1,2,ii);
        end

        % make the plot of choice
        switch plot_type
            case 1
                [casestring,~] = plot_composite_AEFs(char(comp(ifig)),char(terms(ii)),SSW_set,region);
            case {2,3,4,5}
                [casestring,~] = plot_composite_AEFs(char(comp(ifig)),char(terms(ifig)),SSW_set(ii),region);
            case 7
                [casestring,~] = plot_composite_AEFs(char(comp(ifig)),char(terms(ifig)),SSW_set,char(region(ii)));                
        end
        
        % grab axis info, make y-axis symmetric
        xlim = get(gca,'Xlim');
        ylim = get(gca,'Ylim');
        ylim_max = max(ylim);
        
        % actually, define ylimits depending on parameter
        switch char(comp(ifig))
            case {'X1','X2'}
                ylim_max = 20;
            case 'X3'
                ylim_max = 0.25;
        end
        
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
            case {2,3,4,5,6,7}
                %text(xlim(1)+.02*dxlim,ylim(1)+0.95*dylim,casestring,'FontSize',16) 
                title(casestring)
        end      
        
        
    end





    %% adjust the axes and stuff.

    %linkaxes(h);
    
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

    plot_dir = '/home/ig/neef/Documents/Plots/SSW_AAM/';
    
    % figure name also depends on plotting case
    switch plot_type
        case 1
            fig_name = ['composite_',char(comp(ifig)),'_',suff,'.png'];
        case {2,3,4,5,6,7}
            fig_name = ['composite_',char(comp(ifig)),char(terms(ifig)),'_',suff,'.png'];        
    end

    for k = 1:nplots 
       set( h(k)                       , ...
       'FontName'   , 'Helvetica' ,...
       'FontSize'   , 16         ,...
       'Box'         , 'on'     , ...
       'YGrid'       , 'on'      , ...
       'XGrid'       , 'on'      , ...
       'TickDir'     , 'out'     , ...
       'TickLength'  , [.02 .02] , ...
       'XColor'      , [.3 .3 .3], ...
       'YColor'      , [.3 .3 .3], ...
       'LineWidth'   , 1         );
    end
   
    exportfig(figH,[plot_dir,fig_name],'width',pw,'height',ph,...
              'fontmode','fixed', 'fontsize',fs,'color','cmyk',...
              'LineMode','fixed','LineWidth',LW,'format','png');
    close(figH)

end

