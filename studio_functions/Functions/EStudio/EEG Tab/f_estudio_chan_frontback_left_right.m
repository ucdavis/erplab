%% Reorder channels according to the standard 10/20 (and extended 10-10) system.
%
% Channels whose labels match the canonical list are placed first, in
% front-to-back / left-to-right order.  Non-matching channels (eye
% channels, mastoid references, bipolar derivations, etc.) are appended
% at the end in their original order.
%
% Matching is case-insensitive; coordinates are NOT required.

function [chanindexnew, errormessg] = f_estudio_chan_frontback_left_right(chanlocs)

chanindexnew = [];
errormessg   = '';

if nargin < 1
    help f_estudio_chan_frontback_left_right;
    return;
end
if isempty(chanlocs)
    errormessg = 'The input is empty.';
    return;
end

% Canonical 10/20 and extended 10-10 order: front-to-back, left-to-right.
canonical_order = { ...
    'nz', ...
    'fp1','fpz','fp2', ...
    'af9','af7','af5','af3','af1','afz','af2','af4','af6','af8','af10', ...
    'f9','f7','f5','f3','f1','fz','f2','f4','f6','f8','f10', ...
    'ft9','ft7','fc5','fc3','fc1','fcz','fc2','fc4','fc6','ft8','ft10', ...
    't9','t7','t3','c5','c3','c1','cz','c2','c4','c6','t4','t8','t10', ...
    'tp9','tp7','cp5','cp3','cp1','cpz','cp2','cp4','cp6','tp8','tp10', ...
    'p9','p7','t5','p5','p3','p1','pz','p2','p4','p6','t6','p8','p10', ...
    'po9','po7','po5','po3','po1','poz','po2','po4','po6','po8','po10', ...
    'o1','oz','o2', ...
    'iz' ...
};

labels       = {chanlocs.labels};
labels_lower = cellfun(@lower, labels, 'UniformOutput', false);

nchan         = length(chanlocs);
canonical_pos = zeros(1, nchan);
for ii = 1:nchan
    idx = find(strcmp(labels_lower{ii}, canonical_order), 1);
    if ~isempty(idx)
        canonical_pos(ii) = idx;
    end
end

matched   = find(canonical_pos > 0);
unmatched = find(canonical_pos == 0);

if isempty(matched)
    errormessg = 'None of the channel labels match the standard 10/20 system. Displaying in original order.';
    return;
end

[~, sort_idx] = sort(canonical_pos(matched));
chanindexnew  = [matched(sort_idx), unmatched];

end
