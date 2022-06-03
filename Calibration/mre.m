function mre = mre(P, circle_features, parameters)
    Ou=3867.3-7728/2;
    Ov=2685.7-5368/2;
    pp=1.4*0.001;

    pm=parameters(1);
    Si=parameters(2);
    fl=parameters(3);
    fm=parameters(4);
    k=parameters(5);

    Cu=circle_features(:,1);
    Cv=circle_features(:,2);
    Ddf=circle_features(:,3);
    r=(Cu-Ou).^2+(Cv-Ov).^2;
    Cucorr=(1+k*r).*(Cu-Ou)+Ou;
    Cvcorr=(1+k*r).*(Cv-Ov)+Ov;

    k1=pp/(Si+fl);
    Pz=(Si-fm)/(fm*Si)-k1/pm.*Ddf;
    Pz=1./Pz;
    Px=k1.*(Cucorr-Ou).*Pz;
    Py=k1.*(Cvcorr-Ov).*Pz;
    
    mre=[Px Py Pz]-P;
    figure;
    plot3(Px,Py,Pz,'r.');hold on;
    plot3(P(:,1),P(:,2),P(:,3),'b.');
    xlabel({'X(mm)'});ylabel({'Y(mm)'});zlabel({'Z(mm)'});
end