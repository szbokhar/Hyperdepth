function [M2s] = getProjectionMatrices(E)
    [U,S,V] = svd(E);
    av = (S(1,1)+S(2,2))/2;
    E = U * [av, 0, 0; 0, av, 0; 0, 0, 0] * V';
    [U,S,V] = svd(E);
    W = [0, -1, 0; 1, 0, 0; 0, 0, 1];

    if (det(U*W*V')<0)
        W = -W;
    end

    M2s = zeros(3,4,4);

    M2s(:,:,1) = [U * W * V',U(:,3)./max(abs(U(:,3)))];
    M2s(:,:,2) = [U * W * V',-U(:,3)./max(abs(U(:,3)))];
    M2s(:,:,3) = [U * W' * V',U(:,3)./max(abs(U(:,3)))];
    M2s(:,:,4) = [U * W' * V',-U(:,3)./max(abs(U(:,3)))];
end
