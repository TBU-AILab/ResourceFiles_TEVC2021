%This function is used for L-SHADE bound checking 
function vi = boundConstraint (vi, pop, lu, bound, FES)

% if the boundary constraint is violated, set the value to be the middle
% of the previous value and the bound
%

global ticks;
global ticks1;

[NP, D] = size(pop);  % the population size and the problem's dimension

%% check the lower bound
xl = repmat(lu(1, :), NP, 1);
xu = repmat(lu(2, :), NP, 1);
pos = vi < xl;

soucet1 = sum(pos);
tpos=pos;
%display(pos);
%display(size(pos));


%%%% BOUNDARY ADDITION %%%%		
% 		- 0	- vychozi
% 		- 1	- HARD
% 		- 2	- Random
% 		- 3	- Periodic
% 		- 4	- Reflection
% 		- 5	- Halving
%bounds = [0 1 2 3 4 5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (bound == 0) || (bound == 5) 
    vi(pos) = (pop(pos) + xl(pos)) / 2;
elseif bound == 1
    %HARD
    vi(pos) = xl(pos);
elseif bound == 2
    %Random
    %vi(pos) = (xl(pos) + rand(NP, D) .* (xu(pos) - xl(pos)));
    for i = 1:NP
        for j = 1:D
           if pos(i,j) == 1
                vi(i,j) = -100 + rand() * (100 + 100);
           end
        end
    end
elseif bound == 3
    %periodic
     for i = 1:NP
        for j = 1:D
           if pos(i,j) == 1
                %child[i] = min + PSO_mod(child[i] - max, max - min);
                vi(i,j) = -100 + PSO_mod(vi(i,j) - 100, 200);
           end
        end
    end
elseif bound == 4
    %reflection
     for i = 1:NP
        for j = 1:D
           if pos(i,j) == 1
              vi(i,j) = -100 + (-100 - vi(i,j));
           end
        end
    end
end



%% check the upper bound
xu = repmat(lu(2, :), NP, 1);
pos = vi > xu;

tpos = tpos + pos;
[rowIdcs, ~]   = find(tpos~=0);
[counts, bins] = hist(rowIdcs,1:size(tpos,1));
tpos=size(bins(counts~=0));
if(~isempty(bins(counts~=0)))
    ticks1 = [ticks1; FES tpos(2)];
end

soucet2 = soucet1 + sum(pos);
if(sum(soucet2) > 0)
    ticks = [ticks; FES soucet2];
end

if (bound == 0) || (bound == 5) 
    vi(pos) = (pop(pos) + xu(pos)) / 2;
elseif bound == 1
    %HARD
    vi(pos) = xu(pos);
elseif bound == 2
    %Random
    for i = 1:NP
        for j = 1:D
           if pos(i,j) == 1
                vi(i,j) = -100 + rand() * (100 + 100);
           end
        end
    end
elseif bound == 3
    %periodic
    for i = 1:NP
        for j = 1:D
           if pos(i,j) == 1
                %child[i] = min + PSO_mod(child[i] - max, max - min);
                vi(i,j) = -100 + PSO_mod(vi(i,j) - 100, 200);
           end
        end
    end
elseif bound == 4
    %reflection
     for i = 1:NP
        for j = 1:D
           if pos(i,j) == 1
              vi(i,j) = 100 - (vi(i,j) - 100);
           end
        end
    end
end