[file2,path2]=uigetfile('*.mat','Select One Calibration Images');
cali_image=double(cell2mat(struct2cell(load([path2,file2]))));
load('calibration_parameters/lens_coordinates.mat');

% use 7 for Illum and 5 for lytro 1.0
radius=7;
% radius = 5;

resolution=size(cali_image);
lens_coordinates=round(lens_coordinates);
lens_coordinates(:,(lens_coordinates(1,:)<=radius)|(lens_coordinates(1,:)>=resolution(2)-radius))=[];
lens_coordinates(:,(lens_coordinates(2,:)<=radius)|(lens_coordinates(2,:)>=resolution(1)-radius))=[];

lenslet_images = generate_lenslet_images(cali_image,radius,lens_coordinates);

[point_features, select_points] = generate_point_features(radius,lens_coordinates,lenslet_images);
figure; imshow(uint8(cali_image)); hold on; plot(select_points(1,:),select_points(2,:),'r.'); plot(7728/2,5368/2,'g*');hold off;%%

%%
% Filter the feature points from top to bottom from left to right and name them 'qn', n being the number of points

nfeatures = 9;
D=zeros(nfeatures,3);
for i=1 : nfeatures
    tmp=strcat('q',num2str(i));
    circle_feature = generate_circle_features(radius,eval(tmp),point_features,lens_coordinates);
    D(i,:)=circle_feature;
end
hold on;plot(D(:,1),D(:,2),'g.');
clear q1;clear q2;clear q3;clear q4;clear q5;clear q6;clear q7;clear q8;clear q9;
save(['calibration_plate\d_',file2],'D');

%%
% Select the circle of confusion data for integration

t=0;
nplates=10;
circle_features=zeros(nfeatures*nplates,3);
for i=1019:1:1030
    tmp=strcat('calibration_plate\d_IMG_',num2str(i),'.mat');
    D=cell2mat(struct2cell(load(tmp)));
    D(:,1)=D(:,1)-D(5,1);
    D(:,2)=D(5,2)-D(:,2);
    circle_features(nfeatures*t+1:nfeatures*(t+1),:)=D;
    t=t+1;
end
save('calibration_parameters/circle_features5.mat','circle_features');

