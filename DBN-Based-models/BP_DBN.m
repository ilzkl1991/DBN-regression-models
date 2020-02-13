clc;
clear;


A=xlsread('BB.xlsx'); %The data for traininig and testing

inputdata=A(1:800,1:6);  %Training input data
outputdata=A(1:150,7); %Training output data

inputdata1=inputdata';
outputdata1=outputdata';

%ѡ����������������ݹ�һ��[0,1]
[inputdata11,inputps]=mapminmax(inputdata1,0,1);

[outputdata11,outputps]=mapminmax(outputdata1,0,1);

P=inputdata11';
T=outputdata11';
%%  ex1 train a 100 hidden unit RBM and visualize its weights
%rand('state',0)
dbn.sizes = [30 30];    %RBMÿ��������30���ڵ�
opts.numepochs =  1;         %����ʱ����������ص�����ԪȨֵ�ͷ�ֵ�Ĵ���
opts.batchsize = 80;
opts.momentum  =   0;
opts.alpha     =   1;
dbn = dbnsetup(dbn, P, opts);
dbn = dbntrain(dbn, P, opts);

% figure; visualize(dbn.rbm{1}.W');   %  Visualize the RBM weights 

%unfold dbn to nn
nn = dbnunfoldtonn(dbn, 1);       %1������ڵ�
nn.activation_function = 'sigm';  %�����sigmoid  sigm

%train nn
opts.numepochs = 40;
opts.batchsize = 50;   %1
nn = nntrain(nn, P(1:150,:), T, opts);

Ytrain=nnff1(nn,P(1:150,:));
Ytrain1=Ytrain';

%% BP����ѵ��
%��ʼ������ṹ
inputn=Ytrain1;
outputn=T';
s1=40;%������ڵ�
disp('ѵ��bp������')
net=newff(inputn,outputn,s1);
net.trainParam.epochs=100;%ѵ������
net.trainParam.lr=1;%ѧϰ��
net.trainParam.goal=0.03;%ѧϰĿ��
net.trainParam.max_fail = 200;% ��Сȷ��ʧ�ܴ��� 
net.trainParam.showWindow = false; 
net.trainParam.showCommandLine = false; 
%��������
%����ѵ��
net=train(net,inputn,outputn);
disp('����ѵ��bp������')

%% ELMANѵ�����
% net=newelm(minmax(inputn),[40,1],{'tansig','tansig'});
% net.trainparam.show=100;%ÿ����100����ʾ1��
% net.trainparam.epochs=3000;%����������2000
% net.trainparam.goal=0.03;%����Ŀ��
% net=init(net);%��ʼ������
% %����ѵ��
% [net,tr]=train(net,inputn,outputn);

%% RBFѵ��
% switch 2
% case 1 
%          
% % ��Ԫ����ѵ���������� 
% spread = 1;                % ��ֵԽ��,���ǵĺ���ֵ�ʹ�(Ĭ��Ϊ1) 
% net = newrb(inputn,outputn);    
% % save BRPRBF net;
% case 2 
%      
% % ��Ԫ��������,������ѵ���������� 
% goal = 0.013;                % ѵ������ƽ����(Ĭ��Ϊ0) 
% spread =1;                % ��ֵԽ��,��Ҫ����Ԫ��Խ��(Ĭ��Ϊ1) 
% MN = size(P,2);% �����Ԫ��(Ĭ��Ϊѵ����������) 
% DF = 1;                     % ��ʾ���(Ĭ��Ϊ25) 
% net = newrb(inputn,outputn,goal,spread,MN,DF); 
%    
%     case 3     
% P = Ytrain1; 
% T = train_y1;  
% spread = 1;                % ��ֵԽ��,��Ҫ����Ԫ��Խ��(Ĭ��Ϊ1) 
% net = newgrnn(inputn,outputn,spread); 
%      
% end

%% ��������
input_test1=A(751:800,1:6);     %��������(������һ��)
output_test1=A(751:800,7);
input_test=input_test1';
output_test=output_test1';
test_x=mapminmax('apply',input_test,inputps,0,1)'; 
Test_x=nnff1(nn,test_x);

an=sim(net,Test_x');
%�޸Ĳ��֣����Ԥ��ֵ

BPoutput=mapminmax('reverse',an,outputps);

%% ����Ա�
error2=BPoutput-output_test;
% MSE1=sum((BPoutput-output_test).^2)/length(BPoutput);
figure(1)
plot(BPoutput,'r-*')
hold on
%title('ʵ��ֵ��Ԥ��ֵ���ͼ','fontsize',10,'fontangle','normal')
plot(output_test,'b.-')
legend('Ԥ��ֵ','ʵ��ֵ','Location','NorthEast');
xlabel('��������','fontsize',10)
ylabel('btp','fontsize',10)
grid on;
hold off
figure(2)
plot(error2)
title('���','fontsize',10,'fontangle','normal')


figure(3)
bf=error2./output_test;
plot(100*bf,'r.-')
%title('���ٷֱ�','fontsize',10,'fontangle','normal')
xlabel('��������','fontsize',10)
ylabel('��%��','fontweight','bold')
grid on;
%% �������
