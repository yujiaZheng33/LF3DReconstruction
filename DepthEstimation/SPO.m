function E =SPO(EPI, param)
alpha = param.alpha;
Bins = param.Bins;
Labels = param.Labels;
[~, w, ch] = size(EPI);
E = zeros(w, Labels);
Ib = ceil(EPI*Bins/256);

for label = 1:Labels
    % Rotate around the center of the image.
    sita = 120*(label/Labels)-60;%[-60бу,60бу]
    J = round(imrotate(Ib, sita, 'loose', 'bilinear'));
    [~, row, ~] = size(J);
    
    %Generating histograms by Image
    Jb = generate_histogram(J,ch,Bins);
    
    
    % quadrilateral extraction by Pablo et al.
    % Contour Detection and Hierarchical Image Segmentation
    s = round(row/2+(-w/2)*cosd(sita))+1;
    e = round(row/2+(w/2)*cosd(sita));
    Jb = Jb(s:e,:,:);
    d=1:1:3*alpha*cosd(sita);
    weight = d.*exp(-d.^2/(2*alpha^2));
    deno = convn(Jb, [weight,0,fliplr(weight)] ,'same');
    deno = sum(sum(deno,2),3);
    nu = convn(Jb, [weight,0,-fliplr(weight)] ,'same');
    nu = sum(sum(nu.^2,2),3);
    chi_square = nu./deno;
    E(:,label) = resample(chi_square,w,size(chi_square,1));
    
    
    for x = -w/2+1 : w/2
        Y = round(row/2+x*cosd(sita));
        
        X2 = 0;
        for d =1 : 1 : 3*alpha*cosd(sita)
            if(Y-d>=1 && Y+d<=row)
                weight = d*exp((-(d^2))/(2*alpha^2));
                t = power(Jb(Y-d,:,:)-Jb(Y+d,:,:), 2)./(Jb(Y-d,:,:)+Jb(Y+d,:,:));
                X2 = X2 + weight*nansum(nansum(t,2),3);
            end
        end
        E(x+w/2,label) = X2(Y);
    end
    
end
end
