function [mjd_out,X_out] = erp_per_warming(comp,cdate,dt,hostname)
%% function erp_per_warming.m: 
%   read in the timeseries for a given ERP and a given SSW event.
%   code based on aef_per_warming.m by Lisa neef
%   7 May 2012
%
%  INPUTS:
%   comp: the AAM component that we want (X1, X2, or X3)
%   var : the variable that we want to integrate
%   cdate: the central date of the warming that we are interested in
%           format: [YYYY,MM,DD] (numbers)
%   dt: the radius of time around the central date, in days


%% temporary inputs
%clear all; clc;
%comp = 'X3';
%cdate = [1958,1,31];
%dt = 40;
%hostname = 'blizzard';

%% read in the ERP timeseries
[X1,X2,X3,mjd,~,~,~] = read_eops_simple(hostname);

%% pull out the appropriate interval for this event

% select the boundary dates 
cdate_mjd = date2mjd(cdate(1),cdate(2),cdate(3));
mjdf = cdate_mjd + dt;
mjd0 = cdate_mjd - dt;

% boundary indices
k0 = find(mjd >= mjd0, 1 );
kf = find(mjd <= mjdf, 1, 'last' );

% select timeseries
switch comp
    case 'X1'
        X_out = X1(k0:kf);
    case 'X2'
        X_out = X2(k0:kf);
    case 'X3'
        X_out = X3(k0:kf);
end
mjd_out = mjd(k0:kf);
