% plottet Breiten-H??hen-Schnitt f??r das angegebene Zeitintervall vor und
% nach dem central date von Wind- und Temperaturnaomalien vom mittleren
% JAhresgang f?r den composit

% Eingaben:
% index: Indexvektor f??r die Central dates des gew??nschten
%        stratosph??rischen Zustands
% cdate: Vektor mit Datum zu den central dates im Indexvektor
% para1: einer der Parameter, die betrachtet werden sollen im
%        Breiten-H??hen-Schnitt (hier Temperaturanomalie), Matrix hat
%        Ma??e Breite x H??he x Zeit
% para2: zweiter Parameter, der betrachtet werden soll mit gleichen Ma??en
%       (zB Anomalien des zonal gemittelter Zonalwind) 
% lat:   Vektor der Breiten, L??nge des Vektors muss erster Dimension von 
%        para1 und para2 entsprechen
% lev:   Vektor der H??henlevel in hPa, L??nge des Vektors muss zweiter
%        Dimension von para1 und para2 entsprechen
% dtime: Anzahl der Tage vor und nach dem central date, die verbildlicht
%        werden sollen
% state: String, Bezeichung des betrachteten strat. Zustands (wird f??r den
%        Titel der Abbildung und den Namen, unter dem die Abbildung gespeichert wird,verwendet)

function polar_anomgeopot_composit_before_after_cd(index,cdate,para1,lat,lon,dtime, state)
dt=-dtime:dtime;

% Kontrollabfragen
if ((size(para1,2)~=length(lat)))
    disp('Die Dimensionen von lev und para1 stimmen nicht ??berein.')
    return
end
if ((size(para1,1)~=length(lon)))
    disp('Die Dimensionen von lev und para2 stimmen nicht ??berein.')
    return
end


% k??nnen alle warmings vollst??ndig betrachtet werden oder liegen
% sie zu nahe am Rande der Zeitreihe
if dtime>index(1)
    
    sprintf('Das gew??hlte Zeitintervall dtime ist zu gro??, das erste central date wird ausgeschlossen. Wenn das nicht gew??nscht wird, muss das Zeitintervall auf mindestens %i Zeitschritte verkleinert werden.',index(1))
    index=index(2:length(index));
end

if index(length(index))+dtime>size(para1,3)
    sprintf({'Das gew??hlte Zeitintervall dtime ist zu gro??, das letzte central date wird ausgeschlossen.';
        'Wenn das nicht gew??nscht wird, muss das Zeitintervall auf mindestens %i Zeitschritte verkleinert werden.',size(para1,3)-index(length(index))})
        index=index(1:length(index)-1);

end


a=zeros(length(lon),length(lat),length(index),2*dtime+1);


for i=1:length(index)
    for j=1:length(dt)
        a(:,:,i,j)=squeeze(para1(:,:,index(i)+dt(j)));
        
    end
end
b_mean=zeros(length(lon),length(lat),2);

b1=mean(a,3);
b_mean(:,:,1)=mean(b1(:,:,1:41),3);
bmean(:,:,2)=mean(b1(:,:,41:81),3);


%nboot=1000;
%cw=zeros(length(lon),length(lat),length(dt),2);


%for i=1:length(dt)
%for j=1:length(lat)
%for k=1:length(lon)
%    cw(k,j,i,:)=bootci(nboot,@mean,a(k,j,:,i));
%end
%end
%end

%geomax=zeros(length(lon),length(lat),length(dt));
%for i=1:length(dt)
%for j=1:length(lat)
%for k=1:length(lon)
%if a_mean(k,j,i)>=cw(k,j,i,2);
%    geomax(k,j,i)=a_mean(k,j,i);
%else geomax(k,j,i)=NaN;
%end
%end
%end
%end 


%geomin=zeros(length(lon),length(lat),length(dt));
%for i=1:length(dt)
%for j=1:length(lat)
%for k=1:length(lon)
%if a_mean(k,j,i)<=cw(k,j,i,2);
%    geomin(k,j,i)=a_mean(k,j,i);
%else geomin(k,j,i)=NaN;
%end
%end
%end
%end 

%dt_plot=[-40 -20 0 20 40];

[lata,lona]=meshgrid(lat,lon);
col=makeColorMap([0 0 1],[1 1 1],[1 0 0]);

for i=1:size(b_mean,3)
    close
    graphik(i)=figure(i);
   load coast;
            %axesm('MapProjection','stereo','MapLatLimit',[20 90],'MapLonLimit',[0 360],'Origin',[ 90 0],'LabelUnits','degrees','grid','on');
            axesm('MapProjection','stereo','MapLatLimit',[20 90],'Origin',[ 90 0],'LabelUnits','degrees','grid','on');            
            %colormap(cool(10)) ;
            plotm(lat, long,'b');
            hold on
        %  [c,h]=contourfm(lata,lona,double(squeeze(geomax(:,:,dt_plot(i)+21)))/10);%,-100:1:600,'LineColor','k');
        %    hold on
        %  [cs,hs]=contourfm(lata,lona,double(squeeze(geomin(:,:,dt_plot(i)+21)))/10);%,-100:1:600,'LineColor','k');
        %    hold on
            %[ci,hi]=contourfm(lata,lona,double(squeeze(temp10(:,lat1,tag(i)))));
            %set(hi,'Levellist',[-100:10:30],'Color','none');
            %gfz
            [ci,hi]=contourfm(lata,lona,double(squeeze(b_mean(:,:,i)))/10,-600:2:0,'k--'); 
            hold on
            [cis,his]=contourfm(lata,lona,double(squeeze(b_mean(:,:,i)))/10,0:2:600,'LineColor','k'); 

           % caxis([-90, 10]);
            colormap(col)
            colorbar;
          
           % [c,h]=contourm(lata,lona,double(squeeze(gh(:,lat1,tag(i)))),[0:spacing:60000],'LineColor','k','Linewidth',1);
           % set(h,'LineColor','k','Linewidth',1);
            tightmap
            w=[-600:2:0];
            text_handle = clabelm(ci,hi,w);
            set(text_handle,'BackgroundColor','none','FontSize',12,'FontWeight','bold');
            
            wi=[-0:2:600];
            text_handle = clabelm(cis,his,wi);
            set(text_handle,'BackgroundColor','none','FontSize',12,'FontWeight','bold');
if i==1
title({strcat(num2str(state),' - composit - 40 days before CD:  \Delta gph [gdm]       ')},'FontSize',15);% \Delta T [K]')},'FontSize',15);


%Speichern
set(graphik(i),'PaperPositionMode','auto');
print(graphik(i),'-dpng',strcat('polar500_anomgeopot_composit',num2str(state),'_40d_before_CD'))

else if i==2
title({strcat(num2str(state),' - composit - 40 days after CD:  \Delta gph [gdm]       ')},'FontSize',15);% \Delta T [K]')},'FontSize',15);


%Speichern
set(graphik(i),'PaperPositionMode','auto');
print(graphik(i),'-dpng',strcat('polar500_anomgeopot_composit',num2str(state),'_40d_after_CD'))


end
end

   
end


return