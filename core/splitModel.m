function result = splitModel(X, Y, opt, sigma2, result_dir)
%% preprocess
paths.rpca_path = 0;
if opt.debug
    paths.off_path = [result_dir, '/off'];    % store off file
    paths.pic_path = [result_dir, '/pic'];    % store pictures
    paths.X_path = [paths.off_path, '/X'];          % store off file of blocks of X
    paths.Y_path = [paths.off_path, '/Y'];          % store off file of blocks of Y
    paths.rpca_path = [paths.pic_path, '/inexact']; % store results of rpca 
    paths.block_path = [paths.pic_path, '/block'];  % store results of block
    checkAndMkdir(paths.off_path);
    checkAndMkdir(paths.pic_path);
    checkAndMkdir(paths.X_path);
    checkAndMkdir(paths.Y_path);
    checkAndMkdir(paths.rpca_path);
    checkAndMkdir(paths.block_path);
end

%% split the point cloud along the logest axis
% ѡȡX��Y��Z���е㸲�ǳ�������Ტ�Ը���Ϊ��������
[X, Y] = sort_By_Longest_Axis(X, Y, opt);

% ��ģ�;��ȷ�Ϊnum�ݣ�����ÿһ�ݵ�����󲻳���thred
[N, ~] = size(X);
[M, ~] = size(Y);
num = ceil(max(N, M) / opt.thred);
n = floor(N / num);
m = floor(M / num);
if opt.debug
    disp(['These models are splitted to ',num2str(num), ' blocks.']);
    disp(['Each block of X has ', num2str(n), ' points.'])
    disp(['Each block of Y has ', num2str(m), ' points.'])
end

%% compute rpca result each block
result = cell(1, num);
for i = 1 : num - 1
    x = X((i - 1) * n + 1 :  n * i, :, :);
    y = Y((i - 1) * m + 1 :  m * i, :, :);
    result{1,i} = compute_result(x, y, sigma2, opt, paths, i);
end

x = X((num - 1) * n + 1 : end, :, :);
y = Y((num - 1) * m + 1 : end, :, :);
result{1,num} = compute_result(x, y, sigma2, opt, paths, num);
end

%% util function
function A = compute_result(x, y, sigma2, opt, paths, num)
    if opt.debug
        % ��xy�ֿ�ȽϽ������ΪjpgͼƬ��ʽ
        % savePic(num2str(k), [block_path, '/part_', num2str(k)], x, y);
        % ��xy�ֿ�ȽϽ�����浽fig�ļ���
        %block_path = path.block_path;
        saveFig(num2str(num), [paths.block_path, '/part_', num2str(num)], x, y);
        write_off([paths.X_path, '/part_', num2str(num), '.off'], x);
        write_off([paths.Y_path, '/part_', num2str(num), '.off'], y);
    end
    p = resbonsibility(x, y, sigma2, opt);
    [A, ok]= rpca(p, num, paths.rpca_path, opt);
end

function [A, ok]= rpca(p, i, rpca_path, opt)
    ok = 1;
    disp('inexact_alm_rpca');
    tic;
    try
        [A, ~, ~] = inexact_alm_rpca(p');
    catch
        disp("error occur!! Treat it as completely unmatched.")
        ok = 0;
        return;
    end
    if opt.debug
        inexact = figure('name',['A_', num2str(i)]);
        plot(A(:,1));
        saveas(inexact,[rpca_path,'/part_', num2str(i)],'jpg');
    end
    disptime(toc);
end

function savePic(pic_name, store_name, x, y)
    pic = figure('Name',pic_name);
    disp(['===========The ', pic_name, 'th part==========']);
    disp(['x : ', num2str(size(x)), ' y : ', num2str(size(y))]);
    cpd_plot_iter(x, y); 
    saveas(pic,store_name,'jpg');
end

function saveFig(pic_name, store_name, x, y)
    pic = figure('Name',pic_name);
    disp(['===========The ', pic_name, 'th part==========']);
    disp(['x : ', num2str(size(x)), ' y : ', num2str(size(y))]);
    cpd_plot_iter(x, y); 
    saveas(pic,store_name,'fig');
end

function checkAndMkdir(dirname)
    if exist(dirname,'dir')
        rmdir(dirname, 's');
    end
    mkdir(dirname);
end

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

function P = resbonsibility(X, Y, sigma2, opt)
    % X and Y must normalize to zero mean and unit variance
    [X, Y, ~]=cpd_normalize(X,Y); 
    % comupte resbonsibility
    P = postProbablity(X, Y, sigma2, opt.outliers);
end
