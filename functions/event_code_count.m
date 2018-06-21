% Summarise EEG events
% axs Jun 2018
function [ev_count] = event_code_count(EEG)

evt = struct2table(EEG.event);
evtype = evt.type;

n_ev = numel(evtype);

ev2 = zeros(n_ev,1);


str_flag = 0;
for i = 1:n_ev
    
    ev_here = evt.type{i};
    
    ev_num = str2double(ev_here);
    
    
    if isnan(ev_num)
        if strcmp(ev_here,'boundary') == 1
            ev_num = -99;
        else
            ev_num = 0;
            str_flag = 1;
        end
    end
    
    ev2(i) = ev_num;
end


% Now parse and display
n_ev_types = unique(ev2);

ev_count = zeros(numel(n_ev_types),2);
ev_count(1:end,1) = n_ev_types;



for i = 1:numel(n_ev_types)
    indx_here = find(ev2 == n_ev_types(i));
    count_here = numel(indx_here);
    ev_count(i,2) = count_here;
end

disp('Your event code counts are:')
disp(ev_count)

if str_flag == 1
    disp('Event codes of unknown strings were taken as 0s');
end