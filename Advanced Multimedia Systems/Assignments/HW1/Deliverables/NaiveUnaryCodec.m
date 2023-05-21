classdef NaiveUnaryCodec
    % Provides a Naive Unary Codec.
    properties
        % path to file used for (en/de)coding.
        input_dir
    end
    methods
        function obj = NaiveUnaryCodec(input)
            % Class must be constructed with a path to a file.
            if nargin > 0
                obj.input_dir = input; 
            end
        end
        function [enc, cr, et, cdsize, tsize, dsize] = encode(obj, save_to)
            % Encode file in a naive manner.
            if nargin > 0
                tic;
                % read file as image and get its size (assumed grayscale)
                img = imread(obj.input_dir);
                [M, N] = size(img);
                % because MATLAB does not offer bit-level access, create an 
                % cell array to hold the unary code for every single pixel.
                enc = cell([M*N 1]);
                pos = 1;
                for i = 1:M
                    for j = 1:N
                        % naively encode every pixel value
                        % img(i, j) times 1 followed by a 0
                        enc{pos} = uint8([ones([img(i, j), 1]); 0]);
                        pos = pos + 1;
                    end
                end
                % concatenate all of the cells to create a bit-vector
                % noting that every element of the "bit-vector" is still
                % stored as a uint8
                enc = cell2mat(enc);
                % because MATLAB does not offer bit-level access, in order
                % to write to a bit-represented file we must ensure the
                % number of bits are a multiple of 8 (and therefore the
                % file can be cleanly divided into bytes with no remainder) 
                pad = 8 - mod(numel(enc), 8);
                % pad the file with 1's by the amount of bits it is missing to form
                % a multiple of 8
                % NOTE: Padding with 1's because a sequence of 1's not
                % leading to a 0 does NOT correspond to any valid unary
                % code.
                enc = [enc; ones([pad, 1])];
                % calculate compression ratio
                cr = (M*N) / (8 + numel(enc)/8);
                % calculate cdsize in BPP
                cdsize = numel(enc)/(M*N);
                % calculate tsize (cdsize + 8 bytes of header) in BPP
                tsize = (numel(enc)+ 8*8)/(M*N);
                % no dictionary, dsize always 0
                dsize = 0;
                write = fopen(save_to, 'w');
                % save the dimensions of the image, using uint because the
                % dimensions are unknown
                fwrite(write, [M; N], 'uint');
                % write the encoded vector to file, making sure to specify
                % that "enc" is a bit-level representation by using the
                % '*ubit1' flag
                fwrite(write, enc, '*ubit1');
                fclose(write);
                et = toc;
            end
        end
        function [dec, et] = decode(obj, save_to)
            % Decode a file that has been encoded naively with unary
            % encoding.
            if nargin > 0
                tic;
                % open the encoded file
                read = fopen(obj.input_dir);
                % store the dimensions written on top of the file
                sz = fread(read, [1 2], 'uint');
                M = sz(1); N = sz(2);
                % read the rest of the file as a bit-level representation
                bits = uint8(fread(read, '*ubit1'));
                fclose(read);
                pad = 0;
                % read backwards from the end of the file to remove padding
                for i = size(bits):-1:1
                    if bits(i)
                        pad = pad + 1;
                    else
                        break
                    end
                end
                % pad := the number of consecutive 1's encountered from the
                % end of file before reaching the first 0. (refer to the
                % NOTE on the padding section of encoding)
                bits = bits(1:size(bits)-pad);
                dec = uint8(zeros([M*N 1]));
                code = 0;
                pos = 1;
                % code := number of 1's visited until reaching the first 0
                % going from the start of file
                for i = 1:size(bits)
                    if bits(i)
                        code = code+1;
                    else
                        dec(pos) = code;
                        pos = pos + 1;
                        code = 0;
                    end
                end
                % reshape the dec array into an N by M image
                dec = reshape(dec, [N M]);
                % transpose it and save it
                imwrite(dec', save_to);
                et = toc;
            end
        end
    end
end