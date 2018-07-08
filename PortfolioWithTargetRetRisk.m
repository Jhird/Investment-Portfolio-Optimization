%load('optimizePortfolio.mat');
bioCovar = cov(Returns);
bioMean = mean(Returns);
p = Portfolio('AssetList', ticker);
p = setAssetMoments(p, bioMean, bioCovar);
p = setInitPort(p, 1/p.NumAssets);
[ersk, eret] = estimatePortMoments(p, p.InitPort);
portfolioexamples_plot('Asset Risks and Returns', ...
	{'scatter', ersk, eret, {'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

p = setDefaultConstraints(p);

pwgt = estimateFrontier(p, 20);
[prsk, pret] = estimatePortMoments(p, pwgt);

% Plot efficient frontier

clf;
portfolioexamples_plot('Efficient Frontier', ...
	{'line', prsk, pret}, ...
	{'scatter', ersk, eret, {'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

[rsk, ret] = estimatePortMoments(p, estimateFrontierLimits(p));

display(rsk);
display(ret);
%% Obtain portfolios with targeted return and risk
TargetReturn = 0.80;            % input target annualized return and risk here
TargetRisk = 0.08;

awgt = estimateFrontierByReturn(p, TargetReturn/12);
[arsk, aret] = estimatePortMoments(p, awgt);

bwgt = estimateFrontierByRisk(p, TargetRisk/sqrt(12));
[brsk, bret] = estimatePortMoments(p, bwgt);

% Plot efficient frontier with targeted portfolios

clf;
portfolioexamples_plot('Efficient Frontier with Targeted Portfolios', ...
	{'line', prsk, pret}, ...
	{'scatter', ersk, eret, {'Equal'}}, ...
	{'scatter', arsk, aret, {sprintf('%g%% Return',100*TargetReturn)}}, ...
	{'scatter', brsk, bret, {sprintf('%g%% Risk',100*TargetRisk)}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Show allocation!

aBlotter = dataset({100*awgt(awgt > 0),'Weight'}, 'obsnames', p.AssetList(awgt > 0));

fprintf('Portfolio with %g%% Target Return\n', 100*TargetReturn);
disp(aBlotter);

bBlotter = dataset({100*bwgt(bwgt > 0),'Weight'}, 'obsnames', p.AssetList(bwgt > 0));

fprintf('Portfolio with %g%% Target Risk\n', 100*TargetRisk);
disp(bBlotter);