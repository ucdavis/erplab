% colonrange2num text parser
% take in a string, parse any colon-specified ranges, like 1:5
% output str containing all numbers in range, like 1 2 3 4 5
% axs June 2020
function str_with_range_nums = colonrange2num(string_in)

%

where_colon = strfind(string_in,':');

colon_count = numel(where_colon);

latest_position = numel(string_in);

reg_exp_find_nums = '\d';
reg_exp_find_non_nums = '\D';

while any(where_colon)
    
    last_col_position = where_colon(end);
    
    % Parse the string after the colon
    str_after = string_in(last_col_position+1:end);
    all_nums_after_pos = regexp(str_after,reg_exp_find_nums);
    immediate_num_after_start_pos = all_nums_after_pos(1);
    non_num_after_pos = regexp(str_after(immediate_num_after_start_pos:end),reg_exp_find_non_nums);
    
    if isempty(non_num_after_pos)
        range_chars_after_col = numel(string_in) - last_col_position;
    else
        range_chars_after_col = non_num_after_pos(1);
    end
    
    % Parse string before the (last) colon
    str_before = string_in(1:last_col_position-1);
    [all_nums_before_pos] = regexp(str_before,reg_exp_find_nums);
    immediate_num_before_pos = all_nums_before_pos(end);
    non_num_before_pos = regexp(str_before(1:immediate_num_before_pos),reg_exp_find_non_nums);
    
    if isempty(non_num_before_pos)
        range_chars_before_col = 1;
    else
        range_chars_before_col = non_num_before_pos(end);
    end
    
    % setup the range
    range_start_str = string_in(range_chars_before_col:last_col_position-1);
    range_end_str = string_in(last_col_position+1:last_col_position+range_chars_after_col);
    
    range_start = str2double(range_start_str);
    range_end = str2double(range_end_str);
    
    range_num_here = range_start : range_end;
    
    % replace the colon-indicated range string with numeric range
    replace_pos_before_col = immediate_num_before_pos;
    replace_pos_after_col = last_col_position+non_num_after_pos;
    
    new_str1 = string_in(1:replace_pos_before_col-1);
    new_str2 = num2str(range_num_here);
    new_str3 = string_in(replace_pos_after_col:end);
    
    string_in = [new_str1, new_str2, new_str3];
    
    
    where_colon = strfind(string_in,':');  % ..and look again for colons, for next loop
end

str_with_range_nums = string_in;