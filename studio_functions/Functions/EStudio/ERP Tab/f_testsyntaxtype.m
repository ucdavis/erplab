%--------------------------------------------------------------------------
function [val, formulaArray]= f_testsyntaxtype(FormulaArrayIn, whocall)
val = 1;
formulaArray = FormulaArrayIn;

if isempty(formulaArray)
        return
else
        formulaArray = strtrim(cellstr(formulaArray));
end
nformulas = length(formulaArray);
[expspliter parts] = regexp(formulaArray, '=','match','split');
ask4fix = 1;
wantfix = 0;
newnumbin = 1;

for t=1:nformulas        
        fcomm = formulaArray{t};
        tokcommentb  = regexpi(fcomm, '^#', 'match');  % comment symbol (June 3, 2013)     
        
        if isempty(tokcommentb) % skip comment symbol               
                pleft  = regexpi(parts{t}{1}, '(\s*nb[in]*\d+)', 'tokens');
                plcom  = regexpi(parts{t}{1}, '(\s*b[in]*\d+)', 'tokens');              
                
                if isempty(pleft) &&  ~isempty(plcom) && strcmpi(whocall,'norecu')
                        if ask4fix
                                BackERPLABcolor = [1 0.9 0.3];    % yellow
                                question = ['For non recursive mode, left side of equation\nmust be define as a new bin.\n'...
                                            'For instance, nbin1 = ...\n\n'...
                                            'Do you want that EStudio corrects the syntax for you?'];
                                title = 'WARNING: Syntax is not proper for non recursive mode';
                                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                                button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
                                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                                
                                if strcmpi(button,'Yes')
                                        ask4fix = 0;
                                        wantfix = 1;
                                elseif strcmpi(button,'Cancel')
                                        val = 0; % cancel
                                        break
                                else
                                        ask4fix = 0;
                                        wantfix = 0;
                                end
                                %else
                                %      wantfix =1;
                        end
                elseif ~isempty(pleft) && strcmpi(whocall,'recu')
                        if ask4fix
                                BackERPLABcolor = [1 0.9 0.3];    % yellow
                                question = ['For recursive mode, left side of equation cannot\nbe define as a new bin.\n'...
                                            'For instance, you must write bin1 = ...\n\n'...
                                            'Do you want that EStudio corrects the syntax for you?'];
                                title = 'WARNING: Syntax is not proper for recursive mode';
                                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                                button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
                                set(0,'DefaultUicontrolBackgroundColor',oldcolor)
                                
                                if strcmpi(button,'Yes')
                                        ask4fix = 0;
                                        wantfix =1;
                                elseif strcmpi(button,'Cancel')
                                        val = 0; % cancel
                                        break
                                else
                                        ask4fix = 0;
                                        wantfix = 0;
                                end
                                %else
                                %      wantfix =1;
                        end
                        %else
                        %      wantfix = 0;

                end
                if wantfix && (~isempty(pleft) || ~isempty(plcom))% fixed  (June 3, 2013): JLC
                        fprintf('WARNING: equation %s ', formulaArray{t})
                        if strcmpi(whocall,'recu') % for recursive mode delete the n in nch
                                formulaArray{t} = sprintf('%s = %s', strtrim(regexprep(parts{t}{1}, '^n*','','ignorecase')), strtrim(parts{t}{2}));
                        else
                                formulaArray{t} = sprintf('%s = %s', strtrim(regexprep(parts{t}{1}, '^n*b(\D*)(\d*)',['nb$1' num2str(newnumbin)],'ignorecase')), strtrim(parts{t}{2}));
                                newnumbin = newnumbin+1;
                        end
                        fprintf('was changed to equation %s \n', formulaArray{t})
                end
        end
end
% if val==1
%         set(handles.editor,'String', char(formulaArray));
% end

