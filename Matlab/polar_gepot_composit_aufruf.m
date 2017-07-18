% liest beobachtungsdaten ein , filtert perioden von 13-14d raus und zieht
% Jahresgang ab und bildet composits, von dem jeweils noch das Mittel ?ber
% 81 Tage abgezogen wird
clear all
clc
close all
%ncid = netcdf.open('/home/sophia/Desktop/paper_richtig/geopot_500_20-90N.nc','NC_NOWRITE');
ncid = netcdf.open('/home/sophia/Desktop/paper_richtig/geopot_500_20-90N_climatanom.nc','NC_NOWRITE');

%get variables

varid = netcdf.inqVarID(ncid,'var156');
v130 = netcdf.getVar(ncid,varid);

varid = netcdf.inqVarID(ncid,'lon');
lon= netcdf.getVar(ncid,varid);

varid = netcdf.inqVarID(ncid,'lat');
lat = netcdf.getVar(ncid,varid);


netcdf.close(ncid);

% composits
para1=squeeze(v130);
%state=1;
%state=[1 2 3 6 7 11 12 13 14];  
state=[1 2 3];
dtime=40;

addpath(path,'/home/sophia/Desktop/paper_richtig/');
date_era;

for n=1:length(state)
    
if state(n)==1
    index_u_major=load('major_index.txt');
state1='major';
else if state(n)==2
index_u_major=load('major_index_D.txt');
state1='displacement';
else if state(n)==3   
  index_u_major=load('major_index_S.txt');
state1='split';
else if state(n)==6
index_u_major=load('major_index_50hPa.txt');
state1='down-to-50hPa';
else if state(n)==7
 index_u_major=load('major_index_100hPa.txt');
state1='down_to_100hPa';
else if state(n)==11
index_u_major=load('major_index_uanom60N_50hPa_-20ms_stark.txt');
state1='uanom-20-strong';
else if state(n)==12
  index_u_major=load('major_index_uanom60N_50hPa_-20ms_schwach.txt');
state1='uanom-20-weak';
else if state(n)==13
  index_u_major=load('major_index_uanom60N_50hPa_-15ms_stark.txt');
state1='uanom-15-strong';
else if state(n)==14
 index_u_major=load('major_index_uanom60N_50hPa_-15ms_schwach.txt');
state1='uanom-15-weak';
    end
    end
    end
    end
    end
    end
    end
    end
end
cdate=[];
for o=1:length(index_u_major)
    cdate=[cdate; date(index_u_major(o),:)];
end

  %polar_geopot_composit(index_u_major,cdate,para1,lat,lon,dtime,state1); 

  polar_anomgeopot_composit(index_u_major,cdate,para1,lat,lon,dtime,state1); 
polar_anomgeopot_composit_before_after_cd(index_u_major,cdate,para1,lat,lon,dtime,state1); 
    end
