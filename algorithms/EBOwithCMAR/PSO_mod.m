% double PSO_mod(double a, double b)
% {
% 	if (b < 0) //you can check for b == 0 separately and do what you want
% 		return PSO_mod(a, -b);
% 	double ret = fmod(a, b);//a % b;
% 	if (ret < 0)
% 		ret += b;
% 	return ret; 
% }
function ret = PSO_mod (a, b)

if b < 0
    ret = PSO_mod(a, -b);
    return
end
ret = mod(a, b);
if ret < 0
    ret = ret + b;
end