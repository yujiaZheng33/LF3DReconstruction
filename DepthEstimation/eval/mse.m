%%
%% Mean squared error times 100
%%
function e = mse(dmap, dgt)
  e = mean2((dmap - dgt).^2) * 100;
end
