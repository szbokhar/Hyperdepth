imageset = 'playtable'

H1 = load(fullfile(imageset,'im0_resized.mat'))
H2 = load(fullfile(imageset,'im1_resized.mat'))
I1 = imresize(im2double(imread(fullfile(imageset,'im0.png'))), [224, 224]);
I2 = imresize(im2double(imread(fullfile(imageset,'im1.png'))), [224, 224]);

H1 = permute(reshape(H1.hcol', [224, 224, 4096]), [2,1,3]);
H2 = permute(reshape(H2.hcol', [224, 224, 4096]), [2,1,3]);

slice = randperm(4096);
slice = slice(1:(19^2*3))
range = 40;

W = size(H1, 1)
H = size(H1, 2)
Z = zeros(H, W)
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
