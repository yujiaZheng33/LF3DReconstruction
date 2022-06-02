function LFView(LF)
% input : 5D light field image structure (y, x, rgb, v, u), single type pixel intensities.

% height = size(LF,1);
% wight = size(LF,2);
v_axis = size(LF,4);
u_axis = size(LF,5);

% cnt=1;
for v=1:v_axis
    for u=1:u_axis
        img = squeeze(LF(:,:,:,v,u));
        
        figure(1); imshow(uint8(img)); 
        title(sprintf('u : %d, v : %d',u,v));
        pause(0.05);
    end
end

