%------- Only for weekday------
function trip2vec(taxi_manhattan)
delete('./temp.txt');
trip_vec=zeros(1,22);%embedded vectors of trips  ��4��score
checkins=load('checkin_manhattan.mat');%%%%��Ľ�
autoenc_50=load('autoenc_50.mat');
autoenc_50=autoenc_50.autoenc_50;
autoenc_50_10=load('autoenc_50_10.mat');
autoenc_50_10=autoenc_50_10.autoenc_50_10;
Ctrs=load('Ctrs.mat');
Ctrs=Ctrs.Ctrs;
checkin_manhattan=checkins.checkin_manhattan;
%tic
%[p,q]=size(checkin_manhattan);
score_s=zeros(1,9); %s��9��poi����
score_e=zeros(1,9); %e��9��poi����
checkin=cell2mat(checkin_manhattan(:,7));
% checkin_time=cell2mat(checkin_manhattan(:,8));

score_se=zeros(1,1);%Popularity(s/e) + travel_distance
score_t=zeros(1,2); %weekday��0��1��+ time_stamp
s_index=taxi_manhattan{6};%cell2mat()
e_index=taxi_manhattan{9};%ȡ���������ܱ߹�9��grid������
s_indexes=[s_index,s_index+1,s_index-1,s_index+149,s_index+150,s_index+151,s_index-149,s_index-150,s_index-151];
e_indexes=[e_index,e_index+1,e_index-1,e_index+149,e_index+150,e_index+151,e_index-149,e_index-150,e_index-151];
s_lng=taxi_manhattan{4};%ȡ����γ��
s_lat=taxi_manhattan{5};
e_lng=taxi_manhattan{7};
e_lat=taxi_manhattan{8};

t_s=datevec(taxi_manhattan{2});%ȡ��sʱ��
t_e=datevec(taxi_manhattan{3});%ȡ��eʱ��
score_se(1)=etime(t_e,t_s);
%score_se(2)=dis_node(s_lat,s_lng,e_lat,e_lng);
t_s(4)=t_s(4)-2;%ѡ����ϳ�ʱ���ǰ2��Сʱ���ܱ�check-in����

if t_s(4)<0
    t_s(4)=t_s(4)+24;
end

taxi_e_lat=zeros(9,100);%�洢eλ���ϵ�9��poi��Ӧcheckin_lat�������ָ���
taxi_s_lat=zeros(9,100);%�洢eλ���ϵ�9��poi��Ӧcheckin_lat�������ָ���
%taxi_e_lat_4h=zeros(9,1);%�洢eλ���ϵ�ǰ4h��9��poi��Ӧcheckin_lat�������ָ���
taxi_s_dis=zeros(9,100);%�洢sλ���ϵ�9��poi��Ӧcheckin��s�ľ���
%taxi_e_dis_4h=zeros(9,1);%�洢eλ���ϵ�9��poi��ǰ4h�ڶ�Ӧcheckin��e�ľ���
taxi_e_dis=zeros(9,100);%�洢eλ���ϵ�9��poi��Ӧcheckin��e�ľ���
k_s=zeros(1,9);%taxi_s�����ۼ�����
k_e=zeros(1,9);%taxi_e�����ۼ�����
% k_e_4h=ones(1,9);%taxi_e_4h�����ۼ�����
k_e_uniq=zeros(1,9);%��type�ĸ�������������check-in������
k_s_uniq=zeros(1,9);%��type�ĸ�������������check-in������

checkin_s_index=find(ismember(checkin, s_indexes));
ts=datevec(cell2mat(checkin_manhattan(checkin_s_index,8)));
checkin_s_t=find(abs(etime(t_s,ts))<=3600);
checkin_s=checkin_s_index(checkin_s_t);%����index��ʱ��������checkin��id

checkin_e_index=find(ismember(checkin, e_indexes));%�±꣨checkin_manhattan�ģ�
te=datevec(cell2mat(checkin_manhattan(checkin_e_index,8)));%checkin_e_index�±�����Ӧ��ֵ
checkin_e_t=find(abs(etime(t_e,te))<=3600);%�±꣨checkin_e_index�ģ�
checkin_e=checkin_e_index(checkin_e_t);
%     toc
%c_t1=regexp(checkin_manhattan{j,8}, '\s+', 'split');
%1��ȡ���������ڣ�2��ȡǰ��ʱ����ڵ�check-in����;
%����type���ͷֱ�check_in���ݵ�id�洢��9�еľ����У�������;
for j1=1:length(checkin_e)
    h1=checkin_e(j1);
    if checkin_manhattan{h1,9}==0
        c_type=checkin_manhattan{h1,2};
        c_lat=checkin_manhattan{h1,5};
        c_lng=checkin_manhattan{h1,6};
        dis_e=dis_node(e_lat,e_lng,c_lat,c_lng);
        if dis_e<=250
            taxi_e_dis(c_type,k_e(c_type)+1)=dis_e;%����õ����³���ľ��룬�����Ӧtype�ľ�����
            k_e(c_type)=k_e(c_type)+1;
            if not (ismember(c_lat,taxi_e_lat(c_type,:)))
                k_e_uniq(c_type)=k_e_uniq(c_type)+1;
                taxi_e_lat(c_type,k_e_uniq(c_type))=c_lat;%������k_e(n1)+1
            end
        end
    end

end
for j1=1:length(checkin_s)
    h2=checkin_s(j1);
    if checkin_manhattan{h2,9}==0 
    %1��ȡ���������ڣ�2��ȡǰ��ʱ����ڵ�check-in����;
    %����type���ͷֱ�check_in���ݵ�id�洢��9�еľ����У�������;
        c_lat2=checkin_manhattan{h2,5};
        c_lng2=checkin_manhattan{h2,6};
        c_type2=checkin_manhattan{h2,2};
        dis_s=dis_node(s_lat,s_lng,c_lat2,c_lng2);
        if dis_s<=250
            taxi_s_dis(c_type2,k_s(c_type2)+1)=dis_s;%����õ����ϳ���ľ��룬�����Ӧtype�ľ�����
            k_s(c_type2)=k_s(c_type2)+1;
            if not (ismember(c_lat2,taxi_s_lat(c_type2,:)))
                k_s_uniq(c_type2)=k_s_uniq(c_type2)+1;
                taxi_s_lat(c_type2,k_s_uniq(c_type2))=c_lat2;%������k_e(n1)+1
            end
        end
    end
end
score_s=score_s_computing(k_s,taxi_s_dis,k_s_uniq);
%score_e=score_e_computing(k_e,k_e_4h,taxi_e_dis,taxi_e_dis_4h,k_e_uniq,k_e_4h_uniq);
score_e=score_e_computing(k_e,taxi_e_dis,k_e_uniq);
if t_s(3)<3
    score_t(1)=0;
end
if t_s(3)>10
    score_t(1)=1;
end
score_t(2)=t_e(4)/100;%%%��   ����slot
s=[score_s,score_e,score_se,score_t];
%s(19:21)=mapminmax(s(19:21),0,1);
s(1:9)=s(1:9)/29.6216;
s(10:18)=s(10:18)/29.6755;
s(19)=s(19)/13585;
s(21)=s(21)/0.23;
trip_vec=s;
%����10-dim feature
x=trip_vec';
x(20:21,:)=x(20:21,:)/10;
x(20,:)=x(20,:)/100;
f_trip_vec =encode(autoenc_50_10,encode(autoenc_50,x))';
%��������ȡ���
for k = 1:8
    %relation(k) = corr2(feature_50_10(:,1)',cluster_mean_feature(k,:));
    dis_vec=[f_trip_vec;Ctrs(k,:)];
    Dis_8(k)=pdist(dis_vec,'euclidean');
end
[value,index]= min(Dis_8);
%�ж�����һ��purpose
if index==8 || index==2
    trip_type=1;
elseif index==7 || index==6
    trip_type=2;
elseif index==3
    trip_type=3;
elseif index==1 || index==5
    trip_type=4;
elseif index==4
    trip_type=5;
end
Dis_5(1)=min([Dis_8(2),Dis_8(8)]);
Dis_5(2)=min([Dis_8(6),Dis_8(7)]);
Dis_5(3)=Dis_8(3);
Dis_5(4)=min([Dis_8(1),Dis_8(5)]);
Dis_5(5)=Dis_8(4);
Dis_5=roundn(Dis_5,-5); 
%������ʱ�ļ�
path = "./temp.txt";
file=fopen(path,'w+');
fprintf(file,mat2str([Dis_5,trip_type]));
fclose(file);


