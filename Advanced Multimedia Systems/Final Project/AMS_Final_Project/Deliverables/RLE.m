function data = RLE(x)
    % data = RLE(x) (de)compresses the data with the RLE-Algorithm
    %   Compression:
    %      if x is a numbervector data{1} contains the values
    %      and data{2} contains the run lengths
    %
    %   Decompression:
    %      if x is a cell array, data contains the uncompressed values
    if iscell(x) % decoding
	    i = cumsum([ 1 x{2} ]);
	    j = zeros(1, i(end)-1);
	    j(i(1:end-1)) = 1;
	    data = x{1}(cumsum(j));
    else % encoding
	    if size(x,1) > size(x,2), x = x'; end % if x is a column vector, tronspose
        i = [ find(x(1:end-1) ~= x(2:end)) length(x) ];
	    data{2} = diff([ 0 i ]);
	    data{1} = x(i);
    end
end