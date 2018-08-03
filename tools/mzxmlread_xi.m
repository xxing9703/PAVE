function out = mzxmlread_xi(filename,varargin)
% MZXMLREAD Read an mzXML file into MATLAB as a structure.
% modification on line 466, 
%
%   OUT = MZXMLREAD(FILENAME) reads an mzXML file into MATLAB as a
%   structure. FILENAME is a string containing a file name, or a path and a
%   file name, of a mzXML file that conforms to the mzXML 2.1 specification
%   or earlier specifications. OUT is a MATLAB structure with the following
%   fields: scan, index, mzXML. The fields scan and index are placed into
%   the first level of the output structure for improved access to the
%   spectra data, the remainder of the mzXML document tree is parsed in
%   following the schema specifications. The mzXML 2.1 specification can be
%   found at:
%
%   http://sashimi.sourceforge.net/schema_revision/mzXML_2.1/Doc/mzXML_2.1_tutorial.pdf
%
%   MZXMLREAD(...,'LEVELS',LEVEL) specifies which msLevel of scans to
%   extract from the mzXML file.  LEVEL must be a positive integer or
%   vector of integers.  Default is to extract all scan levels.  
%
%   MZXMLREAD(...,'TIMERANGE', RANGE) specifies which range of time to
%   extract scans from the mzXML file.  RANGE is a two-element numeric
%   array, [START END].  START is a scalar that must fall between the
%   startTime and endTime attributes of msRun element.  END is a scalar
%   that must fall between START and the endTime attribute of msRun.  START
%   must be less then END.  Default is to extract all scans.  If
%   SCANINDICES option is used, then TIMERANGE option can not be used.
%
%   MZXMLREAD(...,'SCANINDICES',INDICES) specifies an index or a vector of 
%   indices extract scans. INDICES must contain unique positive integers   
%   less or equal that the number of scans in the file. For example, to
%   indicate a range of indices, use [START_IND:END_IND]. Default is to 
%   extract all scans.  If TIMERANGE option is used, then SCANINDICES 
%   option can not be used. 
%
%   MZXMLREAD(...,'VERBOSE',T/F) show progress of reading the mzXML file.
%   Default is true.
%
%   Example:
%
%       out = mzxmlread('results.mzxml');
%       % view the first scan in the mzXML file:
%       m = out.scan(1).peaks.mz(1:2:end);
%       z = out.scan(1).peaks.mz(2:2:end);
%       stem(m,z,'marker','none')
%
%   Note that the file results.mzxml is not provided. Sample files can be
%   found at http://sashimi.sourceforge.net/repository.html.
%
%   If you receive any errors related to memory or java heap space, try
%   increasing your java heap space as described here:
%
%       http://www.mathworks.com/support/solutions/data/1-18I2C.html
%
%   See also JCAMPREAD, MZCDF2PEAKS, MZCDFINFO, MZCDFREAD, MZXML2PEAKS,
%   MZXMLINFO, TGSPCINFO, TGSPCREAD.

% Copyright 2006-2012 The MathWorks, Inc.


scanFlag = 0;
countScan = 0;

bioinfochecknargin(nargin,1,mfilename);

if( ~ischar( filename ) )
    error(message('bioinfo:mzxmlread:invalidUsage'));
end

% Check if file exists
if ~exist(filename,'file')
     error(message('bioinfo:mzxmlread:FileNotFound', filename));
end

%Check parameter value pairs
[levels,tmrange,indices,verbose] = parse_inputs(filename,varargin{:});

tmrange = sort(tmrange);

% Grab first few lines of file to check if XML file and mzXML format
fid = fopen(filename,'rt');
str = fread(fid,120,'*char')';
fclose(fid);

% Check if XML file
if isempty(regexp(str,'<\?xml','once'))
    error(message('bioinfo:mzxmlread:missingXMLdeclaration', filename, filename));
end

% Check if mzXML format
if isempty(regexp(str,'<mzXML|<msRun','once'))
    error(message('bioinfo:mzxmlread:notValidMZXMLFile', filename));
end

%check if filename contains full path, if not get it
if isempty(regexp(filename,filesep,'once'))
    filename = which(filename);
end

mzinfo = mzxmlinfo(filename);

defaultScanStruct = struct('num',[],'msLevel',[],'peaksCount',[],...
                    'polarity',[],'scanType',[],'centroided',[],'deisotoped',[],...
                    'chargeDeconvoluted',[],'retentionTime',[],'ionisationEnergy',[],...
                    'collisionEnergy',[],'collisionGas',[],'collisionGasPressure',[],...
                    'startMz',[],'endMz',[],'lowMz',[],'highMz',[],'basePeakMz',[],...
                    'basePeakIntensity',[],'totIonCurrent',[],...
                     'scanOrigin',struct('parentFileID',[],'num',[]),...
                    'precursorMz',struct('precursorScanNum',[],'precursorIntensity',[],'precursorCharge',[],'windowWideness',[],'value',[]),...
                    'maldi',[],'peaks',struct('precision',[],'byteOrder',[],'pairOrder',[],'mz',[]),...
                    'nameValue',struct('name',[],'value',[],'type',[]),...
                    'comment',[]);  
                
out.scan = repmat(defaultScanStruct,mzinfo.NumberOfScans,1);

%Create Java StAX parser
biostax = com.mathworks.toolbox.bioinfo.util.xml.BioStAX();
errorCallback = handle(biostax.getNotifyFailedParserCallback());
handle.listener(errorCallback,'delayed',{@notifyFailedParserCallback});

parser = biostax.createStreamParser(filename);

if isempty(parser)
    error(message('bioinfo:mzxmlread:FailedParser', filename));    
end


if verbose 
    disp('Starting to parse document...')
end

while parser.hasNext()
    
    if parser.isStartElement()
        
        elementName = char(parser.getLocalName());
        switch elementName 
            case 'mzXML'
                out.mzXML.xmlns = char(parser.getNamespaceURI());
                out.mzXML.xmlns_xsi = char(parser.getAttributeNamespace(0));
                out.mzXML.xsi_schemaLocation = char(parser.getAttributeValue(0));

            case 'msRun'
                
                if verbose
                    disp('Building mzXML substructure...')
                    scanFlag = 1; 
                end
                
                if ~exist('out','var')
                    out.mzXML.xmlns = char(parser.getNamespaceURI());
                    out.mzXML.xmlns_xsi = char(parser.getAttributeNamespace(0));
                    out.mzXML.xsi_schemaLocation = char(parser.getAttributeValue(0));
                    startAttCount = 1;
                else
                    startAttCount = 0;
                end

                numAttr = parser.getAttributeCount();
                for i = startAttCount:numAttr-1
                    out.mzXML.msRun.(char(parser.getAttributeLocalName(i))) =...
                        processStr(char(parser.getAttributeValue(i)));
                end

            case 'parentFile'

                %Account for multiple parentFile elements
                if isfield(out.mzXML.msRun,elementName)
                    count = numel(out.mzXML.msRun.(elementName));
                else
                    count = 0;
                end

                numAttr = parser.getAttributeCount();
                for i = 0:numAttr-1
                    out.mzXML.msRun.(elementName)(count+1).(char(parser.getAttributeLocalName(i))) =...
                        processStr(char(parser.getAttributeValue(i)));
                end

                % Handle Elements with children elements
            case {'instrument','msInstrument','dataProcessing','spotting'}

               % elementName = char(parser.getLocalName());

                %account for multiple elements with same name
                if isfield(out.mzXML.msRun,elementName)
                    count = numel(out.mzXML.msRun.(elementName));
                else
                    count = 0;
                end

                %get instrument (ver 2.0<), dataProcessing attributes
                numAttr = parser.getAttributeCount();
                for i = 0:numAttr-1
                    out.mzXML.msRun.(elementName)(count+1).(char(parser.getAttributeLocalName(i))) =...
                        processStr(char(parser.getAttributeValue(i)));
                end

                %move to next element
                parser.nextTag();

                %Loop through instrument,msInstruments and dataProcessing child elements
                while ~parser.isEndElement() || ~parser.getLocalName().equals(elementName)
                    if parser.isStartElement()
                        childElemNm = char(parser.getLocalName());
                        switch childElemNm %char(parser.getLocalName())
                            case {'nameValue','processingOperation'}

                                %account for multiple elements with same
                                %name
                                %childElemNm = char(parser.getLocalName());
                                if isfield(out.mzXML.msRun.(elementName),childElemNm)
                                    count2 = numel(out.mzXML.msRun.(elementName).(childElemNm));
                                else
                                    count2 = 0;
                                end

                                %get attributes
                                numAttr = parser.getAttributeCount();
                                for i = 0:numAttr-1
                                    out.mzXML.msRun.(elementName)(count+1).(childElemNm)(count2+1).(char(parser.getAttributeLocalName(i))) =...
                                        processStr(char(parser.getAttributeValue(i)));
                                end

                                %get element text
                                out.mzXML.msRun.(elementName)(count+1).(childElemNm)(count2+1).value = char(parser.getElementText());


                            case 'comment'
                                out.mzXML.msRun.(elementName)(count+1).(childElemNm)(count2+1).value = char(parser.getElementText());

                                %Get spotting.plate attributes and elements.
                            case 'plate'
                               % childElemNm = char(parser.getLocalName());
                                %Track the number of plate elements
                                if isfield(out.mzXML.msRun,elementName)&& isfield(out.mzXML.msRun.(elementName),childElemNm)
                                    countPlate = numel(out.mzXML.msRun.(elementName).(childElemNm));
                                else
                                    countPlate = 0;
                                end

                                %get plate attributes
                                numAttr = parser.getAttributeCount();
                                for i = 0:numAttr-1
                                    out.mzXML.msRun.(elementName).(childElemNm)(countPlate+1).(char(parser.getAttributeLocalName(i))) =...
                                        processStr(char(parser.getAttributeValue(i)));
                                end

                                %get plate elements
                                while ~parser.isEndElement() || ~parser.getLocalName().equals(childElemNm)
                                    if parser.isStartElement()
                                        switch char(parser.getLocalName())

                                            case {'plateManufacturer','plateModel'}

                                                numAttr = parser.getAttributeCount();
                                                for i = 0:numAttr-1
                                                    out.mzXML.msRun.(elementName).(childElemNm)(countPlate+1).(char(parser.getLocalName())).(char(parser.getAttributeLocalName(i))) =...
                                                        processStr(char(parser.getAttributeValue(i)));
                                                end

                                            case {'spottingPattern','orientation'}
                                                numAttr = parser.getAttributeCount();
                                                for i = 0:numAttr-1
                                                    out.mzXML.msRun.(elementName).(childElemNm)(countPlate+1).pattern.(char(parser.getLocalName())).(char(parser.getAttributeLocalName(i))) =...
                                                        processStr(char(parser.getAttributeValue(i)));
                                                end

                                            case 'spot'
                                                % Track the number or spot
                                                % elements
                                                spotElem = 'spot';%char(parser.getLocalName());
                                                if isfield(out.mzXML.msRun.(elementName).(childElemNm)(countPlate+1),spotElem)
                                                    countSpot = numel(out.mzXML.msRun.(elementName).(childElemNm)(countPlate+1).(spotElem));
                                                else
                                                    countSpot = 0;
                                                end
                                                
                                                numAttr = parser.getAttributeCount();
                                                for i = 0:numAttr-1
                                                    out.mzXML.msRun.(elementName).(childElemNm)(countPlate+1).(spotElem)(countSpot+1).(char(parser.getAttributeLocalName(i))) =...
                                                        processStr(char(parser.getAttributeValue(i)));
                                                end


                                            case 'maldiMatrix'
                                                %Get spot element
                                                %maldiMatrix
                                                numAttr = parser.getAttributeCount();
                                                for i = 0:numAttr-1
                                                    out.mzXML.msRun.(elementName).(childElemNm)(countPlate+1).(spotElem)(countSpot+1).(char(parser.getLocalName())).(char(parser.getAttributeLocalName(i))) =...
                                                        processStr(char(parser.getAttributeValue(i)));
                                                end

                                        end

                                    end
                                    parser.nextTag();
                                end

                                %Get spotting.robot Attributes
                            case 'robot'

                                numAttr = parser.getAttributeCount();
                                for i = 0:numAttr-1
                                    out.mzXML.msRun.(elementName).(childElemNm).(char(parser.getAttributeLocalName(i))) =...
                                        processStr(char(parser.getAttributeValue(i)));
                                end

                                %Get spotting.robot elements
                            case {'robotManufacturer','robotModel'}
                                %get robotManufacturer and
                                %robotModel attributes
                                numAttr = parser.getAttributeCount();
                                for i = 0:numAttr-1
                                    out.mzXML.msRun.(elementName).robot.(childElemNm).(char(parser.getAttributeLocalName(i))) =...
                                        processStr(char(parser.getAttributeValue(i)));
                                end

                            otherwise
                                numAttr = parser.getAttributeCount();
                                for i = 0:numAttr-1
                                    out.mzXML.msRun.(elementName)(count+1).(childElemNm).(char(parser.getAttributeLocalName(i))) =...
                                        processStr(char(parser.getAttributeValue(i)));
                                end
                        end
                    end
                    parser.nextTag();
                end


            case 'separation'
               
                parser.nextTag();
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % This is specifically designed for a column_separation
                % Schema.  This schema can be  found at
                % http://sashimi.sourceforge.net/schema_revision/mzXML_2.1/
                % separations/column_1.0/column_separation_1.0.xsd
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %Loop through separation elements
                while ~parser.isEndElement() || ~parser.getLocalName().equals('separation')
                    if parser.isStartElement() %separation

                        while ~parser.isEndElement() || ~parser.getLocalName().equals('column')
                            if parser.isStartElement() %column
                                childElemNm = char(parser.getLocalName());
                                switch childElemNm %char(parser.getLocalName())
                                    case 'column'
    
                                        %account for multiple elements with same name
                                        if isfield(out.mzXML.msRun,elementName) && isfield(out.mzXML.msRun.(elementName),childElemNm)
                                            countCol = numel(out.mzXML.msRun.(elementName).(childElemNm));
                                        else
                                            countCol = 0;
                                        end

                                    case 'event'
                                        %account for multiple elements with same name
                                        if isfield(out.mzXML.msRun,elementName) && ...
                                                isfield(out.mzXML.msRun.(elementName),'column') && ...
                                                numel(out.mzXML.msRun.(elementName).column)>countCol && ...
                                                isfield(out.mzXML.msRun.(elementName).column(countCol+1),'event')

                                            countEvent = numel(out.mzXML.msRun.(elementName).column(countCol+1).event);
                                        else
                                            countEvent = 0;
                                        end
                                    otherwise
                                        %get attributes
                                        numAttr = parser.getAttributeCount();
                                        for i = 0:numAttr-1
                                            out.mzXML.msRun.(elementName).column(countCol+1).event(countEvent+1).(char(parser.getLocalName())).(char(parser.getAttributeLocalName(i))) =...
                                                processStr(char(parser.getAttributeValue(i)));
                                        end

                                        %get element text
                                        out.mzXML.msRun.(elementName).column(countCol+1).event(countEvent+1).(char(parser.getLocalName())).value = ...
                                            processStr(char(parser.getElementText()));
                                end % COLUMN switch case
                            end
                            parser.nextTag();
                        end %end for COLUMN while loop
                    end
                    parser.nextTag();
                end %end for SEPARATION while loop

            case 'scan'
                
                if scanFlag
                    disp('Building scan substructure...'); 
                    scanFlag =0; 
                end
                
				% switch away from axis1
                % b64 = org.apache.axis.encoding.Base64( );
				b64 = org.apache.commons.codec.binary.Base64( );
				
                
                if any(levels > 0) && any(processStr(char(parser.getAttributeValue([],'msLevel'))) == levels)   
                    if any(tmrange(1)>0) && (sscanf(char(parser.getAttributeValue([],'retentionTime')),'PT%f') >= tmrange(1)) && ...
                       (sscanf(char(parser.getAttributeValue([],'retentionTime')),'PT%f') <= tmrange(2))                   
                        parseScan;
                    elseif any(indices>0) && any(processStr(char(parser.getAttributeValue([],'num'))) == indices)
                        parseScan;
                    elseif any(tmrange==0) && any(indices==0)
                        parseScan;
                    end
                elseif any(levels==0) && any(tmrange(1)>0) && ...
                       (sscanf(char(parser.getAttributeValue([],'retentionTime')),'PT%f') >= tmrange(1)) && ...
                       (sscanf(char(parser.getAttributeValue([],'retentionTime')),'PT%f') <= tmrange(2))
                    
                   parseScan;
                   
                elseif any(levels==0) && any(indices>0) && any(processStr(char(parser.getAttributeValue([],'num'))) == indices)
                     
                    parseScan;
                elseif any(levels==0) && any(tmrange==0) && any(indices==0) 
                     
                    parseScan;
                end
                
                countScan = countScan+1;

            case 'index'
                
                if verbose
                    disp('Building index substructure...');
                end
                
                out.(elementName).(char(parser.getAttributeLocalName(0))) =...
                        processStr(char(parser.getAttributeValue(0)));
               

                parser.nextTag();
                countOffset = 0;
                while ~parser.isEndElement() || ~parser.getLocalName().equals('index')

                    if parser.isStartElement() && parser.getLocalName().equals('offset')
                        countOffset = countOffset+1;
                        
                        out.(elementName).offset(countOffset).(char(parser.getAttributeLocalName(0))) =...
                                processStr(char(parser.getAttributeValue(0)));
                        

                        out.(elementName).offset(countOffset).value = processStr(char(parser.getElementText()));
                    end

                    parser.nextTag();
                end

            case 'indexOffset'
                out.mzXML.(elementName) = processStr(char(parser.getElementText()));
            case 'sha1'
                if verbose
                    disp('DONE!');
                end
                out.mzXML.(elementName) = char(parser.getElementText());
        end %end for MAIN SWITCH
    end
     parser.next();

end %end for MAIN WHILE LOOP
%remove empty structures from scan struct array
%out.scan = out.scan([out.scan.num]); 

parser.close();


%----------------------------------------------------------------------
%   parseScan is used to recursively parse the scan element in mzXML files.
%   The scan element can have scan elements.
%----------------------------------------------------------------------
%function out = parseScan(parser,out,b64,countScan,varargin)
function parseScan
elementNameScan = char(parser.getLocalName());

numAttr = parser.getAttributeCount();
for iScan = 0:numAttr-1
    attName = char(parser.getAttributeLocalName(iScan)); 
    out.scan(countScan+1).(attName) =...
        processStr(char(parser.getAttributeValue(iScan)));
end

parser.nextTag();

while ~parser.isEndElement() || ~parser.getLocalName().equals('scan')
    if parser.isStartElement() %scan
        childElemNmScan = char(parser.getLocalName());
        switch childElemNmScan 
            case 'scanOrigin'                                 
                countSO = numel([out.(elementNameScan)(count+1).(childElemNmScan).num]);    
                numAttr = parser.getAttributeCount();
                for iScan = 0:numAttr-1
                    out.(elementNameScan)(count+1).(childElemNmScan)(countSO+1).(char(parser.getAttributeLocalName(iScan))) =...
                        processStr(char(parser.getAttributeValue(iScan)));
                end

                out.(elementNameScan)(countScan+1).(childElemNmScan)(countSO+1).value = processStr(char(parser.getElementText()));

            case 'precursorMz'              
                countPM = numel([out.(elementNameScan)(countScan+1).(childElemNmScan).value]);
                numAttr = parser.getAttributeCount();
                for iScan = 0:numAttr-1
                    out.(elementNameScan)(countScan+1).(childElemNmScan)(countPM+1).(char(parser.getAttributeLocalName(iScan))) =...
                        processStr(char(parser.getAttributeValue(iScan)));
                end

                out.(elementNameScan)(countScan+1).(childElemNmScan)(countPM+1).value = processStr(char(parser.getElementText()));

            case 'maldi'
                numAttr = parser.getAttributeCount();
                for iScani = 0:numAttr-1
                    out.(elementNameScan)(countScan+1).maldi.(char(parser.getAttributeLocalName(iScan))) =...
                        processStr(char(parser.getAttributeValue(iScan)));
                end

                out.(elementNameScan)(countScan+1).maldi.value = processStr(char(parser.getElementText()));

            case {'nameValue'}
                %account for multiple elements with same
                %name           
                countNV = numel([out.(elementNameScan)(countScan+1).(childElemNmScan).name]);
                %get attributes
                numAttr = parser.getAttributeCount();
                for iScan = 0:numAttr-1
                    out.(elementNameScan)(countScan+1).(childElemNmScan)(countNV+1).(char(parser.getAttributeLocalName(iScan))) =...
                        processStr(char(parser.getAttributeValue(iScan)));
                end

                %get element text
                out.(elementNameScan)(countScan+1).(childElemNmScan)(countNV+1).value = char(parser.getElementText());


            case 'comment'
                out.(elementNameScan)(countScan+1).(char(parser.getLocalName()))(countNV+1) = char(parser.getElementText());

            case 'peaks'
                numAttr = parser.getAttributeCount();
                for iScan = 0:numAttr-1
                    out.(elementNameScan)(countScan+1).peaks.(char(parser.getAttributeLocalName(iScan))) =...
                        processStr(char(parser.getAttributeValue(iScan)));
                end

                data = parser.getElementText().getBytes();
                if ~isempty(data)
                    switch out.scan(countScan+1).peaks.precision
                        case 32
                            % switch away from axis1
                            % out.(elementNameScan)(countScan+1).peaks.mz = processPeaks(b64.decode(char(parser.getElementText())),32);
                            out.(elementNameScan)(countScan+1).peaks.mz = processPeaks(b64.decode(data),32);
                        case 64
                            % switch away from axis1
                            % out.(elementNameScan)(countScan+1).peaks.mz = processPeaks(b64.decode(char(parser.getElementText())),64);
                            out.(elementNameScan)(countScan+1).peaks.mz = processPeaks(b64.decode(data),64);
                        otherwise
                            warning(message('bioinfo:mzxmlread:invalidPrecis', out.scan( countScan + 1 ).peaks.precision));
                            % switch away from axis1
                            % out.(elementNameScan)(countScan+1).peaks.mz = processPeaks(b64.decode(char(parser.getElementText())),32);
                            out.(elementNameScan)(countScan+1).peaks.mz = processPeaks(b64.decode(data),32);
                    end
                end

            case 'scan'
               
                 countScan = countScan+1;
                if any(levels > 0) && any(processStr(char(parser.getAttributeValue([],'msLevel'))) == levels)
                    if any(tmrange(1)>0) && (sscanf(char(parser.getAttributeValue([],'retentionTime')),'PT%f') >= tmrange(1)) && ...
                       (sscanf(char(parser.getAttributeValue([],'retentionTime')),'PT%f') <= tmrange(2))                   
                        parseScan;
                    elseif any(indices>0) && any(processStr(char(parser.getAttributeValue([],'num'))) == indices)
                        parseScan;
                    elseif any(tmrange==0) && any(indices==0)
                        parseScan;
                    end
                   
                elseif any(levels==0) && any(tmrange>0) && ...
                       (sscanf(char(parser.getAttributeValue([],'retentionTime')),'PT%f') >= tmrange(1)) && ...
                       (sscanf(char(parser.getAttributeValue([],'retentionTime')),'PT%f') <= tmrange(2))
                    
                   parseScan;
                   
                elseif any(levels==0) && any(indices>0) && any(processStr(char(parser.getAttributeValue([],'num'))) == indices)
                     
                    parseScan;
                elseif any(levels==0) && any(tmrange==0) && any(indices==0) 
                     
                    parseScan;
                end
        end %switch

    end %if
    parser.nextTag();
end %while
end




end  % END OF NESTED AND MAIN FUNCTIONS


%----------------------------------------------------------------------
%  parse_inputs parses and checks parameter value pairs
%----------------------------------------------------------------------

function [levels,tmrange,indices,verbose] = parse_inputs(fname,varargin)
% Parse the varargin parameter/value inputs

% Check that we have the right number of inputs
if rem(nargin-1,2)== 1
    error(message('bioinfo:mzxmlread:IncorrectNumberOfArguments', mfilename));
end

mzinfo = mzxmlinfo(fname);

% The allowed inputs
okargs = {'levels','timerange','scanindices','verbose'};

% Set default values
levels = 0;
tmrange = [0 0];
indices = [0 0];
verbose = true;

% Loop over the values
for j=1:2:nargin-1
    % Lookup the pair
    [k, pval] = bioinfoprivate.pvpair(varargin{j}, varargin{j+1}, okargs, mfilename);
    switch(k)
        case 1  % levels
            if ~isnumeric(pval) || ~isvector(pval) ||any(pval<0)
                error(message('bioinfo:mzxmlread:LevelsNonNumeric'))
                               
            end
            levels = pval;
        case 2  % timerange
            if ~isnumeric(pval) || ~isvector(pval) || any(pval<0)||numel(pval)<2||numel(pval)>2
                error(message('bioinfo:mzxmlread:TimeRangeNonNumeric'))
            elseif any(indices>0) 
                error(message('bioinfo:mzxmlread:ConflictingPVPairsLevelsOrIndices'))
            
            elseif ~strcmp(mzinfo.StartTime,'N/A') && ~strcmp(mzinfo.EndTime,'N/A')
                startTm = sscanf(mzinfo.StartTime,'PT%f');
                endTm = sscanf(mzinfo.EndTime,'PT%f');
                
                if pval(1)<startTm || pval(2)>endTm
                    error(message('bioinfo:mzxmlread:InvalidTimeRange', num2str(startTm), num2str(endTm)));                    
                end
            end
            tmrange = pval;                

        case 3  % scanindices
            if ~isnumeric(pval) || ~isvector(pval) || any(pval<=0) 
                error(message('bioinfo:mzxmlread:IndicesNonNumeric'))
            elseif  any(tmrange>0) 
                error(message('bioinfo:mzxmlread:ConflictingPVPairsLevelsOrTimeRange'))
            elseif ~strcmp(mzinfo.NumberOfScans,'N/A')                                  
               if any(pval>mzinfo.NumberOfScans)
                    error(message('bioinfo:mzxmlread:InvalidScanIndices', 1, mzinfo.NumberOfScans));                    
               end
            
            end
                indices = pval;                
            
        case 4 %verbose
            verbose = bioinfoprivate.opttf(pval,okargs{k},mfilename);
    end

end
end %parse_inputs

%----------------------------------------------------------------------
%  processStr checks that the limits of the token matches the
%  string's length to determine if it is really numeric
%----------------------------------------------------------------------
function a_out = processStr(a)
[a_out,ct,err,n] = sscanf(a,'%f',1);
if ~isempty(err) || n<numel(a)
    a_out = a;
end
end %processStr

%----------------------------------------------------------------------
%  processPeaks process the mz peak information according to 32 or 64 bit
%  precision
%----------------------------------------------------------------------

function mzpeaks = processPeaks(peaks,precision)
% top level shared variables/objects

[comp,maxsize,endian]=computer;

switch endian
    case 'L'
        if precision == 32
            mzpeaks = swapbytes(typecast(peaks,'single'));
        else
            mzpeaks = swapbytes(typecast(peaks,'double'));
        end
    otherwise
        if precision == 32
            mzpeaks = typecast(peaks,'single');
        else
            mzpeaks = typecast(peaks,'double');
        end
end
end %processPeaks

%-----------------------------------------------------------
% Error message callbacks
%-----------------------------------------------------------
function notifyFailedParserCallback(hsrc,hevt)%#ok

     fileFailed.loaded = hevt.JavaEvent.loaded;
     fileFailed.errormsg = hevt.JavaEvent.errormsg;
     fileFailed.filename = hevt.JavaEvent.filename;
   
end

