function str = cell2header(header)
str = cell2str([header(:)'; cellstr(repmat('\t',numel(header),1))']);
str(end) = 'n';