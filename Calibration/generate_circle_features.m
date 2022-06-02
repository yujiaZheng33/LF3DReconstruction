function circle_features = generate_circle_features(radius,points,point_features,lens_coordinates)

    idx = arrayfun(@(n) find((point_features(1,:)==points(n,1))&(point_features(2,:)==points(n,2))),1:length(points(:,1)),'un',false);
    idx = cell2mat(idx);
    lens=lens_coordinates(:,idx)';
    
    
    Dsub=2*radius+1;
    nfeatures=length(points(:,1));
    data_x=[repmat([-Dsub,0],nfeatures,1), lens(:,1)-points(:,1), Dsub*lens(:,1)];
    data_y=[repmat([0,-Dsub],nfeatures,1), lens(:,2)-points(:,2), Dsub*lens(:,2)];
    circle_data=[data_x;data_y];
    [~,~,V] = svd(circle_data);
    v = V(:,end);
    v = v/v(end);
    Cdf = v(1:2)';
    Ddf = v(3);
    circle_feature = [Cdf,Ddf];

    circle_features=circle_feature;
    viscircles([Cdf(1),Cdf(2)],abs(Ddf)/2,'Color','g');
%     plot(Cdf(:),Cdf(:),'g.');
    
end