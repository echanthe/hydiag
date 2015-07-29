% LAAS-CNRS - DISCO Team
% email address: elodie.chanthery@laas.fr  
% Website: http://projects.laas.fr/hydiag/ 
% 2015

% License
%=========
% HyDiag and its extensions is licensed under the BSD license.

%
close all
clear all
clc

global results % structure (fill in after simulation in right_frame)
global Sys_hybride
global Behavior
global Diagnoser
global Prognoser


%Add current directory and all subdirectories
%Maybe add only GUI/ ?
addpath(genpath(fileparts(which(mfilename))))
addpath(genpath(fileparts([pwd '/ruw.m'])))

%parameters
global sim_sample_time
sim_sample_time = 1e-2;

run GUI_main_window
