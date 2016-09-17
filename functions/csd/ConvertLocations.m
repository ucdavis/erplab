% function ConvertLocations ( ReadFileName, WriteFileName, eegLabels )
% 
% This routine converts between *.ced and *.locs (EEGlab) and *.csd (CSD
% toolbox) electrode location ASCII text files by rotating the spherical
% angle theta +90 or -90 degrees.
%
% Usage: function ConvertLocations ( ReadFileName, WriteFileName, eegLabels );
%
%  Input arguments:   ReadFileName    ASCII montage file name(s) with ...
%                    WriteFileName    ... one of the following extensions:
%                          *.csd   (CSD toolbox spherical, 3-D Cartesian)
%                          *.ced   (EEGlab polar, 3-D Cartesian, spherical)
%                          *.locs  (EEGlab polar)
%                          *.xyz   (3-D Cartesian)
%                          *.txt   (write only: 3-D Cartesian exponent format,
%                                               skip labels and comments)
%                        eegLabels    cell string array with channel labels
%
%   Note: 1) Entering only <ReadFileName> will default the conversion to
%            *.ced for *.csd files, or to *.csd for *.ced and *.locs files
%         2) Entering only an extension for <WriteFileName> will
%            substitute the extension of <ReadFileName> as output file
%         3) Specifying a cell string array <eegLabels> will reorder and 
%            convert only those locations included in this list
%
% Copyright (C) 2009 by Jürgen Kayser (Email: kayserj@pi.cpmc.columbia.edu)
% GNU General Public License (http://www.gnu.org/licenses/gpl.txt)
% Updated: $Date: 2009/05/19 11:55:00 $ $Author: jk $
%        - convert between *.csd, *.ced and *.locs formats
%   Added: $Date: 2009/05/21 13:24:00 $ $Author: jk $
%        - input argument <eegLabels> to selectively convert/reorder locations
%   Added: $Date: 2009/07/30 10:52:00 $ $Author: jk $
%        - convert 3-D Cartesian locations *.xyz format
%   Added: $Date: 2010/04/11 19:38:00 $ $Author: jk $
%        - convert 3-D Cartesian locations *.txt format
%
function ConvertLocations ( ReadFileName, WriteFileName, eegLabels )
if nargin < 1
   help ConvertLocations
   disp('*** Error: Specify a montage file');
   return
end
disp(sprintf('Reading: %s',ReadFileName));
period = find(ReadFileName == '.');
ReadExt = ReadFileName(period(end)+1:end);
FileName = ReadFileName(1:period);
switch ReadExt
  case 'csd'
    [lab,theta,phi] = textread(ReadFileName, '%s%f%f%*[^\n]','commentstyle','c++');
  case 'ced'
    [Number,lab,th,radius,X,Y,Z,sph_theta,sph_phi,sph_radius] = ...
      textread(ReadFileName, '%n%s%f%f%f%f%f%f%f%f%*[^\n]','headerlines',1);
    theta = sph_theta + 90;              % rotate theta +90 degrees
    if theta > 180
      theta = theta - 360; end;          % adjust theta if neccessary
    phi = sph_phi;
  case 'locs'
    [Number,th,radius,lab] = textread(ReadFileName, '%n%f%f%s%*[^\n]');
    theta = -th + 90;
    if theta > 180
      theta = theta - 360; end;          % adjust theta if neccessary
    phi = 90 - (radius * 180);
  case 'xyz'
    [lab,X,Y,Z] = textread(ReadFileName, '%s%f%f%f%*[^\n]','commentstyle','c++');
    [ThetaRad,PhiRad] = cart2sph(X,Y,Z);
    theta = ThetaRad * 180 / pi;
    phi = PhiRad * 180 / pi;

    nElec = size(X,1);
    for n = 1:nElec
      z = X(n).^2 + Y(n).^2 + Z(n).^2 - 1; % calculate off sphere surface
      disp(sprintf('%8s%10.4f%10.4f%10.4f%22.17f', ...
          char(lab(n,:)),X(n),Y(n),Z(n),z)); 
    end;
  otherwise
    help ConvertLocations  
    disp(sprintf('*** Error: File extension (%s) not recognized',ReadExt));
    return
end; 
if nargin < 2
  switch ReadExt
    case 'csd'
      WriteExt = 'ced';
    case {'ced' 'locs'}
      WriteExt = 'csd';
  end
  WriteFileName = strcat(FileName,WriteExt);
else
  period = find(WriteFileName == '.');
  if size(period,2) == 0
     WriteExt = WriteFileName;
  else   
     WriteExt = WriteFileName(period(end)+1:end);
  end
  if (size(WriteFileName,1) == 0) | (size(period,2) == 0)
     WriteFileName = strcat(FileName,WriteExt);
  end    
end

if nargin < 3
  nLab = 0;  
else
  nLab = length(eegLabels);  
  n = 0;
  theta0 = theta;
  phi0 = phi;
  lab0 = lab;  
  for e = 1:nLab
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
                   char(eegLabels(e,:)),ReadFileName));
      lab0(e,:) = eegLabels(e,:);
      theta0(e) = NaN; 
      phi0(e) = NaN;
    end
  end
  if ~(n == nLab)
    help ConvertLocations  
    disp(sprintf('*** Error: %d assigned <> %d read EEG channel labels',n,nLab));
    return
  end;
  theta = theta0(1:length(eegLabels));
  phi = phi0(1:length(eegLabels));
  lab = lab0(1:length(eegLabels),:);
end;

sph_theta = theta - 90;                  % rotate theta -90 degrees
if sph_theta < -180; 
  sph_theta = sph_theta + 360; end;      % adjust theta if neccessary
sph_phi = phi;
th = -sph_theta;
radius = (90 - phi) / 180;
switch WriteExt
  case 'ced'                             % reassign spherical angles ...
    theta = sph_theta;                   % .. for X,Y,Z coordinates
    phi = sph_phi;
end
ThetaRad = pi / 180 * theta;             % convert Theta and Phi to radians ...
PhiRad = pi / 180 * phi;                 % ... and Cartesian coordinates ...
[X,Y,Z] = sph2cart(ThetaRad,PhiRad,1);   % ... for optimal resolution

nElec = size(theta,1);                   % determine size of output EEG montage
disp(sprintf('Writing: %s',WriteFileName));
fid = fopen(WriteFileName,'w');          % open output file for write
switch WriteExt                          % write optional header comments
  case 'csd'
    fprintf(fid,'%s%31s%30s\n', ...   
      '// MatLab','Sphere coordinates [degrees]','Cartesian coordinates');
    fprintf(fid,'%s%12s%10s%10s%10s%10s%10s%25s\n', ...
      '// Label','Theta','Phi','Radius','X','Y','Z','off sphere surface');
    disp(sprintf('%5s %7s %10s %10s','#','Label','Theta','Phi'));
  case 'ced'
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ... 
      'Number','labels','theta','radius','X','Y','Z','sph_theta','sph_phi','sph_radius');
    disp(sprintf('%5s %7s %10s %10s','#','Label','Sph_Theta','Sph_Phi'));
  case 'locs'
    disp(sprintf('%5s %7s %10s %10s','#','Label','Th(eta)','Radius'));
  case 'xyz'
    fprintf(fid,'%s%10s%10s%10s\n', ...
      '// Label','X','Y','Z');
    disp(sprintf('%5d %7s %10s %10s %10s','#','Label','X','Y','Z'));
end
for n = 1:nElec
  switch WriteExt                        
    case 'csd'
      z = X(n).^2 + Y(n).^2 + Z(n).^2 - 1; % calculate off sphere surface
      fprintf(fid,'%8s%12.3f%12.3f%12.3f%10.4f%10.4f%10.4f%22.17f\n', ...
        char(lab(n,:)),theta(n),phi(n),1.0,X(n),Y(n),Z(n),z); 
      disp(sprintf('%5d %7s %10.3f %10.3f',n,char(lab(n,:)),theta(n),phi(n)));
    case 'ced'
      fprintf(fid,'%d\t%s\t%.3g\t%.3g\t%.3g\t%.3g\t%.3g\t%.3g\t%.3g\t%.3g\n', ...
        n,char(lab(n,:)),th(n),radius(n),X(n),Y(n),Z(n),sph_theta(n),sph_phi(n),1); 
      disp(sprintf('%5d %7s %10.3f %10.3f',n,char(lab(n,:)),sph_theta(n),sph_phi(n)));
    case 'locs'
      fprintf(fid,'%d\t%.5g\t%.5g\t%s\n', ...
        n,th(n),radius(n),char(lab(n,:))); 
      disp(sprintf('%5d %7s %10.3f %10.5f',n,char(lab(n,:)),th(n),radius(n)));
    case 'xyz'
      fprintf(fid,'%8s%10.4f%10.4f%10.4f\n', ...
        char(lab(n,:)),X(n),Y(n),Z(n)); 
      disp(sprintf('%5d %7s %10.4f %10.4f %10.4f',n,char(lab(n,:)),X(n),Y(n),Z(n)));
    case 'txt'
      fprintf(fid,'%16E %16E %16E\n',X(n),Y(n),Z(n)); 
      disp(sprintf('%5d %7s %16E %16E %16E',n,char(lab(n,:)),X(n),Y(n),Z(n)));
  end
end
fclose(fid);                             % close output file
disp(sprintf('Montage: %d locations converted',nElec));
return
