function ret = PSO_mod (a, b)

if b < 0
    ret = PSO_mod(a, -b);
    return
end
ret = mod(a, b);
if ret < 0
    ret = ret + b;
end