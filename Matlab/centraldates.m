%% centraldates.m  
%
%  This program generates lists of central dates for various sets of stratospheric warming events.
%
%  Lisa Neef, 18 Aug 2012
%  (based on classification_centraldates.m by Sophia Walther)
%
%-------------------------------------------------------------------

clear all
clc

%% Inputs: 

dataset = 'ERA-40';
add_temp_criterion = 0;
hostname = 'blizzard';

%% Retrieve the list of days that fall into categories disturbed, minor, major, final

[DIST,MAJOR,MINOR,FINAL,MJD,G,U] = ssw_classification_lisa(dataset,add_temp_criterion,hostname);


%% Find central dates as MJDs:

% each day marked in MAJOR has wind-turnaround, and maybe the temp criterion.  
% mark it as a central date.

major = find(MAJOR == 1);

% next, apply the criterium that you can't have a new central date 20 days after each 
% central date, since it's the same event.

CD = MJD*0+NaN;
CD(major) = MJD(major);

n = length(MAJOR)
for ii = 1:n
  if MAJOR(ii) == 1
    % if we hit on a day of wind turnaround, the subsequent 20 days can't be central dates
    CD(ii+1:ii+20) = NaN;
  end
end


% display the remaining central dates

events = find(isfinite(CD));
nevents = length(events);
disp([num2str(nevents),' major SSW events found:'])
for ii = 1:nevents
   [y,m,d] = mjd2date(CD(events(ii)));
   disp([num2str(y),'  ',num2str(m),'  ',num2str(d)])
end

