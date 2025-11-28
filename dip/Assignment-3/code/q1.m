text = 'INKYPINKYPONKYPINKYNONPONKY';
original_bits = length(text) * 8;

fprintf("============================================================\n");
fprintf("                TEXT COMPRESSION REPORT\n");
fprintf("============================================================\n\n");
fprintf("Original Text: %s\n", text);
fprintf("Original Size: %d bits\n\n", original_bits);

%%% Running Compressions
search_buf = 6; 
lookahead_buf = 4;
lz77_tokens = lz77_compress(text, search_buf, lookahead_buf);
lz78_pairs  = lz78_compress(text);
lzw_codes   = lzw_compress(text);

%%% Decompressing
lz77_out = lz77_decompress(lz77_tokens);
lz78_out = lz78_decompress(lz78_pairs);
lzw_out  = lzw_decompress(lzw_codes);

lz77_bits = length(lz77_tokens) * (ceil(log2(lookahead_buf)) + ceil(log2(search_buf)) + 8); %offset + len + 
lz77_ratio = original_bits / lz77_bits;

% LZ78 fields: index=4 bits, char=8 bits
lz78_bits = 0;
for k = 1:length(lz78_pairs)
    if isempty(lz78_pairs{k}.next)
        lz78_bits = lz78_bits + 4;
    else
        lz78_bits = lz78_bits + 12;
    end
end
lz78_ratio = original_bits / lz78_bits;

% LZW fields: code width = ceil(log2(maxCode))
maxCode = max(lzw_codes);
code_bits = ceil(log2(maxCode));
lzw_bits = length(lzw_codes) * code_bits;
lzw_ratio = original_bits / lzw_bits ;

%% ------------------------------------------------------------
% DISPLAY CLEAN TOKENS AND RESULT STRINGS
%% ------------------------------------------------------------
fprintf("=== LZ77 TOKENS ===\n");
for k = 1:length(lz77_tokens)
    t = lz77_tokens{k};
    if isempty(t.next)
        fprintf("(%d, %d, EOF)\n", t.offset, t.len);
    else
        fprintf("(%d, %d, '%s')\n", t.offset, t.len, t.next);
    end
end
fprintf("\nLZ77 Output: %s\n\n", lz77_out);

fprintf("=== LZ78 PAIRS ===\n");
for k = 1:length(lz78_pairs)
    p = lz78_pairs{k};
    if isempty(p.next)
        fprintf("(%d, EOF)\n", p.index);
    else
        fprintf("(%d, '%s')\n", p.index, p.next);
    end
end
fprintf("\nLZ78 Output: %s\n\n", lz78_out);

fprintf("=== LZW CODES ===\n");
disp(lzw_codes);
fprintf("\nLZW Output: %s\n\n", lzw_out);

%% ------------------------------------------------------------
% SUMMARY TABLE
%% ------------------------------------------------------------
Summary = table( ...
    ["LZ77"; "LZ78"; "LZW"], ...
    [lz77_bits; lz78_bits; lzw_bits], ...
    [lz77_ratio; lz78_ratio; lzw_ratio], ...
    'VariableNames', {'Algorithm', 'CompressedBits', 'CompressionRatio'} ...
);

fprintf("============================================================\n");
fprintf("                    SUMMARY TABLE\n");
fprintf("============================================================\n\n");
disp(Summary);


%% ---------------- LZ77 COMPRESS ----------------



%% ---------------- LZ77 DECOMPRESS ----------------
function out = lz77_decompress(tokens)
out = '';
for i = 1:numel(tokens)
    t = tokens{i};
    if t.offset == 0 && t.len == 0
        out = [out t.next];
    else
        startIdx = numel(out) - t.offset + 1;
        % safety check
        if startIdx < 1
            error('Invalid offset during LZ77 decompression.');
        end
        seq = out(startIdx : startIdx + t.len - 1);
        out = [out seq];
        if ~isempty(t.next)
            out = [out t.next];
        end
    end
end
end


%% ---------------- LZ78 COMPRESS ----------------
function pairs = lz78_compress(s)
s = char(s);
pairs = {};
dict = containers.Map('KeyType','char','ValueType','double');
nextIndex = 1;
n = numel(s);
i = 1;

while i <= n
    lastIdx = 0;
    j = i;
    % find longest prefix present in dict
    while j <= n
        cand = s(i:j);
        if isKey(dict, cand)
            lastIdx = dict(cand);
            j = j + 1;
        else
            break;
        end
    end

    if j <= n
        nextChar = s(j);
        % store new phrase = s(i:j)
        dict(s(i:j)) = nextIndex;
        nextIndex = nextIndex + 1;
        pairs{end+1} = struct('index',lastIdx,'next',nextChar);
        i = j + 1;
    else
        % end reached
        pairs{end+1} = struct('index',lastIdx,'next','');
        break;
    end
end
end


%% ---------------- LZ78 DECOMPRESS ----------------
function out = lz78_decompress(pairs)
dict = {};
out = '';
for k = 1:length(pairs)
    idx = pairs{k}.index;
    nxt = pairs{k}.next;
    if idx == 0
        entry = nxt;
    else
        entry = dict{idx};
        if ~isempty(nxt)
            entry = [entry nxt];
        end
    end
    out = [out entry];
    dict{end+1} = entry;
end
end


%% ---------------- LZW COMPRESS ----------------
function codes = lzw_compress(s)
s = char(s);
dict = containers.Map('KeyType','char','ValueType','double');
for k = 1:26
    dict(char('A' + k - 1)) = k;
end
nextCode = 27;
w = s(1);
codes = [];

for i = 2:numel(s)
    c = s(i);
    wc = [w c];
    if isKey(dict, wc)
        w = wc;
    else
        codes(end+1) = dict(w);
        dict(wc) = nextCode;
        nextCode = nextCode + 1;
        w = c;
    end
end
codes(end+1) = dict(w);
end


%% ---------------- LZW DECOMPRESS ----------------
function out = lzw_decompress(codes)
% initialize dictionary
dict = cell(1, 2000);
for k = 1:26
    dict{k} = char('A' + k - 1);
end
nextCode = 27;

old = codes(1);
prevEntry = dict{old};
out = prevEntry;

for i = 2:length(codes)
    new = codes(i);
    if new <= length(dict) && ~isempty(dict{new})
        entry = dict{new};
    else
        % special case: new not yet in dict
        entry = [prevEntry prevEntry(1)];
    end

    out = [out entry];
    % add prevEntry + first char of entry
    dict{nextCode} = [prevEntry entry(1)];
    nextCode = nextCode + 1;

    prevEntry = entry;
    old = new;
end
end
