%% Orientational Order Parameter (OOP) Calculator
% Beta version 1.0
% date: 4/26/2013
%
% The following code is part of the development of COBRA: the Cytoskeletal
% Organization Benchmark and Representation Assay.
%
% written by: Francesco S. Pasqualini
%
% DISEASE BIOPHYSICS GROUP CONFIDENTIAL
% Unpublished Copyright (c) 2013,
% DISEASE BIOPHYSICS GROUP, All Rights Reserved.
%
% NOTICE:  All information contained herein is, and remains the property of
% the DISEASE BIOPHYSICS GROUP. The intellectual and technical concepts
% contained herein are proprietary to the DISEASE BIOPHYSICS GROUP and may
% be covered by U.S. and Foreign Patents, patents in process, and are
% protected by trade secret or copyright law. 
% Dissemination of this information or reproduction of this material is
% strictly forbidden unless prior written permission is obtained
% from the DISEASE BIOPHYSICS GROUP.  Access to the source code contained
% herein is hereby forbidden to anyone except current
% DISEASE BIOPHYSICS GROUP employees, managers or contractors who have
% executed Confidentiality and Non-disclosure agreements explicitly
% covering such access.
%
% The copyright notice above does not evidence any actual or intended
% publication or disclosure  of  this source code, which includes
% information that is confidential and/or proprietary, and is a trade
% secret, of  the DISEASE BIOPHYSICS GROUP.
% ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
% OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE
% EXPRESS WRITTEN CONSENT OF COMPANY IS STRICTLY PROHIBITED,
% AND IN VIOLATION OF APPLICABLE LAWS AND INTERNATIONAL TREATIES.
% THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION
% DOES NOT CONVEY OR IMPLY ANY RIGHTS  TO REPRODUCE, DISCLOSE OR
% DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT
% IT  MAY DESCRIBE, IN WHOLE OR IN PART.


%% INITIALIZATION

%% Main GUI Function
% this piece of standard CODE sets up the GUI based on the .fig file
% prepared with GUIDE (help GUIDE for more info)

function varargout = OOP_Ver1b0(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @OOP_Ver1b0_OpeningFcn, ...
    'gui_OutputFcn',  @OOP_Ver1b0_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% load COBRA-specific dependencies

[PATHSTR,NAME,EXT] = fileparts(pwd);
addpath(genpath([PATHSTR,...
    '\Dependencies']));

% suppress warnings
warning ('off','all');

%% GUI Initialization Function
% this piece of standard CODE sets up the default values (and images) for
% the elements in the GUI

% --- Executes just before OOP_Ver1b0 is made visible.
function OOP_Ver1b0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OOP_Ver1b0 (see VARARGIN)

% Choose default command line output for OOP_Ver1b0
handles.output = hObject;


% user-defined handles

% store the metric values to be saved in the final spreadsheet
handles.TotalDataset = [];
% temporary store the metric values obtained for each images
handles.Dataset = [];

% store the name of the file being analyzed
handles.filename = []; 
% store the name of the folder from which the files are taken
handles.pathname = []; 
% store the name of the text file in which all the data are saved
handles.savename = [];
% store all the user-defined options for the OOP calculation
handles.OOPopt = []; 


% initialize LOGO windows
axes(handles.dBGLogo);
imshow(imread('DBGHeader.PNG'),[])

% enable buttons 
set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,'string',...
    'Analyze','enable','on');
set(handles.pushbutton2,'Enable','off')

% Update handles structure
guidata(hObject, handles);



%% ANALYZE BUTTON

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear the matlab workspace
clc
% clear variables between executions
clear OOPsOpt imOutput

% changes the apparence of the "Analyze" button
set(handles.pushbutton1,'BackgroundColor','r','string',...
    'Analyzing','enable','off');
set(handles.pushbutton2,'Enable','off')
guidata(hObject, handles);

% if the fields Dataset and TotalDataset have been initialized in previous
% executions, this piece of code clears them
if ~isempty(handles.Dataset)
handles = rmfield(handles,'Dataset');
handles = rmfield(handles,'TotalDataset');
end


% prompt the user to imput numerical values for threshold 
prompt = {'Intensity:','Coherency:'};
dlg_title = 'Specify orientation inclusion threshold';
num_lines = 1;
def = {'0.1','0.3'};
UserSelections = inputdlg(prompt,dlg_title,num_lines,def);

% return the GUI to normal state if the users cancels
if isempty(UserSelections)
    set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,...
        'string', 'Analyze','enable','on');
    return
end

UserSelections = str2double(UserSelections);

% pass the thresholds to a structure that will be used later in the
% computation
OOPsOpt.thValues = UserSelections(1);
OOPsOpt.thCoherency = UserSelections(2);


% check if the user has selected a Batch Process 
if get(handles.checkbox1, 'Value')
    % prompt the user to select a folder containing images
    ListOfFiles = SelectFolder(hObject, eventdata, handles);
    NumFiles = length(ListOfFiles);
    filenames = cell(1,NumFiles);
    % process one image at a time
    
    
    % assemble the header for the spreadsheet to be exported
    VariableNames = ...
        {'filename','OOP','OOP1','OOP2','gamma','th','rsq'};
    
    
    for idx1 = 1:NumFiles
        
        % extract idx-th filename
        filenames{idx1} = ListOfFiles(idx1).name;


        % extract parts of idx-th filename and save them in handles
        [PATHSTR,NAME,EXT] = fileparts(filenames{idx1});
        handles.filename = NAME;
        handles.pathname = PATHSTR;
        guidata(hObject, handles);
        
        % save in the structure imOutput the outcomes of the analysis on 
        % the idx-th image
        imOutput = AnalyzeSingleImage(filenames{idx1},OOPsOpt,hObject,...
            eventdata, handles);
        
        % fill axes1 with the ith-image
        axes(handles.axes1)
        imshow(imOutput.input.im,[])

        % fill axes2 with the thresholded verstion of the ith-image        
        axes(handles.axes2)
        imshow(hsv2rgb(imOutput.output.image2show_hard),[])
        
        
        % include the value of the threshold used for the idx-th image                
        imOutput.output.ExtractedMetrics(1,7) = OOPsOpt.thCoherency;


        % assemble the data for the idx-th entry in the spreadsheet 
        Data = {handles.filename,...
            imOutput.output.ExtractedMetrics(1),...
            imOutput.output.ExtractedMetrics(2),...
            imOutput.output.ExtractedMetrics(3),...
            1-imOutput.output.ExtractedMetrics(4) - ...
            imOutput.output.ExtractedMetrics(5),...
            imOutput.output.ExtractedMetrics(7),...
            imOutput.output.ExtractedMetrics(6),...
            };
        
        % assembles the idx-th entry in a dataset format
        handles.Dataset = dataset({Data, VariableNames{:}});
        
        % merge the idx-th dataset with the others
        if idx1 == 1
            handles.TotalDataset = handles.Dataset;
        else
            handles.TotalDataset = cat(1, handles.Dataset,...
                handles.TotalDataset);
        end

        % plot the extracted numerical values in the GUI
        set(handles.edit1,'String',imOutput.output.ExtractedMetrics(1));
        set(handles.edit2,'String',imOutput.output.ExtractedMetrics(2));
        set(handles.edit3,'String',imOutput.output.ExtractedMetrics(3));
        set(handles.edit4,'String',1-imOutput.output.ExtractedMetrics(4)-...
            imOutput.output.ExtractedMetrics(5))
        set(handles.edit5,'String',imOutput.output.ExtractedMetrics(7))
        set(handles.edit6,'String',imOutput.output.ExtractedMetrics(6))
        % update the handles
        guidata(hObject, handles);
    end
    
    
% if instead the user has preferred the analysis of a single image at a 
% time
else
    
    % start the search from the folder containing the DEMO images
    [PATHSTR,NAME,EXT] = fileparts(pwd);
    imageFolder = [PATHSTR,...
        '\DemoImages\OOP\pCM\'];   

    
    % let the user select a specific iamge
    [filename, pathname] = uigetfile(...
        {'*.bmp;*.jpg;*.tif;*.png;','All Image Files';...
        '*.*','All Files' },...
        'Pick an image',...
        imageFolder);

    % if the user cancels here, return the GUI normal state
    
    if isequal(filename,0) || isequal(pathname,0)

        set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,...
            'string', 'Analyze','enable','on');
        return
    end
    
    % store filename info for later use    
    handles.filename = filename;
    handles.pathname = pathname;
    guidata(hObject, handles);
    
    % analyze the selected image    
    imOutput = AnalyzeSingleImage([pathname, filename],OOPsOpt,hObject,...
        eventdata, handles);

    % fill axes1 with the selected image    
    axes(handles.axes1)
    imshow(imOutput.input.im,[])
    
    % fill axes1 with the FFT of the selected image     
    axes(handles.axes2)
    imshow(hsv2rgb(imOutput.output.image2show_hard),[])

    
    % include the value of the threshold used for the idx-th image
    imOutput.output.ExtractedMetrics(1,7) = OOPsOpt.thCoherency;
    guidata(hObject, handles);
    
    
    % plot the extracted numerical values in the GUI
    
    set(handles.edit1,'String',imOutput.output.ExtractedMetrics(1));
    set(handles.edit2,'String',imOutput.output.ExtractedMetrics(2));
    set(handles.edit3,'String',imOutput.output.ExtractedMetrics(3));
    set(handles.edit4,'String',1-imOutput.output.ExtractedMetrics(4)-...
        imOutput.output.ExtractedMetrics(5))
    set(handles.edit5,'String',imOutput.output.ExtractedMetrics(7))
    set(handles.edit6,'String',imOutput.output.ExtractedMetrics(6))
    
end

% at the end of the computation restore normal GUI appearence
set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,'string',...
    'Analyze','enable','on');
set(handles.pushbutton2,'Enable','on')
guidata(hObject, handles);


%% SAVE BUTTON
% saving is implemented differently, depending on the type of analysis
% 1. single image: the program saves 3 eps (illustrator editable files) 
% containing a snapshot of the GUI, as well as the image
% 2. batch mode: the program does not save any of the images, but instead
% saves a csv spreadsheet ready for further statistical analysis
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this pushbotton triggers the saving routines
guidata(hObject, handles);  

% change appearence to reflect activation fo savig routine
set(handles.pushbutton1,'Enable','off')
set(handles.pushbutton2,'BackgroundColor','r','string',...
    'Saving','enable','on');
% if the batch mode is selected, only save the dataset array
if get(handles.checkbox1, 'Value')
    export(handles.TotalDataset,'file',...
        [handles.pathname, '\', 'FolderSummary.csv'],'Delimiter',',')
    % include a pause to show the button becoming red during saving, this
    % can be commented out for final releases
     pause(1.1) 
     
% otherwise save the images
else
    % take an editable snapshot of the GUI
    saveas(gcbf,[handles.pathname,handles.filename,'.eps'],'psc2')
    
    % export into a single EPS file the histogram and fitting
    figTemp = figure('visible','off');
    newax = copyobj(handles.axes3,figTemp);
    saveas(figTemp,[handles.pathname,handles.filename,'_1D.eps'],'psc2')
    close(figTemp)
    
    % export into a single EPS file the thresholded image
    figTemp = figure('visible','off');
    newax = copyobj(handles.axes2,figTemp);
    saveas(figTemp,[handles.pathname,handles.filename,'_2D.eps'],'psc2')
    
end

% update the appearence of the buttons
set(handles.pushbutton1,'Enable','on')
set(handles.pushbutton2,'BackgroundColor',[240, 240, 240]/255,'string',...
    'Save','enable','off');
guidata(hObject, handles);    


%% CORE FUNCTIONS
% this section lists all the function that are specifically use to compute
% the OOP

%% Analyze single image
% main function that calls all the sub-routines needed to analyze a single
% image
function imOutput = ...
    AnalyzeSingleImage(filename,OOPsOpt, hObject, eventdata, handles)

imOutput.input = imageSelection(filename,hObject, eventdata, handles);

imOutput.output = exectuteAnalysisSingleImage(imOutput.input.im,OOPsOpt,...
    hObject, eventdata, handles);

%% Image Selection
function imOutput = imageSelection(filename,hObject, eventdata, handles)


imOutput.im = imread(filename);

%% Folder Selection
function ListOfFiles = SelectFolder(hObject, eventdata, handles)
[PATHSTR,NAME,EXT] = fileparts(pwd);
imageFolder = [PATHSTR,...
    '\DemoImages\OOP\pCM'];

d = uigetdir(imageFolder);


   if isequal(d,0) || isequal(d,0)
        disp('User pressed cancel')
        set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,...
            'string','Analyze','enable','on');
        return
   end
        
   
   
ListOfFiles = dir(fullfile(d, '*.tif'));

for idx1 = 1:length(ListOfFiles)
    ListOfFiles(idx1).name = [d,'\',ListOfFiles(idx1).name ];
end




function output = ...
    exectuteAnalysisSingleImage(im,OOPsOpt,hObject, eventdata, handles)
im_RGB = im;

% general use vectors
% interval for circular statistics operations
intervalRad = linspace(-pi,pi,360);
% starting point for optimization procedure
startingPoints = [0.1, 5,5,deg2rad(0),deg2rad(90),.1];

NumOrientations = 180;
theta = floor(linspace(-90,89,NumOrientations));

ExtractedMetrics = zeros(1,7);
% convert in hue, saturation and value format
im_HSV = rgb2hsv(im_RGB);
image2show = zeros(size(im_HSV));
% extract Orientations
Orientation = im_HSV(:,:,1);
% extract Coherency
Coherency = im_HSV(:,:,2);
% extract Gray Values for the original image
Values = im_HSV(:,:,3);

% apply defined thresholds
NonBackgroundOrientations = Orientation(Values>OOPsOpt.thValues);
HighConfidenceEdgeOrientations = Orientation(Values>OOPsOpt.thValues &...
    Coherency>=(OOPsOpt.thCoherency*max(Coherency(:))));

output.image2show_hard(:,:,1) = Orientation;
output.image2show_hard(:,:,2) = Coherency.*(Coherency>=...
    (OOPsOpt.thCoherency*max(Coherency(:))));
output.image2show_hard(:,:,3) = Values.*(Values>=OOPsOpt.thValues);

%
axes(handles.axes3)
output.ExtractedMetrics(1,1:6) = ...
    calculateOOPs(HighConfidenceEdgeOrientations,...
    intervalRad,startingPoints,hObject, eventdata, handles);

%%
function output = ...
    calculateOOPs(y,interval_rad,startingPoints,hObject, eventdata, handles)

fsp360_180deg = @(x) mod((x/2)+90,180)-90;
fsp_hue_360rad = @(x) mod(x*2*pi,2*pi)-pi;
fsp360_180rad = @(x) mod((x/2)+pi/2,pi)-pi/2;
% input data manipulation

if(max(y(:))<=1 & min(y(:))>=0)
    y = fsp_hue_360rad(y);
end

%%
%remove -5 to 5 degrees
%5 degrees = 0.0872665
%10 degrees = 0.174533
%45 degrees = 0.785398
% for i = 1:numel(y)
%     if y(i) > -0.785398 && y(i) < 0.785398
%         y(i) = nan;
%     end
%     %if y(i) > 3.05433 && y(i) < 3.22886
%     %    y(i) = nan;
%     %end
% end
% y(isnan(y)) = [];
%%

[counts_angles] = hist(y,interval_rad);
count_angles_density = counts_angles/trapz(interval_rad,counts_angles);
sumCounts = trapz(interval_rad, count_angles_density);
% circular statistics: OOPr
Srad = circ_stats(y);
mean_angle = Srad.mean;
stdDev = Srad.std;
OOPr = circ_r(y);

% Von Mises mixture best fitting procedure
% use parameter estimation function from circular stat toolbox so uses the
% circular representation (vector y not y1)

try
    
    [cf_, gof_]= Trimodal_VonMisesFit(interval_rad,count_angles_density,...
        startingPoints);
    cfvalues = coeffvalues(cf_);
    fhat = cfvalues(1);
    khat1 = cfvalues(2);
    khat2 = abs(cfvalues(3));
    
    mhat1 = cfvalues(4);
    mhat2 = ((-1)^(cfvalues(3)<0).*cfvalues(5));
    
    ghat = cfvalues(6);
    OOP1 = circ_r(circ_vmrnd(mhat1,khat1,1e3));
    OOP2 = circ_r(circ_vmrnd(mhat2,khat2,1e3));
    gof = gof_.rsquare;
    
    
    
    output = [OOPr, OOP1, OOP2,fhat,ghat,gof];
    
    % plot the values of all OOP indicators, as well as the graph of OOP vs
    % spread paraneter k and circular standard deviation
    
    bestFit_VM = ghat*circ_vmpdf(interval_rad,0,0)+...
        fhat*circ_vmpdf(interval_rad,mhat1,khat1)+...
        (1-fhat-ghat)*circ_vmpdf(interval_rad,mhat2,khat2);
    AreaFit = trapz(interval_rad,bestFit_VM);
    
    
    bar(interval_rad,count_angles_density,'EdgeColor','g','FaceColor','g')
    % plot(interval_rad,count_angles_density,'g')
    hold on
    plot(interval_rad,bestFit_VM,'k','LineWidth',2)
    % bar(interval_rad,bestFit_VM,'EdgeColor','g','FaceColor','g','alpha',0.6)
    hold off
    legend({'data', 'best fit'},'FontSize',14,'FontWeight','bold')
        legend boxoff
    title('Von Mises Circular Fit','FontSize',18,'FontWeight','bold')
    xlabel('deg','FontSize',14,'FontWeight','bold')
    ylabel('normalized occurrence','FontSize',14,'FontWeight','bold')
    set(handles.axes3,'Box','off','TickDir','out')
    set(handles.axes3,'FontSize',14,'FontWeight','bold')
    set(handles.axes3,'Xlim',[-pi, pi],'Xtick',[-3.14,0,3.14],...
        'XTickLabel',{'-90','0','90'});
catch err
    output = [OOPr, zeros(1,5)];
    display(['could not perform fitting:']);
    getReport(err, 'extended')
  
    
end


function [cf_, gof_] = ...
    Trimodal_VonMisesFit(interval_rad,count_angles_density,startingPoints)


interval_rad = interval_rad(:);
count_angles_density = count_angles_density(:);

ok_ = isfinite(interval_rad) & isfinite(count_angles_density);


st = startingPoints;
opt = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0 1 1 deg2rad(-90) deg2rad(91) 0],...
    'Upper',[1 100 100 deg2rad(90) deg2rad(180) 1],...
    'StartPoint',st);


ft_ = fittype(['0*circ_vmpdf(x,0,0) + f*circ_vmpdf(x,mhat1,khat1)+'...
    '(1-f-g)*circ_vmpdf(x,mhat2,khat2)'],...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'f', 'khat1', 'khat2', 'mhat1', 'mhat2','g'},...
    'options',opt);


[cf_, gof_] = fit(interval_rad(ok_),count_angles_density(ok_),ft_);



%% GUI SUPPL FUNCTIONs
% do not edit

% --- Outputs from this function are returned to the command line.
function varargout = OOP_Ver1b0_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



