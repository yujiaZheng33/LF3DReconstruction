addpath('LFToolbox0.4');

[file,path]=uigetfile('*.LFR','Select One Light Field','MultiSelect','on');

if length(path)<2
    return;
end
if ~iscell(file)
    file=cellstr(file);
end

nfile=length(file);
for n=1:nfile
    disp(['processing ',file{n},'......']);
    [LFP, ExtraSections] = LFReadLFP( [path,file{n}] );
    RawImg = LFP.RawImg;
    save(strcat('Results_saving/',file{n}(1:8),'.mat'),'RawImg');
end

% RawImg = double(RawImg);
% RawImg = uint8(RawImg./max(max(RawImg))*255);
% RawImg = demosaic(RawImg,LFP.DemosaicOrder);
% imwrite(RawImg,'raw_fig/IMG_0002.bmp');
% 
% tmp=(double(RawImg)+0.5)/256;
% tmp = tmp.^(1/1.7);
% tmp=uint8(tmp*256-0.5);
% imshow(tmp);