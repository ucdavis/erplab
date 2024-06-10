% PURPOSE: gets current ERPLAB's version
%
% FORMAT:
%
%   version = geterplabversion;
%
% or
%
%
%  [version reldate] = geterplabversion; % reldate=release date


function [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef

erplab_default_values;
version = erplabver;
reldate = erplabrel;
ColorB_def =ColorB;
ColorF_def=ColorF;
errorColorF_def = errorColorF;
ColorBviewer_def = [0.8 0.8 0.9];