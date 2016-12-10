function [K1, K2, cpts1, cpts2] = reconstruct(im1, im2, cpts1, cpts2, nplanes)
I1 = rgb2gray(im1);
I2 = rgb2gray(im2);

%-----------------------------------------------------
% Compute Planar Homographies

% Get lots of feature points
points1 = detectSURFFeatures(I1, 'MetricThreshold', 10);
points2 = detectSURFFeatures(I2, 'MetricThreshold', 10);

[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);

indexPairs = matchFeatures(features1,features2);

matchedPoints1_1 = valid_points1(indexPairs(:,1),:)
matchedPoints2_1 = valid_points2(indexPairs(:,2),:)
matches = repmat((1:length(matchedPoints1_1))', [1,2]);

figure(1); showMatchedFeatures(I1,I2,matchedPoints1_1,matchedPoints2_1);
title('Matches for plane estimation')


% Fit first plane
[H, mat] = ransacH(matches, matchedPoints1_1.Location, matchedPoints2_1.Location,...
           10000, 2);
H1 = H;
plane1_I1 = matchedPoints1_1.Location(mat, :);
plane1_I2 = matchedPoints2_1.Location(mat, :);
[plane1_I1, plane1_I2] = removeOutliers(plane1_I1, plane1_I2);

matchedPoints1_2 = matchedPoints1_1(~mat, :)
matchedPoints2_2 = matchedPoints2_1(~mat, :)
matches = repmat((1:sum(~mat))', [1,2]);

% Fit second plane
[H, mat] = ransacH(matches, matchedPoints1_2.Location, matchedPoints2_2.Location,...
           10000, 2);
H2 = H;
plane2_I1 = matchedPoints1_2.Location(mat, :);
plane2_I2 = matchedPoints2_2.Location(mat, :);
[plane2_I1, plane2_I2] = removeOutliers(plane2_I1, plane2_I2);

matchedPoints1_3 = matchedPoints1_2(~mat, :)
matchedPoints2_3 = matchedPoints2_2(~mat, :)
matches = repmat((1:sum(~mat))', [1,2]);

% Fit third plane if need be
if nplanes == 3
    [H, mat] = ransacH(matches, matchedPoints1_3.Location, matchedPoints2_3.Location,...
               10000, 2);
    H3 = H;
    plane3_I1 = matchedPoints1_3.Location(mat, :);
    plane3_I2 = matchedPoints2_3.Location(mat, :);
    [plane3_I1, plane3_I2] = removeOutliers(plane3_I1, plane3_I2);
end

if nplanes == 3
    allpts_I1 = [plane1_I1; plane2_I1; plane3_I1];
    allpts_I2 = [plane1_I2; plane2_I2; plane3_I2];
else
    allpts_I1 = [plane1_I1; plane2_I1];
    allpts_I2 = [plane1_I2; plane2_I2];
end

%---------------------------------------------------
% Display Planar Homographies
%{
figure(2);
imshow(I1)
title('Planes on the first image')
hold on
plot(plane1_I1(:,1), plane1_I1(:,2), 'ro')
plot(plane2_I1(:,1), plane2_I1(:,2), 'bo')
if nplanes == 3
    plot(plane3_I1(:,1), plane3_I1(:,2), 'go')
end


figure(3);
imshow(I2)
title('Planes on the second image')
hold on
plot(plane1_I2(:,1), plane1_I2(:,2), 'ro')
plot(plane2_I2(:,1), plane2_I2(:,2), 'bo')
if nplanes == 3
    plot(plane3_I2(:,1), plane3_I2(:,2), 'go')
end
export_fig '../results/03_featurematches.png'
%}

% ---------------------------------------------------
% Compute Camera Calibration Matrices

[K1, cpts1] = calibrate(I1,cpts1)
[K2, cpts2] = calibrate(I2,cpts2)

%----------------------------------------------------
% Compute Essential Matrix
F = eightpoint(double(allpts_I1), double(allpts_I2), max([size(I1), size(I2)]))
F = F{1};
F = F/F(3,3)
%displayEpipolarF(I1, I2, F)

E = essentialMatrix(F, K1, K2);

[e1, e2] = getEpipoles(E);
e1 = e1 / e1(3);
e2 = e2 / e2(3);
e_mat = [0, -e2(3), e2(2);
         e2(3), 0, e2(1);
         -e2(2), -e2(1), 0]

P1 = K1*[eye(3), [0, 0, 0]']
P2 = getProjectionMatrices(E);

% -------------------------------------------------
% Plot 3d

[try1, err] = triangulate(P1, allpts_I1, K2*P2(:,:,1), allpts_I2);
[try2, err] = triangulate(P1, allpts_I1, K2*P2(:,:,2), allpts_I2);
[try3, err] = triangulate(P1, allpts_I1, K2*P2(:,:,3), allpts_I2);
[try4, err] = triangulate(P1, allpts_I1, K2*P2(:,:,4), allpts_I2);

[~, bestM2] = max([min(try1(:,3)), min(try2(:,3)), min(try3(:,3)), min(try4(:,3))])

figure(4)
[Pts1, err] = triangulate(P1, plane1_I1, K2*P2(:,:,bestM2), plane1_I2);
[Pts2, err] = triangulate(P1, plane2_I1, K2*P2(:,:,bestM2), plane2_I2);
plot3(Pts1(:,1), Pts1(:,2), Pts1(:,3), 'ro')
hold on
plot3(Pts2(:,1), Pts2(:,2), Pts2(:,3), 'bo')
if nplanes == 3
    [Pts3, err] = triangulate(P1, plane3_I1, K2*P2(:,:,bestM2), plane3_I2);
    plot3(Pts3(:,1), Pts3(:,2), Pts3(:,3), 'go')
end
title('3D Reconstruction of points on the planes')

% ---------------------------------------------------------------------
% Fit planes


[gX1, gY1, gZ1, gc1, quad1_1, quad1_2] = computePlaneReconstruction(Pts1, plane1_I1, im1, H1, ...
    P1, K2*P2(:,:,bestM2));

[gX2, gY2, gZ2, gc2, quad2_1, quad2_2] = computePlaneReconstruction(Pts2, plane2_I1, im1, H2, ...
    P1, K2*P2(:,:,bestM2));

if nplanes == 3
    [gX3, gY3, gZ3, gc3, quad3_1, quad3_2] = computePlaneReconstruction(Pts3, plane3_I1, im1, H3, ...
        P1, K2*P2(:,:,bestM2));
end

figure(55)
surf(gX1, gY1, gZ1, gc1, 'FaceColor', 'texturemap', 'LineStyle', 'none')
hold on
surf(gX2, gY2, gZ2, gc2, 'FaceColor', 'texturemap', 'LineStyle', 'none')
if nplanes == 3
    surf(gX3, gY3, gZ3, gc3, 'FaceColor', 'texturemap', 'LineStyle', 'none')
end
title('Dense Reconstruction of planes')

figure(6);
imshow(im1)
hold on
plot(plane1_I1(:,1), plane1_I1(:,2), 'ro')
plot(quad1_1(1,:), quad1_1(2,:), 'r*-', 'LineWidth', 3)
plot(plane2_I1(:,1), plane2_I1(:,2), 'bo')
plot(quad2_1(1,:), quad2_1(2,:), 'b*-', 'LineWidth', 3)
if nplanes == 3
    plot(plane3_I1(:,1), plane3_I1(:,2), 'go')
    plot(quad3_1(1,:), quad3_1(2,:), 'g*-', 'LineWidth', 3)
end
title('Polygons used for planes in Image 1')


figure(6);
imshow(im2)
hold on
plot(plane1_I2(:,1), plane1_I2(:,2), 'ro')
plot(quad1_2(1,:), quad1_2(2,:), 'r*-', 'LineWidth', 3)
plot(plane2_I2(:,1), plane2_I2(:,2), 'bo')
plot(quad2_2(1,:), quad2_2(2,:), 'b*-', 'LineWidth', 3)
if nplanes == 3
    plot(plane3_I2(:,1), plane3_I2(:,2), 'go')
    plot(quad3_2(1,:), quad3_2(2,:), 'g*-', 'LineWidth', 3)
end
title('Polygons used for planes in Image 2')
