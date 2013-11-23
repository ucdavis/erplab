% under construction...

function com = makecommand4history(p, skipfields, type, funcname)
%skipfields = {'ALLEEG', 'Saveas'};
fn     = fieldnames(p.Results);
if length(setindex)==1 && setindex(1)==1
      inputvari = 'EEG'; % Thanks to Felix Bacigalupo for this suggestion. Dic 12, 2011
else
      inputvari = inputname(1);
end
erpcom = sprintf( 'ERP = pop_averager( %s ', inputvari);
for q=1:length(fn)
      fn2com = fn{q};
      if ~ismember_bc2(fn2com, skipfields)
            fn2res = p.Results.(fn2com);
            if ~isempty(fn2res)
                  if ischar(fn2res)
                        if ~strcmpi(fn2res,'off')
                              erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                        end
                  else
                        if iscell(fn2res)
                              fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                              fnformat = '{%s}';
                        else
                              fn2resstr = vect2colon(fn2res, 'Sort','on');
                              fnformat = '%s';
                        end
                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                  end
            end
      end
end
erpcom = sprintf( '%s );', erpcom);