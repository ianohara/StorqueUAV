function stDiff = testDiff(stateVec)
% Compute the least squared distance between the first and last states
stDiff = sqrt(sum((stateVec(size(stateVec,1),:) - stateVec(1,:)).^2));
end