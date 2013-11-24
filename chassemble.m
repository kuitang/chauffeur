function chassemble(designPath)
% chassemble 
%    chassemble designIGN reads an experimental designign and prepares the
%    directory in which designIGN residesign for runs with chdrive.
%
% TODO: Iterative refinement (this just restarts everything)

pth = fileparts(designPath);
design = load(designPath);

% This needs to be conservative indexing.
% Idea: Build the full matrix, fill in zeros which exist, and then restart.

op = [pth '/index.mat'];
if exist(op, 'file')
    oldIndex = load(op);
    start = oldIndex.assignments(end) + 1;
else
    start = 1;
end

names = fieldnames(design);
dims  = structfun(@(v) numel(v), design);

Nparams   = length(dims);
Nsettings = prod(dims);

assignments = zeros(dims{:});
assignments(:) = start:(start - 1 + Nsettings);

% Codesign
% 0  - Not started
% 1  - Started
% 2  - Finished; validated
% -1 - Exception thrown
% -2 - Finished; not validated

status = zeros(dim{:});

for n = 1:Nruns
n = 1;
while n <= 
    % Enumerate each possible cross product.
    inds{1:nargout} = ind2sub(n, dims);
    
    % TODO:
    
    for p = 1:Nparams
        nm = names{p};
        params.(nm) = design.(nm)(inds{p});
    end
        
    d = [pth '/' num2str(n)];
    mkdir(d);
    
    save([d '/params.mat'], '-struct', params);
end

[~, host] = system('hostname');
host = strtrim(host);
tm   = now();
info = struct('writer', host, 'create_time', tm);

save([path '/index.mat'], 'info', 'assignments', 'design');

end

