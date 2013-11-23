% Eric, please check this out.
%  
%

function [signal, time, chanlabels, pnts, nchan, serror] = loadtxterp(fullname, transpose, timex, elabel)

signal=[]; time=[]; chanlabels=''; pnts=[]; nchan=[];
serror = 0; % no errors
delimiter  = '\t';

%if transpose == 0; % data matrix is point x elec  (normal, no transpose)
if elabel==1
        nheaderlines = 1;
else
        nheaderlines = 0;
end
%else   % data matrix is elec x points  (transposed. should be corrected)
%    nheaderlines = 0;  %changed from 0 to 3
%end

% try
%  if transpose==1
%         fid = fopen(fullname,'rt');
%         nLines = 0;
%         while (fgets(fid) ~= -1)
%             nLines = nLines+1;
%         end
%         fclose(fid);
%         fid = fopen(fullname,'rt');
%         [A, count]=fscanf(fid, '%s');
%         fclose(fid);
%
%         if timex==1
%         columns_of_header=count/nLines; %counts the number of channels +1 (time header)
%         num_of_col=columns_of_header-1; %stores number of columns (time points)
%         signal_trans=signal(:,2:end);
%         signal=signal_trans;
%         time= dlmread(fullname, '', [0 1 0 num_of_col]);
%         else
%             signal=dlmread(fullname, '', [0 1 nLines num_of_col]);
%             time=[];
%         end
%  end

if nheaderlines==1
        values     = importdata(fullname);
        signal     = values.data;
        
        if transpose==1
                signal=signal';
                if timex==1
                        time=signal(:,1);
                        signal=signal(:,2:end);
                else
                        time=[];
                end
        else
                if timex==1
                        time = signal(:,1);
                        signal = signal(:,2:end);
                else
                        time = [];
                end
        end       
else
        values=importdata(fullname);
        signal=values;
        if transpose==1
                signal=signal';
                if timex==1
                        time=signal(:,1);
                        signal=signal(:,2:end);
                else
                        time=[];
                end
        else
                signal = dlmread(fullname);
                
                if timex==1
                        time=signal(:,1);
                        signal=signal(:,2:end);
                else
                        time=[];
                end                
                if transpose==1
                        signal=signal';
                end                
        end
end

%  if nheaderlines==1
%      values     = importdata(fullname);
%      signal     = values.data;
%
%
%      if timex==1
%          time = signal(:,1);
%          signal = signal(:,2:end);
%      else
%          time = [];
%      end
%
%
%      if transpose==1
%          signal = signal'; % corrected
%      end
%  else
%      signal = dlmread(fullname);
%
%      if timex==1
%          time=signal(:,1);
%          signal=signal(:,2:end);
%      else
%          time=[];
%      end
%
%      if transpose==1
%          signal=signal';
%      end
%
%  end

pnts  = size(signal,1);
nchan = size(signal,2);

%       try
if elabel==1
        chanlabels = values.textdata;
        if size(chanlabels,1)==1 && size(chanlabels,2)==1
                %                         try
                chanlabels=regexp(chanlabels,'.*?\s+', 'match');
                chanlabels = [chanlabels{:}];
                chanlabels=strtrim(chanlabels);
                %                         catch
                %                               fprintf('Oops...Please check ERP.chanlocs.labels. Is it fine?');
                %                         end
        end
        if timex==1
                chanlabels = chanlabels(~ismember_bc2(chanlabels,{'time'}));
        end
else
        chanlabels = '';
end

%       catch
%             chanlabels = '';
%       end

if isempty(char(chanlabels))
        chanlabels = cell(1);
        for e=1:nchan
                chanlabels{e} = ['Ch' num2str(e)];
        end
end

% catch
%       serror = 1; % error found
% end