function out = updateoutput(out, X, f, counteval, countiter, varargin)
%UPDATEOUTPUT Update output info
[fmin, fminidx] = min(f);
xmin = X(:, fminidx);
i = out.iRecordFEs;
out.fmin(i) = fmin;
out.fmean(i) = mean(f);
out.fstd(i) = std(f);
out.xmin(:, i) = xmin;
out.xmean(:, i) = mean(X, 2);
out.xstd(:, i) = std(X, 0, 2);
out.fes(i) = counteval;
out.G(i) = countiter;
out.iRecordFEs = out.iRecordFEs + 1;

if ~isempty(varargin)
	for j = 1 : 2 : numel(varargin)
		data = out.(varargin{j});
		if length(varargin{j + 1}) == 1
			data(i) = varargin{j + 1};
		else
			data(:, i) = varargin{j + 1}(:);
		end
		out.(varargin{j}) = data;
	end
end
end
