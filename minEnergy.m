function path = minEnergy(dists, win)
DP = zeros(size(dists));
W = size(dists,2)
H = size(dists,1)

DP(1,:) = dists(1,:);
for r = 2:H
    for c = 1:W
        parts = [repmat(2*max(DP(r-1,:)), [1, -(c-win)+1]), DP(r-1,max(c-win,1):min(c+win,W)), repmat(2*max(DP(r-1,:)), [1, (c+win)-W])];

        [val, idx] = min(parts+dists(r,c));
        DP(r,c) = val;
    end

%{
    [~, c] = min(DP(r,:))

    path = zeros([1,r])
    path(r) = c;
    for rr = (r-1):-1:1
        c = path(rr+1);
        parts = [repmat(max(DP(:)), [1, -(c-win)+1]), DP(rr,max(c-win,1):min(c+win,W)), repmat(max(DP(:)), [1, (c+win)-W])];
        [~,idx] = min(parts);
        offs = idx - win - 1;
        path(rr) = c + offs;
    end
    figure(1)
    imagesc(dists)
    hold on
    plot(path, 1:r, 'r-')
    hold off
    pause
    %}
end

path = zeros([1,H])
path(H) = c;
for rr = (H-1):-1:1
    c = path(rr+1);
    parts = [repmat(max(DP(:)), [1, -(c-win)+1]), DP(rr,max(c-win,1):min(c+win,W)), repmat(max(DP(:)), [1, (c+win)-W])];
    [~,idx] = min(parts);
    offs = idx - win - 1;
    path(rr) = c + offs;
end
