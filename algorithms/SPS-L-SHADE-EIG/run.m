% if matlabpool('size') == 0
% 	matlabpool open;
% end

addpath('utils');

% ponechame optimalizovane hodnoty
% optimize_de_D10;
% optimize_de_D30;
% optimize_de_D50;
% optimize_de_D100;


for BOUND = [0 1 2 3 4 5]


measureOptions.Dimension = 10;
measureOptions.MaxFunEvals = measureOptions.Dimension * 1e4;
[~, ~, ~, ~, ~, ~, filename_D10] = ...
	genresults_cec15('SPS_L_SHADE_EIG', measureOptions, BOUND);
 
measureOptions.Dimension = 30;
measureOptions.MaxFunEvals = measureOptions.Dimension * 1e4;
[~, ~, ~, ~, ~, ~, filename_D30] = ...
	genresults_cec15('SPS_L_SHADE_EIG', measureOptions, BOUND);
 
measureOptions.Dimension = 50;
measureOptions.MaxFunEvals = measureOptions.Dimension * 1e4;
[~, ~, ~, ~, ~, ~, filename_D50] = ...
	genresults_cec15('SPS_L_SHADE_EIG', measureOptions, BOUND);
 
measureOptions.Dimension = 100;
measureOptions.MaxFunEvals = measureOptions.Dimension * 1e4;
[~, ~, ~, ~, ~, ~, filename_D100] = ...
	genresults_cec15('SPS_L_SHADE_EIG', measureOptions, BOUND);

filenames = {filename_D10, ...
	filename_D30, ...
	filename_D50, ...
	filename_D100};

save('filenames_last.mat', 'filenames');

% gentable2(...
% 	'filenames_201503081051.mat');
% gentable3(...
% 	'filenames_201503081051.mat');
gentable2('filenames_last.mat');
gentable3('filenames_last.mat');
genparamtable;

end