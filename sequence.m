function seqs = sequence(x,len,pool)
% Return all sequences (contiguous true values) in 'x' with a minimum 
% length of 'len'. Consecutive sequences separated by less than or equal to
% 'pool' are pooled together into a single sequence (default = 0; no
% pooling). 'seqs' is an Nx3 matrix containing N sequences along the rows
% and columns specifying 
%       [sequence start index, sequence end index, sequence length].
% Indices in 'seqs' correspond to linear indices of 'x', regardless of the
% shape of 'x'.

% Leave early
if isempty(x)
    seqs = [];
    return;
end

% Default pooling argument, catch errors
if nargin<3
    pool = 0; 
elseif ~(isnumeric(pool) && isscalar(pool))
    error('Argument ''pool'' must be a numeric scalar.');
end

% Remove NaNs
x(isnan(x)) = 0;

% Try getting all the sequences from the recursive subroutine
try
    seqs = sequence_r(x(:),1,0,len);
catch ex
    if contains(ex.identifier,'StackOverflow')
        % Recursion limit exceeded; use iterative method
        seqs = sequence_i(x(:),len);
    else
        % Some other error
        rethrow(ex);
    end
end

% sequence_() returns a 0x3 if there's no sequences. Change this to []
if isempty(seqs)
    seqs = []; 
    return;
end

% Pool sequences with less than or equal to 'pool' indices between them
i=1;
while pool && i<size(seqs,1)
    d = seqs(i+1,1)-seqs(i,2)-1; % Distance between the i_th end and (i+1)_th start
    if d <= pool % Needs to be pooled
        seqs(i,:) = [seqs(i,1),seqs(i+1,2),sum(seqs(i:i+1,3))+d];
        seqs(i+1,:) = [];
    else
        i=i+1;
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subroutines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function seqs = sequence_r(x,i,n,len)
% Recursive routine
%     x - the logical vector to search through.
%     i - the current index.
%     n - the number of sequences.
%   len - minimum sequence length.

% First iterate through Boolean array 'x'
seq = 0; % Current sequence length
for k = i:length(x)
    if x(k) % Start of potential sequence
        seq = seq+1;
    end
    if ( seq && ~x(k) ) || k==length(x) % End of sequence or last element of 'x'
        if seq >= len % Valid sequence
            n = n+1; % Increment
        end
        if k==length(x) % Last element
            seqs = nan(n,3); % Create output structure
        else
            seqs = sequence_r(x,k+1,n,len); % Elements in 'x' left to search; step back in
        end
        if n % If there are any sequences
            adj = seq >= len && k==length(x); % True IF: we're at the end of 'x' and this 'k' is part of the sequence
            seqs(n,:) = [k-seq+adj,k-1+adj,seq]; % Fill in this step
        end
        return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seqs = sequence_i(x,len)
% Iterative routine
%     x - the logical vector to search through.
%   len - minimum sequence length.
n = 0; % Number of sequences
seq = 0; % Current sequence length
seqs = zeros(numel(x),3); % Excessive preallocation
for i = 1:numel(x)
    if x(i)
        if ~seq % New sequence
            n = n+1; % Increment
        end
        seq = seq+1; % Count sequence length
    elseif seq % End of running sequence
        if seq<len
            % Invalid sequence
            n = n-1; % Decrement
        else
            % Valid sequence; get start/end elements and range
            seqs(n,:) = [i-0-seq,i-1,seq];
        end
        seq = 0; % Reset counter
    end
end
seqs(n+1:end,:) = []; % Discard non-sequences