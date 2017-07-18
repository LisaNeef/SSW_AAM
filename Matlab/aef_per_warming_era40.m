%function [t_out,X_out] = aef_per_warming_era40(comp,variable,cdate,dt)
%% function aef_per_warming_era40.m: 
%   retrieve the AAM excitation function for a given SSW event.
%   code based on richtig_integration_pol.m by Sophia Walther
%   adapted and modified by Lisa Neef, starting 4 April 2012
%
%  version _era40 by Lisa Neef, 23 May 2012: 
%   changing file and variable paths for era40 extended data I got on
%   Klimod.
%
%  INPUTS:
%   comp: the AAM component that we want (X1, X2, or X3)
%   var : the variable that we want to integrate
%   cdate: the central date of the warming that we are interested in
%           format: [YYYY,MM,DD] (numbers)
%   dt: the radius of time around the central date, in days


%% temporary inputs
clear all; clc;
comp = 'X1';
variable = 'PS';
cdate = [1981,12,4];
dt = 40;


%% figure out which files need to be read in for this event.

% select the boundary dates 
cdate_mjd = date2mjd(cdate(1),cdate(2),cdate(3));
mjdf = cdate_mjd + dt;
mjd0 = cdate_mjd - dt;

[y0,m0] = mjd2date(mjd0);
[~,mf] = mjd2date(mjdf);

% arrays of years and months to loop over
if mf > m0
    % in this case the array of months is easy
    mm = m0:1:mf;
else
    % if we cross a year, have to be more elaborate
    mm = [m0:12,1:mf];
end
    
nf = length(mm);

% array of years
yy = y0+zeros(1,nf);
for imonth = 2:length(mm)
    if mm(imonth) < mm(imonth-1)
        yy(imonth) = y0+1;
    end
end
new_year_start = find(yy == y0+1);
yy(new_year_start:nf) = y0+1;

% file path leading to the date
%datadir = '/home/ig/swalther/paper/potsdam/daten/';
%pref  = 'era-interim-';
%suff  = '-T42.nc';
datadir = '/dsk/nathan/lisa/ERA40/'
pref = 'era40_';
suff = '.nc';


%% cycle over the files for each month needed and load the data

% large arrays to hold the data
mjd = mjd0:1:mjdf;
nt = length(mjd);
break

for ii = 1:nf;

    month = num2str(mm(ii));
    if length(month) == 1
        month = ['0',month];
    end
    fname = [datadir,pref,num2str(yy(ii)),month,suff];
    
    if exist(fname,'file')
        
        % on the first file, load dimension arrays, and initialize X
        if ii == 1
            lat = nc_varget(fname,'lat');
            lon = nc_varget(fname,'lon');
            nlat = length(lat);
            nlon = length(lon);
            if strcmp(variable,'U') || strcmp(variable,'V')
                lev = nc_varget(fname,'lev');
                nlev = length(lev);
            end
            switch variable
                case 'PS'
                    X = zeros(nt,nlat,nlon)+NaN;
                case {'U','V'}
                    X = zeros(nt,nlev,nlat,nlon)+NaN;
            end
        end
        
        % load time array
        time = nc_varget(fname,'time');
        
        % load other arrays, depending on the variable.
        switch variable
            case 'PS'
                x = nc_varget(fname,'var134');
            case 'U'
                x = nc_varget(fname,'var131'); 
            case 'V'
                x = nc_varget(fname,'var132'); 
        end
    
        % figure out which days of this array to record
        ref_day = date2mjd(yy(ii),mm(ii),1,0,0,0);
        mjd_t0 = round(time(1))+ref_day;
        mjd_tf = round(max(time))+ref_day;
        if mjd_t0 < mjd0
            % first day of this month is outside out interested period, so
            % start at the beginning of the period
            mjd_start = mjd0;
        else 
            % first day of this month is in the focus period, so start there.
            mjd_start = mjd_t0;
        end
    
    
        if mjd_tf > mjdf
            % last day of this month is outside the period - only go to the end
            % of the period
            mjd_stop = mjdf;
        else
             % last day of this month is within the period - go all the way to
            % this day
            mjd_stop = mjd_tf;
        end
    
    
        % sort the retrieved data into the waiting arrays.
        mjd_temp = round(time)+ref_day;
        after_start_day = find(mjd_temp >= mjd_start);
        before_end_day = find(mjd_temp <= mjd_stop);
        focus = intersect(after_start_day,before_end_day);

        % and these are the indices for the large array
        k1 = find(mjd == (mjd_start) );
        k2 = find(mjd == (mjd_stop) );
    
        switch variable 
            case 'PS'
                X(k1:k2,:,:) = x(focus,:,:);
            case {'U','V'}
                X(k1:k2,:,:,:) = x(focus,:,:,:);
        end
    
    
    else
        disp(['Cant find the file  ',fname])
        return
    end
    
end

% also set up lon and lat arrays in radians
rlon=lon*pi/180;
rlat=lat*pi/180;

 
%% load some other stuff that's needed for the integration

%  the weights for this variable  
w = eam_weights(lat,lon,comp,variable);

% the prefactors that nondimensionalize the excitation functions
fac = eam_prefactors(comp,variable);

% sidereal LOD in milliseconds.
LOD0_ms = double(86164*1e3);     
 


%% load in the variables and integrate globally for each time.
switch variable
    case 'PS'      
        % IB approximation 
        ps = zeros(nt,nlat,nlon);
        ff_lm = '/home/ig/neef/Data/landmask_emac_T42.nc';
        slm = nc_varget(ff_lm,'slm');
        LM = double(squeeze(slm(1,:,:)));      % land mask
        SM = double(LM*0);
        SM(LM == 0) = 1;                 % sea mask
        dxyp = gridcellarea(nlat,nlon);
        dxyp2 = dxyp*ones(1,nlon);
        sea_area = sum(sum(dxyp2.*SM));
        
        for ii=1:nt
          pstemp = double(squeeze(X(ii,:,:)));
          ps_sea_ave = sum(sum(pstemp.*SM.*dxyp2))/sea_area;
          ps_ave = pstemp.*LM+ps_sea_ave*SM;
          ps(ii,:,:) = ps_ave;
        end
       
        % Set up the array papa1a, which represents the weighted variables.
        papa1a = zeros(size(ps));
        for i=1:nt
            papa1a(i,:,:)=squeeze(ps(i,:,:)).*w';
        end

            
        papa1=squeeze(papa1a);
       
        %Integration über lon
        ps2 = zeros(nt,nlat);
        for i=1:nt
            for j=1:nlat
                ps2(i,j)=trapz(rlon,squeeze(papa1(i,j,:)));
            end                         
        end
     
 
        % Integration über lat
        ps3=zeros(1,nt);
        for i=1:nt
            %a negative sign enters here because latitude array is defined
            %in opposite direction of the integral.
            ps3(i) = -trapz(rlat,ps2(i,:));
        end
                 
     
        % Vorfaktoren

        switch comp
            case 'X1'
                ps4=ps3*fac*360*3600*1000/(2*pi);
            case 'X2'
                ps4=ps3*fac*360*3600*1000/(2*pi);
            case 'X3'
                ps4=ps3*fac*LOD0_ms;
        end
     
    
        % Speichern
        %fid = fopen(strcat(num2str(comp),'_',num2str(var),'vgl_1989_1990.txt'), 'w');
        %fprintf(fid, '%i \n',ps4');
        %fclose(fid);
      
    case {'U','V'}
                  
       % Set up the array papa1, which represents the weighted variables.
        papa1 = zeros(nt,nlev,nlat,nlon);
        for i=1:nlev
            for j=1:nt
                papa1(j,i,:,:)=squeeze(X(j,i,:,:)).*w';
            end                        
        end
    
      
        
       %Integration über lon
       ps2 = zeros(nt,nlev,nlat);
       for i=1:nlev   % i over levels
           for j=1:nlat  % j over lat 
               for k=1:nt % k over time
                   ps2(k,i,j)=trapz(rlon,papa1(k,i,j,:),4);   
               end             
           end        
       end                        
 
       
       % Integration über lat
       % add a negative sign here because the lat array is defined
       % North-South but the integral is defined the other way.
       ps3a=zeros(nt,nlev);
       for i=1:nlev  % i over levels
           for j=1:nt  % j over time
               ps3a(j,i)=-trapz(rlat,ps2(j,i,:),3);
           end               
       end
       
     
       % Integration über lev
       ps3 = zeros(1,nt);
       for i=1:nt
           ps3(i) = -trapz(lev,ps3a(i,:),2);
       end

    
      
       switch comp
           case 'X1'
               ps4=ps3*fac*360*3600*1000/(2*pi);
           case 'X2'
               ps4=ps3*fac*360*3600*1000/(2*pi);
           case 'X3'
               ps4=ps3*fac*LOD0_ms;
       end        

       
       % Speichern
       %fid = fopen(strcat(num2str(comp),'_',num2str(var),'vgl_1989_1990.txt'), 'w');
       %fprintf(fid, '%i \n',ps4');
       %fclose(fid); 

end
 


%% prepare output
t_out = mjd;
X_out = ps4;


 