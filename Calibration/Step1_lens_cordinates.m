[file1,path1]=uigetfile('*.png;*.jpg;*.mat','Select One or More White Images','MultiSelect','on');
if length(path1)<2
    return;
end
if ~iscell(file1)
    file1=cellstr(file1);
end

% use 7 for lytro ILLUM
radius=7;

%% 
ImageNum=length(file1);
for n=1:ImageNum
%     temp=load([path1,file1{n}]);
    temp=cell2mat(struct2cell(load([path1,file1{n}])));
    if n==1
        accumulation=double(temp);
    else
        accumulation=accumulation+double(temp);
    end
end
source_type=class(temp);

vig=accumulation/ImageNum;
height=size(vig,1);
width=size(vig,2);
bitsperpixel=size(vig,3);

if bitsperpixel>1
    switch source_type
        case 'uint8'
            vigb=double(rgb2gray(uint8(vig)));
        case 'uint16'
            vigb=double(rgb2gray(uint16(vig)));
    end
else
    switch source_type
        case 'uint8'
            vigb=double(vig);
        case 'uint16'
            vigb=double(vig);
    end
end
%% 
iteration_max=1;

idxS=ceil((height/radius)*(width/radius)/2);%idxS Í¸¾µ´óÖÂÊýÁ¿

lens_coordinates=zeros(2,idxS*2);

center=MicroLensCenter(vigb,[width/2;height/2],radius,iteration_max*10);

idxL=ceil(height/radius/2);
idxR=idxL;
center_line_init=zeros(2,idxL*2);
center_line_init(:,idxL)=center;
while true
    center=MicroLensCenter(vigb,center-[radius*2;0],radius,iteration_max);
    if center(1)>0
        idxL=idxL-1;
        center_line_init(:,idxL)=center;
    else
        break;
    end
end
center=center_line_init(:,idxR);
while true
    center=MicroLensCenter(vigb,center+[radius*2;0],radius,iteration_max);
    if center(1)>0
        idxR=idxR+1;
        center_line_init(:,idxR)=center;
    else
        break;
    end
end
center_line_init=center_line_init(:,idxL:idxR);
lens_coordinates(:,idxS:idxS+idxR-idxL)=center_line_init;
idxE=idxS+idxR-idxL;

triangle_direction=1;

center_line=center_line_init;
while true
    len=size(center_line,2);
    center_line=[center_line(:,1)-[radius*2;0],center_line,center_line(:,len)+[radius*2;0]];
    center_line=MicroLensCenter(vigb,center_line+repmat(radius*[triangle_direction;-1.73],1,size(center_line,2)),radius,iteration_max);
    center_line(:,center_line(1,:)<0)=[];
    if isempty(center_line)
        break;
    else
        lens_coordinates(:,idxS-size(center_line,2):idxS-1)=center_line;
        idxS=idxS-size(center_line,2);
        triangle_direction=-triangle_direction;
    end
end

center_line=center_line_init;
while true
    len=size(center_line,2);
    center_line=[center_line(:,1)-[radius*2;0],center_line,center_line(:,len)+[radius*2;0]];
    center_line=MicroLensCenter(vigb,center_line+repmat(radius*[triangle_direction;1.73],1,size(center_line,2)),radius,iteration_max);
    center_line(:,center_line(1,:)<0)=[];
    if isempty(center_line)
        break;
    else
        lens_coordinates(:,idxE+1:idxE+size(center_line,2))=center_line;
        idxE=idxE+size(center_line,2);
        triangle_direction=-triangle_direction;
    end 
end

lens_coordinates=lens_coordinates(:,idxS:idxE);

center_connection=zeros(7,length(lens_coordinates(1,:)));
for n=1:length(lens_coordinates(1,:))
    dist=(lens_coordinates(1,:)-lens_coordinates(1,n)).^2+(lens_coordinates(2,:)-lens_coordinates(2,n)).^2;
    idx7=find(dist>radius*radius&dist<radius*radius*8);
    dx=lens_coordinates(1,idx7)-lens_coordinates(1,n);
    dy=lens_coordinates(2,idx7)-lens_coordinates(2,n);
    ratio=dy./dx;
    idx0=idx7(ratio>=-0.58&ratio<0.58&dx>0);
    if isempty(idx0)
        idx0=n;
    end
    idx1=idx7(ratio>=0.58&dy>0);
    if isempty(idx1)
        idx1=n;
    end
    idx2=idx7(ratio<-0.58&dy>0);
    if isempty(idx2)
        idx2=n;
    end
    idx3=idx7(ratio>=-0.58&ratio<0.58&dx<0);
    if isempty(idx3)
        idx3=n;
    end
    idx4=idx7(ratio>=0.58&dy<0);
    if isempty(idx4)
        idx4=n;
    end
    idx5=idx7(ratio<-0.58&dy<0);
    if isempty(idx5)
        idx5=n;
    end
    center_connection(:,n)=[n;idx0;idx1;idx2;idx3;idx4;idx5];
end

scale=radius*2;

height_scaled=length(0.5+scale*0.5:scale:height);
width_scaled=length(0.5+scale*0.5:scale:width);

CenterImageInfo=[ones(3,width_scaled*height_scaled);zeros(3,width_scaled*height_scaled)];
CenterImageSize=[width_scaled,height_scaled];

[~,idx_row_start]=min((0.5+scale*0.5-lens_coordinates(1,:)).^2+(0.5+scale*0.5-lens_coordinates(2,:)).^2);
for j=1:height_scaled
    J=0.5+scale*0.5+scale*(j-1);
    for i=1:width_scaled
        I=0.5+scale*0.5+scale*(i-1);
        if i==1
            idx_prev=idx_row_start;
        else
            idx_prev=idx;
        end
        while true
            candidate=center_connection(:,idx_prev)';
            [~,idx]=min((J-lens_coordinates(2,candidate)).^2+(I-lens_coordinates(1,candidate)).^2);
            idx=candidate(idx);
            if idx==idx_prev
                break;
            else
                idx_prev=idx;
            end
        end
        if i==1
            idx_row_start=idx;
        end

        s=lens_coordinates(:,idx);
        idx7=center_connection(:,idx)';
        center_neighbor=lens_coordinates(:,idx7);
        target=[I;J];

        k=sub2ind([height_scaled,width_scaled],j,i);
        for k1=1:length(idx7)-1
            s1=center_neighbor(:,k1);
            for k2=k1+1:length(idx7)
                s2=center_neighbor(:,k2);
                if (s1-s)'*(s2-s)>0
                    source=[idx,idx7(k1),idx7(k2)];
                    weight=InterpolationTriangleWeight(target,lens_coordinates(:,source));
                    if weight(1)>=0 && weight(2)>=0 && weight(3)>=0
                        CenterImageInfo(1:6,k)=[source,weight]';
                        break;
                    end
                end
            end
            if sum(CenterImageInfo(1:3,k))>3
                break;
            end
        end
    end
end

image_size=[width,height];
save('calibration_parameters/lens_coordinates.mat','lens_coordinates');
save('calibration_parameters/center_image_info.mat','CenterImageInfo','CenterImageSize');
vig=vig/max(max(vig))*255;
figure; imshow(uint8(vig)); hold on; plot(lens_coordinates(1,:),lens_coordinates(2,:),'r.'); hold off;
