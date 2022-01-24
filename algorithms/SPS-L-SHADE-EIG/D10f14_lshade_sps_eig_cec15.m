function f = D10f14_lshade_sps_eig_cec15(x, varargin)
%D10F14_LSHADE_SPS_EIG_CEC15 Fitness of L-SHADE-SPS-EIG-CEC15 on CEC15_f14
% x is a 15x1 vector
% f is an estimate of the solution error
solver	= 'SPS_L_SHADE_EIG';
D		= 10;
fnum	= 14;
fitfun	= 'cec15_func';
lb		= -100 * ones(D, 1);
ub		= 100 * ones(D, 1);
maxfes	= 1e4 * D;

[~, T] = size(x);
f = zeros(1, T);

for t = 1 : T
	options = setDEoptions(x, t, fnum);
	
	[~, f(t), ~] = ...
		feval(solver, fitfun, lb, ub, maxfes, options);
end
end

