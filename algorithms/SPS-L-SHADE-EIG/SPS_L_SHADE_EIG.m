function [xmin, fmin, out] = SPS_L_SHADE_EIG(fitfun, lb, ub, maxfunevals, options, BOUND)
% SPS_L_SHADE_EIG L-SHADE algorithm with SPS+EIG framework (variant CEC15)
% SPS_L_SHADE_EIG(fitfun, lb, ub, maxfunevals) minimize the function fitfun in
% box constraints [lb, ub] with the maximal function evaluations
% maxfunevals.
% SPS_L_SHADE_EIG(..., options) minimize the function by solver options.
if nargin <= 4
	options = [];
end

defaultOptions.NP = 600;
defaultOptions.F = 0.5;
defaultOptions.CR = 0.5;
defaultOptions.ER = 1.0;
defaultOptions.p = 0.11;
defaultOptions.H = 6;
defaultOptions.Q = 64;
defaultOptions.Ar = 2.6;
defaultOptions.cw = 0.3;
defaultOptions.fw = 0.1;
defaultOptions.crw = 0.1;
defaultOptions.erw = 0.2;
defaultOptions.CRmin = 0.05;
defaultOptions.CRmax = 0.3;
defaultOptions.NPmin = '4';
defaultOptions.Display = 'off';
defaultOptions.Plotting = 'off';
defaultOptions.ftarget = -Inf;
defaultOptions.TolStagnationIteration = Inf;
defaultOptions.usefunevals = inf;
defaultOptions.initial.X = [];
defaultOptions.initial.f = [];
defaultOptions.initial.A = [];
defaultOptions.initial.nA = [];
defaultOptions.initial.MER = [];
defaultOptions.initial.MCR = [];
defaultOptions.initial.MF = [];
defaultOptions.initial.psai = [];
defaultOptions.initial.iM = [];
defaultOptions.initial.FC = [];
defaultOptions.initial.C = [];
defaultOptions.initial.SP = [];
defaultOptions.initial.fSP = [];
defaultOptions.initial.iSP = [];
defaultOptions.initial.iRecord = [];
defaultOptions.initial.counteval = [];
defaultOptions.initial.countiter = [];
defaultOptions.initial.countstagnation = [];
defaultOptions.initial.countcon = [];
defaultOptions.ConstraintHandling = 'Interpolation';
defaultOptions.EpsilonValue = 0;
defaultOptions.nonlcon = [];
defaultOptions.EarlyStop = 'none';
defaultOptions.CEC15_fnum = 1;
defaultOptions.RecordFEsFactor = [0.0001, 0.001, 0.01, 0.02, 0.03, 0.04, ...
	0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
defaultOptions.Noise = false;

options = setdefoptions(options, defaultOptions);
p = options.p;
H = options.H;
Q = options.Q;
fw = options.fw;
cw = options.cw;
Ar = options.Ar;
NPinit = options.NP;
cwinit = options.cw;
crw = options.crw;
erw = options.erw;
CRmin = options.CRmin;
CRmax = options.CRmax;
NPmin = eval(options.NPmin);
usefunevals = options.usefunevals;
isDisplayIter = strcmp(options.Display, 'iter');
isPlotting = isequal(options.Plotting, 'iter');
RecordPoint = numel(options.RecordFEsFactor);
ftarget = options.ftarget;
TolStagnationIteration = options.TolStagnationIteration;
CEC15_fnum = options.CEC15_fnum;
RecordFEs = options.RecordFEsFactor * maxfunevals;
noiseHandling = options.Noise;

if isequal(options.ConstraintHandling, 'Interpolation')
	interpolation = true;
else
	interpolation = false;
end

nonlcon = options.nonlcon;
EpsilonValue = options.EpsilonValue;
if ~isempty(strfind(options.ConstraintHandling, 'EpsilonMethod'))
	EpsilonMethod = true;
else
	EpsilonMethod = false;
end

if ~isempty(strfind(options.EarlyStop, 'fitness'))
	EarlyStopOnFitness = true;
	AutoEarlyStop = false;
elseif ~isempty(strfind(options.EarlyStop, 'auto'))
	EarlyStopOnFitness = false;
	AutoEarlyStop = true;
else
	EarlyStopOnFitness = false;
	AutoEarlyStop = false;
end

if ~isempty(options.initial)
	options.initial = setdefoptions(options.initial, defaultOptions.initial);
	X		= options.initial.X;
	fx		= options.initial.f;
	A		= options.initial.A;
	nA		= options.initial.nA;
	MER		= options.initial.MER;
	MF		= options.initial.MF;
	MCR		= options.initial.MCR;
	psai_x	= options.initial.psai;
	iM		= options.initial.iM;
	FC		= options.initial.FC;
	C		= options.initial.C;
	SP		= options.initial.SP;
	fSP		= options.initial.fSP;
	iSP		= options.initial.iSP;
	iRecord	= options.initial.iRecord;
	counteval = options.initial.counteval;
	countiter = options.initial.countiter;
	countstagnation = options.initial.countstagnation;
	countcon = options.initial.countcon;
else
	X		= [];
	fx		= [];
	A		= [];
	nA		= [];
	MER		= [];
	MF		= [];
	MCR		= [];
	psai_x	= [];
	iM		= [];
	FC		= [];
	C		= [];
	SP		= [];
	fSP		= [];
	iSP		= [];
	iRecord	= [];
	counteval = [];
	countiter = [];
	countstagnation = [];
	countcon = [];
end

D = numel(lb);
if isempty(X)
	NP = options.NP;
else
	[~, NP] = size(X);
end

% Initialize variables
out = initoutput(RecordPoint, D, NP, ...
	'countcon', ...
	'muMF', ...
	'muMCR', ...
	'muMER', ...
	'muFC');

% Initialize contour data
if isPlotting
	[XX, YY, ZZ] = advcontourdata(D, lb, ub, fitfun, CEC15_fnum);
else
	XX = [];
	YY = [];
	ZZ = [];
end

% counteval
if isempty(counteval)
	counteval = 0;
end

% countiter
if isempty(countiter)
	countiter = 1;
end

% countstagnation
if isempty(countstagnation)
	countstagnation = 0;
end

% countcon
if isempty(countcon)
	countcon = 0;
end

% iRecord
if isempty(iRecord)
	iRecord = 1;
end

% Initialize population
if isempty(X)
	X = zeros(D, NP);
	for i = 1 : NP
		X(:, i) = lb + (ub - lb) .* rand(D, 1);
	end
end

% Evaluation
if isempty(fx)
	fx = feval(fitfun, X, CEC15_fnum);
	counteval = counteval + NP;
	
	if iRecord <= numel(RecordFEs)
		while counteval >= RecordFEs(iRecord)
			out = updateoutput(out, X, fx, counteval, countiter, ...
				'countcon', countcon, ...
				'muMF', mean(MF), ...
				'muMCR', mean(MCR), ...
				'muMER', mean(MER), ...
				'muFC', mean(FC));
			
			iRecord = iRecord + 1;
			
			if iRecord > numel(RecordFEs)
				break;
			end
		end
	end
end

% Constraint violation
if isempty(psai_x) && EpsilonMethod
	psai_x = zeros(1, NP);
	for i = 1 : NP		
		clbx = lb - X(:, i);
		cubx = X(:, i) - ub;
		psai_x(i) = sum(clbx(clbx > 0)) + sum(cubx(cubx > 0));
		
		if ~isempty(nonlcon)			
			[cx, ceqx] = feval(nonlcon, X(:, i));
			countcon = countcon + 1;
			psai_x(i) = psai_x(i) + sum(cx(cx > 0)) + sum(ceqx(ceqx > 0));
		end
	end
end

% Initialize archive
if isempty(A)
	Asize = round(Ar * NP);
	A = zeros(D, Asize);
	for i = 1 : Asize
		A(:, i) = lb + (ub - lb) .* rand(D, 1);
	end
else
	[~, Asize] = size(A);
	if Asize > round(Ar * NP)
		Asize = round(Ar * NP);
		A = A(:, 1 : Asize);
	elseif Asize < round(Ar * NP)
		Asize = round(Ar * NP);
		A = zeros(D, Asize);
		for i = 1 : Asize
			A(:, i) = lb + (ub - lb) .* rand(D, 1);
		end
	end
end

if isempty(nA)
	nA = 0;
else
	nA = min(nA, Asize);
end

% Sort
if ~EpsilonMethod
	[fx, fidx] = sort(fx);
	X = X(:, fidx);
else
	PsaiFx = [psai_x', fx'];
	[~, SortingIndex] = sortrows(PsaiFx);
	X = X(:, SortingIndex);
	fx = fx(SortingIndex);
	psai_x = psai_x(SortingIndex);
end

% MF
if isempty(MF)
	MF = options.F * ones(H, 1);
end

% MCR
if isempty(MCR)
	MCR = options.CR * ones(H, 1);
end

% MER
if isempty(MER)
	MER = options.ER * ones(H, 1);
end

% iM
if isempty(iM)
	iM = 1;
end

% FC
if isempty(FC)
	FC = zeros(1, NP);		% Consecutive Failure Counter
end

% C
if isempty(C)
	C = cov(X');
end

% SP and fSP
if isempty(SP)
	SP = X;
	fSP = fx;
elseif isempty(fSP)
	fSP = feval(fitfun, SP, CEC15_fnum);
	counteval = counteval + NP;	
	
	if iRecord <= numel(RecordFEs)
		while counteval >= RecordFEs(iRecord)
			out = updateoutput(out, X, fx, counteval, countiter, ...
				'countcon', countcon, ...
				'muMF', mean(MF), ...
				'muMCR', mean(MCR), ...
				'muMER', mean(MER), ...
				'muFC', mean(FC));
			
			iRecord = iRecord + 1;
			
			if iRecord > numel(RecordFEs)
				break;
			end
		end
	end
end

% iSP
if isempty(iSP)
	iSP = 1;
end

% Initialize variables
V = X;
U = X;
S_ER = zeros(1, NP);	% Set of EIG rate
S_F = zeros(1, NP);		% Set of scaling factor
S_CR = zeros(1, NP);	% Set of crossover rate
S_df = zeros(1, NP);	% Set of df
Chy = cauchyrnd(0, fw, NP + 10);
iChy = 1;
psai_u = zeros(1, NP);
[~, sortidxfSP] = sort(fSP);

% Display
if isDisplayIter
	displayitermessages(...
		X, U, fx, countiter, XX, YY, ZZ);
end

while true
	% Termination conditions
	outofmaxfunevals = counteval > maxfunevals - NP;
	outofusefunevals = counteval > usefunevals - NP;
	if ~EarlyStopOnFitness && ~AutoEarlyStop
		if outofmaxfunevals || outofusefunevals
			break;
		end
	elseif AutoEarlyStop
		reachftarget = min(fx(:)) <= ftarget;
		TolX = 10 * eps(mean(X(:)));
		solutionconvergence = std(X(:)) <= TolX;
		TolFun = 10 * eps(mean(fx(:)));
		functionvalueconvergence = std(fx(:)) <= TolFun;
		stagnation = countstagnation >= TolStagnationIteration;
		
		if outofmaxfunevals || ...
				reachftarget || ...
				solutionconvergence || ...
				functionvalueconvergence || ...
				stagnation
			break;
		end
	elseif EarlyStopOnFitness
		reachftarget = min(fx) <= ftarget;
		
		if outofmaxfunevals || ...
				reachftarget
			break;
		end
	end
	
	% Iteration counter
	countiter = countiter + 1;
	
	% Memory Indices
	r = floor(1 + H * rand(1, NP));
	
	% EIG rates
	ER = MER(r)' + erw * randn(1, NP);
	ER(ER < 0) = 0;
	ER(ER > 1) = 1;
	
	% Scaling factors
	F = zeros(1, NP);
	for i = 1 : NP
		while F(i) <= 0
			F(i) = MF(r(i)) + Chy(iChy);
			iChy = mod(iChy, numel(Chy)) + 1;
		end
		
		if F(i) > 1
			F(i) = 1;
		end
	end
	
	% Crossover rates	
	CR = MCR(r)' + crw * randn(1, NP);
	CR(CR <= CRmin) = CRmin;
	CR(CR > CRmax) = CRmax;
	
	% pbest
	pbest = 1 + floor(max(2, round(p * NP)) * rand(1, NP));
	
	% Archive
	XA = [X, A];
	SPA = [SP, A];
	
	% Index selection
	r1 = zeros(1, NP);
	r2 = zeros(1, NP);
	
	for i = 1 : NP		
		% Generate r1
		r1(i) = floor(1 + NP * rand);
		while i == r1(i)
			r1(i) = floor(1 + NP * rand);
		end
		
		% Generate r2
		r2(i) = floor(1 + (NP + nA) * rand);
		while i == r1(i) || r1(i) == r2(i)
			r2(i) = floor(1 + (NP + nA) * rand);
		end
	end
	
	% Mutation
	for i = 1 : NP	
		if FC(i) <= Q
			V(:, i) = X(:, i) ...
				+ F(i) .* (X(:, pbest(i)) - X(:, i)) ...
				+ F(i) .* (X(:, r1(i)) - XA(:, r2(i)));
		else
			V(:, i) = SP(:, i) ...
				+ F(i) .* (SP(:, sortidxfSP(pbest(i))) - SP(:, i)) ...
				+ F(i) .* (SP(:, r1(i)) - SPA(:, r2(i)));
		end
	end
	
	C = (1 - cw) * C + cw * cov(X');
	[B, ~] = eig(C);
	XT = X;
	VT = V;
	UT = U;
	SPT = SP;
	
	for i = 1 : NP
		jrand = floor(1 + D * rand);
		if FC(i) <= Q
			if rand < ER(i)
				% EIG Framework
				XT(:, i) = B' * X(:, i);
				VT(:, i) = B' * V(:, i);
				for j = 1 : D
					if rand < CR(i) || j == jrand
						UT(j, i) = VT(j, i);
					else
						UT(j, i) = XT(j, i);
					end
				end
				U(:, i) = B * UT(:, i);
			else
				% Binominal Crossover
				for j = 1 : D
					if rand < CR(i) || j == jrand
						U(j, i) = V(j, i);
					else
						U(j, i) = X(j, i);
					end
				end
			end
		else
			if rand < ER(i)
				% SPS+EIG framework
				XT(:, i) = B' * X(:, i);
				VT(:, i) = B' * V(:, i);
				SPT(:, i) = B' * SP(:, i);
				for j = 1 : D
					if rand < CR(i) || j == jrand
						UT(j, i) = VT(j, i);
					else
						UT(j, i) = SPT(j, i);
					end
				end
				U(:, i) = B * UT(:, i);
			else
				% SPS framework
				for j = 1 : D
					if rand < CR(i) || j == jrand
						U(j, i) = V(j, i);
					else
						U(j, i) = SP(j, i);
					end
				end
			end
		end
	end
	
	if interpolation
        
        %%%%%%%   BOUND HERE
        %display("BOUND = "+BOUND);
        %%%% BOUNDARY ADDITION %%%%		
        % 		- 0	- vychozi
        % 		- 1	- HARD
        % 		- 2	- Random
        % 		- 3	- Periodic
        % 		- 4	- Reflection
        % 		- 5	- Halving
        %bounds = [0 1 2 3 4 5];
        
        %   0 == 5
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        
		% Correction for outside of boundaries
		for i = 1 : NP
			if FC(i) <= Q
				for j = 1 : D
					if U(j, i) < lb(j)
						if BOUND == 0
                            U(j, i) = 0.5 * (lb(j) + X(j, i));
                        elseif BOUND == 1
                            U(j, i) = lb(j);
                        elseif BOUND == 2
                            U(j, i) = -100 + rand() * (100 + 100);
                        elseif BOUND == 3
                            U(j, i) = -100 + PSO_mod(U(j, i) - 100, 200);
                        elseif BOUND == 4
                            U(j, i) = -100 + (-100 - U(j, i));
                        elseif BOUND == 5
                            U(j, i) = (X(j, i) + lb(j)) / 2;
                        end
					elseif U(j, i) > ub(j)
						if BOUND == 0
                            U(j, i) = 0.5 * (ub(j) + X(j, i));
                        elseif BOUND == 1
                            U(j, i) = ub(j);
                        elseif BOUND == 2
                            U(j, i) = -100 + rand() * (100 + 100);
                        elseif BOUND == 3
                            U(j, i) = -100 + PSO_mod(U(j, i) - 100, 200);
                        elseif BOUND == 4
                            U(j, i) = 100 - (U(j, i) - 100);
                        elseif BOUND == 5
                            U(j, i) = (X(j, i) + ub(j)) / 2;
                        end
					end
				end
			else
				for j = 1 : D
					if U(j, i) < lb(j)
						if BOUND == 0
                            U(j, i) = 0.5 * (lb(j) + SP(j, i));
                        elseif BOUND == 1
                            U(j, i) = lb(j);
                        elseif BOUND == 2
                            U(j, i) = -100 + rand() * (100 + 100);
                        elseif BOUND == 3
                            U(j, i) = -100 + PSO_mod(U(j, i) - 100, 200);
                        elseif BOUND == 4
                            U(j, i) = -100 + (-100 - U(j, i));
                        elseif BOUND == 5
                            U(j, i) = (SP(j, i) + lb(j)) / 2;
                        end
					elseif U(j, i) > ub(j)
                        if BOUND == 0
                            U(j, i) = 0.5 * (ub(j) + SP(j, i));
                        elseif BOUND == 1
                            U(j, i) = ub(j);
                        elseif BOUND == 2
                            U(j, i) = -100 + rand() * (100 + 100);
                        elseif BOUND == 3
                            U(j, i) = -100 + PSO_mod(U(j, i) - 100, 200);
                        elseif BOUND == 4
                            U(j, i) = 100 - (U(j, i) - 100);
                        elseif BOUND == 5
                            U(j, i) = (SP(j, i) + ub(j)) / 2;
                        end
					end
				end				
			end
		end
	end
	
	% Display
	if isDisplayIter
		displayitermessages(...
			X, U, fx, countiter, XX, YY, ZZ);
	end
	
	% Evaluation
	fu = feval(fitfun, U, CEC15_fnum);
	counteval = counteval + NP;
	
	% Noise Handling
	if noiseHandling
		index = FC > Q;
		fx(index) = feval(fitfun, X(:, index), CEC15_fnum);
		counteval = counteval + sum(index);
	end
	
	if iRecord <= numel(RecordFEs)
		while counteval >= RecordFEs(iRecord)
			out = updateoutput(out, X, fx, counteval, countiter, ...
				'countcon', countcon, ...
				'muMF', mean(MF), ...
				'muMCR', mean(MCR), ...
				'muMER', mean(MER), ...
				'muFC', mean(FC));
			
			iRecord = iRecord + 1;
			
			if iRecord > numel(RecordFEs)
				break;
			end
		end
	end
	
	% Constraint violation
	if EpsilonMethod
		for i = 1 : NP
			clbu = lb - U(:, i);
			cubu = U(:, i) - ub;
			psai_u(i) = sum(clbu(clbu > 0)) + sum(cubu(cubu > 0));
			
			if ~isempty(nonlcon)
				[cu, cequ] = feval(nonlcon, U(:, i));
				countcon = countcon + 1;
				psai_u(i) = psai_u(i) + sum(cu(cu > 0)) + sum(cequ(cequ > 0));
			end
		end
	end
	
	% Selection
	FailedIteration = true;
	nS = 0;
	if ~EpsilonMethod
		for i = 1 : NP
			if fu(i) < fx(i)
				nS			= nS + 1;
				S_ER(nS)	= ER(i);
				S_F(nS)		= F(i);
				S_CR(nS)	= CR(i);
				S_df(nS)	= abs(fu(i) - fx(i));
				X(:, i)		= U(:, i);
				fx(i)		= fu(i);
				
				if nA < Asize
					A(:, nA + 1)	= X(:, i);
					nA				= nA + 1;
				else
					ri				= floor(1 + Asize * rand);
					A(:, ri)		= X(:, i);
				end
				
				FailedIteration = false;
				FC(i)		= 0;
				SP(:, iSP)	= U(:, i);
				fSP(iSP)	= fu(i);
				iSP			= mod(iSP, NP) + 1;
			else
				FC(i) = FC(i) + 1;
			end
		end
	else
		% Epsilon level comparisons
		for i = 1 : NP
			X_AND_U_IN_EPSILON = psai_u(i) < EpsilonValue && psai_x(i) < EpsilonValue;
			X_AND_U_EQUAL_EPSILON = psai_u(i) == psai_x(i);
			
			if ((X_AND_U_IN_EPSILON || X_AND_U_EQUAL_EPSILON) && fu(i) < fx(i)) || ...
					(~X_AND_U_IN_EPSILON && psai_u(i) < psai_x(i))

				nS			= nS + 1;
				S_ER(nS)	= ER(i);
				S_F(nS)		= F(i);
				S_CR(nS)	= CR(i);
				S_df(nS)	= abs(fu(i) - fx(i));
				X(:, i)		= U(:, i);
				fx(i)		= fu(i);
				psai_x(i)	= psai_u(i);
				
				if nA < Asize
					A(:, nA + 1)	= X(:, i);
					nA				= nA + 1;
				else
					ri				= floor(1 + Asize * rand);
					A(:, ri)		= X(:, i);
				end
				
				FailedIteration = false;
				FC(i)		= 0;
				SP(:, iSP)	= U(:, i);
				fSP(iSP)	= fu(i);
				iSP			= mod(iSP, NP) + 1;
			else
				FC(i) = FC(i) + 1;				
			end
		end
	end
	
	% Update MER, MF, and MCR
	if nS > 0
		w = S_df(1 : nS) ./ sum(S_df(1 : nS));
		MER(iM) = sum(w .* S_ER(1 : nS));
		MCR(iM) = sum(w .* S_CR(1 : nS));
		MF(iM) = sum(w .* S_F(1 : nS) .* S_F(1 : nS)) / sum(w .* S_F(1 : nS));
		iM = mod(iM, H) + 1;
	end
	
	% Update cw
	cw = (1 - counteval / maxfunevals) * cwinit;
	
	% Sort	
	if ~EpsilonMethod
		[fx, fidx] = sort(fx);
		X = X(:, fidx);
		FC = FC(fidx);
	else
		PsaiFx = [psai_x', fx'];
		[~, SortingIndex] = sortrows(PsaiFx);
		X = X(:, SortingIndex);
		fx = fx(SortingIndex);
		FC = FC(SortingIndex);
		psai_x = psai_x(SortingIndex);
	end	
	
	% Update NP and population
    NP = round(NPinit - (NPinit - NPmin) * counteval / maxfunevals);
    fx = fx(1 : NP);
    X = X(:, 1 : NP);
	U = U(:, 1 : NP);
    Asize = round(Ar * NP);	
	if nA > Asize
		nA = Asize;
		A = A(:, 1 : Asize);
	end
    FC = FC(1 : NP);
	[~, sortidxfSP] = sort(fSP);    
    remainingfSPidx = sortidxfSP <= NP;
    SP = SP(:, remainingfSPidx);
    fSP = fSP(:, remainingfSPidx);
    sortidxfSP = sortidxfSP(remainingfSPidx);
    iSP	= mod(iSP - 1, NP) + 1;
	
	% Stagnation iteration
	if FailedIteration
		countstagnation = countstagnation + 1;
	else
		countstagnation = 0;
	end
end

fmin = fx(1);
xmin = X(:, 1);

final.A			= A;
final.nA		= nA;
final.MER		= MER;
final.MCR		= MCR;
final.MF		= MF;
final.psai		= psai_x;
final.iM		= iM;
final.FC		= FC;
final.C			= C;
final.SP		= SP;
final.fSP		= fSP;
final.iSP		= iSP;
final.iRecord	= iRecord;
final.counteval = counteval;
final.countiter = countiter;
final.countstagnation = countstagnation;
final.countcon	= countcon;

while iRecord <= numel(RecordFEs)
	out = updateoutput(out, X, fx, counteval, countiter, ...
		'muMF', mean(MF), ...
		'muMCR', mean(MCR), ...
		'muFC', mean(FC));
	
	iRecord = iRecord + 1;
end

out = finishoutput(out, X, fx, ...
	'final', final);
end
