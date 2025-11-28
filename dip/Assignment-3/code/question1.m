%% ================================================================
%  DATA
% ================================================================
text = "INKYPINKYPONKYPONKYPINKYINKYNKYPONKY";
og_bits = strlength(text) * 8;

fprintf("\nINPUT STRING: %s\n", text);
fprintf("Original bits = %d\n", og_bits);



%% ================================================================
%  LZ77 COMPRESSION
% ================================================================
search_buf = 6;
lookahead_buf = 4;

lz77_tokens = lz77_compress(text, search_buf, lookahead_buf);

fprintf("\n===================== LZ77 TOKENS =====================\n");
for k = 1:length(lz77_tokens)
    t = lz77_tokens{k};
    if isempty(t.next)
        fprintf("(%d, %d, EOF)\n", t.offset, t.len);
    else
        fprintf("(%d, %d, '%s')\n", t.offset, t.len, t.next);
    end
end

offset_bits = ceil(log2(search_buf+1));
length_bits = ceil(log2(lookahead_buf+1));

lz77_bits = 0;
for k = 1:length(lz77_tokens)
    t = lz77_tokens{k};
    literal_bits = ~isempty(t.next) * 8;
    lz77_bits = lz77_bits + offset_bits + length_bits + literal_bits;
end

fprintf("\n=== LZ77 BIT STATISTICS ===\n");
fprintf("Original bits:   %d\n", og_bits);
fprintf("Compressed bits: %d\n", lz77_bits);
fprintf("Compression ratio: %.3f\n", og_bits / lz77_bits);



%% ================================================================
%  LZ78 (PAIRS ONLY — NO DICTIONARY TRANSMISSION)
% ================================================================
[pairs78, dict78, lz78_bits] = lz78_pairs_only(text);

fprintf("\n===================== LZ78 (Pairs Only) =====================\n");

fprintf("\nDICTIONARY (not transmitted):\n");
for k = 1:length(dict78)
    fprintf("%3d -> %s\n", k-1, dict78{k});
end

fprintf("\nPAIRS (transmitted):\n");
for k = 1:length(pairs78)
    p = pairs78{k};
    if isempty(p.next)
        fprintf("(%d, EOF)\n", p.index);
    else
        fprintf("(%d, '%s')\n", p.index, p.next);
    end
end

fprintf("\n=== LZ78 BIT STATISTICS (Pairs Only) ===\n");
fprintf("Original bits:   %d\n", og_bits);
fprintf("Compressed bits: %d\n", lz78_bits);
fprintf("Compression ratio: %.3f\n", og_bits / lz78_bits);



%% ================================================================
%  LZW (UNCHANGED — TRANSMITS BASIC ALPHABET + CODES)
% ================================================================
[codes, triplets, dictMap, basicDict] = lzw_compress_with_order(text);

fprintf("\n===================== LZW TRIPLETS =====================\n");
for k = 1:length(triplets)
    t = triplets{k};
    fprintf("(%d , '%s' , '%s')\n", t.code, t.current, t.next);
end

fprintf("\n=== LZW CODE STREAM ===\n");
disp(codes);

%% Bit Cost
lzw_dict_bits = length(basicDict) * 8;

maxCode = max(double(codes));
code_bits = ceil(log2(maxCode + 1));
lzw_code_bits = length(codes) * code_bits;
lzw_bits = lzw_dict_bits + lzw_code_bits;

fprintf("\n=== LZW BIT STATISTICS ===\n");
fprintf("Dictionary bits: %d\n", lzw_dict_bits);
fprintf("Code stream:     %d\n", lzw_code_bits);
fprintf("Total bits:      %d\n", lzw_bits);
fprintf("Compression ratio: %.3f\n", og_bits / lzw_bits);

fprintf("\n=== LZW DICTIONARY (code → string) ===\n");
maxCode = max(cell2mat(values(dictMap)));
for c = 1:maxCode
    if isKey(dictMap, num2str(c))
        fprintf("%3d → %s\n", c, dictMap(num2str(c)));
    end
end



%% ================================================================
%  LZ77 SEARCH WINDOW EXPERIMENT
% ================================================================
compression_ratio = zeros(1, (strlength(text)-lookahead_buf+1));
lengths = 1:(strlength(text)-lookahead_buf+1);

for i = lengths
    search_buf = i;
    tokens = lz77_compress(text, search_buf, lookahead_buf);

    offset_bits = ceil(log2(search_buf + 1));
    length_bits = ceil(log2(lookahead_buf + 1));

    bits = 0;
    for k = 1:length(tokens)
        t = tokens{k};
        bits = bits + offset_bits + length_bits + (~isempty(t.next))*8;
    end

    compression_ratio(i) = og_bits / bits;
end

figure;
plot(lengths, compression_ratio, 'o-', 'LineWidth', 1.5);
grid on;
xlabel("Search Buffer Size");
ylabel("Compression Ratio (original / compressed)");
title("LZ77 Compression Ratio vs Search Buffer Size");

%% ================================================================
%  LZ77 LOOKAHEAD WINDOW EXPERIMENT
% ================================================================
search_buf = 6;   % keep search window fixed
max_lookahead = strlength(text) - 1;  % cannot exceed n-1

compression_ratio_LA = zeros(1, max_lookahead);
lookahead_lengths = 1:max_lookahead;

for la = lookahead_lengths
    tokens = lz77_compress(text, search_buf, la);

    offset_bits = ceil(log2(search_buf + 1));
    length_bits = ceil(log2(la + 1));

    bits = 0;
    for k = 1:length(tokens)
        t = tokens{k};
        bits = bits + offset_bits + length_bits + (~isempty(t.next))*8;
    end

    compression_ratio_LA(la) = og_bits / bits;
end

figure;
plot(lookahead_lengths, compression_ratio_LA, 's-', 'LineWidth', 1.5);
grid on;
xlabel("Lookahead Buffer Size");
ylabel("Compression Ratio (original / compressed)");
title("LZ77 Compression Ratio vs Lookahead Buffer Size");




%% ================================================================
%  FUNCTIONS
% ================================================================

function tokens = lz77_compress(s, searchSize, lookaheadSize)
s = char(s);
n = length(s);
pos = 1;
tokens = {};
idx = 0;

while pos <= n
    windowStart = max(1, pos - searchSize);
    window = s(windowStart:pos-1);

    bestLen = 0;
    bestOffset = 0;

    laMax = min(lookaheadSize, n - pos + 1);

    for L = laMax:-1:1
        substr = s(pos:pos+L-1);
        matchPos = strfind(window, substr);
        if ~isempty(matchPos)
            last = matchPos(end);
            matchStart = windowStart + last - 1;
            bestOffset = pos - matchStart;
            bestLen = L;
            break
        end
    end

    idx = idx + 1;
    if bestLen == 0
        tokens{idx} = struct('offset',0,'len',0,'next',s(pos));
        pos = pos + 1;
    else
        if pos+bestLen <= n
            nextChar = s(pos+bestLen);
            pos = pos + bestLen + 1;
        else
            nextChar = '';
            pos = pos + bestLen;
        end
        tokens{idx} = struct('offset',bestOffset,'len',bestLen,'next',nextChar);
    end
end
end


function [pairs, dict, total_bits] = lz78_pairs_only(s)

s = char(s);
dict = {""};
pairs = {};
n = length(s);
i = 1;

while i <= n
    prefixIdx = 0;
    j = i;

    while j <= n
        cand = s(i:j);
        found = find(strcmp(dict,cand),1);
        if ~isempty(found)
            prefixIdx = found - 1;
            j = j + 1;
        else
            break
        end
    end

    if j <= n
        nextChar = s(j);
        newEntry = s(i:j);
        dict{end+1} = newEntry;
        pairs{end+1} = struct('index',prefixIdx,'next',nextChar);
        i = j + 1;
    else
        newEntry = s(i:j-1);
        dict{end+1} = newEntry;
        pairs{end+1} = struct('index',prefixIdx,'next','');
        break
    end
end

max_index = 0;

for k = 1:length(pairs)
    max_index = max(max_index, pairs{k}.index);
end

idx_bits = max(1, ceil(log2(max_index + 1)));   % at least 1 bit
total_bits = 0;
for k = 1:length(pairs)
    total_bits = total_bits + idx_bits;      % index bits
    if ~isempty(pairs{k}.next)
        total_bits = total_bits + 8;  % literal bit
    end
end

end


%% LZW
function [codes, triplets, dictMap, basicDict] = lzw_compress_with_order(s)

s = char(s);
n = numel(s);

seen = containers.Map('KeyType','char','ValueType','double');
nextCode = 1;

for i = 1:n
    if ~isKey(seen, s(i))
        seen(s(i)) = nextCode;
        nextCode = nextCode + 1;
    end
end

basicDict = keys(seen);
dict = containers.Map('KeyType','char','ValueType','double');
dictMap = containers.Map('KeyType','char','ValueType','char');

for k = 1:length(basicDict)
    c = basicDict{k};
    dict(c) = seen(c);
    dictMap(num2str(seen(c))) = c;
end

w = s(1);
codes = [];
triplets = {};
row = 1;

for i = 2:n
    c = s(i);
    wc = [w c];
    if isKey(dict,wc)
        w = wc;
    else
        code_w = dict(w);
        codes(end+1) = code_w;
        triplets{row} = struct('code',code_w,'current',w,'next',c);
        dict(wc) = nextCode;
        dictMap(num2str(nextCode)) = wc;
        nextCode = nextCode + 1;
        w = c;
        row = row + 1;
    end
end

code_w = dict(w);
codes(end+1) = code_w;
triplets{row} = struct('code',code_w,'current',w,'next','EOF');

end
