close all
figure; imshow(I1)

figure
for i=1:1472
    imagesc(H1(:,:,i))
    title(i)
    pause

end
figure; imagesc(H1(:,:,1))
figure; imagesc(H1(:,:,10))
figure; imagesc(H1(:,:,30))
figure; imagesc(H1(:,:,60))
