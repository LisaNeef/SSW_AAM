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

function lat_lev_anom_u_temp_composit(index,cdate,para1, para2,lat,lev,dtime, state)
dt=-dtime:dtime;

% Kontrollabfragen
if ((size(para1)~=size(para2)))
    disp('Die Dimensionen von para1 und para2 stimmen nicht ??berein.')
    return
end
if ((size(para1,2)~=length(lev)))
    disp('Die Dimensionen von lev und para1 stimmen nicht ??berein.')
    return
end
if ((size(para2,2)~=length(lev)))
    disp('Die Dimensionen von lev und para2 stimmen nicht ??berein.')
    return
end
if ((size(para1,1)~=length(lat)))
    disp('Die Dimensionen von lat und para1 stimmen nicht ??berein.')
    return
end
if ((size(para2,1)~=length(lat)))
    disp('Die Dimensionen von lat und para2 stimmen nicht ??berein.')
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

% remove mean um central date von plusminus qbo Tagen
qbo=30;
paraa=zeros(length(lat),length(lev),length(index));

for i=1:length(index)
for j=1:length(lat)
for k=1:length(lev)

paraa(j,k,i)=mean(para2(j,k,index(i)-qbo:index(i)+qbo));
end
end
end

a=zeros(length(lat),length(lev),length(index),2*dtime+1);
b=zeros(length(lat),length(lev),length(index),2*dtime+1);

for i=1:length(index)
    for j=1:length(dt)
        a(:,:,i,j)=squeeze(para1(:,:,index(i)+dt(j)));
        b(:,:,i,j)=(squeeze(para2(:,:,index(i)+dt(j)))-paraa(:,:,i));
    end
end
cos2=cos(lat*pi/180).^2;

a_mean=squeeze(mean(a,3));
b_mean1=squeeze(mean(b,3));
b_mean=zeros(size(b_mean1));
for i=1:size(b_mean1,2)
    for j=1:size(b_mean1,3)
   b_mean(:,i,j)=squeeze(b_mean1(:,i,j)).*cos2;     
    end
end

  min(min(min(a_mean)))
  max(max(max(a_mean)))
  min(min(min(b_mean)))
  max(max(max(b_mean)))
  
  
[lata,leva]=meshgrid(lat,lev);
col=makeColorMap([0 0 1],[1 1 1],[1 0 0]);

for i=1:size(a_mean,3)
    close
    graphik(i)=figure(i);
  %  [co,ho]=contourf(lata,leva,squeeze(a_mean(:,:,i))','LevelList',[-30:5:30],'Color','none');
%caxis([-30, 30]);
%cmap=flipud(hot);
%colormap(cmap)
%colorbar
%colormap(col)
%colorbar

%hold on
[ci,hi]=contour(lata,leva,squeeze(b_mean(:,:,i))','-','LevelList',[0],'LineColor','black','LineWidth',2);
hold on
[c,h]=contour(lata,leva,squeeze(b_mean(:,:,i))','-.','LevelList',[-60:1:-1],'LineColor','black');
tick=[-100:1:100];
text_handle=clabel(c,h,tick);
set(h,'ShowText','on');
hold on
[ce,he]=contour(lata,leva,squeeze(b_mean(:,:,i))','-','LevelList',[1:1:60],'LineColor','black');
text_handle=clabel(ce,he,tick);
set(h,'ShowText','on');
hold on
h=find(lev==10);
plot(lat,lev(h));
title({strcat(num2str(state),' - composit - day:',num2str(dt(i)),':   \Delta u [m/s]        ')},'FontSize',15);% \Delta T [K]')},'FontSize',15);
 xlabel(' latitude','FontSize',10)
 ylabel ('p in hPa','FontSize',10)
 set(gca,'YDIR','reverse');
set(gca,'YScale','log');
levtick=[lev(31) lev(27) lev(23) lev(21) lev(18) lev(17) lev(13) lev(8) lev(4) lev(1)];
set(gca,'ytick',levtick);
set(gca,'yticklabel',levtick,'FontSize',10);

%Speichern
set(graphik(i),'PaperPositionMode','auto');
print(graphik(i),'-dpng',strcat('lev_lat_anom_u_composit',num2str(state),'_',num2str(dt(i)),'day'))

   
end


return