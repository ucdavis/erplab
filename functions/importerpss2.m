
%
% Eric, I was improving the code a little bit (mostly my part) cause it was very slow.
% I also added more stuffs like error detectors (July 11, 2012).


function [ERP serror] = importerpss2(fullname, format, transpose)

ERP    = buildERPstruct;
serror = 0;
if nargin<2
      error('ERPLAB says: error, filename and pathname are needed as inputs.')
end

%
% Reading the file
%
fid = fopen(fullname);
asciiERP = textscan(fid, '%s', 'delimiter','\n');
asciiERP = asciiERP{:};
fclose(fid);
subdesc = regexpi(asciiERP, '\s*subdesc\s*=\s*"(.*)"','tokens');
if isempty(subdesc)      
        asciiERP = textscanu(fullname, encoding, del_sym, eol_sym, wb);
        subdesc = regexpi(asciiERP, '\s*subdesc\s*=\s*"(.*)"','tokens');
end

%
% Getting filename (changed from expdesc to subdesc. Thanks Antigona M.!)
%
subdesc = subdesc(~cellfun(@isempty, subdesc));
subdesc = [subdesc{:}];
subdesc = [subdesc{:}];

%
% Getting number of channels
%
nchans = regexpi(asciiERP, '\s*nchans\s*(\d*)','tokens');
nchans = nchans(~cellfun(@isempty, nchans));
nchans = [nchans{:}];
nchans = [nchans{:}];
if length(nchans)==1
      nchans = str2num(char(nchans));
else
      error('nchans got multiple values!')
end

%
% Getting channel labels
%
chlabels = regexpi(asciiERP, '\s*\d\s*"(.*)"','tokens');
chlabels = chlabels(~cellfun(@isempty, chlabels));
chlabels = [chlabels{:}];
chlabels = [chlabels{:}];

%
% Getting resolution
%
resolution = regexpi(asciiERP, '\s*resolution\s*(\d*)','tokens');
resolution = resolution(~cellfun(@isempty, resolution));
resolution = [resolution{:}];
resolution = [resolution{:}];
if length(resolution)==1
      resolution = str2num(char(resolution));
else
      error('resolution got multiple values!')
end

%
% Getting digperiod (same as sampleperiod -?-)
%
digperiod = regexpi(asciiERP, '\s*digperiod\s*(\d*)','tokens');
digperiod = digperiod(~cellfun(@isempty, digperiod));
digperiod = [digperiod{:}];
digperiod = unique_bc2([digperiod{:}]);
if length(digperiod)==1
      digperiod = str2num(char(digperiod));
else
      error('digperiod got multiple values!')
end

%
% Getting bin descriptors
%
BDesc = regexpi(asciiERP, '\s*bindesc\s*=\s*"(.*)"','tokens');
BDesc = BDesc(~cellfun(@isempty, BDesc));
BDesc = [BDesc{:}];
BDesc = [BDesc{:}];

%
% Getting npoints
%
npoints = regexpi(asciiERP, '\s*npoints\s*(.*)','tokens');
npoints = npoints(~cellfun(@isempty, npoints));
npoints = [npoints{:}];
npoints = unique_bc2([npoints{:}]);
if length(npoints)==1
      npoints = str2num(char(npoints));
else
      error('npoints got multiple values!')
end

%
% Getting sampleperiod
%
sampleperiod = regexpi(asciiERP, '\s*sampleperiod\s*(.*)','tokens');
sampleperiod = sampleperiod(~cellfun(@isempty, sampleperiod));
sampleperiod = [sampleperiod{:}];
sampleperiod = unique_bc2([sampleperiod{:}]);
if length(sampleperiod)==1
      sampleperiod = str2num(char(sampleperiod));
else
      error('sampleperiod got multiple values!')
end

%
% Getting presampling
%
presampling = regexpi(asciiERP, '\s*presampling\s*(.*)','tokens');
presampling = presampling(~cellfun(@isempty, presampling));
presampling = [presampling{:}];
presampling = unique_bc2([presampling{:}]);
if length(presampling)==1
      presampling = str2num(char(presampling));
      presampling = -presampling/1000; % usec to msec
else
      error('presampling got multiple values!')
end

%
% Getting sums (total trials)
%
sums = regexpi(asciiERP, '\s*sums\s*(.*)','tokens');
sums = sums(~cellfun(@isempty, sums));
sums = [sums{:}];
sums = [sums{:}];
sums = str2num(char(sums'))'; %JLC

%
% Getting arejects
%
arejects = regexpi(asciiERP, '\s*arejects\s*(.*)','tokens');
arejects = arejects(~cellfun(@isempty, arejects));
arejects = [arejects{:}];
arejects = [arejects{:}];
arejects = str2num(char(arejects'))';
arejects = sum(arejects, 1); %JLC

%
% Getting data (search for decimal numbers - it's faster than the previously used regular expression)
%
m=1;
for k=1:length(asciiERP)
      if nnz(ismember_bc2(asciiERP{k}, '.'))>0
            row4data(m) = k;
            m = m+1;
      end
end

data = asciiERP(row4data);
data = cellfun(@str2num, data, 'UniformOutput',0);
data = [data{:}]'; % column with all data.

% % data = regexpi(asciiERP, '(\s*(\-*\d+\.\d*)\s*)','tokens');
% % data = data(~cellfun(@isempty, data));
% % data = [data{:}];
% % data = [data{:}];
% % data = str2num(char(data)); % numeric!

% data(1:20);
%
% Organizing data
%
numbins    = length(BDesc);
fs_ERPSS   = round((1/digperiod)*10^6);
times = presampling:(1000/fs_ERPSS):npoints*(1000/fs_ERPSS)+(presampling)-1;
ERP.times = times;
ERP.xmin  = min(times)/1000;
ERP.xmax  = max(times)/1000;
totalpoints = length(data);

if format==0  % explicit
      currpoint=1;
      for i=1:numbins
            for j=1:nchans
                  for k=1:npoints
                        ERP.bindata(j, k, i) = data(currpoint);
                        currpoint = currpoint+1;
                  end
            end
      end
else % implicit
      if transpose==0
            
            %
            % implicit rows channels, columns samples
            %            
            currpoint=1;
            for i=1:numbins
                  for j=1:nchans
                        for k=1:npoints
                              ERP.bindata(j, k, i) = data(currpoint);
                              currpoint = currpoint+1;
                        end
                  end
            end
      else            
            %
            %implicit rows samples, columns, channels
            %
            for i=1:numbins
                  for j=1:nchans
                        currpoint = j+npoints*nchans*(i-1);
                        for k=1:npoints
                              ERP.bindata(j,k,i) = data(currpoint);
                              currpoint = currpoint+nchans;
                        end
                  end
            end
      end
end

ERP.erpname      = char(subdesc);
ERP.filename     = '';
ERP.filepath     = '';
ERP.workfiles    = '';
ERP.subject      = '';
ERP.nchan        = nchans;
ERP.nbin         = numbins;
ERP.pnts         = npoints;
ERP.srate        = fs_ERPSS;
ERP.binerror     = []; % error field
[ERP.chanlocs(1:nchans).labels] = chlabels{:};
ERP.ref          = [];
ERP.bindescr     = BDesc;
ERP.ntrials.accepted  = sums - arejects;
ERP.ntrials.rejected  = arejects;
ERP.ntrials.invalid   = arejects*0;
ERP.ntrials.arflags   = zeros(numbins, 8); %JLC
ERP.pexcluded    = 0;
ERP.history      = [];
ERP.saved        = 'no';
ERP.isfilt       = 'no';
ERP.EVENTLIST    = [];
ERP.version      = geterplabversion;
ERP.splinefile   = '';

[ERP serror]     = sorterpstruct(ERP);