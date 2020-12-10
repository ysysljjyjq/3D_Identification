clear all; close all; clc;

addpath(genpath('../core'));
addpath(genpath('../utils'));
addpath(genpath('../thirdparty/CPD2/core'));
addpath(genpath('../thirdparty/inexact_alm_rpca'));
addpath(genpath('../mex'));

% N > M
source_path = '../data/Horse/horse_noise_intensity0.0050_keepboundary_number3.off';
des_path = '../data/Horse/horse.off';

result_dir = 'horse_base';
if ~exist(result_dir,'dir')
    mkdir(result_dir);
end

diary([result_dir,'/simp_horse_base.log']);
diary on;

opt.max_it = 200;
opt.debug = 0;
opt.viz = 0; 
opt.segment = 0;
opt.metric = "ALL";

X = read_mesh(source_path);
Y = read_mesh(des_path);


disp('=======origin models=========');
disp(size(X));
disp(size(Y));
opt.savename = "horse_base.mat";
distance = Identification(X, Y, opt, result_dir);

diary off;