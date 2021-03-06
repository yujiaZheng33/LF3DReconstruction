clear all;
clc;
close all;
addpath('filter');




% parameters initialization 

param.Bins = 64;                                              % number of bins in the histogram
param.Labels = 64;                                          
param.Views = 9;                                              % 9x9 views
param.alpha = 0.8;
param.r = 7;                                                      %use radius 7 for lytro ILLUM
param.eps = 0.0001;
sigma = 0.26;


% load the light field images into a 5D double array: (y, x, rgb, v, u)

[file,path]=uigetfile('*.mat','Select Light Field');
LF=double(cell2mat(struct2cell(load([path,file]))));

[height, width, ~, ~, ~] = size(LF);

mid = round(param.Views/2);
LFuc = squeeze(LF(:, :, :,mid, :));
EPIuc = permute(LFuc, [4 2 3 1]);
LFvc = squeeze(LF(:, :, :, :,mid));
EPIvc = permute(LFvc, [4 1 3 2]);
clear LFuc LFvc;

% Local depth estimation via spinning parallelogram operator

tic; 

fprintf('EPIH CostVolume...    \n');
parfor y=1:height
    EPI = squeeze(EPIuc(:,:,:,y));
    part_cost = SPO(EPI, param);
    cost1(y,:,:) = part_cost(:,:);
end
[~, depth1] = max(cost1,[],3);
figure; imagesc(depth1); axis equal; colorbar;

fprintf('EPIV CostVolume...    \n');
parfor x=1:width
    EPI = squeeze(EPIvc(:,:,:,x));
    part_cost = SPO(EPI, param);
    cost2(:,x,:) = part_cost(:,:);
end
[~, depth2] = max(cost2,[],3);
figure; imagesc(depth2); axis equal; colorbar;


% Confidence calculation

confidence1 = exp(mean(cost1,3)./max(cost1,[],3)./(-2*sigma^2));
confidence2 = exp(mean(cost2,3)./max(cost2,[],3)./(-2*sigma^2));
cost3 = confidence1.*cost1 + confidence2.*cost2;
[~, depth3] = max(cost3,[],3);
figure; imagesc(depth3); axis equal; colorbar;


% Depth optimization via weighted median filter

center_image = squeeze(LF(:,:,:,mid,mid));
fprintf('Weighted Median Filtering...    \n');
depth4 = WMT(depth3 , center_image);
figure; imagesc(depth4); axis equal; colorbar;

toc;

% Save data 

depth1 = uint8((256/(param.Labels))*(depth1-1)); depth2 = uint8((256/(param.Labels))*(depth2-1));
depth3 = uint8((256/(param.Labels))*(depth3-1)); depth4 = uint8((256/(param.Labels))*(depth4-1));

imwrite(uint8(depth1),'result/depth1.png'); imwrite(uint8(depth2),'result/depth2.png');
imwrite(uint8(depth3),'result/depth3.png'); imwrite(uint8(depth4),'result/depth4.png');



