classdef UnaryCodec
    % Proposed Unary Codec.
    properties
        % path to file used for (en/de)coding.
        input_dir
        % dictionary used to store codewords in descending order of the
        % repetition of their values in the histogram of the target file
        dict
    end
    methods
        function obj = UnaryCodec(input)
            if nargin > 0
                obj.input_dir = input;
                % can be interpreted differently depending on if it's being
                % used in enc or dec mode.
                % 1. dict(<code_word>):= actual grayscale value
                % 2. dict(<actual_value>):= code word
                obj.dict = uint8(zeros([256, 1]));
            end
        end
        function obj = BuildDict(obj, mode)
            % Builds a dictionary from an unencoded file or reads the it from the header of an encoded file.
            if nargin > 0
                if mode == "enc"
                    img = imread(obj.input_dir);
                    [M, N] = size(img);
                    % construct a histogram from the input image
                    h = zeros([256, 1]);
                    for i = 1:M
                        for j = 1:N
                            h(img(i,j) + 1) = h(img(i, j) + 1) + 1;
                        end
                    end
                    % sort the histogram in descending order, keeping track
                    % of the original indices.
                    % NOTE: Throwing away the actual sorted histogram because
                    % the values in it are worthless. Only the ordering
                    % matters.
                    [~, imap] = sort(h, 'descend');
                    % imap(i) := which value corresponds to the i-th
                    % most frequent value in the histogram of the image
                    % invert the mapping from indices to values to get
                    % dict(<actual_value>) := code word
                    for i = 1:256
                        obj.dict(imap(i)) = i-1;
                    end
                elseif mode == "dec"                    
                    read = fopen(obj.input_dir);
                    % skip 8 bytes because that is where we store
                    % dimensions as two 4 byte integers M and N
                    fseek(read, 8, 'bof');
                    % here we need dict(<code_word>) := actual_value so we
                    % invert the mapping again
                    imap = fread(read, [256, 1]);
                    fclose(read);
                    for i = 1:256
                        obj.dict(imap(i) + 1) = i-1;
                    end
                else
                     error('BuildDict called with unsupported mode.');
                end
            end
        end
        function [enc, cr, et, cdsize, tsize, dsize] = encode(obj, save_to)
            % Unary encoding using a frequency dictionary.
            if nargin > 0
                tic;
                obj = BuildDict(obj, "enc");
                img = imread(obj.input_dir);
                [M, N] = size(img);
                enc = cell([M*N 1]);
                pos = 1;
                for i = 1:M
                    for j = 1:N
                        % instead of naively putting img(i, j) ones
                        % followed by a 0, lookup dict(img(i, j) + 1) and
                        % put that many ones followed by a 0.
                        % NOTE: Performs better than the naive version
                        % because the most frequent values are assigned the
                        % shortest code words.
                        enc{pos} = uint8([ones([obj.dict(img(i,j)+1), 1]); 0]);
                        pos = pos + 1;
                    end
                end          
                enc = cell2mat(enc);
                pad = 8 - mod(numel(enc), 8);
                enc = [enc; ones([pad, 1])];
                cr = (M*N) / (264 + numel(enc)/8);
                cdsize = numel(enc)/(M*N);
                tsize = (numel(enc) + 264*8)/(M*N);
                dsize = (256*8)/(M*N);
                write = fopen(save_to, 'w');
                fwrite(write, [M; N], 'uint');
                % write 256 bytes of dictionary signifying the order in
                % which values 0 - 255 appear in the descending-sorted
                % histogram
                fwrite(write, obj.dict);                
                fwrite(write, enc, '*ubit1');
                fclose(write);
                et = toc;
            end
        end
        function [dec, et] = decode(obj, save_to)
            % Unary decoding using a frequency dictionary.
            if nargin > 0
                tic;
                obj = BuildDict(obj, "dec");
                read = fopen(obj.input_dir);
                sz = fread(read, [1 2], 'uint');
                M = sz(1); N = sz(2);
                % skip 8 (dimensions in bytes) + 256 (dictionary) = 264
                % bytes to arrive the data
                fseek(read, 264, 'bof');
                bits = uint8(fread(read, '*ubit1'));
                fclose(read);
                pad = 0;
                for i = size(bits):-1:1
                    if bits(i)
                        pad = pad + 1;
                    else
                        break
                    end
                end
                bits = bits(1:size(bits)-pad);
                dec = uint8(zeros([M*N 1]));
                code = 0;
                pos = 1;
                for i = 1:size(bits)
                    if bits(i)
                        code = code + 1;
                    else
                        % look up the corresponding value from the dictionary
                        dec(pos) = obj.dict(code + 1);
                        pos = pos + 1;
                        code = 0;
                    end
                end
                dec = reshape(dec, [N M]);
                imwrite(dec', save_to);
                et = toc;
            end
        end
    end
end