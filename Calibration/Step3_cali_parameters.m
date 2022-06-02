% --parameters initialization --
fm=25;
M=-0.06;
pp=1.4*0.001;
r=7;
Fm=2;

% Si=fm*(1-M);
% Fl=Fm/(1-M);
% pm=fm/Fm;
% pl=2*r*pp;
% fl=Fl*pl;


param_init=[fm/Fm fm*(1-M) Fm/(1-M)*2*r*pp fm 0];

load('calibration_parameters/circle_features6.mat');
load('calibration_parameters/P61');

options = optimoptions(@lsqnonlin);
options.Algorithm = 'levenberg-marquardt';
options.ScaleProblem = 'jacobian';
%     options.OptimalityTolerance = 1e-4;
options.Display = 'iter';
P(:,3)=P(:,3)+1;
parameters = lsqnonlin(@(param) fn_project_error(P, param, circle_features),param_init,[0 0 0 0 0],[],options);
save('calibration_parameters/parameters2.mat','parameters');
% M=parameters(2)/parameters(4)-1
%% Calibration Tests
mre = test_mean_reprojection_error(P, circle_features, parameters);

