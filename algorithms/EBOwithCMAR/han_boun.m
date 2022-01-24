%% ============EBOwithCMAR============
% This code is taken from UMOEA-II
% =========================================================================

function x = han_boun (x, xmax, xmin, x2, PopSize,hb, BOUND, FES)

%display(BOUND);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       BOUND
% 		- 0	- vychozi
% 		- 1	- HARD
% 		- 2	- Random
% 		- 3	- Periodic
% 		- 4	- Reflection
% 		- 5	- Halving
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global ticks;
global ticks1;

[NP, dim] = size(x);
%display(NP);
%display(dim);


% mereni pro vsechno
x_xl = repmat(xmin, PopSize, 1);
x_xu = repmat(xmax, PopSize, 1);
x_posL = x < x_xl;
x_posU = x > x_xu;

soucet1 = sum(x_posL);
soucet2 = soucet1 + sum(x_posU);
if(sum(soucet2) > 0)
    xxx = size(soucet2);
    if(xxx(2) <= 1)
        ticks = [ticks;FES x_posL + x_posU];
    else
        ticks = [ticks;FES soucet2];
    end
end

tpos = x_posL + x_posU;
[rowIdcs, ~]   = find(tpos~=0);
[counts, bins] = hist(rowIdcs,1:size(tpos,1));
tpos=size(bins(counts~=0));
if(~isempty(bins(counts~=0)))
    ticks1 = [ticks1; FES tpos(2)];
end



if BOUND == 1
    %HARD
    x_L = repmat(xmin, PopSize, 1);
    pos = x < x_L;
    
    x(pos) = x_L(pos);
    
    x_U = repmat(xmax, PopSize, 1);
    pos = x > x_U;
    
    
    x(pos) = x_U(pos);
end
if BOUND == 2
    %Random
    x_L = repmat(xmin, PopSize, 1);
    pos = x < x_L;
    for i = 1:PopSize
        for j = 1:dim
           if pos(i,j) == 1
                x(i,j) = -100 + rand() * (100 + 100);
           end
        end
    end
    
    x_U = repmat(xmax, PopSize, 1);
    pos = x > x_U;
    for i = 1:PopSize
        for j = 1:dim
           if pos(i,j) == 1
                x(i,j) = -100 + rand() * (100 + 100);
           end
        end
    end

end
if BOUND == 3
    %Periodic
    x_L = repmat(xmin, PopSize, 1);
    pos = x < x_L;
    for i = 1:PopSize
        for j = 1:dim
           if pos(i,j) == 1
                x(i,j) = -100 + PSO_mod(x(i,j) - 100, 200);
           end
        end
    end

    x_U = repmat(xmax, PopSize, 1);
    pos = x > x_U;
    for i = 1:PopSize
        for j = 1:dim
           if pos(i,j) == 1
                x(i,j) = -100 + PSO_mod(x(i,j) - 100, 200);
           end
        end
    end

end
if BOUND == 4
    %Reflection
    x_L = repmat(xmin, PopSize, 1);
    pos = x < x_L;
    for i = 1:PopSize
        for j = 1:dim
           if pos(i,j) == 1
              x(i,j) = -100 + (-100 - x(i,j));
           end
        end
    end

    x_U = repmat(xmax, PopSize, 1);
    pos = x > x_U;

    for i = 1:PopSize
        for j = 1:dim
           if pos(i,j) == 1
              x(i,j) = 100 - (x(i,j) - 100);
           end
        end
    end

end
if BOUND == 5
    %Halving
    x_L = repmat(xmin, PopSize, 1);
    pos = x < x_L;
    x(pos) = (x2(pos) + x_L(pos)) / 2;

    x_U = repmat(xmax, PopSize, 1);
    pos = x > x_U;

    x(pos) = (x2(pos) + x_U(pos)) / 2;

end

if BOUND == 0
    switch hb;
        case 1 % for DE
            x_L = repmat(xmin, PopSize, 1);
            pos = x < x_L;
            %soucet1 = sum(pos);
            x(pos) = (x2(pos) + x_L(pos)) / 2;

            x_U = repmat(xmax, PopSize, 1);
            pos = x > x_U;
            %soucet2 = soucet1 + sum(pos);
            %if(sum(soucet2) > 0)
            %    ticks = [ticks;FES soucet2];
            %end
            x(pos) = (x2(pos) + x_U(pos)) / 2;

        case 2 % for CMA-ES
            x_L = repmat(xmin, PopSize, 1);
            pos = x < x_L;
            %soucet1 = sum(pos);
            %xxx_pos = pos;
            x_U = repmat(xmax, PopSize, 1);
            x(pos) = min(x_U(pos),max(x_L(pos),2*x_L(pos)-x2(pos)))  ;
            pos = x > x_U;
            %soucet2 = soucet1 + sum(pos);
            %if(sum(soucet2) > 0)
            %    xxx = size(pos);
            %    if(xxx(1) <= 1)
            %        ticks = [ticks;FES pos+xxx_pos];
            %    else
            %        ticks = [ticks;FES soucet2];
            %    end
            %end
            x(pos) = max(x_L(pos),min(x_U(pos),2*x_L(pos)-x2(pos)));

    end  
end
