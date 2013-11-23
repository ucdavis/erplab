

function erpsinglecolorbar(haxes, hcolorbar, nlat)
if isempty(hcolorbar) || ismember_bc2(0, hcolorbar)
        fprintf('erpsinglecolorbar() got an invalid colorbar handle...\n');
        return
end

%
% When single colorbar is requiered (custom scale)
%
ksub = length(haxes);
Pwidth(1)=1;
kk2=1;
for kk=1:ksub
        %axes(haxes(kk))
        if haxes(kk)~=0
                Pk = get(haxes(kk),'OuterPosition');
                %Pleft(kk) = Pk(1);
                Pwidth(kk2) = Pk(3);
                kk2 = kk2+1;
        end
end
%set(hcb, 'Position', [min([0.57+0.16*nlat max(Pleft)+max(Pwidth)]) .11 max(Pwidth)/(100/nlat) .8150])
% set(hcolorbar, 'Position', [0.01 .11 max(Pwidth)/(100/nlat) .8150], 'CLim', maplimit)
set(hcolorbar, 'Position', [0.01 .11 max(Pwidth)/(100/nlat) .8150])
set(hcolorbar, 'Visible','on')