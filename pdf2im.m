function varargout = pdf2im(d,dpi)

% Ensure this is a .pdf
if numel(d)<4 || ~contains(d(end-2:end),'pdf')
    error(['File ''',d,''' is not a PDF.']);
end

% Force this to a full path
if exist(d,'file')
    d = dir(d);
    d = [d.folder,filesep,d.name];
else
    error(['Unable to locate ''',d,''.']);
end


% Default resolution
if nargin<2
    dpi = 300;
end

%% Process
import org.apache.pdfbox.*;
import java.io.*;

document = pdmodel.PDDocument.load(File(d));
count = document.getNumberOfPages();
pdfRenderer = rendering.PDFRenderer(document);
pdfRenderer.setSubsamplingAllowed(true);

% Convert each page
for i = 1:count

    % Append page number to file name if >1 page
    if count==1
        file = d(1:end-4) + ".png";
    else
        file = d(1:end-4) + "_" + num2str(i) + ".png";
    end

    % Convert
    bim = pdfRenderer.renderImageWithDPI(i-1, dpi, rendering.ImageType.RGB);
    tools.imageio.ImageIOUtil.writeImage(bim, file, dpi);
end
document.close();