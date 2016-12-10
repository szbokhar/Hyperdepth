imageset = 'recycle'
I1 = imresize(im2double(imread(fullfile(imageset,'im0.png'))), [224, 224]);
I2 = imresize(im2double(imread(fullfile(imageset,'im1.png'))), [224, 224]);

W = size(I1, 1)
H = size(I1, 2)
Z = zeros(H, W)

win = 4;
range = 20;

H1 = zeros(H, W, (2*win+1)^2*3);
H2 = zeros(H, W, (2*win+1)^2*3);

for y=(win+1):(H-win-1)
    for x=(win+1):(W-win-1)
        p = I1((y-win):(y+win), (x-win):(x+win), :);
        H1(y,x,:) = p(:);
        p = I2((y-win):(y+win), (x-win):(x+win), :);
        H2(y,x,:) = p(:);
    end
end

slice = 1:(2*win+1)^2*3;

for y = 1:H
    row2 = reshape(H2(y,:,slice), [224, length(slice)]);
    row1 = reshape(H1(y,:,slice), [224, length(slice)]);


    dists = pdist2(row1, row2);
    [~,bests] = sort(dists, 2);
    tmp = bsxfun(@minus, (1:W)', bests);
    tmp2 = [];
    for x=1:W
        p = tmp(x,abs(tmp(x,:)) < range);
        tmp2 = [tmp2, p(1)];
    end
    Z(y,:) = tmp2;

    y
end
blurZ = imgaussfilt(Z, 3);
[X1, Y] = meshgrid(1:W, 1:H);
X2 = X1 - blurZ;
rawZ = Z;

matchesq = [X1(:), Y(:), X2(:), Y(:)]
figure; imagesc(Z)
