function CT_Processing
    figObject = createMainFigure();
    
    %Create Navigation Axes
    navigationAxesObjects = createNavigationAxes(figObject);
    
    %Create Information Texts
    informationTextsObjects = createInformationTexts(navigationAxesObjects.informationAxesObject);
    
    %Create Menus
    menuObjects = createMenuObjects(figObject);
    
    handles.gui.figObject = figObject;
    handles.gui.informationTextsObjects = informationTextsObjects;
    handles.gui.menuObjects = menuObjects;
    handles.gui.sliderBarObjects = createSlideBarObjects(figObject);
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
      'Position', [0.2, 0.15, 0.6, 0.8],...
      'Color', 'black',...
      'XtickLabel', '',...
      'YtickLabel', '',...
      'Tag', 'navigationAxes');

  navigationAxesObjectStructure.informationAxesObject = axes('Parent', parentFigureObject,...
      'Units', 'Normalized',...
      'Position', [0.15, 0.08, 0.7, 0.9],...
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
        'HorizontalAlignment', 'center');
    
    informationTextsObjectsStructure.slicePosition = text(0.01, 0.02, '1/-',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold',...
        'Tag', 'slicePositionTag');
    
    informationTextsObjectsStructure.numberOfRows = text(0.01, 0.06, 'Image Size: -',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold',...
        'Tag', 'numberOfRowsTag');     


    informationTextsObjectsStructure.pixelValue = text(0.14, 0.02, 'Pixel Value = -',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold',...
        'Tag', 'pixelValueTag');
end

function menuObjectsStructure = createMenuObjects(parentFigureObject)
    %Create Menu Objects
    
    menuObjectsStructure.fileMenu = uimenu('Parent', parentFigureObject,...
        'Label', 'File');
    openGroup = uimenu('Parent', menuObjectsStructure.fileMenu, 'Label', 'Open');
    %Load Frame Menu
    menuObjectsStructure.loadFrame = uimenu('Parent', openGroup,...
        'Label', 'Open Frame',...
        'Acc', 'O',...
        'Callback', @openDicom);
    %Load Masks Menu
    menuObjectsStructure.loadFrame = uimenu('Parent', openGroup,...
        'Label', 'Open Masks',...
        'Acc', 'M',...
        'Callback', @openMask);
    
    %Quit Menu
    menuObjectsStructure.quitMenu = uimenu('Parent', menuObjectsStructure.fileMenu,...
        'Label', 'Quit',...        
        'Callback', '');
end

function slideBarObjectsStructure = createSlideBarObjects(parentFigureObject)
    slideBarObjectsStructure.windowWidth = uicontrol('Parent', parentFigureObject,...
        'Style', 'Slider',...
        'Units', 'Normalized',...
        'Position', [0.8, 0.45, 0.1, 0.2],...
        'Tag', 'windowWidthSlider',...
        'Callback', @windowWidthCallback);
    
    slideBarObjectsStructure.windowCenter= uicontrol('Parent', parentFigureObject,...
        'Style', 'Slider',...
        'Units', 'Normalized',...
        'Position', [0.86, 0.45, 0.1, 0.2],...
        'Tag', 'windowCenterSlider',...
        'Callback', @windowCenterCallback);
    
    slideBarObjectsStructure.windowWidthText = uicontrol('Parent',parentFigureObject,...
        'Style', 'Text',...
        'Units', 'Normalized',...
        'Position', [0.878, 0.67, 0.03, 0.02],...
        'HorizontalAlignment', 'Center',...        
        'String', '0');
    
    slideBarObjectsStructure.windowWidthText = uicontrol('Parent',parentFigureObject,...
        'Style', 'Text',...
        'Units', 'Normalized',...
        'Position', [0.937, 0.67, 0.03, 0.02],...
        'HorizontalAlignment', 'Center',...
        'String', '0');

end

%%%%%%%%%%%% GUI RELATED FUNCTIONS  - END %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function displayCurrentDicom(handles, dicomImage, slicePosition)
axes(handles.gui.navigationAxes)
imagesc(dicomImage(:, :, slicePosition))
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
    displayCurrentDicom(handles, handles.data.dicomImage, newSlicePosition);
    
    %Refresh pixel value information.
    refreshPixelPositionInfo(handles, handles.gui.navigationAxes)
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
        
        while ~found
            counter =  counter + 1;
            fileName = listOfFiles(counter).name;
            if ~strcmp(fileName, '.') && ~strcmp(fileName, '..')
                completeFileName = [dirPath filesep fileName];
                %Try to discover if files without extension are Dicom files
                try
                    dicominfo(completeFileName);
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
        
        %Display First Slice
        displayCurrentDicom(handles, dicomImage, 1);
        %Display Patients Information
        refreshPatientsInfo(handles, info)
        
        handles.data.dicomImage = dicomImage;
        guidata(hObject, handles)
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
    
    row = C(1);
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

end

function windowCenterCallback(hObject, eventdata)
    handles = guidata(hObject);
    windowCenter = get(handles.gui.windowCenterSlider, 'Value');

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