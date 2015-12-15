function CT_Processing
    figObject = createMainFigure();
    
    %Create Navigation Axes
    navigationAxesObjects = createNavigationAxes(figObject);
    
    %Create Information Texts
    informationTextsObjects = createInformationTexts(navigationAxesObjects.informationAxesObject);
    
    %Create Menus
    createMenuObjects(figObject);
    

    createControlSideBar(figObject);
    handles.gui = guihandles(figObject);  
    guidata(figObject, handles);
end


%%%%%%%%%%%% GUI RELATED FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figObject = createMainFigure()
    %Get the screen size
    screenSize = get(0, 'ScreenSize');
    figObject = figure('Tag', 'mainFig',...
        'MenuBar', 'None',...
        'NumberTitle', 'Off',...
        'Name', 'New CT Processing V 0.0.1dev',...
        'Position', screenSize,...
        'Color', 'black',...
        'WindowScrollWheelFcn', @refreshSlicePosition,...
        'WindowButtonMotionFcn', @mouseMove);  

end

function navigationAxesObjectStructure = createNavigationAxes(parentFigureObject)

    navigationAxesObjectStructure.navigationAxesObject = axes('Parent', parentFigureObject,...
      'Units', 'Normalized',...
      'Position', [0.16, 0.15, 0.6, 0.8],...
      'Color', 'black',...
      'XtickLabel', '',...
      'YtickLabel', '',...
      'Tag', 'navigationAxes');

  navigationAxesObjectStructure.informationAxesObject = axes('Parent', parentFigureObject,...
      'Units', 'Normalized',...
      'Position', [0.11, 0.08, 0.7, 0.9],...
      'XtickLabel', '',...
      'YtickLabel', '',...
      'Color', 'black');
  

end

function informationTextsObjectsStructure = createInformationTexts(parentAxesObject)

    informationTextsObjectsStructure.patientName = text(0.5, 0.98, 'Patient''s Name',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold',...
        'Tag', 'patientNameTag',...
        'HorizontalAlignment', 'center',...
        'Visible', 'Off');
    
    informationTextsObjectsStructure.slicePosition = text(0.01, 0.02, '1/-',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold',...
        'Visible', 'Off',...
        'Tag', 'slicePositionTag');
    
    informationTextsObjectsStructure.numberOfRows = text(0.01, 0.06, 'Image Size: -',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold',...
        'Visible', 'Off',...
        'Tag', 'numberOfRowsTag');     


    informationTextsObjectsStructure.pixelValue = text(0.14, 0.02, 'Pixel Value = -',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold',...
        'Visible', 'Off',...
        'Tag', 'pixelValueTag');
end

function createMenuObjects(parentFigureObject)
    %Create Menu Objects
    
    
    %%%FILE MENU
    fileMenu = uimenu('Parent', parentFigureObject,...
        'Label', 'File');
    openGroup = uimenu('Parent', fileMenu, 'Label', 'Open');
    %Load Frame Menu
    uimenu('Parent', openGroup,...
        'Label', 'Open Frame',...
        'Acc', 'O',...
        'Callback', @openDicom);
    %Load Masks Menu
    uimenu('Parent', openGroup,...
        'Label', 'Open Masks',...
        'Acc', 'M',...
        'Enable', 'Off',...
        'Tag', 'openMaskMenu',...
        'Callback', @openMask);    
    %Quit Menu
    uimenu('Parent', fileMenu,...
        'Label', 'Quit',...        
        'Callback', '');
    
    %%%ANALYSIS MENU
    analysisMenu = uimenu('Parent', parentFigureObject,...
        'Label', 'Analysis');
    
    uimenu('Parent', analysisMenu,...
        'Label', 'Mass and Volume',...
        'Callback', @massAndVolumeCalculation,...
        'Enable', 'Off',...
        'Tag', 'massAndVolumeCalculation')
    
end

function createControlSideBar(parentFigureObject)
    mainPanel = uipanel('Parent', parentFigureObject,...
        'Units', 'Normalized',...
        'Position', [0.8, 0, 0.2, 1],...'
        'BackGroundColor', 'black',...
        'Visible', 'Off',...
        'Tag', 'sideBarMainPanel');
    
     uicontrol('Parent', mainPanel,...
        'Style', 'Slider',...
        'Units', 'Normalized',...
        'Position', [0.1, 0.45, 0.1, 0.2],...
        'Tag', 'windowWidthSlider',...
        'Callback', @windowWidthCallback);
    
    uicontrol('Parent', mainPanel,...
        'Style', 'Slider',...
        'Units', 'Normalized',...
        'Position', [0.35, 0.45, 0.1, 0.2],...
        'Tag', 'windowCenterSlider',...
        'Callback', @windowCenterCallback);
    
     uicontrol('Parent',mainPanel,...
        'Style', 'Text',...
        'Units', 'Normalized',...
        'Position', [0.12, 0.67, 0.11, 0.02],...
        'HorizontalAlignment', 'Center',...        
        'String', '0',...
        'BackGroundColor', 'black',...
        'ForeGroundColor', 'white',...
        'Tag', 'windowWidthText');
    
     uicontrol('Parent',mainPanel,...
        'Style', 'Text',...
        'Units', 'Normalized',...
        'Position', [0.37, 0.67, 0.11, 0.02],...
        'HorizontalAlignment', 'Center',...
        'String', '0',...
        'BackGroundColor', 'black',...
        'ForeGroundColor', 'white',...
        'Tag', 'windowCenterText');
    
    uicontrol('Parent', mainPanel,...
        'Units', 'Normalized',...
        'Position', [0.48, 0.45, 0.28, 0.06],...
        'String', 'Reset',...
        'Callback', @resetWindowWidthCenter);
end

%%%%%%%%%%%% GUI RELATED FUNCTIONS  - END %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function handles = displayCurrentDicom(handles, dicomImage, slicePosition)
    axes(handles.gui.navigationAxes)
    handles.gui.imagePlot = imagesc(dicomImage(:, :, slicePosition));
    set(handles.gui.navigationAxes, 'Clim', [handles.data.displayLow, handles.data.displayHigh]);
    colormap(gray)
end

function refreshPatientsInfo(handles, info)
   patientName = info.PatientName.FamilyName;
   %Check if Patient has Give Name
   if isfield(info.PatientName, 'GivenName')
       patientName = [info.PatientName.GivenName ' ' patientName];
   end
   set(handles.gui.patientNameTag, 'String', patientName)
   set(handles.gui.numberOfRowsTag, 'String', sprintf('Image Size: %d x %d', info.Rows, info.Columns));
   end

function refreshSlicePosition(hObject, eventdata)

   
slicePositionPlaceHolder = '%d/%d';

handles = guidata(hObject);

if isfield(handles, 'data')
    
    nSlices = size(handles.data.dicomImage, 3);
    
    currentSlicePosition = get(handles.gui.slicePositionTag, 'String');
    
    %Get the new slice position based on the displayed values using regexp
    newSlicePosition = getSlicePosition(currentSlicePosition,...
        eventdata.VerticalScrollCount);
    
    %Make sure that the slice number return to 1 if it is bigger than the
    %number of slices
    newSlicePosition = mod(newSlicePosition, nSlices);
    
    %Make sure that the slice number return to nSlices if it is smaller than the
    %number of slices
    if ~newSlicePosition && eventdata.VerticalScrollCount < 0
        newSlicePosition = nSlices;
    elseif ~newSlicePosition && eventdata.VerticalScrollCount > 0
        newSlicePosition = 1;
    end
    
    %Refresh slice position information.
    set(handles.gui.slicePositionTag, 'String',...
        sprintf(slicePositionPlaceHolder, newSlicePosition, nSlices));
    handles = displayCurrentDicom(handles, handles.data.dicomImage, newSlicePosition);
    
    %Refresh pixel value information.
    refreshPixelPositionInfo(handles, handles.gui.navigationAxes)
    
    guidata(hObject, handles)
end
end

function newSlicePosition = getSlicePosition(slicePositionString, direction)
    tempSlicePosition = regexp(slicePositionString, '/', 'split');
    
    if direction > 0  
        newSlicePosition = str2double(tempSlicePosition(1)) + 1;
    else
        newSlicePosition = str2double(tempSlicePosition(1)) - 1;
    end
end


function openDicom(hObject, eventdata)
    dirPath = uigetdir('Select Patient''s Folder');
    
    if dirPath
        handles = guidata(hObject);
        set(handles.gui.mainFig,'Pointer','watch'); drawnow('expose');
        listOfFiles = dir(dirPath);
        
        %Try to open every file with dicomread. If possible use as a Dicom
        nFiles = length(listOfFiles);
        
        found = false;
        counter = 0;
        
        %Create a function to insert this piece of code.
        while ~found
            counter =  counter + 1;
            fileName = listOfFiles(counter).name;
            if ~strcmp(fileName, '.') && ~strcmp(fileName, '..')
                completeFileName = [dirPath filesep fileName];
                %Try to discover if files without extension are Dicom files
                try
                    handles.data.metadata = dicominfo(completeFileName);
                    info = dicom_read_header(completeFileName);
                    
                    found = true;
                catch
                    %Do nothing
                    continue
                end
                
            end
        end
        
        dicomImage = int16(dicom_read_volume(info));
        
        if isfield(info, 'RescaleSlope')
            dicomImage = dicomImage * info.RescaleSlope;
        end
        
        if isfield(info, 'RescaleIntercept')
            dicomImage = dicomImage + info.RescaleIntercept;
        end
        
        set(handles.gui.mainFig,'Pointer','arrow'); drawnow('expose');
        
                
        handles.data.dicomImage = dicomImage;
        
        %Set the Window Width and Window Center
        [handles.data.displayLow, handles.data.displayHigh] =...
            calculateWindowWidthAndCenter(handles);
        
        configureSliders(handles)
        
        %Display First Slice
        handles = displayCurrentDicom(handles, dicomImage, 1);
        
        %Display Patients Information
        refreshPatientsInfo(handles, info)
        
        %Update Interface Appearene
        hideShowImageInformation(handles, 'On')
        hideShowSideBar(handles, 'On')
        set(handles.gui.openMaskMenu, 'Enable', 'On')        

        set(handles.gui.navigationAxes, 'Clim',...
            [handles.data.displayLow, handles.data.displayHigh])
        
        guidata(hObject, handles)
    end
end

function openMask(hObject, eventdata)
[FileName PathName] = uigetfile('*.hdr', 'Select the file containing the masks');

if FileName
    handles = guidata(hObject);
    fileName = [PathName FileName];
    masks = analyze75read(fileName);
    handles.data.masks = masks;
    guidata(hObject, handles)
    
    
    %UPDATE MENU
    set(handles.gui.massAndVolumeCalculation, 'Enable', 'On')
    
end

end

function mouseMove(hObject, eventdata)
    handles = guidata(hObject);
    mainAxes = handles.gui.navigationAxes;
    refreshPixelPositionInfo(handles, mainAxes);    
end

function refreshPixelPositionInfo(handles, mainAxes)

if isfield(handles, 'data')
    C = get(mainAxes,'currentpoint');
    
    xlim = get(mainAxes,'xlim');
    ylim = get(mainAxes,'ylim');
    
    row = round(C(1));
    col = round(C(1, 2));
    
    
    
    %Check if pointer is inside Navigation Axes.
    outX = ~any(diff([xlim(1) C(1,1) xlim(2)])<0);
    outY = ~any(diff([ylim(1) C(1,2) ylim(2)])<0);
    if outX && outY
        %Get the current Slice
        currentSlicePositionString = get(handles.gui.slicePositionTag, 'String');
        tempSlicePosition = regexp(currentSlicePositionString, '/', 'split');
        slicePosition = str2double(tempSlicePosition(1));
        
        currentSlice = handles.data.dicomImage(:, :, slicePosition);
        
        pixelValue = currentSlice(col, row);
        
        set(handles.gui.pixelValueTag, 'String', sprintf('Pixel Value = %.2f', double(pixelValue)))
    else
        set(handles.gui.pixelValueTag, 'String', sprintf('Pixel Value = -'))
    end
    
end
end

function windowWidthCallback(hObject, eventdata)
    handles = guidata(hObject);
    windowWidth = get(handles.gui.windowWidthSlider, 'Value');
    windowCenter = get(handles.gui.windowCenterSlider, 'Value');
    
    set(handles.gui.windowWidthText, 'String',sprintf('%.2f', windowWidth));
    [displayLow, displayHigh] = calculateWindowWidthAndCenter(handles,...
        windowWidth, windowCenter);
    
    set(handles.gui.navigationAxes, 'Clim', [displayLow displayHigh])
    
    handles.data.displayLow = displayLow;
    handles.data.displayHigh = displayHigh;
    
    guidata(hObject, handles);

end

function windowCenterCallback(hObject, eventdata)
    handles = guidata(hObject);
    windowWidth = get(handles.gui.windowWidthSlider, 'Value');
    windowCenter = get(handles.gui.windowCenterSlider, 'Value');
    set(handles.gui.windowCenterText, 'String',sprintf('%.2f', windowCenter));
    
    [displayLow, displayHigh] = calculateWindowWidthAndCenter(handles,...
        windowWidth, windowCenter);
    
    set(handles.gui.navigationAxes, 'Clim', [displayLow displayHigh])
    
    handles.data.displayLow = displayLow;
    handles.data.displayHigh = displayHigh;
    
    guidata(hObject, handles);

end

function resetWindowWidthCenter(hObject, eventdata)
    handles = guidata(hObject);
    
    windowWidth = handles.data.metadata.WindowWidth(1);
    windowCenter = handles.data.metadata.WindowCenter(1);
    
    [handles.data.displayLow, handles.data.displayHigh] =...
        calculateWindowWidthAndCenter(handles, windowWidth, windowCenter);
    set(handles.gui.navigationAxes, 'Clim', ...
        [handles.data.displayLow, handles.data.displayHigh]);
    set(handles.gui.windowWidthSlider, 'Value', windowWidth);
    set(handles.gui.windowCenterSlider, 'Value', windowCenter);
    guidata(hObject, handles)
    
end

function hideShowSideBar(handles, hideOrShow)
    set(handles.gui.sideBarMainPanel, 'Visible', hideOrShow)
end

function hideShowImageInformation(handles, hideOrShow)
    set(handles.gui.patientNameTag, 'Visible', hideOrShow)
    set(handles.gui.slicePositionTag, 'Visible', hideOrShow)
    set(handles.gui.numberOfRowsTag, 'Visible', hideOrShow)
    set(handles.gui.pixelValueTag, 'Visible', hideOrShow)
end

%%%%%%%%%%%%% ANALYSIS CALLBACKS %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function massAndVolumeCalculation(hObject, eventdata)
    handles = guidata(hObject);
    
    lung = handles.data.dicomImage;
    masks = handles.data.masks;
    metadata = handles.data.metadata;
    
    %Default HU values - will be able to be changed in the future.
    hyperRange = [-1000 -900];
    normallyRange = [-900 -500];
    poorlyRange = [-500 -100];
    nonRange = [-100 100];
    
    
    %Calculates the Volume.
    volumeCalculation(lung, masks, metadata, hyperRange, normallyRange,...
    poorlyRange, nonRange)
    
    
    
end

function volumeCalculation(lung, masks, metadata, hyperRange, normallyRange,...
    poorlyRange, nonRange)
 
    voxelVolume = calculateVoxelVolume(metadata);
    
    if ~isnan(voxelVolume)
        hyperVolume = length(lung(lung >= hyperRange(1) &...
            lung < hyperRange(2))) * voxelVolume;
        
        normallyVolume = length(lung(lung >= normallyRange(1) &...
            lung < normallyRange(2))) * voxelVolume;
        
        poorlyVolume = length(lung(lung >= poorlyRange(1) &...
            lung < poorlyRange(2))) * voxelVolume;
        
        nonVolume = length(lung(lung >= nonRange(1) &...
            lung < nonRange(2))) * voxelVolume;
        
        totalLungVolume = hyperVolume + normallyVolume + poorlyVolume + ...
            nonVolume;
    end


end

function voxelVolume = calculateVoxelVolume(metadata)
    
    voxelVolume = NaN;
    
    if isfield(metadata,'SpacingBetweenSlices');
        if isfield(metadata,'SliceThickness')
            voxelVolume = (metadata.PixelSpacing(1) ^ 2 * metadata.SliceThickness * 0.001) *...
                (metadata.SpacingBetweenSlices / metadata.SliceThickness);
        else
            voxelVolume = (metadata.PixelSpacing(1) ^ 2 *...
                metadata.SliceThickness * 0.001);
        end
    end
    
end










%%%%%%%%% External Functions %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function voxelvolume = dicom_read_volume(info)
% function for reading volume of Dicom files
%
% volume = dicom_read_volume(file-header)
%
% examples:
% 1: info = dicom_read_header()
%    V = dicom_read_volume(info);
%    imshow(squeeze(V(:,:,round(end/2))),[]);
%
% 2: V = dicom_read_volume('volume.dcm');

voxelvolume=dicomread(info.Filenames{1});
nf=length(info.Filenames);
if(nf>1)
    % Initialize voxelvolume
    voxelvolume=zeros(info.Dimensions,class(voxelvolume));
    % Convert dicom images to voxel volume
    h = waitbar(0,'Please wait...');
    for i=1:nf,
        waitbar(i/nf,h)
        I=dicomread(info.Filenames{i});
        if((size(I,3)*size(I,4))>1)
            voxelvolume=I; break;
        else
            voxelvolume(:,:,i)=I;
        end
    end
    close(h);
end

end

function [displayLow, displayHigh] = calculateWindowWidthAndCenter(handles,...
    windowWidth, windowCenter)

if nargin == 1
    %Get the Window Width and Window Center Information
    windowWidth = handles.data.metadata.WindowWidth(1);
    windowCenter = handles.data.metadata.WindowCenter(1);
end

%Calculate the Window Width and Information parameters
displayLow = max(windowCenter - 0.5 * windowWidth,...
    min(double(handles.data.dicomImage(:))));

displayHigh = max(windowCenter + 0.5 * windowWidth,...
    min(double(handles.data.dicomImage(:))));
end

function configureSliders(handles)
dicomImage = handles.data.dicomImage;

windowWidth = handles.data.metadata.WindowWidth(1);
windowCenter = handles.data.metadata.WindowCenter(1);

%Width Configuration
ctRange = double(max(dicomImage(:)) - min(dicomImage(:)));
set(handles.gui.windowWidthSlider, 'Max', ctRange);
set(handles.gui.windowWidthSlider, 'Min', 1);
set(handles.gui.windowWidthSlider, 'Value', windowWidth);
set(handles.gui.windowWidthSlider, 'sliderstep', [1 1] / ctRange);

%Center Configuration
set(handles.gui.windowCenterSlider, 'Max', max(dicomImage(:)));
set(handles.gui.windowCenterSlider, 'Min', min(dicomImage(:)));
set(handles.gui.windowCenterSlider, 'Value', windowCenter);
set(handles.gui.windowCenterSlider, 'sliderstep', [1 1] / ctRange);
end


function info=dicom_read_header(filename)
% function for reading header of Dicom volume file
%
% info = dicom_read_header(filename);
%
% examples:
% 1,  info=dicom_read_header()
% 2,  info=dicom_read_header('volume.dcm');

% Check if function is called with folder name

% Read directory for Dicom File Series
datasets=dicom_folder_info(filename,false);
if(isempty(datasets))
    datasets=dicom_folder_info(filename,true);
end

if(length(datasets)>1)
    c=cell(1,length(datasets));
    for i=1:length(datasets)
        c{i}=datasets(i).Filenames{1};
    end
    id=choose_from_list(c,'Select a Dicom Dataset');
    datasets=datasets(id);
end

info=datasets.DicomInfo;
info.Filenames=datasets.Filenames;
info.PixelDimensions=datasets.Scales;
info.Dimensions=datasets.Sizes;
end

function datasets=dicom_folder_info(link,subfolders)
% Function DICOM_FOLDER_INFO gives information about all Dicom files
% in a certain folder (and subfolders), or of a certain dataset
%
% datasets=dicom_folder_info(link,subfolders)
%
% inputs,
%   link : A link to a folder like "C:\temp" or a link to the first
%           file of a dicom volume "C:\temp\01.dcm"
%   subfolders : Boolean if true (default) also look in sub-folders for 
%           dicom files
%
% ouputs,
%   datasets : A struct with information about all dicom datasets in a
%            folder or of the selected dicom-dataset.
%              (Filenames are already sorted by InstanceNumber)
%
%
% Example output:
%  datasets=dicom_folder_info('D:\MedicalVolumeData',true);
%
%  datasets =  1x7 struct array with fields
%
%  datasets(1) = 
%             Filenames: {24x1 cell}
%                 Sizes: [512 512 24]
%                Scales: [0.3320 0.3320 4.4992]
%             DicomInfo: [1x1 struct]
%     SeriesInstanceUID: '1.2.840.113619.2.176.2025'
%     SeriesDescription: 'AX.  FSE PD'
%            SeriesDate: '20070101'
%            SeriesTime: '120000.000000'
%              Modality: 'MR'
%
%  datasets(1).Filenames =
%   'D:\MedicalVolumeData\IM-0001-0001.dcm'
%   'D:\MedicalVolumeData\IM-0001-0002.dcm'
%   'D:\MedicalVolumeData\IM-0001-0003.dcm'
%
% Function is written by D.Kroon University of Twente (June 2010)

% If no Folder given, give folder selection dialog
if(nargin<1), link =  uigetdir(); end

% If no subfolders option defined set it to true
if(nargin<2), subfolders=true; end

% Check if the input is a file or a folder
if(isdir(link))
    dirname=link; filehash=[];
else
    dirname = fileparts(link);
    info=dicominfo(link);
    SeriesInstanceUID=0;
    if(isfield(info,'SeriesInstanceUID')), SeriesInstanceUID=info.SeriesInstanceUID; end
    filehash=string2hash([dirname SeriesInstanceUID]);
    subfolders=false;
end

% Make a structure to store all files and folders
dicomfilelist.Filename=cell(1,100000);
dicomfilelist.InstanceNumber=zeros(1,100000);
dicomfilelist.ImagePositionPatient=zeros(100000,3);
dicomfilelist.hash=zeros(1,100000);
nfiles=0;

% Get all dicomfiles in the current folder (and sub-folders)
[dicomfilelist,nfiles]=getdicomfilelist(dirname,dicomfilelist,nfiles,filehash,subfolders);
if(nfiles==0), datasets=[]; return; end

% Sort all dicom files based on a hash from dicom-series number and folder name
datasets=sortdicomfilelist(dicomfilelist,nfiles);

% Add Dicom information like scaling and size
datasets=AddDicomInformation(datasets);
end
function datasets=AddDicomInformation(datasets)
for i=1:length(datasets)
    Scales=[0 0 0];
    Sizes=[0 0 0];
    SeriesInstanceUID=0;
    SeriesDescription='';
    SeriesDate='';
    SeriesTime='';
    Modality='';
    info=dicominfo(datasets(i).Filenames{1});
    nf=length(datasets(i).Filenames);

    if(isfield(info,'SpacingBetweenSlices')), Scales(3)=info.SpacingBetweenSlices; end
    if(isfield(info,'PixelSpacing')), Scales(1:2)=info.PixelSpacing(1:2); end
    if(isfield(info,'ImagerPixelSpacing ')), Scales(1:2)=info.PixelSpacing(1:2); end
    if(isfield(info,'Rows')), Sizes(1)=info.Rows; end
    if(isfield(info,'Columns')), Sizes(2)=info.Columns; end
    if(isfield(info,'NumberOfFrames')), Sizes(3)=info.NumberOfFrames; end
    if(isfield(info,'SeriesInstanceUID')), SeriesInstanceUID=info.SeriesInstanceUID; end
    if(isfield(info,'SeriesDescription')), SeriesDescription=info.SeriesDescription; end
    if(isfield(info,'SeriesDate')),SeriesDate=info.SeriesDate; end
    if(isfield(info,'SeriesTime')),SeriesTime=info.SeriesTime; end
    if(isfield(info,'Modality')), Modality=info. Modality; end
    if(nf>1), Sizes(3)=nf; end
    if(nf>1)
        info1=dicominfo(datasets(i).Filenames{2});
        if(isfield(info1,'ImagePositionPatient'))
            dis=abs(info1.ImagePositionPatient(3)-info.ImagePositionPatient(3));
            if(dis>0), Scales(3)=dis; end
        end
    end
    datasets(i).Sizes=Sizes;
    datasets(i).Scales=Scales;
    datasets(i).DicomInfo=info;
    datasets(i).SeriesInstanceUID=SeriesInstanceUID;
    datasets(i).SeriesDescription=SeriesDescription;
    datasets(i).SeriesDate=SeriesDate;
    datasets(i).SeriesTime=SeriesTime;
    datasets(i).Modality= Modality;
end
end
function datasets=sortdicomfilelist(dicomfilelist,nfiles)
datasetids=unique(dicomfilelist.hash(1:nfiles));
ndatasets=length(datasetids);
for i=1:ndatasets
    h=find(dicomfilelist.hash(1:nfiles)==datasetids(i));
    InstanceNumbers=dicomfilelist.InstanceNumber(h);
    ImagePositionPatient=dicomfilelist.ImagePositionPatient(h,:);
    if(length(unique(InstanceNumbers))==length(InstanceNumbers))
        [temp ind]=sort(InstanceNumbers);
    else
        [temp ind]=sort(ImagePositionPatient(:,3));
    end
    h=h(ind);
    datasets(i).Filenames=cell(length(h),1);
    for j=1:length(h)
        datasets(i).Filenames{j}=dicomfilelist.Filename{h(j)};
    end
end
end

function [dicomfilelist nfiles]=getdicomfilelist(dirname,dicomfilelist,nfiles,filehash,subfolders)
% dirn=fullfile(dirname);
dirn=dirname;
if(~isempty(dirn)), filelist = dir(dirn); else filelist = dir; end

for i=1:length(filelist)
    fullfilename=fullfile(dirname,filelist(i).name);
    if((filelist(i).isdir))
        if((filelist(i).name(1)~='.')&&(subfolders))
            [dicomfilelist nfiles]=getdicomfilelist(fullfilename ,dicomfilelist,nfiles,filehash,subfolders);
        end
    else
        if(file_is_dicom(fullfilename))
            try info=dicominfo(fullfilename); catch me, info=[]; end
            if(~isempty(info))
                InstanceNumber=0;
                ImagePositionPatient=[0 0 0];
                SeriesInstanceUID=0;
                Filename=info.Filename;
                if(isfield(info,'InstanceNumber')), InstanceNumber=info.InstanceNumber; end
                if(isfield(info,'ImagePositionPatient')),ImagePositionPatient=info.ImagePositionPatient; end
                
                if(isfield(info,'SeriesInstanceUID')), SeriesInstanceUID=info.SeriesInstanceUID; end
                hash=string2hash([dirname SeriesInstanceUID]);
                if(isempty(filehash)||(filehash==hash))
                    nfiles=nfiles+1; 
                    dicomfilelist.Filename{ nfiles}=Filename;
                    dicomfilelist.InstanceNumber( nfiles)=InstanceNumber;
                    dicomfilelist.ImagePositionPatient(nfiles,:)=ImagePositionPatient(:)';
                    dicomfilelist.hash( nfiles)=hash;
                end
            end
        end
    end
end
end

function isdicom=file_is_dicom(filename)
isdicom=false;
try
    fid = fopen(filename, 'r');
    status=fseek(fid,128,-1);
    if(status==0)
        tag = fread(fid, 4, 'uint8=>char')';
        isdicom=strcmpi(tag,'DICM');
    end
    fclose(fid);
catch me
end
end

function hash=string2hash(str,type)
% This function generates a hash value from a text string
%
% hash=string2hash(str,type);
%
% inputs,
%   str : The text string, or array with text strings.
% outputs,
%   hash : The hash value, integer value between 0 and 2^32-1
%   type : Type of has 'djb2' (default) or 'sdbm'
%
% From c-code on : http://www.cse.yorku.ca/~oz/hash.html 
%
% djb2
%  this algorithm was first reported by dan bernstein many years ago 
%  in comp.lang.c
%
% sdbm
%  this algorithm was created for sdbm (a public-domain reimplementation of
%  ndbm) database library. it was found to do well in scrambling bits, 
%  causing better distribution of the keys and fewer splits. it also happens
%  to be a good general hashing function with good distribution.
%
% example,
%
%  hash=string2hash('hello world');
%  disp(hash);
%
% Function is written by D.Kroon University of Twente (June 2010)


% From string to double array
str=double(str);
if(nargin<2), type='djb2'; end
switch(type)
    case 'djb2'
        hash = 5381*ones(size(str,1),1); 
        for i=1:size(str,2), 
            hash = mod(hash * 33 + str(:,i), 2^32-1); 
        end
    case 'sdbm'
        hash = zeros(size(str,1),1);
        for i=1:size(str,2), 
            hash = mod(hash * 65599 + str(:,i), 2^32-1);
        end
    otherwise
        error('string_hash:inputs','unknown type');
end
end

function [id,name] = choose_from_list(varargin)
%
% example :
%
% c{1}='apple'
% c{2}='orange'
% c{3}='berries'
% [id,name]=choose_from_list(c,'Select a Fruit');
%

if(strcmp(varargin{1},'press'))
   handles=guihandles;
   id=get(handles.listbox1,'Value');
   setMyData(id);
   uiresume
   return
end

% listbox1 Position [12, 36 , 319, 226]
% pushbutton [16,12,69,22]
% figure position 520 528 348 273
handles.figure1=figure;
c=varargin{1};
set(handles.figure1,'tag','figure1','Position',[520 528 348 273],'MenuBar','none','name',varargin{2});
handles.listbox1=uicontrol('tag','listbox1','Style','listbox','Position',[12 36 319 226],'String', c);
handles.pushbutton1=uicontrol('tag','pushbutton1','Style','pushbutton','Position',[16 12 69 22],'String','Select','Callback','choose_from_list(''press'');');
uiwait(handles.figure1);
id=getMyData();
name=c{id};
close(handles.figure1);
end
function setMyData(data)
% Store data struct in figure
setappdata(gcf,'data3d',data);
end
function data=getMyData()
% Get data struct stored in figure
data=getappdata(gcf,'data3d');
end