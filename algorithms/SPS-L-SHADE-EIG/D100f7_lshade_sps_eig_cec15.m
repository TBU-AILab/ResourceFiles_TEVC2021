function f = D100f7_lshade_sps_eig_cec15(x, varargin)
%D100F7_LSHADE_SPS_EIG_CEC15 Fitness of L-SHADE-SPS-EIG-CEC15 on
%CEC15_D100f7
% x is a 15x1 vector
% f is an estimate of the solution error
solver	= 'SPS_L_SHADE_EIG';
D		= 100;
fnum	= 7;
fitfun	= 'cec15_func';
lb		= -100 * ones(D, 1);
ub		= 100 * ones(D, 1);
maxfes	= 1e4 * D;

[~, T] = size(x);
f = zeros(1, T);

parfor t = 1 : T
	options = setDEoptions(x, t, fnum);
	
	[~, f(t), ~] = ...
		feval(solver, fitfun, lb, ub, maxfes, options);
end
end

