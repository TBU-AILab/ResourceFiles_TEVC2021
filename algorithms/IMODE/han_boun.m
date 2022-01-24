%% ============ Improved Multi-operator Differential Evolution Algorithm (IMODE) ============
% Should you have any queries, please contact
% Dr. Karam Sallam. Zagazig University
% karam_sallam@zu.edu.eg
% =========================================================================

%function x = han_boun (x, xmax, xmin, x2, PopSize,hb)
function x = han_boun (x, xmax, xmin, x2, PopSize,BOUND)

%display("BOUND - 2");
[temp dim] = size(x);
%display(dim);

%% uprava BOUND
%       -- BOUND 0	- vychozi
% 		-- BOUND 1	- HARD
% 		-- BOUND 2	- Random
% 		-- BOUND 3	- Periodic
% 		-- BOUND 4	- Reflection
% 		-- BOUND 5	- Halving
%%
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
   %RANDOM
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
    %PERIODIC
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
    %REFLECTION
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
   % Halving
    x_L = repmat(xmin, PopSize, 1);
    pos = x < x_L;
    x(pos) = (x2(pos) + x_L(pos)) / 2;

    x_U = repmat(xmax, PopSize, 1);
    pos = x > x_U;
    x(pos) = (x2(pos) + x_U(pos)) / 2;
end

if BOUND == 0
    hb=randi(3);
    switch hb
        case 1 % for DE
            x_L = repmat(xmin, PopSize, 1);
            pos = x < x_L;
            x(pos) = (x2(pos) + x_L(pos)) / 2;

            x_U = repmat(xmax, PopSize, 1);
            pos = x > x_U;
            x(pos) = (x2(pos) + x_U(pos)) / 2;

        case 2 
            x_L = repmat(xmin, PopSize, 1);
            pos = x < x_L;
            x_U = repmat(xmax, PopSize, 1);
            x(pos) = min(x_U(pos),max(x_L(pos),2*x_L(pos)-x2(pos)))  ;
            pos = x > x_U;
            x(pos) = max(x_L(pos),min(x_U(pos),2*x_L(pos)-x2(pos)));

       case 3 
            x_L = repmat(xmin, PopSize, 1);
            pos = x < x_L;
            x_U = repmat(xmax, PopSize, 1);
            x(pos) = x_L(pos)+ rand*(x_U(pos)-x_L(pos) ) ;
            pos = x > x_U;
            x(pos) = x_L(pos)+ rand*(x_U(pos)-x_L(pos));

    end  
end
