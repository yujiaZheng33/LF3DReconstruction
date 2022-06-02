clear; clc;
addpath('filter');
% --Parameter setting--
param.Bins = 64;
param.Labels = 64;
param.Views = 9;
param.alpha = 0.8;
param.r = 7;
param.eps = 0.0001;
sigma = 0.26;

% --Load the light field images into a 5D double array: (y, x, rgb, v, u)--
[file,path]=uigetfile('*.mat','Select Light Field');
LF=double(cell2mat(struct2cell(load([path,file]))));

[h, w, ~, ~, ~] = size(LF);

mid = round(param.Views/2);
LFuc = squeeze(LF(:, :, :,mid, :));
EPIuc = permute(LFuc, [4 2 3 1]);
LFvc = squeeze(LF(:, :, :, :,mid));
EPIvc = permute(LFvc, [4 1 3 2]);
clear LFuc LFvc;

% --Local depth estimation via spinning parallelogram operator--
tic; 
fprintf('EPIH CostVolume...    \n');
parfor y=1:h
    EPI = squeeze(EPIuc(:,:,:,y));
    Part = SPO_ez(EPI, param);
    E1(y,:,:) = Part(:,:);
end
[~, D1] = max(E1,[],3);
figure; imagesc(D1); axis equal; colorbar;

fprintf('EPIV CostVolume...    \n');
parfor x=1:w
    EPI = squeeze(EPIvc(:,:,:,x));
    Part = SPO_ez(EPI, param);
    E2(:,x,:) = Part(:,:);
end
toc;
[~, D2] = max(E2,[],3);

% --Confidence calculation--
C1 = exp(mean(E1,3)./max(E1,[],3)./(-2*sigma^2));
C2 = exp(mean(E2,3)./max(E2,[],3)./(-2*sigma^2));
E3 = C1.*E1 + C2.*E2;
[~, D3] = max(E3,[],3);

% --Depth Optimization--
Imgcen = squeeze(LF(:,:,:,mid,mid));
fprintf('Weighted Median Filtering...    \n');
D4 = WMT(D3 , Imgcen);


% --Output Depth --%
figure; imagesc(D1); axis equal; colorbar;figure; imagesc(D2); axis equal; colorbar;
figure; imagesc(D3); axis equal; colorbar;figure; imagesc(D4); axis equal; colorbar;

% --Save Data --%
save('result/cotton/D1','D1');save('result/cotton/D2','D2');
save('result/cotton/D3','D3');save('result/cotton/D4','D4');

D1 = uint8((256/(param.Labels))*(D1-1)); D2 = uint8((256/(param.Labels))*(D2-1));
D3 = uint8((256/(param.Labels))*(D3-1)); D4 = uint8((256/(param.Labels))*(D4-1));

imwrite(uint8(D1),'result/cotton/D12.png'); imwrite(uint8(D2),'result/cotton/D22.png');
imwrite(uint8(D3),'result/cotton/D32.png'); imwrite(uint8(D4),'result/cotton/D52.png');



