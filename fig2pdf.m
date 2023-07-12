function fig2pdf(filename,h,dpi)
% Save the figure in the figure handle 'h' as a .pdf file named 'filename'
% with no whitespace padding. Use the resolution (dots-per-inch) specified
% by the numeric scalar 'dpi' (default = 300).
if nargin<3, dpi=300; end
if nargin<2, h=gcf; end
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'Renderer','painters','PaperUnits','Inches','PaperPositionMode','Manual',...
    'PaperPosition',[0,0,pos(3),pos(4)],...
    'PaperSize',[pos(3),pos(4)]);
if ~strcmp(filename(end-3:end),'.pdf'), filename = [filename,'.pdf']; end
print(h,filename,'-dpdf',['-r',num2str(dpi)]);