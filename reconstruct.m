I1 = im2double(imread('motorcycle/im0.png'));
I2 = im2double(imread('motorcycle/im1.png'));
im1 = rgb2gray(I1);
im2 = rgb2gray(I2);
cam1=[3997.684 0 1176.728; 0 3997.684 1011.728; 0 0 1];
cam2=[3997.684 0 1176.728; 0 3997.684 1011.728; 0 0 1];

pts1 = detectSURFFeatures(im1)
pts2 = detectSURFFeatures(im2)

[feats1, valid_pts1] = extractFeatures(im1, pts1);
[feats2, valid_pts2] = extractFeatures(im2, pts2);

matches = matchFeatures(feats1, feats2)

matchedPoints1 = pts1(matches(:,1),:);
matchedPoints2 = pts2(matches(:,2),:);

pts1 = matchedPoints1.Location;
pts2 = matchedPoints2.Location;

figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);

F = estimateFundamentalMatrix(matchedPoints1, matchedPoints2)

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

figure; scatter3(P1(:,1), P1(:,2), P1(:,3), 5, C)
figure; scatter3(P2(:,1), P2(:,2), P2(:,3), 5, C)
figure; scatter3(P3(:,1), P3(:,2), P3(:,3), 5, C)
figure; scatter3(P4(:,1), P4(:,2), P4(:,3), 5, C)
