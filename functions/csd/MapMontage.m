% function MapMontage (Montage)
% 
% This routine roughly maps the 2-D locations of an EEG montage (down view, 
% nose on top, circle approximates Fpz-T7-Oz-T8 plane).
%
% Usage: MapMontage (Montage);
%
%   Input argument:  Montage   cell structure returned by the CSD toolbox 
%                              ExtractEEGMontage.m consisting of a channel
%                              label 'lab', 2-D plane x-y coordinates 'xy',
%                              and 3-D spherical angles 'theta' and 'phi'
%        
% Copyright (C) 2009 by Jürgen Kayser (Email: kayserj@pi.cpmc.columbia.edu)
% GNU General Public License (http://www.gnu.org/licenses/gpl.txt)
% Updated: $Date: 2009/05/14 14:10:00 $ $Author: jk $
%   Fixed: $Date: 2010/07/19 15:39:00 $ $Author: jk $
%        - create new Matlab figure before drawing locations
%        - improved 2-D location mapping
function MapMontage (Montage)
if nargin < 1
  disp('*** Error: No EEG montage specified');
  return
end
figure;
nElec = size(Montage.xy,1);
set(gcf,'Name',sprintf('%d-channel EEG Montage',nElec),'NumberTitle','off')
m = 100;
t = [0:pi/100:2*pi]; 
r = m/2 + 0.5;
head = [sin(t)*r + m/2+1; cos(t)*r + m/2+1]' - m/2;
scrsz = get(0,'ScreenSize');
d = min(scrsz(3:4)) / 2;
set(gcf,'Position',[scrsz(3)/2 - d/2 scrsz(4)/2 - d/2 d d]); 
whitebg('w');
axes('position',[0 0 1 1]);
set(gca,'Visible','off');
line(head(:,1),head(:,2),'Color','k','LineWidth',1); 
mark = '\bullet'; 
if nElec > 129; mark = '.'; end;
l = sqrt((Montage.xy(:,1)-0.5).^2 + (Montage.xy(:,2)-0.5).^2) * 2;
r = (r - 3.5) / (max(l) / max([max(Montage.xy(:,1)) max(Montage.xy(:,2))]));
for e = 1:nElec
    text(Montage.xy(e,1)*2*r - r + 0.5,Montage.xy(e,2)*2*r - r + 2.5,mark);
    text(Montage.xy(e,1)*2*r - r + 1, ...
         Montage.xy(e,2)*2*r - r , ...
         Montage.lab(e), ...
          'FontSize',8, ...
          'FontWeight','bold', ...
          'VerticalAlignment','middle', ...
          'HorizontalAlignment','center');
end
