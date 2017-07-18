function [t_out,X_out] = richtig_integration_pol_LN_rechteck(comp,var)
%comp = 'X1';
%var = 'V';

switch var
    case 'PS'
        %ncid = n_trim/comp_subseasonal_IBeffect_X3t.pngetcdf.open('/home/ig/swalther/paper/potsdam/daten/eraint_ps_minusmean_1989-1990.nc','NC_NOWRITE');    
        ncid = netcdf.open('/home/ig/swalther/paper/potsdam/daten/era-interim-198902-T42.nc','NC_NOWRITE');
      varid = netcdf.inqVarID(ncid,'var134');

    case 'U'
        %ncid = netcdf.open('/home/ig/swalther/paper/potsdam/daten/eraint_u_v_1989-1990.nc','NC_NOWRITE');
        ncid = netcdf.open('/home/ig/swalther/paper/potsdam/daten/era-interim-198902-T42.nc','NC_NOWRITE');
        varid = netcdf.inqVarID(ncid,'var131');     
        levid = netcdf.inqVarID(ncid,'lev');
        lev = netcdf.getVar(ncid,levid);
    
    case 'V'
        %ncid = netcdf.open('/home/ig/swalther/paper/potsdam/daten/eraint_u_v_1989-1990.nc','NC_NOWRITE');
        ncid = netcdf.open('/home/ig/swalther/paper/potsdam/daten/era-interim-198902-T42.nc','NC_NOWRITE');
        varid = netcdf.inqVarID(ncid,'var132');      
        levid = netcdf.inqVarID(ncid,'lev');
        lev = netcdf.getVar(ncid,levid);       
end

v134 = netcdf.getVar(ncid,varid);
lonid = netcdf.inqVarID(ncid,'lon');
lon = netcdf.getVar(ncid,lonid);

latid = netcdf.inqVarID(ncid,'lat');
lat = netcdf.getVar(ncid,latid);

timeid = netcdf.inqVarID(ncid,'time');
time = netcdf.getVar(ncid,timeid);

netcdf.close(ncid);   

% also set up lon and lat arrays in radians
rlon=lon*pi/180;
rlat=lat*pi/180;


% compute dlev, dlon, dlat (for use in the integral)
nlev = length(lev);
dlev = zeros(1,nlev);
for ilev = 1:nlev-1
   dlev(ilev) = lev(ilev+1)-lev(ilev); 
end
dlev(nlev) = 0-lev(nlev);

nlat = length(rlat);
nlon = length(rlon);

dlat = rlat*0+rlat(2)-rlat(1);
dlon = rlon*0+rlon(2)-rlon(1);

 
%% load some other stuff that's needed for the integration
% load the weights for this variable and the prefactors that
% nondimensionalize the excitation functions
w=eam_weights(lat,lon,comp,var);
fac = eam_prefactors(comp,var);


LOD0_ms = double(86164*1e3);     % sidereal LOD in milliseconds.
 


%% load in the variables and integrate globally for each time.
switch var
    case 'PS'
        %ps=IB_korrektur(squeeze(v134));  
        
        %***TEMP: put in IB approximation (separate code for sophia)
        ntime = size(v134,4);
        nlat = length(lat);
        nlon = length(lon);

        ps = zeros(nlon,nlat,ntime);
        ff_lm = '/home/ig/neef/Data/landmask_emac_T42.nc';
        slm = nc_varget(ff_lm,'slm');
        LM = double(squeeze(slm(1,:,:)))';      % land mask - transpose to get correct dimensions
        SM = double(LM*0);
        SM(LM == 0) = 1;                 % sea mask
        dxyp = gridcellarea(nlat,nlon);
        dxyp2 = dxyp*ones(1,nlon);
        sea_area = sum(sum(dxyp2'.*SM));
        
        for ii=1:ntime
          pstemp = double(squeeze(v134(:,:,:,ii)));
          ps_sea_ave = sum(sum(pstemp.*SM.*dxyp2'))/sea_area;
          ps_ave = pstemp.*LM+ps_sea_ave*SM;
          ps(:,:,ii) = ps_ave;
        end
       
        % Set up the array papa1a, which represents the weighted variables.
        papa1a = zeros(size(ps));
        for i=1:size(ps,3)
            papa1a(:,:,i)=squeeze(ps(:,:,i)).*w;
        end

            
        papa1=squeeze(papa1a);
       
        %Integration über lon
        ps2=zeros(size(squeeze(papa1),2),size(squeeze(papa1),3));

        for i=1:size(papa1,3)
            for j=1:length(lat)
                ps2(j,i)=trapz(rlon,squeeze(papa1(:,j,i)));
            end                         
        end
     
 
        % Integration über lat
        ps3=zeros(1,size(ps2,2));
        for i=1:size(ps2,2)
            %a negative sign enters here because latitude array is defined
            %in opposite direction of the integral.
            ps3(i) = -trapz(rlat,ps2(:,i));
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
        fid = fopen(strcat(num2str(comp),'_',num2str(var),'vgl_1989_1990.txt'), 'w');
        fprintf(fid, '%i \n',ps4');
        fclose(fid);
    

        
    case {'U','V'}
               
       ntime = size(v134,4);
      
       % Set up the array papa1, which represents the weighted variables.
        papa1 = zeros(nlon,nlat,nlev,ntime);
        for i=1:nlev
            for j=1:ntime
                papa1(:,:,i,j)=squeeze(v134(:,:,i,j)).*w;
            end                        
        end
    
      
        
       %Integration über lon

       ps2 = zeros(nlat,nlev,ntime);
       for i=1:nlev   % i over levels
           for j=1:nlat  % j over lat 
               for k=1:ntime % k over time
                 %  ps2(j,i,k)=trapz(rlon,squeeze(papa1(:,j,i,k)),1);   
                   ps2(j,i,k) = sum(dlon.*squeeze(papa1(:,j,i,k)),1);
               end             
           end        
       end                        
 
       
       
       % Integration über lat
       % add a negative sign here because the lat array is defined
       % North-South but the integral is defined the other way.
       ps3a=zeros(nlev,ntime);
       for i=1:nlev  % i over levels
           for j=1:ntime  % j over time
               %ps3a(i,j)=-trapz(rlat,ps2(:,i,j),1);
               ps3a(i,j) = sum(dlat.*ps2(:,i,j),1);
           end               
       end
       
     
       % Integration über lev
       ps3 = zeros(1,ntime);
       for i=1:ntime
          % ps3(i) = -trapz(lev,ps3a(:,i),1);
           ps3(i) = sum(dlev'.*ps3a(:,i),1);
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
       fid = fopen(strcat(num2str(comp),'_',num2str(var),'vgl_1989_1990.txt'), 'w');
       fprintf(fid, '%i \n',ps4');
       fclose(fid); 

end
 


%% more stuff added by Lisa

refday = datenum(1989,2,1,0,0,0);
t2 = time+refday;

%% prepare output
t_out = t2;
X_out = ps4;


 