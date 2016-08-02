% function [Montage] = ExtractMontage (csdFileName, eegLabels)
% 
% This is a generic routine to determine any EEG montage from a *.CSD
% ASCII file (cf. Kayser & Tenke, 2006a) using an ordered list of channel
% labels (i.e., a cell string array).
%
% Usage: [ Montage ] = ExtractMontage ( csdFileName, eegLabels );
%
%   Input arguments:   csdFileName   *.CSD file name (generic CSD montage)
%                        eegLabels   cell string array with channel labels
%
%   Output argument:       Montage   cell structure consisting of a channel
%                                    label 'lab', 2-D plane x-y coordinates
%                                    'xy', and 3-D spherical angles 'theta'
%                                    and 'phi'
%        
% Copyright (C) 2007 by Jürgen Kayser (Email: kayserj@pi.cpmc.columbia.edu)
% GNU General Public License (http://www.gnu.org/licenses/gpl.txt)
% Updated: $Date: 2009/05/14 17:26:00 $ $Author: jk $
%
function [Montage] = ExtractMontage (csdFileName, eegLabels)
[lab,theta,phi] = textread(csdFileName,'%s %f %f','commentstyle','c++');
n = 0;
theta0 = theta;
phi0 = phi;
lab0 = lab;
for e = 1:length(eegLabels)
   ok = 0; 
   for f = 1:length(lab)
      if strcmp(upper(char(eegLabels(e,:))),upper(lab(f,:)))
         n = n + 1;
         theta0(e) = theta(f); 
         phi0(e) = phi(f);
         lab0(e,:) = eegLabels(e,:);
         ok = 1;
         break
      end
   end
   if ~ ok
      disp(sprintf('*** Error: Label %s undefined in %s',...
                   char(eegLabels(e,:)),csdFileName));
      lab0(e,:) = eegLabels(e,:);
      theta0(e) = NaN; 
      phi0(e) = NaN;
   end
end
theta = theta0(1:length(eegLabels));
phi = phi0(1:length(eegLabels));
lab = lab0(1:length(eegLabels),:);
phiT = 90 - phi;                    % calculate phi from top of sphere
theta2 = (2 * pi * theta) / 360;    % convert degrees to radians
phi2 = (2 * pi * phiT) / 360;
[x,y] = pol2cart(theta2,phi2);      % get plane coordinates
xy = [x y];
xy = xy/max(max(xy));               % set maximum to unit length
xy = xy/2 + 0.5;                    % adjust to range 0-1
save tmpMontage.mat lab theta phi xy;
Montage = open('tmpMontage.mat');
delete tmpMontage.mat;
disp(sprintf('%5s %7s %10s %10s %8s %8s', ...
             '#','Label','theta','phi','X','Y'));
for e = 1:length(Montage.xy);
   if isnan(theta(e))
      disp(sprintf('%5d %7s %10.3f %10.3f %8.3f %8.3f *** ERROR ***', ...
                    e,char(lab(e,:)),theta(e),phi(e),xy(e,:)));
   else
      disp(sprintf('%5d %7s %10.3f %10.3f %8.3f %8.3f', ...
                    e,char(lab(e,:)),theta(e),phi(e),xy(e,:)));
   end
end;
if ~(n == length(eegLabels))
   Montage = NaN
   disp(sprintf('*** Error: %d assigned <> %d read EEG channel labels',n,length(eegLabels)));
end;

