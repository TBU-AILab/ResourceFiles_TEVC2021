function out = initoutput(RecordPoint, D, NP, varargin)
% INITOUTPUT Initialize output info
out.iRecordFEs = 1;
out.fmin = inf(1, RecordPoint);
out.fmean = inf(1, RecordPoint);
out.fstd = inf(1, RecordPoint);
out.xmean = inf(D, RecordPoint);
out.xmin = inf(D, RecordPoint);
out.xstd = inf(D, RecordPoint);
out.fes = zeros(1, RecordPoint);
out.bestever.fmin = Inf;
out.G = zeros(1, RecordPoint);

if ~isempty(varargin)
	nvarargin = numel(varargin);
	for i = 1 : nvarargin
		if isequal(varargin{i}, 'FC') || ...
				isequal(varargin{i}, 'MF') || ...
				isequal(varargin{i}, 'MCR')
			out.(varargin{i}) = zeros(NP, RecordPoint);
		else
			out.(varargin{i}) = zeros(1, RecordPoint);
		end
	end
end
end
