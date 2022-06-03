function lenslet_images = generate_lenslet_images(cali_image,radius,lens_coordinates)

    idxS=length(lens_coordinates(1,:));
    valid_pixels = double(sqrt((repmat(((1:(2*radius+1))-(radius+1))',1,(2*radius+1)).^2)+...
        (repmat(((1:(2*radius+1))-(radius+1))',1,(2*radius+1)).^2)') < radius);
    
    lenslet_images=zeros(2*radius+1,2*radius+1,idxS);

    for i=1:idxS
            coordinate=lens_coordinates(:,i)';
            lenslet_images(:,:,i)=valid_pixels.*cali_image(coordinate(2)-radius:coordinate(2)+radius, coordinate(1)-radius:coordinate(1)+radius);
%             lenslet_images(:,:,i)=cali_image(coordinate(2)-radius:coordinate(2)+radius, coordinate(1)-radius:coordinate(1)+radius);

    end

end