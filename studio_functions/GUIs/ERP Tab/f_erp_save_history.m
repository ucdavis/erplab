
function erpcom = f_erp_save_history(erpname,fname,pname)

% fname = [fname ext];
erpcom = sprintf('%s = pop_savemyerp(%s', 'ERP','ERP');
if ~isempty(erpname)
    erpcom = sprintf('%s, ''erpname'', ''%s''', erpcom, erpname);
end
if ~isempty(fname)
    erpcom = sprintf('%s, ''filename'', ''%s''', erpcom, fname);
end
if ~isempty(pname)
    erpcom = sprintf('%s, ''filepath'', ''%s''', erpcom, pname);
%     if warnop==1
%         erpcom = sprintf('%s, ''Warning'', ''on''', erpcom);
%     end
end
   erpcom = sprintf('%s);', erpcom);
end