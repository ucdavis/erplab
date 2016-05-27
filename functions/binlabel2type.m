% *** This function is part of ERPLAB Toolbox ***
% Author: Johanna Kreither & Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2014

function EEG = binlabel2type(EEG, multip)

if nargin<2
        multip = 1;
end
nevent = length(EEG.event);
kk = 0;
for k=1:nevent
        a = EEG.event(k).type;
        if ischar(a)
                b = regexp(a, '\((\d*)\)$', 'tokens');
                b = char(b{:});
                if ~isempty(b)
                        c = str2num(b);
                        if ~isempty(c)
                                EEG.event(k).type = c*multip;
                                kk = kk+1;
                        end
                end
                %                 c = str2num(b);
                %                 if ~isempty(c)
                %                         EEG.event(k).type = c;
                %                 else
                %                         %fprintf('Event #%g (%s) is not a valid bin label\n', k, a)
                %                 end
        end
end
if kk<1
        warning('Caution:binlabel2type', 'ERPLAB Warning: No valid Bin Labels found');
else
        EEG = eeg_checkset(EEG, 'eventconsistency');
        fprintf('\ndone: binlabel2type recovered %g event codes from your Bin Labels\n', kk);
end



