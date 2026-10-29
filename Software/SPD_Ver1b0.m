%% Sarcomere Packing Density (SPD) Calculator
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

function varargout = SPD_Ver1b0(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SPD_Ver1b0_OpeningFcn, ...
    'gui_OutputFcn',  @SPD_Ver1b0_OutputFcn, ...
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

% --- Executes just before SPD_Ver1b0 is made visible.
function SPD_Ver1b0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SPD_Ver1b0 (see VARARGIN)

% Choose default command line output for SPD_Ver1b0
handles.output = hObject;


% user-defined handles

% store the metric values to be saved in the final spreadsheet
handles.TotalDataset = [];
% temporary store the metric values obtained for each images
handles.Dataset = [];


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

%% parameter: gamma correction    
    userDefinedGamma = 0.1;

% changes the apparence of the "Analyze" button
set(handles.pushbutton1,'BackgroundColor','r','string',...
    'Analyzing','enable','off');
set(handles.pushbutton2,'Enable','off')
guidata(hObject, handles);

% if the fields Dataset and TotalDataset have been initialized in previous
% executions, this piece of code clears them
if ~(isempty(handles.Dataset)|isempty(handles.TotalDataset))
    handles = rmfield(handles,'Dataset');
    handles = rmfield(handles,'TotalDataset');
end


% prompt the user to imput numerical values for Pixel size

prompt = {'Pixel size:'};
dlg_title = 'Specify image resolution (um/pixel)';
num_lines = 1;
def = {'0.1543'};
userSelection = inputdlg(prompt,dlg_title,num_lines,def);


% return the GUI to normal state if the users cancels
if isempty(userSelection)
    set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,'string',...
        'Analyze','enable','on');
    return
end


% pass the thresholds to a structure that will be used later in the
% computation
handles.PxlSize = str2double(userSelection);
guidata(hObject, handles);



% check if the user has selected a Batch Process 
if get(handles.checkbox1, 'Value')
    % prompt the user to select a folder containing images
    ListOfFiles = SelectFolder(hObject, eventdata, handles);
    NumFiles = length(ListOfFiles);
    filenames = cell(1,NumFiles);
    VariableNames = {'filename','SL','SPD'};
    
    % process one image at a time
    for idx1 = 1:NumFiles
        
        % extract filename
        filenames{idx1} = ListOfFiles(idx1).name;
        
        % extract parts of filename and save them in handles
        [PATHSTR,NAME,EXT] = fileparts(filenames{idx1});
        handles.filename = NAME;
        handles.pathname = PATHSTR;
        guidata(hObject, handles);
        
   %       analyze the image
    handles = AnalyzeSingleImage(filenames{idx1},hObject,...
        eventdata, handles);
    

    % a gamma correction of userDefinedGamma is adopted in the rest to improve
    % visualization
    normGamma = @(x,gamma) ((x - min(x(:)))/(max(x(:))-min(x(:)))).^gamma; 

    
    
    % fill axes1 with the ith-image
    axes(handles.axes1)
    imshow(handles.originalImage,[])
    freezeColors 
    
    
    axes(handles.axes2)
    imshow(normGamma(handles.PowerSpectrum,userDefinedGamma),[])
    colormap jet
    colorbar
    freezeColors

    
    
    % assemble the data for the idx-th entry in the spreadsheet
    Data = {handles.filename,...
        handles.SL,handles.SPD};
    % assembles the idx-th entry in a dataset format
    handles.Dataset = dataset({Data, VariableNames{:}});
        % update the GUI data structure
    guidata(hObject, handles);
    
        % merge the idx-th dataset with the others
        if idx1 == 1
            handles.TotalDataset = handles.Dataset;
        else
            handles.TotalDataset = cat(1, handles.Dataset,...
                handles.TotalDataset);
        end

        % plot the extracted numerical values in the GUI
    set(handles.edit1,'String',handles.SL);
    set(handles.edit2,'String',handles.SPD);
    
    % update the GUI data structure
    guidata(hObject, handles);      
        
    end
% if instead the user has preferred the analysis of a single image at a 
% time    
else
    
    % start the search from the folder containing the DEMO images
    [PATHSTR,NAME,EXT] = fileparts(pwd);
    imageFolder = [PATHSTR,...
        '\DemoImages\SPD\pCM\'];   

    
    % let the user select a specific iamge
    [filename, pathname] = uigetfile(...
        {'*.bmp;*.jpg;*.tif;*.png;','All Image Files';...
        '*.*','All Files' },...
        'Pick an image',...
        imageFolder);

    % if the user cancels here, return the GUI normal state
    
    if isequal(filename,0) || isequal(pathname,0)
        set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,'string',...
            'Analyze','enable','on');
        return

    end
    
    % store filename info for later use
    handles.filename = filename;
    handles.pathname = pathname;
    guidata(hObject, handles);
    
    % analyze the selected image
    handles = AnalyzeSingleImage([pathname, filename],hObject,...
        eventdata, handles);

    % a gamma correction of userDefinedGamma is adopted in the rest to improve
    % visualization    
    normGamma = @(x,gamma) ...
        ((x - min(x(:)))/(max(x(:))-min(x(:)))).^gamma; 

        
    % fill axes1 with the selected image
    axes(handles.axes1)
    imshow(handles.originalImage,[])
    freezeColors 
    
    % fill axes1 with the FFT of the selected image    
    axes(handles.axes2)
    imshow(normGamma(handles.PowerSpectrum,0.1),[])
    colormap jet
    colorbar
    freezeColors

    
    %       visualize the values of the 2 metrics in the GUI
    set(handles.edit1,'String',handles.SL);
    set(handles.edit2,'String',handles.SPD);
    
    %       update the GUI data structure
    guidata(hObject, handles);
    
    
end

% at the end of the computation restore normal GUI appearence
set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,...
    'string', 'Analyze','enable','on');
set(handles.pushbutton2,'enable','on');
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
% otherwise save the images
pause(1)
else
    % take an editable snapshot of the GUI
    saveas(gcbf,[handles.pathname,handles.filename,'ScreenShot.eps'],...
        'psc2')
    
    % export into a single EPS file the histogram and fitting
    figTemp = figure('visible','off');
    newax = copyobj(handles.axes2,figTemp);
    saveas(figTemp,[handles.pathname,handles.filename,...
        '_Originalimage.eps'],'psc2')
    close(figTemp)
    
    % export into a single EPS file the thresholded image
    figTemp = figure('visible','off');
    newax = copyobj(handles.axes2,figTemp);
    saveas(figTemp,[handles.pathname,handles.filename,...
        '_ThreshImage.eps'],'psc2')
pause(1)   
end

% update the appearence of the buttons
set(handles.pushbutton1,'Enable','on')
set(handles.pushbutton2,'BackgroundColor',[240, 240, 240]/255,'string',...
    'Save','enable','off');
guidata(hObject, handles);

%% CORE FUNCTIONS
% this section lists all the function that are specifically use to compute
% the SPD

%% Analyze single image
% main function that calls all the sub-routines needed to analyze a single
% image
function handles = AnalyzeSingleImage(filename,hObject,...
    eventdata, handles)
% image selection
handles = imageSelection(filename,hObject, eventdata, handles);        

% FFT calculation
handles = calculatePowerSpectrum(hObject, eventdata, handles);

% 1D Mapping
handles = radialIntegration(hObject, eventdata, handles);

% NON-LINEAR FITTING
handles = sarcPackDensityDetector(hObject, eventdata, handles);

%% Image Selection
function handles = imageSelection(filename,hObject, eventdata, handles)

handles.originalImage = imread(filename);

%% Folder Selection
function ListOfFiles = SelectFolder(hObject, eventdata, handles)
[PATHSTR,NAME,EXT] = fileparts(pwd);
imageFolder = [PATHSTR,...
    '\DemoImages\SPD\pCM'];

% d = uigetdir(pwd); % to start from the current folder
d = uigetdir(imageFolder); % to start from a folder containing demo files

   if isequal(d,0) || isequal(d,0)
        disp('User pressed cancel')
        set(handles.pushbutton1,'BackgroundColor',[240 240 240]/255,...
            string', 'Analyze','enable','on');
        return
   end
        
        
ListOfFiles = dir(fullfile(d, '*.tif'));

for idx1 = 1:length(ListOfFiles)
    ListOfFiles(idx1).name = [d,'\',ListOfFiles(idx1).name ];
end



function handles = calculatePowerSpectrum(hObject, eventdata, handles)

im = handles.originalImage;

% function [N, PxlSize, PowerSpectrum] = calc2DPowerSpectrum(im)
% FFT CALCULATIONS

% pad image for greater FFT speed

im = padtomakepowof2(im);
[ M, handles.N, ~ ] = size(im);

% helper in-line function to normalize values between 0 and 1
normGamma = @(x,gamma) ((x - min(x(:)))/(max(x(:))-min(x(:)))).^gamma; 
% gamma is used to improve the 2D visualization


% Perform 2D Fast Fouier Transform operations

fftA = fft2(double(im));
% obtain the DC value (# of pixels positive for cytoskeletal protein)
DCvalue = fftA(1,1);
% eliminate the DC value to avoid extremely high peak at the center
fftA(1,1) = 0;
% shift the FFT so the DC component is in the center and the orientations
% can be appreciated
freqComponts = fftshift(fftA);
% finally take the power of the spectrum
handles.PowerSpectrum = abs(freqComponts).^2;



function handles = radialIntegration(hObject, eventdata, handles)
% function [waveNum, Gamma] = radialIntegration(N,PxlSize,PowerSpectrum)
N = handles.N;
PxlSize = handles.PxlSize;
PowerSpectrum = handles.PowerSpectrum;


Fs_x = 1/PxlSize;
dFx = Fs_x/N; % cycles per micron
Fx = (-Fs_x/2:dFx:Fs_x/2-dFx)'; % cycles per micron

% transform in radial coordinates
[MFx MFy] = meshgrid(Fx,Fx);
[th ro] = cart2pol(MFx,MFy);

% Perform 2D to 1D mapping
% calculate the center of the matrix
nhalf = floor(N/2);

% perform radial integration of the 2D power spectru
dPxl = floor(numel(ro)/nhalf);
nmEL = dPxl*nhalf; % -> prepare for reshape

[rProfile,idx] = sort(ro(:));
y = rProfile.*PowerSpectrum(idx); % here is where we perform G(w) * w

% control for elements in the arrays that could not be reshaped
rProfile(nmEL+1:end) = [];
y(nmEL+1:end) = [];

% extract the 1D profile (integration)
ySum = sum(reshape(y,dPxl,nhalf),1)';
waveNum = mean(reshape(rProfile,dPxl,nhalf),1)';
% normalize the 1D profile so that the Area is 1
Gamma = ySum/trapz(waveNum, ySum);

handles.waveNum = waveNum;
handles.Gamma = Gamma;


function handles = sarcPackDensityDetector(hObject, eventdata, handles)

waveNum = handles.waveNum;
Gamma = handles.Gamma;


% Set up figure to receive data sets and fits
% anonymous functions
gaussianpeak = @(x,prms) prms(1)*exp(-((x-prms(2))/prms(3)).^2);
expPeak = @(x,prms) prms(1)*exp(-prms(2)*x)+ prms(3);
HWTM = @(x) sqrt(2*log(10))*x;
axes(handles.axes3)
cla
h_ = line(waveNum,Gamma,'Parent',handles.axes3,'Color','b',...
        'LineStyle','-', 'LineWidth',1,...
        'Marker','.', 'MarkerSize',12);

    % PERFORM FIT

%% fitting equation
fitEqn = ...
    ['a*exp(-b*x)+',...
    'a1*exp(-((x-b0)/c1)^2)+',...
    'a2*exp(-((x-2*b0)/c2)^2)+',...
    'a3*exp(-((x-3*b0)/c3)^2)+',...
    '+d'];
%% fitting range: lower limits
lowerLimits = ...
    [0,... % a
    0,0,0,... % a1-3
    0,... % b
    .4,... %b0
    0,0,0,... % c1-5
    0];% d
%% fitting range: upper limits
upperLimits = ...
    [0.5,... % a
    10,10,10,... % a1-3
    100,... % b
    0.7,... %b0
    0.15,0.15,0.15,... % c1-5
    1];% d    
%% fitting range: Starting points 
startingPoints = ...
    [.2,... % a
    1,0.5,0.1,... % a1-3
    0,... % b
    0.57,... %b0
    0.05,0.05,0.05,... % c1-5
    0]; % d
fo_ = fitoptions('method','NonlinearLeastSquares',...
    'Lower',lowerLimits,...
    'Upper',upperLimits);% d

ok_ = isfinite(waveNum) & isfinite(Gamma);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs',...
        'Ignoring NaNs and Infs in data.' );
end



set(fo_,'Startpoint',startingPoints);
ft_ = fittype(fitEqn,...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a', 'a1', 'a2', 'a3', 'b', 'b0',...
    'c1', 'c2', 'c3', 'd'});

% Fit this model using new data
    [cf gof_] = fit(waveNum(ok_),Gamma(ok_),ft_,fo_);

    vp = [coeffvalues(cf)];
    
    ParametersForPeak(1,:) = vp([2,6,7]);
    ParametersForPeak(2,:) = vp([3,6,8]);
    ParametersForPeak(2,2) = 2*ParametersForPeak(1,2);
    ParametersForPeak(3,:) = vp([4,6,9]);
    ParametersForPeak(3,2) = 3*ParametersForPeak(1,2);

    ParametersForExp = vp([1 5 10]);

    axes(handles.axes3)
    hold on
    plot(waveNum,expPeak(waveNum,ParametersForExp),'k','LineWidth',2)
    plot(waveNum,gaussianpeak(waveNum,ParametersForPeak(1,:))+...
        gaussianpeak(waveNum,ParametersForPeak(2,:))+...
        gaussianpeak(waveNum,ParametersForPeak(3,:)),'r','LineWidth',2)
    hold off
    set(handles.axes3,'box','off','TickDir','out'); 
    % ylim('auto');
    legend({'data','aperiodic','periodic'},'EdgeColor','white')
    xlabel('wavenumber \omega [\mu m ^{-1}]')
    ylabel('\Gamma (\omega) / E')

    
    axes(handles.axes3)
    legend({'data','aperiodic','periodic'},'EdgeColor','white')

SL = 1/ParametersForPeak(1,2);

flagPeak2 = ParametersForPeak(1,2) + HWTM(ParametersForPeak(1,3)) <=...
ParametersForPeak(2,2)-HWTM(ParametersForPeak(2,3));

flagPeak3 = ParametersForPeak(2,2) + HWTM(ParametersForPeak(2,3)) <=...
ParametersForPeak(3,2)-HWTM(ParametersForPeak(3,3));

sarcPackDensityEps = trapz(waveNum,...
        gaussianpeak(waveNum,ParametersForPeak(1,:))) +...
        flagPeak2*trapz(waveNum,...
        gaussianpeak(waveNum,ParametersForPeak(2,:))) +...
        flagPeak2*flagPeak3*trapz(waveNum,...
        gaussianpeak(waveNum,ParametersForPeak(3,:)));

handles.SL = SL;
handles.SPD = sarcPackDensityEps;

function A = padtomakepowof2(A,varargin)

% % % Default Values
padvalue=0;
defaultValues = {padvalue};
% % % Assign Values
nonemptyIdx = ~cellfun('isempty',varargin);
defaultValues(nonemptyIdx) = varargin(nonemptyIdx);
[padvalue] = deal(defaultValues{:});
% % ------------------------------------
B=A;
[M,N]=size(B);
type_A=class(A);
A=converttoclass(A,'double');
padvalue=converttoclass(padvalue,'double');
npo2=2^nextpow2(max(size(A)));
% % ------------------------------------
% % Padding process
A(1:npo2,1:npo2)=padvalue; % A expanded to required size
A(1:M,1:N)=B(1:M,1:N);     % 1:M,1:N locations filled with origincal values
% % OR
% % alternatively A can be padded using image processing tool
% % box method 'padarray' by following statement
% % A=padarray(A,[npo2-M,npo2-N],padvalue,'post'); 

% % ------------------------------------

A=converttoclass(A,type_A); % back to original type


%% GUI SUPPL FUNCTIONs
% do not edit

% --- Outputs from this function are returned to the command line.
function varargout = SPD_Ver1b0_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


        
