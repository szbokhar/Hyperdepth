I1 = imresize(im2double(imread(fullfile(imageset,'im0.png'))), [224, 224]);
I2 = imresize(im2double(imread(fullfile(imageset,'im1.png'))), [224, 224]);

W = size(H1, 1)
H = size(H1, 2)

figure; imagesc(Z)
for i=1:H
    i
    toplot = matchesq(((i-1)*W+1):(i*W), :);

    figure(1);
    imshow(I1); hold on;
    plot(toplot(:,1), toplot(:,2), 'y-')
    figure(2);
    imshow(I2); hold on;
    plot(toplot(:,3), toplot(:,4), 'y-', toplot(:,1), toplot(:,2), 'r-')
    waitforbuttonpress
end
%{

for y = 1:H
    figure(1); imshow(I1)
    pos = ginput(1)
    x = round(pos(1))
    y = round(pos(2))

    row2 = reshape(H2(y,:,slice), [224, length(slice)]);
    row1 = reshape(H1(y,x,slice), [1, length(slice)]);


    dists = pdist2(row1, row2);
    [~,bests] = sort(dists, 2);
    tmp = x - bests;
    p = tmp(abs(tmp(:)) < range);

    good = x - p(1)

    figure(4)
    showMatchedFeatures(I1, I2, [x, y], [good, y], 'montage')

    figure(3)
    plot(dists, 'r-')
    hold on
    plot([x x], [0 max(dists)], 'g-')
    plot([x-range x-range], [0 max(dists)], 'g-')
    plot([x+range x+range], [0 max(dists)], 'g-')
    plot([good good], [0 max(dists)], 'b--')
    hold off
    waitforbuttonpress
end
%}
