
% fm=25;
% M=-0.05;
% pp=1.4*0.001;
% r=7;
% Fm=2;
% 
% Si=fm*(1-M);
% Fl=Fm/(1-M);
% pm=fm/Fm;
% pl=2*r*pp;
% fl=Fl*pl;
% parameters=[pm Si fl fm 0];


[file2,path2]=uigetfile('*.mat','Select Depth Map');
depth=double(cell2mat(struct2cell(load([path2,file2]))));
load('../Camera_Calibration/calibration_parameters/parameters2.mat');

radius=7;% use 7 for Illum and 5 for lytro 1.0
Dsub=2*radius+1;
pp=1.4*0.001;
pm=parameters(1);
Si=parameters(2);%Ïñ²à½¹Æ½Ãæµ½Ö÷Í¸¾µµÄ¾àÀë Si=fm(1-M)
fl=parameters(3);
fm=parameters(4);%Ö÷Í¸¾µ½¹¾à 9.5-77.8mm


sita_set=70;% sita range [-70¡ã,70¡ã]
sita=-2*sita_set*(depth./max(max(depth)))+sita_set;%%



d_val=tan(sita*pi/180);

f1=(Si-fm)/(fm*Si);
f2=pp/(pm*(Si+fl));

Pz=1./(f1-f2*Dsub.*d_val);
Px=zeros(size(Pz,1),size(Pz,2));
Py=zeros(size(Pz,1),size(Pz,2));
for i=1:size(depth,1)
    for j=1:size(depth,2)
        Px(i,j)=pp*Dsub*i*Pz(i,j)/(Si+fl);
        Py(i,j)=pp*Dsub*j*Pz(i,j)/(Si+fl);
    end
end
Pxind=reshape(Px,[1,size(Pz,1)*size(Pz,2)]);
Pyind=reshape(Py,[1,size(Pz,1)*size(Pz,2)]);
Pzind=reshape(Pz,[1,size(Pz,1)*size(Pz,2)]);

figure; imagesc(d_val);  colorbar;
% figure; imagesc(Px);  colorbar;
% figure; imagesc(Py);  colorbar;
figure; imagesc(Pz);  colorbar;
