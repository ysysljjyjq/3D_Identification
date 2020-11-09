clear all; close all; clc;
% 
addpath(genpath('../core'));
addpath(genpath('../utils'));
addpath(genpath('../thirdparty/CPD2/core'));
addpath(genpath('../thirdparty/inexact_alm_rpca'));
addpath(genpath('../mex'));
store_name = 'xxxx';
metric = "dsfdg";
block_num = 1;
dpath = strcat('distance_', store_name, '_', metric, '_', num2str(block_num), '.csv');
disp(dpath);
% source_path = '../model/frequent/bun_zipper_res4.ply';
% des_path = '../model/stanford 3D/dragon_recon/dragon_vrip_res4.ply';
% X = read_mesh(source_path);
% Y = read_mesh(des_path);
% % Y = X;
% 
% % % generate target point set
% R = cpd_R(rand(1),rand(1),rand(1));
% [N, D] = size(X); 
% t = rand(D, 1);
% X = rand(1) * X * R' + repmat(t', N, 1);
% 
% % Y = downsample(Y, 0.1);
% % 
% % % option
% opt.method = "rigid";
% opt.viz=1;          
% opt.outliers=0;     
% opt.normalize=1;    
% opt.scale=1;       
% opt.rot=1;          
% opt.corresp=1;      
% opt.max_it=30;
% opt.tol=1e-8;
% 
% [Transform,correspondence] = cpd_register(X, Y, opt);
% 
% 
% opt.debug=0;
% [X, Y] = sort_By_Longest_Axis(X, Transform.Y, opt);
% % 
% [XN, YN, ~]=cpd_normalize(X, Y); 
% P = postProbablity(XN, YN, Transform.sigma2, opt.outliers);
% heatmap(P(1:300,1:300),'Colormap',parula(5));
% % heatmap(P,'Colormap',parula(5));
% % sss=sum(P(:,100));
% % figure('Name','1');
% % plot(P(:,100));
% % PT = P';
% % lll = zeros(1, N);
% % for i = 1 : N
% %      lll(i) = kurtosis(PT(i,:));
% % end
% % bbb = kurtosis(P);
% % x = PT(1,:);
% % u = mean(x);
% % d = var(x);
% % disp(u);
% % disp(d);
% % disp(1/N);
% % disp((N-1)/(N*N));
% % disp(lll(1));
% % NN = (N - 1) * (N - 1);
% % disp((NN + 1 / NN) / N);
% if opt.corresp, C=cpd_Pcorrespondence(XN, YN,Transform.sigma2,opt.outliers); else C=0; end;
% 
% %CC = repmat(C,1,3);
% 
% [M, ~] = size(Y);
% 
% YY = zeros(M,3); 
% for i = 1 : M
%     %disp(C(i));
%     YY(i, :) = X(C(i), :);
%     %disp(X(C(i), :));
%     %disp(Y(C(i)));
%     %disp(YY(i));
% end
% R = corr2(Y, YY);


% 
% figure('Name','Before');
% cpd_plot_iter(X, Y); %title('Before');
% figure('Name','After registering Y to X');
% cpd_plot_iter(X, Transform.Y); % title('After registering Y to X');
% 
% tic;
% [AA,EE,ITER] = inexact_alm_rpca(P');
% figure('name','A');
% plot(AA(:,1));
% disptime(toc);
% 
% 
% % aa = PT(P, C);
% % bb = PF(P);
% % 
% % rho = corr(aa(:), bb(:), 'type','pearson');
% % tic;
% % [AA1,EE1,ITER1] = inexact_alm_rpca(P);
% % figure('name','AA');
% % plot(AA1(:,1));
% % disptime(toc);
% 
% 
function [X_new, Y_new] = sort_By_Longest_Axis(X, Y, opt)
    if opt.debug
        disp(['max value of X coordiantes : ', num2str(max(X))]);
        disp(['min value of X coordiantes : ', num2str(min(X))]);
        disp(['length of X coordiantes in 3 axes: ', num2str(max(X) - min(X))]);
    
        disp(['max value of Y coordiantes : ', num2str(max(Y))]);
        disp(['min value of Y coordiantes : ', num2str(min(Y))]);
        disp(['length of Y coordiantes in 3 axes: ', num2str(max(Y) - min(Y))]);
    end
    [max_length, axis] = max(max(X) - min(X));
    [y_length, y_axis] = max(max(Y) - min(Y));
    if max_length < y_length
        max_length = y_length;
        axis = y_axis;
    end
    disp(['the longest axis is ', num2str(axis), ' whose length is ', num2str(max_length)]);
    if max_length == 1
        X_new = sortrows(X);
        Y_new = sortrows(Y);
    else
        X_new = sortrows(X, [axis, 1]);
        Y_new = sortrows(Y, [axis, 1]);
    end
    
end
% 
% 
% function res = PT(P, corres)
%     [M, N] = size(P);
%     res = zeros(M, N);
%     for i = 1 : M
%         res(i, corres(i)) = 1;
%     end
% end
% 
% function res = PF(P)
%     res = P >= 0.5;
% end

