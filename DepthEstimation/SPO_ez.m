
function E =SPO(EPI, param)
alpha = param.alpha;
Bins = param.Bins;
Labels = param.Labels;
% View = param.Views;
[~, width, ch] = size(EPI);
E = zeros(width, Labels);
BinDiv = round(256/Bins);

for label = 1:Labels
%% 以图像中心旋转
sita = 140*(label/Labels)-70;%[-80°,80°]

J = imrotate(EPI, sita, 'nearest', 'loose');

[col, row, ~] = size(J);

%% 构建Jb
Jb = zeros(row, ch, Bins);
Ib= ceil(J/BinDiv);

for chanal = 1:ch
    for x = 1:row
        Patch = Ib(:,x,chanal);
        Patch=sort(Patch(:));
        x1=diff(Patch);
        x1(end+1)=1;
        x1=find(x1); 
        value=Patch(x1); 
        x1=[0;x1]; 
        Freq=diff(x1);
        if(value(1)==0)
            value(1)=[];
            Freq(1)=[];
        end
        Jb(x,chanal,value(:))=Freq(:);
    end
end


%% 四边形提取
for x = -width/2+1:width/2
    
    Y = round(row/2+x*cosd(sita));
    X = round(col/2 - x*sind(sita));
    O = round(Y-3*alpha*cosd(sita));
    Q = round(Y+3*alpha*cosd(sita));
   %{
   % without weight
   X2 = 1;
   if(O>=1 && Q<=row)
        left = sum(Jb(O:Y,:,:),1);
        right = sum(Jb(Y:Q,:,:),1);
  
        for bin  = 1:Bins
            for chanal = 1:ch
                if(left(1,chanal,bin)+right(1,chanal,bin)>0)
                    X2 = X2 + power(left(1,chanal,bin)-right(1,chanal,bin), 2)/(left(1,chanal,bin)+right(1,chanal,bin));
                end
            end
        end
    end
%} 
    
    X2 = 1;
    for d =1 : 1 : 3*alpha*cosd(sita)
        if(Y-d>=1 && Y+d<=row)
            w = d*exp((-(d^2))/(2*alpha^2));
            Temp = power(Jb(Y-d,:,:)-Jb(Y+d,:,:), 2)./(Jb(Y-d,:,:)+Jb(Y+d,:,:));
            X2 = X2 + w*nansum(nansum(Temp,2),3);
        end
    end
    
 
    S = 1;  m = 1;
    for d = 1 : 1 : col
        if ((J(d,Y,1)>0 || J(d,Y,2)>0 || J(d,Y,3)>0)...
                && X>=1 && X<=col && Y>=1 && Y<=row)
            S = S + sqrt(sum(power(J(d,Y,:)-J(X,Y,:),2)));
            m = m + 1;
        end
    end
    S = m/S;
    
    E(x+width/2,label) = X2 * S ;
    %E1(x+width/2,label) = X2;
    %E2(x+width/2,label) = S ;
end
end
end
