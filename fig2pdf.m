function fig2pdf(filename,h,dpi)
% Save the figure in the figure handle 'h' as a .pdf file named 'filename'
% with no whitespace padding. Use the resolution (dots-per-inch) specified
% by the numeric scalar 'dpi' (default = 300).

if nargin<3 || isempty(dpi)
    dpi = 300;
elseif ~( isnumeric(dpi) || isscalar(dpi) )
    error('Optional argument ''dpi'' must be a numeric integer specifying the image resolution in units of dots-per-inch.');
end

if nargin<2 || isempty(h)
    h = gcf;
elseif ~isfigure(h)
    error('Optional argument ''h'' must be a figure handle.');
end

if numel(filename)<4 || ~strcmp(filename(end-3:end),'.pdf')
    filename = [filename,'.pdf'];
end

%%
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'Renderer','painters','PaperUnits','Inches','PaperPositionMode','Manual',...
    'PaperPosition',[0,0,pos(3),pos(4)],...
    'PaperSize',[pos(3),pos(4)]);
print(h,filename,'-dpdf',['-r',num2str(dpi)]);