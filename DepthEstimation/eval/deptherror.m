
function [MSE, Badpix] = deptherror(Depth, DepthGT, delta)

[height, width] = size(Depth);

MSE = 0;
for x=1 : height
    for y = 1:width
        MSE = MSE + power(Depth(x, y) - DepthGT(x, y),2);
    end
end
MSE = MSE/(height*width);
%RMSE = sqrt(MSE);

gap = abs(Depth - DepthGT)./DepthGT;
Badpix = size(find(gap>delta),1)/(height*width);

