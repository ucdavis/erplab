% ciplot(lower,upper)
% ciplot(lower,upper,x)
% ciplot(lower,upper,x,colour)
%
% Plots a shaded region on a graph between specified lower and upper confidence intervals (L and U).
% L and U must be vectors of the same length.
% Uses the 'fill' function, not 'area'. Therefore multiple shaded plots
% can be overlayed without a problem. Make them transparent for total visibility.
% x data can be specified, otherwise plots against index values.
% color can be specified (eg 'k'). Default is blue.

% Raymond Reynolds 24/11/06
% Mofified by Javier Lopez-Calderon, 2009

function ciplot(lower,upper,x,colour, alphaval)
if length(lower)~=length(upper)
        error('lower and upper vectors must be same length')
end
if nargin<5
        alphaval=1;
end
if nargin<4
        colour='b';
end
if nargin<3
        x=1:length(lower);
end

% convert to row vectors so fliplr can work
if find(size(x)==(max(size(x))))<2
        x=x'; end
if find(size(lower)==(max(size(lower))))<2
        lower=lower'; end
if find(size(upper)==(max(size(upper))))<2
        upper=upper'; end
if ispc && ~strcmpi(get(gcf,'Renderer'),'OpenGL') % JLC
        set(gcf, 'Renderer', 'OpenGL')
end

% fill([x fliplr(x)],[upper fliplr(lower)],colour)
fill([x fliplr(x)],[upper fliplr(lower)], colour, 'FaceAlpha', alphaval, 'EdgeColor', 'none'); % See patch properties. JLC
% fill([x fliplr(x)],[upper fliplr(lower)], colour, 'EdgeColor', 'none'); % See patch properties. JLC
% camlight; lighting gouraud; 
% alpha(.5)