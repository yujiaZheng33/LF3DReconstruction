function parameters = estimate_calibration_parameters(circle_features,param_init)
%     param_init=[100 93 1 80 0];
%[pm Si fl fm k]
%     pm��͸����Ч��Ȧ30-250mm
%     Si��ཹƽ�浽��͸���ľ���92.8
%     fl΢͸������
%     fm��͸������80mm
%     k��ͷ����ϵ��

    circle_features(:,1)=circle_features(:,1)-3875;
    circle_features(:,2)=2513-circle_features(:,2);

    circle_features(:,1)=circle_features(:,1)+3867.3;
    circle_features(:,2)=2685.7-circle_features(:,2);
    
    circle_features(:,3)=-circle_features(:,3);
    
    options = optimoptions(@lsqnonlin);
    options.Algorithm = 'levenberg-marquardt';
    options.ScaleProblem = 'jacobian';
%     options.OptimalityTolerance = 1e-4;
    options.Display = 'iter';
%     options.FunctionTolerance = 1e-12;
%     options.StepTolerance = 0;
%     options.MaxFunctionEvaluations=100000;
%     options.MaxIterations = 500;
    parameters = lsqnonlin(@(param) func_project_error2(P, param, circle_features),param_init,[0 0 0 0 0],[],options);

    
    

end
