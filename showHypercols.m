close all
figure; imshow(I1)
export_fig(strcat('poster/',imageset,'_resized.png'))


figure('Position', [100 100 300 300]); imagesc(H1(:,:,41)); colormap jet
export_fig(strcat('poster/',imageset,'_fc7_41.png'))
figure('Position', [100 100 300 300]); imagesc(H1(:,:,248)); colormap jet
export_fig(strcat('poster/',imageset,'_fc7_248.png'))

%{
figure('Position', [100 100 300 300]); imagesc(H1(:,:,81)); colormap jet
export_fig(strcat('poster/',imageset,'_conv2_81.png'))
figure('Position', [100 100 300 300]); imagesc(H1(:,:,177)); colormap jet
export_fig(strcat('poster/',imageset,'_conv2_177.png'))

figure('Position', [100 100 300 300]); imagesc(H1(:,:,305)); colormap jet
export_fig(strcat('poster/',imageset,'_conv3_305.png'))
figure('Position', [100 100 300 300]); imagesc(H1(:,:,334)); colormap jet
export_fig(strcat('poster/',imageset,'_conv3_334.png'))

figure('Position', [100 100 300 300]); imagesc(H1(:,:,508)); colormap jet
export_fig(strcat('poster/',imageset,'_conv4_508.png'))
figure('Position', [100 100 300 300]); imagesc(H1(:,:,520)); colormap jet
export_fig(strcat('poster/',imageset,'_conv4_520.png'))

figure('Position', [100 100 300 300]); imagesc(H1(:,:,976)); colormap jet
export_fig(strcat('poster/',imageset,'_conv4_976.png'))
figure('Position', [100 100 300 300]); imagesc(H1(:,:,992)); colormap jet
export_fig(strcat('poster/',imageset,'_conv4_992.png'))
%}
