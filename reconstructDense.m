I1 = im2double(imread('motorcycle/im0.png'));
I2 = im2double(imread('motorcycle/im1.png'));
im1 = rgb2gray(I1);
im2 = rgb2gray(I2);
cam1=[3997.684 0 1176.728; 0 3997.684 1011.728; 0 0 1];
cam2=[3997.684 0 1176.728; 0 3997.684 1011.728; 0 0 1];

include = abs(rawZ') < 20;
dmatches = matchesq(include(:), :);
dmatches(:,[1,3]) = dmatches(:,[1,3])*2964/224;
dmatches(:,[2,4]) = dmatches(:,[2,4])*2000/224;

pts1 = dmatches(:,1:2);
pts2 = dmatches(:,3:4);

F = estimateFundamentalMatrix(pts1, pts2)

E = essentialMatrix(F, cam1, cam2)

M1 = [eye(3); 0,0,0]'
-inv(M1(1:3,1:3))*M1(1:3,4)

M2s = getProjectionMatrices(E)
-inv(M2s(1:3,1:3,1))*M2s(1:3,4,1)
-inv(M2s(1:3,1:3,2))*M2s(1:3,4,2)
-inv(M2s(1:3,1:3,3))*M2s(1:3,4,3)
-inv(M2s(1:3,1:3,4))*M2s(1:3,4,4)

[P1, err] = triangulate(cam1*M1, pts1,...
                        cam2*M2s(:,:,1), pts2);
[P2, err] = triangulate(cam1*M1, pts1,...
                        cam2*M2s(:,:,2), pts2);
[P3, err] = triangulate(cam1*M1, pts1,...
                        cam2*M2s(:,:,3), pts2);
[P4, err] = triangulate(cam1*M1, pts1,...
                        cam2*M2s(:,:,4), pts2);
C = []
C(:,1) = interp2(I1(:,:,1), pts1(:,1), pts2(:,2));
C(:,2) = interp2(I1(:,:,2), pts1(:,1), pts2(:,2));
C(:,3) = interp2(I1(:,:,3), pts1(:,1), pts2(:,2));

figure; showPointCloud([P1(:,1), P1(:,2), P1(:,3)], C)
figure; showPointCloud([P2(:,1), P2(:,2), P2(:,3)], C)
figure; showPointCloud([P3(:,1), P3(:,2), P3(:,3)], C)
figure; showPointCloud([P4(:,1), P4(:,2), P4(:,3)], C)
