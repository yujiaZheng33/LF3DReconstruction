[file1,path1]=uigetfile('*.jpg;*.bmp','Image');

load('../Camera_Calibration/calibration_parameters/center_image_info.mat');
load('../Camera_Calibration/calibration_parameters/lens_coordinates.mat');

image=imread([path1,file1]);
source_type=class(image);
image=double(image);
channel=size(image,3);

% y, x, rgb, v, u
LF=zeros(CenterImageSize(2),CenterImageSize(1),3,9,9);
for u=-4:4
    for v=-4:4
        s1=Interpolation4_Color([lens_coordinates(1,CenterImageInfo(1,:))+u;lens_coordinates(2,CenterImageInfo(1,:))+v],image);
        s2=Interpolation4_Color([lens_coordinates(1,CenterImageInfo(2,:))+u;lens_coordinates(2,CenterImageInfo(2,:))+v],image);
        s3=Interpolation4_Color([lens_coordinates(1,CenterImageInfo(3,:))+u;lens_coordinates(2,CenterImageInfo(3,:))+v],image);
        interp=s1.*repmat(CenterImageInfo(4,:),channel,1)+s2.*repmat(CenterImageInfo(5,:),channel,1)+s3.*repmat(CenterImageInfo(6,:),channel,1);
        img_center=zeros(CenterImageSize(2),CenterImageSize(1),channel);
        for k=1:channel
            img_center(:,:,k)=reshape(interp(k,:),CenterImageSize(2),CenterImageSize(1));
        end
        LF(:,:,:,v+5,u+5)=img_center;
    end
end

save('LF.mat','LF');
LFView(LF);
