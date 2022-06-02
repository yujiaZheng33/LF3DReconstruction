function error=fn_project_error(P, param, circle_features)
    Ou=3867.3-7728/2;
    Ov=2685.7-5368/2;
    pp=1.4*0.001;


    Px=P(:,1);
    Py=P(:,2);
    Pz=P(:,3);

    pm=param(1);%主透镜有效光圈30-250mm
    Si=param(2);%像侧焦平面到主透镜的距离92.8
    fl=param(3);%微透镜焦距
    fm=param(4);%主透镜焦距80mm
    k=param(5);%镜头畸变系数

    Cu=circle_features(:,1);
    Cv=circle_features(:,2);
    Ddf=circle_features(:,3);
    r=(Cu-Ou).^2+(Cv-Ov).^2;
    Cucorr=(1+k*r).*(Cu-Ou)+Ou;
    Cvcorr=(1+k*r).*(Cv-Ov)+Ov;
    

    k1=(Si+fl)/pp;
    Ddfproj=pm*k1*(1/fm-1/Si-1./Pz);
    Cuproj=k1.*Px./Pz+Ou;%4-14
    Cvproj=k1.*Py./Pz+Ov;%4-15
    

    error=[Cucorr-Cuproj, Cvcorr-Cvproj, Ddf-Ddfproj];
end
