% clear all
% mex cec15_func.cpp -DWINDOWS

D=10;
Xmin=-100;
Xmax=100;
pop_size=100;
iter_max=500;
runs=1;
fhd=str2func('cec15_func');
for i=1:15
    func_num=i;
    for j=1:runs
        i,j,
        [gbest,gbestval,FES]= PSO_func(fhd,D,pop_size,iter_max,Xmin,Xmax,func_num);
        xbest(j,:)=gbest;
        fbest(i,j)=gbestval;
        fbest(i,j)
    end
    f_mean(i)=mean(fbest(i,:));
end


% 
for i=1:15
eval(['load input_data/shift_data_' num2str(i) '.txt']);
eval(['O=shift_data_' num2str(i) '(1,1:10);']);
f(i)=cec15_func(O',i);i,f(i)
end