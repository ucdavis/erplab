% PURPOSE: uiputfile that leaves the calling window in front
%
% FORMAT:
%
% [filename, pathname, filterindex] = erplab_uiputfile(...)
%
% Takes and returns exactly what uiputfile does. The only difference is that the
% windows that were in front before the dialog opened are raised again afterwards,
% so a nested GUI stays stacked over its parent instead of over the MATLAB desktop.
% See erplab_restorefocus for why this is needed.
%
% *** This function is part of ERPLAB Toolbox ***

function varargout = erplab_uiputfile(varargin)

hstack = allchild(groot);   % figures front to back, incl. hidden-handle ones
[varargout{1:nargout}] = uiputfile(varargin{:});
erplab_restorefocus(hstack);

end
