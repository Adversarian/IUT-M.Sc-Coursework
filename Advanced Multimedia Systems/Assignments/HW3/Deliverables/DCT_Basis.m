function dct_basis = DCT_Basis(block_size, resolution)
    % dct_basis[i, j] -> a size by size representation of the (i, j) basis
    % function.
    dct_basis = zeros([block_size, block_size, resolution, resolution]);
    for r=1:block_size
        for c=1:block_size
            % basis function at (r, c)
            for i=1:resolution
                for j=1:resolution
                    dct_basis(r, c, i, j) = Alpha(r-1, resolution)*...
                        Alpha(c-1, resolution)*...
                        cos((pi*(2*(i-1)+1)*(r-1))/(2*resolution))*...
                        cos((pi*(2*(j-1)+1)*(c-1))/(2*resolution));
                end
            end
        end
    end
end
