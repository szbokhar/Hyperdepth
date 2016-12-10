function [ P, error ] = triangulate( M1, p1, M2, p2 )
% triangulate:
%       M1 - 3x4 Camera Matrix 1
%       p1 - Nx2 set of points
%       M2 - 3x4 Camera Matrix 2
%       p2 - Nx2 set of points

% Q2.4 - Todo:
%       Implement a triangulation algorithm to compute the 3d locations
%       See Szeliski Chapter 7 for ideas
%
    P = [];

    for i=1:size(p1, 1)
        u1 = p1(i,1);
        v1 = p1(i,2);
        u2 = p2(i,1);
        v2 = p2(i,2);

        D = [u1*M1(3,:) - M1(1,:);
             v1*M1(3,:) - M1(2,:);
             u2*M2(3,:) - M2(1,:);
             v2*M2(3,:) - M2(2,:)];

        [u s v] = svd(D);
        P = [P, v(:,end)/v(end,end)];

    end

    Q1 = M1*P;
    Q2 = M2*P;
    Q1 = bsxfun(@rdivide, Q1, Q1(3,:))';
    Q2 = bsxfun(@rdivide, Q2, Q2(3,:))';

    p1-Q1(:,1:2);
    p2-Q2(:,1:2);

    P = P';
    error = sum(sqrt(sum((p1-Q1(:,1:2)).^2,2))) + sum(sqrt(sum((p2-Q2(:,1:2)).^2,2)));
end
