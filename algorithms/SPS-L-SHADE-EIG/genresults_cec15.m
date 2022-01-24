function [allout, allfvals, allfes, T0, T1, T2, filename] = genresults_cec15(...
	solver, ...
	measureOptions, BOUND)
% GENRESULTS_CEC15 Generate CEC15 results

% Deal with input arguments
if nargin <= 0
	solver = 'SPS_L_SHADE_EIG';
% 	solver = 'lshade_sps_cec15';
end

if nargin <= 1
	measureOptions = [];
end

startTime = tic;
defaultMeasureOptions.Dimension = 10;
defaultMeasureOptions.Runs = 51;
defaultMeasureOptions.FitnessFunctions = 'cec15_func';
defaultMeasureOptions.FunctionNumbers = 1 : 15;
defaultMeasureOptions.MaxFunEvals = defaultMeasureOptions.Dimension * 1e4;
defaultMeasureOptions.LowerBounds = -100;
defaultMeasureOptions.UpperBounds = 100;
measureOptions = setdefoptions(measureOptions, defaultMeasureOptions);
D		= measureOptions.Dimension;
runs	= measureOptions.Runs;
fitfuns = measureOptions.FitnessFunctions;
fnums	= measureOptions.FunctionNumbers;
maxfes	= measureOptions.MaxFunEvals;
lb		= measureOptions.LowerBounds * ones(D, 1);
ub		= measureOptions.UpperBounds * ones(D, 1);

defaultSolverOptions.EarlyStop = 'none';
defaultSolverOptions.RecordFEsFactor = ...
	[0.0001, 0.001, 0.01, 0.02, 0.03, 0.04, 0.05, 0.1, 0.2, 0.3, 0.4, ...
	0.5, 0.6, 0.7, 0.8, 0.9, 1.0];

progress = numel(defaultSolverOptions.RecordFEsFactor);

% Statistic variables
allfes = zeros(progress, runs, length(fnums));
allfvals = zeros(progress, runs, length(fnums));
allout = cell(runs, length(fnums));

% Collect function values and output
pause(rand); % for the reseeding in the next line
rand('state', sum(100*clock)); %#ok<RAND>
for ifnum = 1 : length(fnums)
	fnum = fnums(ifnum);	
	
	solverOptions = defaultSolverOptions;
	if isequal(solver, 'SPS_L_SHADE_EIG')
		optim_param_file = sprintf('optimize_de_result_D%df%d.mat', D, fnum);
		if isempty(dir(optim_param_file))
			default_param_file = sprintf('default_de_D%d.mat', D);
			load(default_param_file, 'xmin');			
			fprintf('Default parameters for f%d are loaded.\n', fnum);
		else
			load(optim_param_file, 'xmin');
			fprintf('Optimal parameters for f%d are loaded.\n', fnum);
		end
		optimOptions = setDEoptions(xmin, 1, fnum);
		solverOptions = setdefoptions(solverOptions, optimOptions);
	elseif isequal(solver, 'lshade_sps_cec15')
		solverOptions.NP = 18 * D;
		solverOptions.CEC15_fnum = fnum;
	end
	
% 	solverOptions.initial.X = ...
% 		repmat(lb, 1, solverOptions.NP) + ...
% 		repmat(ub - lb, 1, solverOptions.NP) .* ...
% 		lhsdesign(solverOptions.NP, D, 'iteration', 100)';
	
	%parfor iruns = 1 : runs
    for iruns = 1 : runs
		fprintf('fnum: %d, maxfes: %d, iruns: %d\n', ...
			fnum, maxfes, iruns);
		[~, ~, out] = ...
			feval(solver, fitfuns, lb, ub, maxfes, solverOptions, BOUND);
		
		allfes(:, iruns, ifnum) = out.fes;
		allfvals(:, iruns, ifnum) = out.fmin;
		allout{iruns, ifnum} = out;
	end
end

% % Computational complexity
fprintf('Computing T0.....');
startT0 = tic;
for i = 1 : 1000000
	x = 0.55 + double(i);
	x = x + x;
	x = x / 2;
	x = x * x;
	x = sqrt(x);
	x = log(x);
	x = exp(x);
	x = x/(x+2); %#ok<NASGU>
end
T0 = toc(startT0);
fprintf('Done\n');
fprintf('Computing T1.....');
X = rand(D, 1);
startT1 = tic;
for i = 1 : 200000
	feval('cec15_func', X, 1);
end
T1 = toc(startT1);
fprintf('Done\n');
fprintf('Computing T2');
allT2 = zeros(5, 1);
solverOptions.ftarget = -inf;
solverOptions.TolX = -inf;
solverOptions.TolStagnationIteration = inf;
solverOptions.RecordFEsFactor = inf;
for i = 1 : 5
	fprintf('.');
	startT2 = tic;
	feval(solver, 'cec15_func', lb, ub, 200000, solverOptions, BOUND);
	allT2(i) = toc(startT2);
end
T2 = mean(allT2);
fprintf('Done\n');
% T0 = 0;
% T1 = 0;
% T2 = 0;

innerdate = datestr(now, 'yyyymmddHHMMSS');
%filename = sprintf('results\\cec15D%d_%s_%s_%s.mat', ...
%	measureOptions.Dimension, solver, innerdate, BOUND);
filename = sprintf('results\\cec15D%d_%s_%d.mat', ...
	measureOptions.Dimension, solver, BOUND);
elapsedTime = toc(startTime); %#ok<NASGU>

save(filename, ...
	'allout', ...
	'allfvals', ...
	'allfes', ...
	'T0', 'T1', 'T2', ...
	'solver', ...
	'measureOptions', ...
	'solverOptions', ...
	'elapsedTime');
end