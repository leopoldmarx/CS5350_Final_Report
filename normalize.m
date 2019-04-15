function [data,me,st] = normalize(data)
%NORMALIZE Summary of this function goes here
%   Detailed explanation goes here
[n,m] = size(data);
me = zeros(m,1);
st = zeros(m,1);
for j = 1:m
    me(j) = mean(data(:,j));
    st(j) = std(data(:,j));
end

for j = 1:m
    for i = 1:n
        data(i,j) = (data(i,j)-me(j))/st(j);
    end
end
end

