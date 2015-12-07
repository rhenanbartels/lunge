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
    handles.gui = guihandles(figObject);
    guidata(figObject, handles);
end

function figObject = createMainFigure()
    %Get the screen size
    screenSize = get(0, 'ScreenSize');
    figObject = figure('Tag', 'mainFig',...
        'MenuBar', 'None',...
        'NumberTitle', 'Off',...
        'Name', 'New CT Processing V 0.0.1dev',...
        'Position', screenSize,...
        'WindowScrollWheelFcn', @refreshSlicePosition);  

end

function navigationAxesObjectStructure = createNavigationAxes(parentFigureObject)

    navigationAxesObjectStructure.navigationAxesObject = axes('Parent', parentFigureObject,...
      'Units', 'Normalized',...
      'Position', [0.2, 0.15, 0.6, 0.8],...
      'Color', 'black',...
      'XtickLabels', '',...
      'YtickLabels', '');

  navigationAxesObjectStructure.informationAxesObject = axes('Parent', parentFigureObject,...
      'Units', 'Normalized',...
      'Position', [0.15, 0.08, 0.7, 0.9],...
      'XtickLabels', '',...
      'YtickLabels', '',...
      'Color', 'black');
  

end

function informationTextsObjectsStructure = createInformationTexts(parentAxesObject)
    informationTextsObjectsStructure.slicePosition = text(0.01, 0.02, '1/100',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold',...
        'Tag', 'slicePositionTag');
    
    informationTextsObjectsStructure.patientName = text(0.45, 0.98, 'Patient''s Name',...
        'Color', 'white',...
        'Fontsize', 12,...
        'Fontweight', 'bold');
end

function menuObjectsStructure = createMenuObjects(parentFigureObject)
    %Create Menu Objects
    menuObjectsStructure.fileMenu = uimenu('Parent', parentFigureObject,...
        'Label', 'File');
    %Load Frame Menu
    menuObjectsStructure.loadFrame = uimenu('Parent', menuObjectsStructure.fileMenu,...
        'Label', 'Open Frame',...
        'Acc', 'O',...
        'Callback', '');
    %Quit Menu
    menuObjectsStructure.quitMenu = uimenu('Parent', menuObjectsStructure.fileMenu,...
        'Label', 'Quit',...        
        'Callback', '');
end

function refreshSlicePosition(hObject, eventdata)

    nSlices = 100;
    slicePositionPlaceHolder = '%d/%d';

    handles = guidata(hObject);
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
    end
    
    %Refresh slice position information.
    set(handles.gui.slicePositionTag, 'String',...
        sprintf(slicePositionPlaceHolder, newSlicePosition, nSlices));
end

function newSlicePosition = getSlicePosition(slicePositionString, direction)
    tempSlicePosition = regexp(slicePositionString, '/', 'split');
    
    if direction > 0  
        newSlicePosition = str2double(tempSlicePosition(1)) + 1;
    else
        newSlicePosition = str2double(tempSlicePosition(1)) - 1;
    end
end