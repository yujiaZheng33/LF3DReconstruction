function [point_features, select_points] = generate_point_features(radius,lens_coordinates,lenslet_images)

    Threshold=200;

    idxS=length(lens_coordinates(1,:));
    point_features=zeros(2,idxS);
    
    for i=1:idxS
        tmp=lenslet_images(:,:,i);
        maxpix=max(max(tmp));
        if(maxpix>Threshold)
            [y_axis, x_axis]=find(tmp==max(max(tmp)));
            win=tmp(y_axis(1)-1:y_axis(1)+1, x_axis(1)-1:x_axis(1)+1);
            sumImg = sum(win(:));
            x_offset = sum(win)*(1:3)'/sumImg;
            y_offset = (1:3)*sum(win,2)/sumImg;
            point_features(:,i)=[lens_coordinates(1,i)+x_offset+x_axis(1)-radius-3;lens_coordinates(2,i)+y_offset+y_axis(1)-radius-3];
        else
            point_features(:,i)=[0;0];
        end
    end
    
    % Filtered according to the distance between the front and back of the two points
    left=[zeros(2,1),point_features,zeros(2,1)]-[zeros(2,2),point_features];
    right=[point_features,zeros(2,2)]-[zeros(2,1),point_features,zeros(2,1)];
    left_dist=sqrt(left(1,:).^2+left(2,:).^2);
    right_dist=sqrt(right(1,:).^2+right(2,:).^2);
    idx=find((left_dist>10&left_dist<16)|(right_dist>10&right_dist<16));%10-16
    select_points=point_features(:,idx-1);
    

end