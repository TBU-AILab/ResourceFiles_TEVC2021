function out = finishoutput(out, X, f, varargin)
%FINISHOUTPUT Finish output info
if ~isempty(varargin)
	for i = 1 : 2 : numel(varargin)
		out.(varargin{i}) = varargin{i + 1};
	end
end

out.final.X = X;
out.final.f = f;
end
