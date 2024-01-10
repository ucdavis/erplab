%%This function is to reorder the channel orders acrodding to
%%front-back/left-right




function [chanindexnew,errormessg] = f_estudio_chan_frontback_left_right(chanlocs)
chanindexnew = [];

if nargin < 1
    help f_estudio_chan_frontback_left_right;
    return;
end
errormessg = '';
if isempty(chanlocs)
    errormessg  = 'The input is empty';
    return;
end
invalidchan = [];
[eloc, labels, theta, radius, indices] = readlocs( chanlocs);
[checkindex,invalidchan] = checktheta(theta);
checkindex1 = checktheta(radius);
if checkindex || checkindex1
    msgboxText = ['Please do channel location first before display the wave with front-back/left-right '];
    title = 'Estudio: f_estudio_chan_frontback_left_right() inputs';
    errorfound(sprintf(msgboxText), title);
    return
end

namesfield = fieldnames(chanlocs);
[C,IA] = ismember_bc2('X',namesfield);
if IA==0
    errormessg  = 'Please check the chanlocs for the current EEG';
    return;
end


validechan = setdiff([1:length(chanlocs)],invalidchan);

labelsvalid = labels(validechan);

[Simplabels,simplabelIndex,SamAll] =  Simplelabels(labelsvalid);

[xchanpos,ychanpos] = get_chanxylocs(chanlocs(validechan));


[Bxpos,Ixpos] = sort(xchanpos,'descend');
ychanpos = ychanpos(Ixpos);
simplabelIndexNew = simplabelIndex(Ixpos);
chanindexnew = Ixpos;

oldindex = 0;
for jj = 1:length(simplabelIndexNew)
    if jj>length(simplabelIndexNew)
        break;
    end
    if oldindex~=simplabelIndexNew(jj)
        oldindex=simplabelIndexNew(jj);
        [xpos,ypos]= find(simplabelIndexNew == simplabelIndexNew(jj));
        if ~isempty(ypos)
            [x_ychanposcell,y_ychanposcell] = sort(ychanpos(ypos),'descend');
            Ixpos(ypos) = Ixpos(ypos(y_ychanposcell));
        end
    end
end
chanindexnew=[validechan(Ixpos),invalidchan];
end




%%check if there are channel locations
function [checkindex,invalidchan ]= checktheta(theta)
checkindex = 0;
count = 0;
invalidchan = [];
for ii = 1:length(theta)
    if isnan(theta(ii))
        count = count+1;
        invalidchan(count) = ii;
    end
end
if count == length(theta)
    checkindex = 1;
end
end


function [Simplabels,simplabelIndex,SamAll] = Simplelabels(labels)

SamAll = 0;
for ii = 1:length(labels)
    labelcell = labels{ii};
    labelcell(regexp(labelcell,'[1,2,3,4,5,6,7,8,9,10,z,Z]'))=[];
    labelsNew{ii} = labelcell;
end

%%get the simple
[~,X,Z] = unique(labelsNew,'stable');
Simplabels = labelsNew(X);
if length(Simplabels)==1
    SamAll = 1;
end

simplabelIndex = zeros(1,length(labels));
count = 0;
for jj = 1:length(Simplabels)
    for kk = 1:length(labelsNew)
        if strcmp(Simplabels{jj},labelsNew{kk})
            count = count+1;
            simplabelIndex(kk) =   jj;
        end
    end
end
end


%%getx, and y positions
function [xposchan,yposchan] = get_chanxylocs(chanlocs)

namesfield = fieldnames(chanlocs);
[C,IAx] = ismember_bc2('X',namesfield);
[C,IAy] = ismember_bc2('Y',namesfield);

xposchan = nan(1,length(chanlocs));
yposchan = nan(1,length(chanlocs));
for ii = 1:length(chanlocs)
    xposchan(ii) =   getfield(chanlocs(ii),'X');
    yposchan(ii) =   getfield(chanlocs(ii),'Y');
end

end
