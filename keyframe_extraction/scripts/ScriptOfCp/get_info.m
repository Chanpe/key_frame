
%-----------by chenpei------------
function [frame] = get_info(im1,im2,im3)

group_size = 20;
group_num = 3;
img_paths =[];
path_index = 0;
root_path = pwd(); 

%% �õ�ѵ����ͼƬ·��
 im_name{1,1}=im1;
 im_name{1,2}=im2;
 im_name{1,3}=im3;

for index = 1:group_num
    for i = 1:group_size
        path_index  =  path_index+1;
        name= strcat(root_path,'\image_data\',im_name{1,index},'\a (',int2str(i),').jpg');
        img_paths{path_index,1} = name;
    end
end

%% ��ȡsift������ѵ��������ͼƬ��
data_sift = get_sifts(img_paths);

 %% ����׶Σ�K-means��
%������ͼƬsift��������һ����࣬�γ�K��K=800��ά����

K=800;
initMeans = data_sift(randi(size(data_sift,1),1,K),:);%��ʼ��������
[KMeans] = K_Means(data_sift,K,initMeans);%kmeans����
[KFeatures] = get_countVectors(KMeans,K,size(img_paths,1));% ͳ��ͼƬ��ÿ��ͼƬÿ�������������������ÿ��ͼƬ��Ӧһ��Kά����

%% ��ȡhog+gist+Kά����
data_all = get_allfeatures(KFeatures,img_paths);

%% PCA ��ά
[COEFF,SCORE, latent] = princomp(data_all);
 SelectNum = cumsum(latent)./sum(latent);
 index = find(SelectNum >= 0.95);
 ForwardNum = index(1);
 data_all_pca = SCORE(:,1:ForwardNum);
 
%% SVMѵ��������(�˴�ѵ��group_num��)
svm(data_all_pca,group_num,group_size);


%% ��Ƶ֡ȥ�أ�������ȡ
system('ffmpeg -i 1.flv -r 1 -y -f image2 image/%1d.jpg');
D = dir('image/*.jpg');
frame_num = length(D);%��Ƶ֡����
for i=1:frame_num  
    name= strcat('.\image\',int2str(i),'.jpg')  ;
    frame_paths{i,1} = name;%��Ƶ֡ͼƬ�洢λ�ã����ִ���ڼ���Ĺؼ�֡
end
[image_paths,time] = deduplication(frame_num,frame_paths);%��Ƶ֡ȥ��
image_num = size(image_paths,1);%ȥ�غ�ʣ���ͼƬ����
target = frame_features(image_paths,KMeans);%������ȡ


%% ��Ƶ֡������ά
tranMatrix = COEFF(:,1:ForwardNum);
row = size(target,1);
meanValue = mean(data_all);
normXtest = target - repmat(meanValue,[row,1]);
target_pca = normXtest*tranMatrix;

%% ���������ߵ���Ƶ֡ͼƬ ��ʱ��
    score = [];
    Structname = strcat('svmStruct','all-',int2str(2));
    load (Structname);
    w=svmStruct.SVs'*svmStruct.sv_coef;
    b=-svmStruct.rho;
    for j = 1:image_num
        score(j,:) = target_pca(j,:)*w+b;
    end
    score = [score,time];
    score = flipud(sortrows(score,1));
    for z = 1:5
        strtemp=strcat('.\image\',int2str(score(z,2)),'.jpg');
        frame{z,1} = '1.flv';
        frame{z,2} = strcat('test/',int2str(score(z,2)),'.jpg');
        frame{z,3} = secondtotime(score(z,2));
        img = imread(strtemp);
        strtemp=strcat('.\test\',int2str(score(z,2)),'.jpg');
        imwrite(img,strtemp);
    end
    
   