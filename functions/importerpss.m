% PENDING
%
%
%
%
%
%

function [ERP serror] = importerpss(filename, format, transpose)

serror = 0;
if nargin<2
      error('ERPLAB says: error, filename and pathname are needed as inputs.')
end

%%%taken from asc2erp.m%%%
fullname = filename;
fid = fopen(fullname);

%used to verify whether it is an ERPSS file
C = textscan(fid, '%s', 5);
fclose(fid);

G = [C{1:end}];

disp('hola')

%if strcmpi(G{5}, 'nchans') % then it is ERPSS
      
      
      % %       #
      % %       #	binno          1
      % %       #
      % %       bindesc="Cue LSF "
      % %       condesc="Cue LSF "
      % %       npoints      613
      % %       sampleperiod      1953
      % %       presampling     199219
      % %       sums        1181
      % %       procfuncs   "avg"
      % %       arejects    819
      % %
      
      %
      % Getting bin descriptors
      %
      fid = fopen(fullname);
      BD  = textscan(fid, '%s', 'delimiter','\n');
      fclose(fid);
      
      BDesc = regexpi(BD{:}, 'bindesc="(.*)"','tokens');
      BDesc = BDesc(~cellfun(@isempty, BDesc));
      BDesc = [BDesc{:}];
      BDesc = [BDesc{:}];      
      % %       C   = regexprep(C{:}, '"(.*)"','"${strrep($1,'' '',''_'')}"');
      % %
      % %       [pathproc fnameproc ext] = fileparts(fullname);
      % %
      % %       fullfile(pathproc, [fnameproc '_procerplab' ext])
      % %
      % %       fid = fopen(fullfile(pathproc, [fnameproc '_procerplab' ext]), 'w');
      % %       fprintf(fid, '%s\n', C{:});
      % %       fclose(fid);
      % %
      % %       fid = fopen([ fnameproc '_procerplab' ext]);
      % %       C   = textscan(fid, '%s');
      % %       fclose(fid);
      
      fid = fopen(fullname);
      C   = textscan(fid, '%s');
      fclose(fid);
      
      D   = [C{1:end}];
      m   = length(D);
      count=1; x=0; a=0; b=0; c=0; d=0; e=0; f=0; j=1; k=0;
      
      %Explicit Format (header for bins and channels)
      if format==0  % explicit
            fprintf('\nPlease wait, loading ERPset from ERPSS ascii file (explicit format)...\n');
            i=1;
            
            while i<=m-5
                  %x = D{i};
                  a = D{i};
                  b = D{i+1};
                  d = str2num(D{i+3});
                  f = D{i+5};
                  err = 0;
                  
                  if (a=='#' & b=='#' & d>=0 & d<=256 & f=='#' )
                        k = i+6;
                        j = 1;
                        
                        while (D{k} ~= '#' & err==0)
                              E(j,1,count) = str2num(D{k});
                              j = j+1;
                              k = k+1;
                              if k==m
                                    err=1;
                              end
                        end
                        count = count+1; % bin counter
                        i = k-1;
                  else
                        i = i+1;
                  end
            end
            
            %to get very last data point
            E(j,1, count-1) = str2num(D{m});
            %fclose(fid);
            
            %finding channel numbers and bin numbers
            ERP       = buildERPstruct;
            numofchan = str2num(D{6});
            numofbins = ((count-1)/numofchan)-1;
            
            for binnumber=1:numofbins
                  k = (binnumber*numofchan) + 1;
                  for n=1:numofchan
                        ERP.bindata(n,:,binnumber) = E(:,1,k)';
                        k = k+1;
                  end
            end
            %Need to fill ERP.bindata, numofchans, numofbins
      elseif format ==1     % implicit
            fprintf('\nPlease wait, loading ERPset from ERPSS ascii file (implicit format, ');
            
            %rows are channels, columns are samples
            if transpose ==0
                  fprintf('untransposed)...\n')
                  i=1;
                  
                  while i<=m-5
                        %x = D{i};
                        a = D{i};
                        b = D{i+2};
                        d = str2num(D{i+3});
                        err = 0;
                        
                        if (strcmp(a,'procfuncs') & strcmp(b,'arejects') & d>=0) % JLC: "d" might not necessarily be zero
                              k=i+4;
                              j=1;
                              
                              while (D{k} ~= '#' & err==0)
                                    E(j,1,count) = str2num(D{k});
                                    j = j+1;
                                    k = k+1;
                                    if k==m
                                          err=1;
                                    end
                              end
                              count = count+1;
                              i = k-1;
                        else
                              i = i+1;
                        end
                  end
                  %to get very last data point
                  E(j,1, count-1) = str2num(D{m});
                  %fclose(fid);
                  
                  %finding channel numbers and bin numbers
                  ERP = buildERPstruct;
                  numofchan  = str2num(D{6});
                  numofbins  = count-1;
                  sigperchan = j/numofchan; %number of signals per channel
                  k=1;
                  m=1;
                  
                  for binnumber = 1:numofbins
                        for n = 1:numofchan
                              for j=1:sigperchan
                                    x = E(m,1,k);
                                    ERP.bindata(n,j,binnumber) = x;
                                    m = m+1;
                              end
                        end
                        k = k+1;
                        m=1;
                  end
                  %columns are channels, rows are samples
            else
                  fprintf('transposed)...\n')
                  i=1;
                  
                  while i<=m-5
                        %x = D{i};
                        a = D{i};
                        b = D{i+2};
                        d = str2num(D{i+3});
                        err =0;
                        
                        if (strcmp(a,'procfuncs') & strcmp(b,'arejects') & d>=0) %JLC: "d" might not necessarily be zero
                              k = i+4;
                              j=1;
                              
                              while (D{k} ~= '#' & err==0)
                                    E(j,1,count) = str2num(D{k});
                                    j = j+1;
                                    k = k+1;
                                    if k==m
                                          err=1;
                                    end
                              end
                              count = count+1;
                              i = k-1;
                        else
                              i = i+1;
                        end
                  end
                  %to get very last data point
                  E(j,1, count-1) = str2num(D{m});
                  %fclose(fid);
                  
                  %finding channel numbers and bin numbers
                  ERP = buildERPstruct;
                  numofchan  = str2num(D{6});
                  numofbins  = (count-1);
                  sigperchan = j/numofchan; %number of signals per channel
                  k=1;
                  
                  for binnumber=1:numofbins
                        for n=1:numofchan
                              m=n;
                              for j=1:sigperchan
                                    x = E(m,1,k);
                                    ERP.bindata(n,j,binnumber) = x;
                                    m = m+numofchan;
                              end
                        end
                        k = k+1;
                        m=1;
                  end
            end
      end
      
      ERP.nbin     = numofbins; %number of bins
      ERP.nchan    = numofchan; %number of channels
      ERP.binerror = [];
      ERP.isfilt   = 0;
      [a numberofpoints] = size(ERP.bindata(1,:,1));
      ERP.pnts  = numberofpoints;
      
      % ################# NO contrast against OPTIONS #################### JLC
      %ERP.xmin  = xlim(1)/1000;
      %ERP.xmax  = xlim(2)/1000;
      
      %error if fs and estimated fs are not within 10% of each other
      %sdistance = (xlim(2)-xlim(1))/numberofpoints;  %distance between points
      %est_fs=1/sdistance*1000;
      %srdiff = abs((fs-est_fs)/est_fs);
      %if srdiff>0 && srdiff>=0.1
      %        serror=3;
      %end
      %###########################  JLC
      
      %now if the srate from the erpss is offf another error
      %now take the value of ERP.srate= the one from ERPSS
      
      for i=1:500 %because the sample period will be located somewhere in between here
            if strcmp(D{i},'sampleperiod')
                  sam_per  = str2num(D{i+1});
                  fs_ERPSS = round((1/sam_per)*10^6);
                  break % JLC
            end
      end
      
      % #######  JLC  ##############
      for i=1:500 %because the sample period will be located somewhere in between here
            if strcmp(D{i},'presampling')
                  pre_sam = str2num(D{i+1});
                  pre_sam = -pre_sam/1000; % usec to msec
                  break % JLC
            end
      end
      
      %Create ERP structure
      
      % JLC Remainder:  presampling     200000
      %
      % @Eric : ERPSS text file has ALL info you need to load it. It is NOT necessary to contrast fs, xmin, xmax, pnts, etc
      % against what the user entered in OPTIONS at the IMPORT GUI. OPTIONS must work only for universal text.
      %
      % ####################
      
      
      
      %####### no fs test for ERPSS #######  JLC
      %if abs(((fs-fs_ERPSS)/fs_ERPSS)*100)>10
      %        serror=3;
      %end
      %###################################
      
      %ERP.srate     = fs;
      %ERP.srate=(1/sdistance)*1000;
      ERP.srate = fs_ERPSS;  % JLC
      
      %times= round(linspace(xlim(1), xlim(2), numberofpoints));
      
      % JLC  ######
      times = pre_sam:(1000/fs_ERPSS):numberofpoints*(1000/fs_ERPSS)+(pre_sam)-1;
      ERP.times = times;
      ERP.xmin  = min(times)/1000;
      ERP.xmax  = max(times)/1000;
      % JLC ###########
      
      %channel locations
      fid = fopen(fullname);
      C   = textscan(fid, '%d %s', 256, 'headerLines', 6);
      fclose(fid);
      
      channelnames = cellstr(C{2});
      [a b] = size(channelnames);
      
      for i=1:a
            k = channelnames{i};
            j = regexp(k,'"(\w*)"', 'tokens');
            channelnames{i} = char(j{:});
      end
      
      b = int2str(C{1});
      channelnumbers = cellstr(b);
      
      for i=1:a
            x = channelnumbers{i};
            tempchannum = str2num(x);
            tempchannum = tempchannum+1;
            channelnumbers{i} = int2str(tempchannum);
      end
      if isfield(ERP, 'chanlocs')
            ERP=rmfield(ERP, 'chanlocs');
      end
      %channelnames
      for i=1:a
            ERP.chanlocs(1,i) = struct('labels', channelnames{i});
      end
      %ERP.erpname
      g = D{1};
      g = strtrim(strrep(g,' ','_'));
      g = strrep(g,'-','_');
      %g(ismember_bc2(double(g),[45])) = ''; %removes '-'   %%If name starts with numbers, will not work
      
      
      a = regexp(g,'"(.*)"', 'tokens');
      a = strrep(a{:},'"','');
      %     if double(b(1))==48:57
      %         strcat('A_', b);
      %     end
      
      ERP.erpname = char(a{:});    %char(a{:}) converts cell to character
      
% %       %bindescriptor name
% %       if format ==0 % explicit
% %             i=1; j=1; k=1;
% %             
% %             while i<=(m-numberofpoints)
% %                   if strcmp(D{i}, 'Bin') & strcmp(D{i+1}, 'desc:')
% %                         i=i+2;
% %                         
% %                         while strcmp(D{i},'#') ~= 1
% %                               binnames{j,k} = [blanks(1) D{i} ];
% %                               k = k+1;
% %                               i = i+1;
% %                         end
% %                         j = j+1;
% %                         k=1;
% %                   else
% %                         i = i+1;
% %                   end
% %             end
% %             for i=1:numofbins
% %                   ERP.bindescr{1,i} = strtrim(strcat(binnames{i+1,:}));
% %             end
% %       else % implicit
% %             i=1;j=1;
% %             m = length(D);
% %             
% %             while i<= m %JLC
% %                   if D{i}=='#' & strcmp(D{i+1}, 'binno') & D{i+3}=='#'
% %                         i = i+4;
% %                         h = D{i}
% %                         %h = strtrim(strrep(h,' ','_'));
% %                         h = strrep(h,'-','_')
% %                         %h(ismember_bc2(double(h),[45])) = '';   %removes '-'
% %                         %h
% %                         b = regexp(h,'bindesc=(.*)', 'tokens')  %if there is a space between binname and last ", will not work
% %                         b = strrep(b{:},'"','')
% %                         
% %                         ERP.bindescr{1,j} = char(b{:});
% %                         j = j+1;
% %                   else
% %                         i = i+1;
% %                   end
% %             end
% %       end
      ERP.bindescr = BDesc;
      ERP = sorterpstruct(ERP);
      
      % Implicit format (bin header but no channel header)
      
% else %if not ERPSS file
%       msgboxText =  ['Something went wrong. '...
%             'Please, verify the file format.'...
%             ' For ERPSS text file, please check the organization of the data values,'...
%             ' as well as channel headers between channels.'];
%       %title = 'ERPLAB: pop_importerpss() error:';
%       error('Error:importerpss', msgboxText);
%       return
% end
