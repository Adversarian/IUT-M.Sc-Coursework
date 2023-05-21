function imshowable = ReadPPM(ppm_dir)
    % Reads a PPM file and returns an imshow-able array.
    % read file in bytes
    handle = fopen(ppm_dir);
    % the headers are in ASCII. ['P3' width height max_lumin]
    headers = textscan(handle, '%s %d %d %d', 1);
    if ~strcmp(char(headers{1}),'P6') % incorrect magic number
        fclose(handle);
        error(['Input file is not in PPM format.\n' ...
            'Please refer to https://en.wikipedia.org/wiki/Netpbm for more info.'])
    else
        [C, R, max_lumin] = headers{2:4};
        % cast max_lumin to double to not clip off anything until after
        % multiplication. lumin_ratio used to scale [0, max_lumin] to [0, 255].
        lumin_ratio = 255/double(max_lumin);
        imshowable = zeros([R, C, 3]);
        rest = fread(handle);
        pos = 1;
        for i = 1:R % ROWS
            for j = 1:C % COLUMNS
                % pos = (i-1)*C*3 + (j-1)*3 + 1;
                % (rest[x], rest[x+1], rest[x+2]) = (G, R, B) -> fix mapping
                imshowable(i,j, :) = [rest(pos+1), rest(pos+2), rest(pos)]*lumin_ratio;
                pos = pos + 3;
            end
        end
        % cast to uint8 to round doubles (necessary for imshow())
        imshowable = uint8(imshowable); 
        fclose(handle);
    end
end

