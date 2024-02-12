Feladat = [1 2 3; 4 5 6; 7 8 9];

[minimum, min_index] = min(Feladat(:));
[maximum, max_index] = max(Feladat(:));

Feladat = Feladat';
% 1-9, 2-8, 3-7

A = Feladat(:);

for i=1:length(A) / 2
    disp([A(i) A(length(A)-i + 1)])
end
