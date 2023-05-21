% Calculate shannon-entropy of an arbitrary array
function hx = Entropy_Array(A)
    A = reshape(A, 1, []);
    if min(A) ~= 1
        A = A - min(A) + 1;
    end
    p = zeros(1,max(A));
    for i = 1:length(A)
        p(A(i)) = p(A(i)) + 1;
    end
    p = p/sum(p);
    p(p==0) = [];
    hx = sum(-p.*log2(p));
end
