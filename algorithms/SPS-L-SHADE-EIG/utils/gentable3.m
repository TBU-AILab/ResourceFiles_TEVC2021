function gentable3(metafilename)
load(metafilename);
filenames_o = filenames;
nA = numel(filenames_o);
load(filenames_o{1});
[~, nf] = size(allout);


meansuccrates			= zeros(1, nA);
errmeanall				= zeros(nf, nA);
solvers					= cell(1, nA);

for i = 1 : nA
	[solver, errbest, errworst, errmedian, errmean, errstd, succrate, ...
		~, allerrmedian, ~, distancemedian, ~, G, ~, D] = ...
		readonedata(filenames_o{i});
	
	tablefilename		= sprintf('CEC15_D%d_TABLE.xlsx', D);
	convfilename		= sprintf('CEC15_D%d_CONV.xlsx', D);
	contfilename		= sprintf('CEC15_D%d_CONT.xlsx', D);

	solvers{i} = solver;
	solver = sprintf('%d.%s', i, solver);
	xlswrite(tablefilename, {solver}, solver, 'A1');
	xlswrite(tablefilename, {'Func.'}, solver, 'A2');
	xlswrite(tablefilename, (1 : 15)', solver, 'A3:A17');
	xlswrite(tablefilename, {'Best'}, solver, 'B2');
	xlswrite(tablefilename, errbest, solver, 'B3:B17');
	xlswrite(tablefilename, {'Worst'}, solver, 'C2');
	xlswrite(tablefilename, errworst, solver, 'C3:C17');
	xlswrite(tablefilename, {'Median'}, solver, 'D2');
	xlswrite(tablefilename, errmedian, solver, 'D3:D17');
	xlswrite(tablefilename, {'Mean'}, solver, 'E2');
	xlswrite(tablefilename, errmean, solver, 'E3:E17');
	xlswrite(tablefilename, {'Std'}, solver, 'F2');
	xlswrite(tablefilename, errstd, solver, 'F3:F17');
	xlswrite(tablefilename, {'SR'}, solver, 'G2');
	xlswrite(tablefilename, succrate, solver, 'G3:G17');
	xlswrite(convfilename, G, solver, 'A1:U1');
	xlswrite(convfilename, allerrmedian, solver, 'A2:U16');
	xlswrite(contfilename, G, solver, 'A1:U1');
	xlswrite(contfilename, distancemedian, solver, 'A2:U16');
	
	meansuccrates(i) = mean(succrate);
	errmeanall(:, i) = errmean;
	fprintf('%d -- Mean Succ. Rate: %.2f%%\n', i, 100 * meansuccrates(i));
	fprintf('%s: OK!\n', tablefilename);
end

% Normalize Mean Error
normerrmean = zeros(nf, nA);
for i = 1 : nf
	for j = 1 : nA
		normerrmean(i, j) = ...
			(errmeanall(i, j) - min(errmeanall(i, :)) + eps) ...
			./ (max(errmeanall(i, :)) - min(errmeanall(i, :)) + eps);
	end
end
meanerrmean = mean(normerrmean);

fprintf('-- Sorting --\n');
[~, index] = sort(meanerrmean);

for i = 1 : nA
	% Rank 1 (No. 4): lshade_sps; SUCC: 26.43%; NSE: 0.39;
	fprintf('Rank %d (No. %d): %s; SUCC: %.2f%%; NSE: %.2f\n', ...
		i, ...
		index(i), ...
		solvers{index(i)}, ...
		100 * meansuccrates(index(i)), ...
		meanerrmean(index(i)));
end
end

function [solver, errbest, errworst, errmedian, errmean, errstd, succrate, ...
	compcomplex, allerrmedian, qmediansum, distancemedian, fes, G, ...
	qmedianmean, D] = readonedata(filename) %#ok<STOUT>

load(filename);

[~, ~, nF] = size(allfvals); %#ok<*NODEF>
for i = 1 : nF
	fbias = i * 100;
	allfvals(:, :, i) = allfvals(:, :, i) - fbias; %#ok<*AGROW>
end

% Generate Measurements
allfvals(allfvals <= 1e-8) = 0;
errbest		= min(allfvals(end, :, :), [], 2); 
errbest		= errbest(:);
errworst	= max(allfvals(end, :, :), [], 2);
errworst	= errworst(:);
errmedian	= median(allfvals(end, :, :), 2);
errmedian	= errmedian(:);
errmean		= mean(allfvals(end, :, :), 2);
errmean		= errmean(:);
errstd		= std(allfvals(end, :, :), [], 2);
errstd		= errstd(:);
succrate	= mean(allfvals(end, :, :) <= 1e-8);
succrate	= succrate(:);
compcomplex	= (T2 - T1) / T0;
[nprogress, nruns, nfuncs] = size(allfvals);
[~, sortindices] = sort(allfvals(end, :, :), 2);
allfvalssorted = allfvals;
for j = 1 : nfuncs
	allfvalssorted(:, :, j) = allfvals(:, sortindices(:, :, j), j);
end
allerrmedian	= allfvalssorted(:, round(0.5 * (end + 1)), :);
allerrmedian	= reshape(allerrmedian, nprogress, nfuncs)';

if ~isfield(allout{1, 1}, 'FC') %#ok<USENS>
	qmediansum = [];
	qmedianmean = [];
else
	[NP, ~]		= size(allout{1, 1}.FC); 
	q			= zeros(nruns, NP, nprogress, nfuncs);
	for j = 1 : nfuncs
		for k = 1 : nruns
			q(k, :, :, j) = allout{k, j}.FC;
		end
	end
	qsorted = q;
	for j = 1 : nfuncs
		qsorted(:, :, :, j) = q(sortindices(:, :, j), :, :, j);
	end
	qmedian		= qsorted(round(0.5 * (end + 1)), :, :, :);
	qmedianmean = mean(qmedian, 2);
	qmedianmean = reshape(qmedianmean, nprogress, nfuncs)';
	% qmedianmax	= max(qmedian, [], 2);
	% qmedianmax	= reshape(qmedianmax, nprogress, nfuncs)';
	qmedian		= reshape(qmedian, NP, nprogress, nfuncs);
	qmediansum	= sum(qmedian > solverOptions.Q);
	qmediansum	= reshape(qmediansum, nprogress, nfuncs)';
end
distance	= zeros(nruns, nprogress, nfuncs);

for j = 1 : nfuncs
	for k = 1 : nruns
		if isfield(allout{k, j}, 'distancemean')
			if ~isempty(allout{k, j}.distancemean)
				distance(k, :, j) = allout{k, j}.distancemean;
			end
		end
	end
end

distancesorted = distance;
for j = 1 : nfuncs
	distancesorted(:, :, j) = distance(sortindices(:, :, j), :, j);
end
distancemedian	= distancesorted(round(0.5 * (end + 1)), :, :);
distancemedian	= reshape(distancemedian, nprogress, nfuncs)';

fes			= allout{1, 1}.fes;
G			= allout{1, 1}.G;
D			= measureOptions.Dimension;
end