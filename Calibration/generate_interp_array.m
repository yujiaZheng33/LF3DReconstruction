function interp_array = generate_interp_array(lens_coordinates,scale,resolution)
    interp_array = zeros(round(resolution(1)/scale),round(resolution(2)/scale),2,3);
    for v = 1:round(resolution(1)/scale)%5368/15
        for u = 1:round(resolution(2)/scale)%7728/15
            dists = sqrt(sum(bsxfun(@minus,lens_coordinates,[u;v]*scale).^2,1));
            [sorted_dists,indices] = sort(dists);
            nearest_indices = indices(1:3);
            ratios = zeros(1,3);
            for k = 1:3
                ratios(k) = prod(sorted_dists([(1:k-1),(k+1:3)]));
            end
            ratios = ratios/(sum(ratios));
            interp_array(v,u,:,:) = [nearest_indices;ratios];
        end
    end
end
