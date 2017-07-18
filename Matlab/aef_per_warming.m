function [t_out,X_out] = aef_per_warming(comp,variable,cdate,dt,latband,hostname)
%% function aef_per_warming.m: 
%   retrieve the AAM excitation function for a given SSW event.
%   code based on richtig_integration_pol.m by Sophia Walther
%   adapted and modified by Lisa Neef, starting 4 April 2012
%
%  INPUTS:
%   comp: the AAM component that we want (X1, X2, or X3)
%   var : the variable that we want to integrate
%   cdate: the central date of the warming that we are interested in
%           format: [YYYY,MM,DD] (numbers)
%   dt: the radius of time around the central date, in days
%   latband: 1x2 vector the latitude limits over which to compute the AEFs.
%   (30S-30N), or G for the whole globe.
%   hostname: currently supporting 'taku' and 'blizzard'
%
%  MODS:
%   24 may 2012: add the option of integrating only over a latitude region,
%   i.e. NHET or Tropics.
%   20 Aug 2012: make this more flexible for other computers, by adding
%   "hostname" option
%   20 Aug 2012: also taking out the IB approximation here.
%   28 Aug 2012: instead of computing AEFs by region, do it by any old latitude band
%   28 Aug 2012: also add the capability to read ERA-40 data
%    2 Sep 2012: modify the IB approximation to use the T42 ERA landmask
%   11 Sep 2012: make it so that the reanalysis set is chosen based on whether data are needed 
%                before or after 1978.  This makes it more flexible to use larger radii around the CD.
%------------------------------------------------------------------

%% temporary inputs
%%clear all; clc;
%%comp = 'X2';
%variable = 'U';
%cdate = [1989,2,21];
%dt = 120;
%latband = [-90,90];
%hostname = 'blizzard';
%-----------------------------------


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
switch hostname
    case {'blizzard','Blizzard'}
        datadir = '/work/bb0519/b325004/';
    case 'taku'
        datadir = '/home/lneef/Data/SSW/';
    otherwise
        disp('the specified hostname is not recognized...need up update paths & shit')
        return
end

%% cycle over the files for each month needed and load the data

% large arrays to hold the data
mjd = mjd0:1:mjdf;
nt = length(mjd);


for ii = 1:nf;

    month = num2str(mm(ii));
    if length(month) == 1
        month = ['0',month];
    end

    % choose the reanalysis set based on what year we have
    if yy(ii) < 1979 
      RA = 'ERA-40';
    else
      RA = 'ERA-Interim';
    end

    switch RA
      case 'ERA-Interim'
        pref  = 'ERA-Interim/era-interim-';
        if strcmp(variable,'PS')
          % for surface pressure, read the original file (it's weirdly defined)
          suff = '-T42.nc';
        else
          suff  = '-T42.nc.commonlevels';
        end
        fname = [datadir,pref,num2str(yy(ii)),month,suff];
      case 'ERA-40'
        pref  = 'ERA40/ERA40_';
        suff  = '.nc.T42.dm.commonlevels';
        fname = [datadir,pref,num2str(yy(ii)),'_',month,suff];
    end
    
    if exist(fname,'file')
        
        % on the first file, load dimension arrays, and initialize X
        if ii == 1
            lat = nc_varget(fname,'lat');
            lon = nc_varget(fname,'lon');
            nlat = length(lat);
            nlon = length(lon);
            if strcmp(variable,'U') || strcmp(variable,'V')
                switch RA
                  case 'ERA-Interim'
                    lev = nc_varget(fname,'lev');
                  case 'ERA-40'
                    lev = nc_varget(fname,'levelist');
                end
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
        switch RA
          case 'ERA-Interim'
            switch variable
              case 'PS'
                  x = nc_varget(fname,'var134');
              case 'U'
                  x = nc_varget(fname,'var131'); 
              case 'V'
                  x = nc_varget(fname,'var132'); 
            end
          case 'ERA-40'
            switch variable
              case 'PS'
                  disp('surface pressure is not available in the ERA-40 data.')
              case 'U'
                  x = nc_varget(fname,'u'); 
              case 'V'
                  x = nc_varget(fname,'v'); 
            end
         end
    
        % figure out which days of this array to record
        % note that time is defined in days relative to the first of the month in ERA-Interim,
        % but in hours relative to 1-1-1900 in ERA-40.
        switch RA
          case 'ERA-Interim'
            ref_day = date2mjd(yy(ii),mm(ii),1,0,0,0);
            mjd_t0 = round(time(1))+ref_day;
            mjd_tf = round(max(time))+ref_day;
          case 'ERA-40'
            ref_day = date2mjd(1900,1,1,0,0,0);
            mjd_t0 = round(time(1)./24+ref_day);
            mjd_tf = round(max(time)./24+ref_day);
        end

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
        switch RA
          case 'ERA-Interim'
            mjd_temp = round(time)+ref_day;
          case 'ERA-40'
            mjd_temp = round(time)./24+ref_day;
        end
        after_start_day = find(round(mjd_temp) >= round(mjd_start));
        before_end_day = find(round(mjd_temp) <= round(mjd_stop));
        focus = intersect(after_start_day,before_end_day);
    
        % and these are the indices for the large array
        k1 = min(find(mjd >= round(mjd_start)));
        k2 = max(find(mjd <= round(mjd_stop)));
   
        switch variable 
            case 'PS'
              if strcmp(RA,'ERA-40')
                disp('We dont yet have ps data in ERA-40 -- loading a precomputed AEF from the IERS instead.')
                [t_out,X_out] = aef_per_warming_precomputed(comp,'m',cdate,dt,hostname);
                dont_integrate = 1;
              else
                X(k1:k2,:,:) = x(focus,:,:);
                %disp('temporarily loading precomputed wind AEFs.  change this back later!!')
                %[t_out,X_out] = aef_per_warming_precomputed(comp,'w',cdate,dt,hostname);
                %dont_integrate = 1;
                dont_integrate = 0;
              end
            case {'U','V'}
                X(k1:k2,:,:,:) = x(focus,:,:,:);
                %disp('temporarily loading precomputed wind AEFs.  change this back later!!')
                %[t_out,X_out] = aef_per_warming_precomputed(comp,'w',cdate,dt,hostname);
                %dont_integrate = 1;
                dont_integrate = 0;
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


%% define the latitudinal integration bounds
if lat(1) < lat(nlat)
  lat0 = min(find(lat > latband(1)));
  latf = max(find(lat < latband(2)));
else
  latf = max(find(lat > latband(1)));
  lat0 = min(find(lat < latband(2)));
end

nlat2 = length(lat0:latf);

% also adjust the weight matrix.
w2 = w(:,lat0:latf);

% also make a new rlat array
rlat2 = rlat(lat0:latf);


%% load in the variables and integrate globally for each time.
%% unless the dont_integrate flag is set, in which case we've already loaded the AEFs
if ~dont_integrate
  switch variable
    case 'PS'
        % IB approximation 
        ps = zeros(nt,nlat2,nlon);
        switch RA
          case 'ERA-Interim'
            ff_lm = [datadir,'ERA-Interim/','ERA_landmask_T42.nc'];
          case 'ERA-40'
            ff_lm = [datadir,'ERA40/','ERA_landmask_T42.nc'];
        end
        %LM = nc_varget(ff_lm,'lsm');	 % land mask
        %SM = double(LM*0);
        %SM(LM == 0) = 1;                 % sea mask
        %dxyp = gridcellarea(nlat,nlon);
        %dxyp2 = dxyp*ones(1,nlon);
        %sea_area = sum(sum(dxyp2.*SM));
        %for ii=1:nt
        %  pstemp = double(squeeze(X(ii,:,:)));
        %  ps_sea_ave = sum(sum(pstemp.*SM.*dxyp2))/sea_area;
        %  ps_ave = pstemp.*LM+ps_sea_ave*SM;
        %  ps(ii,:,:) = ps_ave(lat0:latf,:);
        %end
        ps = double(squeeze(X(:,lat0:latf,:)));

        % Set up the array papa1a, which represents the weighted variables.
        papa1a = zeros(size(ps));
        for i=1:nt
            papa1a(i,:,:)=squeeze(ps(i,:,:)).*w2';
        end

            
        papa1=squeeze(papa1a);
       
        %Integration über lon
        ps2 = zeros(nt,nlat2);
        for i=1:nt
            for j=1:nlat2
                ps2(i,j)=trapz(rlon,squeeze(papa1(i,j,:)));
            end                         
        end
     
 
        % Integration über lat
        ps3=zeros(1,nt);
        for i=1:nt
            %a negative sign enters here because latitude array is defined
            %in opposite direction of the integral.
            ps3(i) = -trapz(rlat2,ps2(i,:));
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
      
    case {'U','V'}
                  
       % Set up the array papa1, which represents the weighted variables.
        papa1 = zeros(nt,nlev,nlat2,nlon);
        for i=1:nlev
            for j=1:nt
                papa1(j,i,:,:)=squeeze(X(j,i,lat0:latf,:)).*w2';
            end                        
        end
    
      
        
       %Integration über lon
       ps2 = zeros(nt,nlev,nlat2);
       for i=1:nlev   % i over levels
           for j=1:nlat2  % j over lat 
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
               ps3a(j,i)=-trapz(rlat2,ps2(j,i,:),3);
           end               
       end
       
     
       % Integrat over vertical levels.
       % note that the ERA-Interim data are in Pa, the ERA-40 in hPa.
       % the arrays are also reversed for them, so ERA-Interim gets an extra negative sign.
       switch RA
         case 'ERA-Interim'
           ss = -1;
           lev_Pascal = lev;
         case 'ERA-40'
           ss = 1;
           lev_Pascal = lev*100;
       end
       ps3 = zeros(1,nt);
       for i=1:nt
           ps3(i) = ss*trapz(lev_Pascal,ps3a(i,:),2);
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

  end  %switching variables

  %% prepare output
  t_out = mjd;
  X_out = ps4;

end   % flag dont_integrate

%--temp plot------
%figH = figure('visible','off');
%fig_name = 'test_X1m.png';
%pw = 10;
%ph = 6;
%t = t_out*0;
%[y,m,d] = mjd2date(t_out);
%for ii = 1:length(t)
%  t(ii)=datenum([y(ii) m(ii) d(ii)]);
%end
%X_out_DT = detrend(X_out,'constant');
%plot(t,X_out_DT,'o-','LineWidth',3,'Color',rand(1,3))
%datetick('x','mmm-dd (ddd)')
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%---temp-------------




 
