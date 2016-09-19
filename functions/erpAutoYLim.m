% PURPOSE: subroutine for ploterpGUI.m
%          identifies minimum and maximum values of ERP amplitudes for Y scaling.
%
% FORMAT
%
%  [yylim, serror] = erpAutoYLim(ERP, binArray, chanArray, xxlim)
%
% INPUTS
%
% ERP         - ERPset
% binArray    - indices of bins from where to get the amplitude values
% chanArray   - indices of channels from where to get the amplitude values
% xxlim       - current scale for time ([min max] in ms)
%
%
% OUTPUT
%
% yylim       - range for Y scale
% serror      - error flag. 0 means no errors.
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2013

function [yylim, serror] = erpAutoYLim(ERP, binArray, chanArray, xxlim)
serror = 0;
if nargin<1
        error('erpAutoYLim needs 1 input argument at least.')
end

datatype = checkdatatype(ERP);


if nargin<4
        if strcmpi(datatype, 'ERP')
                xxlim = [ERP.xmin ERP.xmax]*1000;
        else
                xxlim = [ERP.xmin ERP.xmax];
        end
end
if nargin<3
        chanArray = 1:ERP.nchan;
end
if nargin<2
        binArray = 1:ERP.nbin;
end
if isempty(binArray)
        binArray = 1:ERP.nbin;
end
if isempty(chanArray)
        chanArray = 1:ERP.nchan;
end
if isempty(xxlim)
    if strcmpi(datatype, 'ERP')
        if strcmp(datatype,'CSD')
            datatype = 'ERP';     % if CSD data, treat as ERP data here
        end
        xxlim = [ERP.xmin ERP.xmax]*1000;
    else
        xxlim = [ERP.xmin ERP.xmax];
    end
end
try
        nbin  = length(binArray);
        nchan = length(chanArray);
        fs    = ERP.srate;
        
        if strcmpi(datatype,'CSD')
            datatype = 'ERP';     % if CSD data, treat as ERP data here
        end
        
        if strcmpi(datatype, 'ERP')
            

            if xxlim(1)<round(ERP.xmin*1000)
                aux_xxlim(1) = round(ERP.xmin*1000);
            else
                aux_xxlim(1) = xxlim(1);
            end
            if xxlim(2)>round(ERP.xmax*1000)
                aux_xxlim(2) = round(ERP.xmax*1000);
            else
                aux_xxlim(2) = xxlim(2);
            end
        else  % fft
            if xxlim(1)<5
                aux_xxlim(1) = 5; % to avoid including the spectrum under 5 Hz in calculating Y auto (too big!)
            else
                aux_xxlim(1) = xxlim(1);
            end
            if xxlim(2)>round(fs/2);
                aux_xxlim(2) = round(fs/2);
            else
                aux_xxlim(2) = xxlim(2);
            end
        end
        
        %disp('start')
        %aux_xxlim
        %[ERP.xmin ERP.xmax]
        %fs
        [p1, p2, checkw] = window2sample(ERP, aux_xxlim(1:2) , fs, 'relaxed');
        %disp('end')
        
        datresh = reshape(ERP.bindata(chanArray,p1:p2,binArray), 1, (p2-p1+1)*nbin*nchan);
        yymax   = max(datresh);
        yymin   = min(datresh);
        if abs(yymax)<1 && abs(yymin)<1
            yylim(1:2) = [yymin*1.2 yymax*1.1]; % JLC. Mar 11, 2015
        else
            yylim(1:2) = round([yymin*1.2 yymax*1.1]); % JLC. Sept 26, 2012
        end
        
        %
        % in case of flatlined ERPs
        %
        if yylim(1)<1E-6 && yylim(2)<1E-6
                if strcmpi(datatype, 'ERP')
                        yylim(1:2) = [-1 1];
                        fprintf('WARNING: It seems like erpAutoYLim() found flatlined ERPs. So auto Y-limit was set to [-1 1].\n');
                else
                        yylim(1:2) = [0 1];
                        fprintf('WARNING: It seems like erpAutoYLim() found flatlined Spectrum. So auto Y-limit was set to [0 1].\n');
                end
        end
catch
        if strcmpi(datatype, 'ERP')
                yylim(1:2) = [-10 10];
        else
                yylim(1:2) = [0 1];
        end
        serror =1;
        fprintf('WARNING: ERPLAB could not find the auto Y limits for %s.\nPlease check your input parameters and waverforms.\n', ERP.erpname);
        fprintf('Default Y limit values were loaded.\n');
        return
end