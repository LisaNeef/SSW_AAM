% code by Lisa to compare Sophia's integraton with Henryk's for the IERS.
% 26 Mar 2012


%% inputs

EAF = 'X2';

%% integrate the era-interim data using sophia's script.

% load all terms.
[t_ps,X_ps] = richtig_integration_pol_LN(EAF,'PS');
[t_u,X_u] = richtig_integration_pol_LN(EAF,'U');
[t_v,X_v] = richtig_integration_pol_LN(EAF,'V');

tS = t_v;

% compute the total EF

XmS = X_ps;
XwS = X_u + X_v;


% fetch the  ERA-Interims 
[Xw_era,Xm_era,mjd] = read_EFs('aam','ERAinterim',1);

% find the start and stop points in ERAinterim (1989-1990)
mjd0 = date2mjd(1989,2,1,0,0,0);
mjdf = date2mjd(1989,2,28,0,0,0);

dum = find(mjd > mjd0);
era0 = min(dum);
dum2 = find(mjd < mjdf);
eraf = max(dum2);

% convert the era time vector to datenum
[y, m, d, h] = mjd2date(mjd);
t_era = mjd*0;
for ii = 1:length(mjd)
    t_era(ii)=datenum([y(ii) m(ii) d(ii)]);
end
tE = t_era(era0:eraf);

% convert ERA to equivalent PM or LOD
rad2mas = (180/pi)*60*60*1000;
LOD0_ms = double(86164*1e3);     % sidereal LOD in milliseconds.

switch EAF
    case {'X1'}
        XwE = rad2mas*Xw_era(1,era0:eraf);
        XmE = rad2mas*Xm_era(1,era0:eraf);
    case {'X2'}
        XwE = rad2mas*Xw_era(2,era0:eraf);
        XmE = rad2mas*Xm_era(2,era0:eraf);
    case {'X3'}
        XwE = LOD0_ms*Xw_era(3,era0:eraf);
        XmE = LOD0_ms*Xm_era(3,era0:eraf);
end


lh = [0,0];

Scol = [0.9448    0.4909    0.4893];

% compare it all
figure(1),clf
lh(1) = plot(tE,detrend(XwE,'constant'),'o-','Color',0.5*ones(1,3),'LineWidth',2);
hold on
lh(2) = plot(tS,detrend(XwS,'constant'),'o-','Color',Scol,'LineWidth',2);
%lh(3) = plot(tS,detrend(X_u,'constant'),'.-','Color',Scol,'LineWidth',2);
%lh(4) = plot(tS,detrend(X_v,'constant'),'--','Color',Scol,'LineWidth',2);
title('WIND TERM')
datetick('x','dd-mmm-yy','keeplimits')
%legend(lh,'IERS','S total','Su','Sv')

% compare it all
figure(2),clf
lh(1) = plot(tE,detrend(XmE,'constant'),'o-','Color',0.5*ones(1,3),'LineWidth',2);
hold on
lh(2) = plot(tS,detrend(XmS,'constant'),'o-','Color',Scol,'LineWidth',2);
title('MASS TERM')
datetick('x','dd-mmm-yy','keeplimits')
legend(lh,'IERS','Sophia')


