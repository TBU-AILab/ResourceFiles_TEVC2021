% data generation for CEC15 learning based optimization problem
% J. J. Liang liangjing@zzu.edu.cn  lian0012@e.ntu.edu.sg
% 16th Nov 2014
%
% Usage:
% Please run this to generate data first and replace the data files in
% "input_data" with the generated files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Shift data
%for normal function and hybrid function
for func_num=1:8
    OShift=-80+rand(1,100)*160;
    eval(['save shift_data_' num2str(func_num) '.txt OShift -ASCII -DOUBLE']);
end

%for composition function: cf_num=10
for func_num=9:15
    OShift=-80+rand(10,100)*160;
    a=[-80:16:80];
    for i=1:100
        for j=1:10
            OShift(j,i)=a(j)+rand*16;
        end
        tmp=randperm(10);
        OShift(:,i)=OShift(tmp,i);
    end
    eval(['save shift_data_' num2str(func_num) '.txt OShift -ASCII -DOUBLE']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M matrix for normal function
%Matrix for D=2
for func_num=1:5
    D=2;
    M=[];c=1;
    M=rot_matrix(D,c);
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M -ASCII -DOUBLE']);
end
%Matrix for =[10,30,50,100];

D_choose=[10,30,50,100];
D=10;
for func_num=1:5;
    M=diag(ones(1,D));
    G=[3,3,4];
    C=[1,2,1];
    j=1;
    for i=1:length(G)
        M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
        j=G(i)+j;
    end

    S=randperm(D);
    M0=M(S,S);
    [tmp,SS]=sort(S);

    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M0 -ASCII -DOUBLE']);
end
% D=20;
% for func_num=1:5
%     M=diag(ones(1,D));
%     G=[3,3,4];
%     C=[1,2,1];
%     j=1;
%     for i=1:length(G)
%         M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
%         j=G(i)+j;
%     end
%
%     S=randperm(D);
%     M0=M(S,S);
%     [tmp,SS]=sort(S);
%
%     dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS, '\t');
%     eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M0 -ASCII -DOUBLE']);
% end
D=30;
for func_num=1:5;
    M=diag(ones(1,D));
    G=[2,3,4,5,7,9];
    C=[1,2,1,2,1,2];
    j=1;
    for i=1:length(G)
        M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
        j=G(i)+j;
    end

    S=randperm(D);
    M0=M(S,S);
    [tmp,SS]=sort(S);

    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M0 -ASCII -DOUBLE']);
end
D=50;
for func_num=1:5;
    M=diag(ones(1,D));
    G=[3,4,5,6,6,8,8,10];
    C=[1,2,1,2,1,2,1,2];
    j=1;
    for i=1:length(G)
        M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
        j=G(i)+j;
    end

    S=randperm(D);
    M0=M(S,S);
    [tmp,SS]=sort(S);

    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M0 -ASCII -DOUBLE']);
end
D=100;
for func_num=1:5;
    M=diag(ones(1,D));
    G=[6,6,8,8,10,10,12,12,14,14];
    C=[1,2,1,2,1,2,1,2,1,2];
    j=1;
    for i=1:length(G)
        M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
        j=G(i)+j;
    end

    S=randperm(D);
    M0=M(S,S);
    [tmp,SS]=sort(S);

    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M0 -ASCII -DOUBLE']);
end

%%%%%%%%%%%%
%M matrix for hybrid function
%hf01
cf_num=3;
D_choose=[10,30,50,100];
func_num=6;
for k=1:4
    G=[];
    D=D_choose(k);
    M=diag(ones(1,D));
    P=[0.3,0.3,0.4];
    G(1:cf_num-1)=ceil(P(1:cf_num-1)*D);
    G(cf_num)=D-sum(G(1:cf_num-1));
    C=[1,1,1];

    j=1;
    for i=1:length(G)
        M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
        j=G(i)+j;
    end

    S=randperm(D);
    M0=M(S,S);
    [tmp,SS]=sort(S);

    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M0 -ASCII -DOUBLE']);
end

%%%%%%%%%%%%%%
%hf02
cf_num=4;
D_choose=[10,30,50,100];
func_num=7;
for k=1:4
    D=D_choose(k);
    M=diag(ones(1,D));
    P=[0.2,0.2,0.3,0.3];
    G=[];
    G(1:cf_num-1)=ceil(P(1:cf_num-1)*D);
    G(cf_num)=D-sum(G(1:cf_num-1));
    C=[1,2,1,2];

    j=1;
    for i=1:length(G)
        M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
        j=G(i)+j;
    end

    S=randperm(D);
    M0=M(S,S);
    [tmp,SS]=sort(S);

    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M0 -ASCII -DOUBLE']);
end

%%%%%%%%%%%%%%
%hf03
cf_num=5;
D_choose=[10,30,50,100];
func_num=8;
for k=1:4
    D=D_choose(k);
    M=diag(ones(1,D));
    P=[0.1,0.2,0.2,0.2,0.3];
    G=[];
    G(1:cf_num-1)=ceil(P(1:cf_num-1)*D);
    G(cf_num)=D-sum(G(1:cf_num-1));
    C=[1,2,1,2,1];

    j=1;
    for i=1:length(G)
        M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
        j=G(i)+j;
    end

    S=randperm(D);
    M0=M(S,S);
    [tmp,SS]=sort(S);

    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M0 -ASCII -DOUBLE']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
%M matrix for composition function
%D=2;
D=2;
for func_num=9:15
    M=[];c=1;
    for j=1:10
        M0=rot_matrix(D,c);
        M=[M;M0];
    end
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M -ASCII -DOUBLE']);
end

%10,30,50,100
D=10;
for func_num=9:15
    M10=[];SS10=[];
    for j=1:10
        M=diag(ones(1,D));
        G=[3,3,4];
        C=[1,2,1];
        j=1;
        for i=1:length(G)
            M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
            j=G(i)+j;
        end
        S=randperm(D);
        M0=M(S,S);
        [tmp,SS]=sort(S);
        M10=[M10;M0];
        SS10=[SS10;SS];
    end
    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS10, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M10 -ASCII -DOUBLE']);
end

% D=20;
% for func_num=9:15
%         M10=[];SS10=[];
%         for j=1:10
%             M=diag(ones(1,D));
%             G=[3,3,4];
%             C=[1,2,1];
%             j=1;
%             for i=1:length(G)
%                 M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
%                 j=G(i)+j;
%             end
%             S=randperm(D);
%             M0=M(S,S);
%             [tmp,SS]=sort(S);
%             M10=[M10;M0];
%             SS10=[SS10,SS];
%         end
%         dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS10, '\t');
%         eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M10 -ASCII -DOUBLE']);
% end

D=30;
for func_num=9:15
    M10=[];SS10=[];
    for j=1:10
        M=diag(ones(1,D));
        G=[2,3,4,5,7,9];
        C=[1,2,1,2,1,2];
        j=1;
        for i=1:length(G)
            M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
            j=G(i)+j;
        end
        S=randperm(D);
        M0=M(S,S);
        [tmp,SS]=sort(S);
        M10=[M10;M0];
        SS10=[SS10,SS];
    end
    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS10, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M10 -ASCII -DOUBLE']);
end

D=50;
for func_num=9:15
    M10=[];SS10=[];
    for j=1:10
        M=diag(ones(1,D));
        G=[3,4,5,6,6,8,8,10];
        C=[1,2,1,2,1,2,1,2];
        j=1;
        for i=1:length(G)
            M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
            j=G(i)+j;
        end
        S=randperm(D);
        M0=M(S,S);
        [tmp,SS]=sort(S);
        M10=[M10;M0];
        SS10=[SS10,SS];
    end
    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS10, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M10 -ASCII -DOUBLE']);
end

D=100;
for func_num=9:15
    M10=[];SS10=[];
    for j=1:10
        M=diag(ones(1,D));
        G=[6,6,8,8,10,10,12,12,14,14];
        C=[1,2,1,2,1,2,1,2,1,2];
        j=1;
        for i=1:length(G)
            M(j:j+G(i)-1,j:j+G(i)-1)= rot_matrix(G(i),C(i));
            j=G(i)+j;
        end
        S=randperm(D);
        M0=M(S,S);
        [tmp,SS]=sort(S);
        M10=[M10;M0];
        SS10=[SS10,SS];
    end
    dlmwrite(strcat('shuffle_data_',char(num2str(func_num)),'_D',char(num2str(D)),'.txt'), SS10, '\t');
    eval(['save M_' num2str(func_num) '_D' num2str(D) '.txt M10 -ASCII -DOUBLE']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%bias values for compostion function 9-15
cf_num=10;
%cf01  do not change global optimum
func_num=9;
bias_value=[0, 100, 200];
bias_value=bias_value([1,randperm(2)+1]);
bias_value((length(bias_value)+1):cf_num)=1000;
eval(['save bias_' num2str(func_num) '.txt bias_value -ASCII -DOUBLE']);


%cf02
func_num=10;
bias_value=[0, 100, 200];
bias_value=bias_value(randperm(3));
bias_value((length(bias_value)+1):cf_num)=1000;
eval(['save bias_' num2str(func_num) '.txt bias_value -ASCII -DOUBLE']);

%cf03  do not change global optimum
func_num=11;
bias_value=[0, 100, 200, 300, 400];
bias_value=bias_value([1,randperm(4)+1]);
bias_value((length(bias_value)+1):cf_num)=1000;
eval(['save bias_' num2str(func_num) '.txt bias_value -ASCII -DOUBLE']);


%cf04
func_num=12;
bias_value=[0, 100, 100, 200, 200];
bias_value=bias_value(randperm(5));
bias_value((length(bias_value)+1):cf_num)=1000;
eval(['save bias_' num2str(func_num) '.txt bias_value -ASCII -DOUBLE']);


%cf05
func_num=13;
bias_value=[0, 100, 200, 300, 400];
bias_value=bias_value(randperm(5));
bias_value((length(bias_value)+1):cf_num)=1000;
eval(['save bias_' num2str(func_num) '.txt bias_value -ASCII -DOUBLE']);


%cf06  do not change global optimum
func_num=14;
bias_value=[0, 100, 200, 300, 300, 400, 400];
bias_value=bias_value([1,randperm(6)+1]);
bias_value((length(bias_value)+1):cf_num)=1000;
eval(['save bias_' num2str(func_num) '.txt bias_value -ASCII -DOUBLE']);


%cf07
func_num=15;
bias_value=[0, 100, 100, 200, 200, 300, 300, 400, 400, 500];
bias_value=bias_value(randperm(10));
eval(['save bias_' num2str(func_num) '.txt bias_value -ASCII -DOUBLE']);
