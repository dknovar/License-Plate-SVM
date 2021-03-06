
function varargout = IdentifikasiPlatKendaraan02(varargin)
% IDENTIFIKASIPLATKENDARAAN02 MATLAB code for IdentifikasiPlatKendaraan02.fig
%      IDENTIFIKASIPLATKENDARAAN02, by itself, creates a new IDENTIFIKASIPLATKENDARAAN02 or raises the existing
%      singleton*.
%
%      H = IDENTIFIKASIPLATKENDARAAN02 returns the handle to a new IDENTIFIKASIPLATKENDARAAN02 or the handle to
%      the existing singleton*.
%
%      IDENTIFIKASIPLATKENDARAAN02('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IDENTIFIKASIPLATKENDARAAN02.M with the given input arguments.
%
%      IDENTIFIKASIPLATKENDARAAN02('Property','Value',...) creates a new IDENTIFIKASIPLATKENDARAAN02 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IdentifikasiPlatKendaraan02_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IdentifikasiPlatKendaraan02_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IdentifikasiPlatKendaraan02

% Last Modified by GUIDE v2.5 08-May-2018 22:34:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IdentifikasiPlatKendaraan02_OpeningFcn, ...
                   'gui_OutputFcn',  @IdentifikasiPlatKendaraan02_OutputFcn, ...
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


% --- Executes just before IdentifikasiPlatKendaraan02 is made visible.
function IdentifikasiPlatKendaraan02_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IdentifikasiPlatKendaraan02 (see VARARGIN)

% Choose default command line output for IdentifikasiPlatKendaraan02
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IdentifikasiPlatKendaraan02 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IdentifikasiPlatKendaraan02_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse_btn.
function browse_btn_Callback(hObject, eventdata, handles)
% hObject    handle to browse_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I;
[nama_file, nama_path] = uigetfile('*.png;*.jpg;*.bmp','Pilih gambar');
if ~isequal (nama_file,0)
    I = imread(fullfile(nama_path,nama_file));
    guidata(hObject,handles);
    axes(handles.axes1);
    imshow(I);
    I = imresize(I, [120 200]);
else
    return;
end

% --- Executes on button press in preprocessing_btn.
function preprocessing_btn_Callback(hObject, eventdata, handles)
% hObject    handle to preprocessing_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%grayscale
    global I;
    global BWrmv;
    
    %grayscale
    G = rgb2gray(I);
    %figure, imshow(G), title('Gray Image');

    %adjust contrast
    G = imadjust(G, [.55 1], []);
    G = imadjust(G);
    %figure, imshow(G), title('Reduced Contrast Image');

    %binerisasi
    blocksize = [100 100];
    fungsi = @(block_struct) im2bw(block_struct.data, graythresh(block_struct.data));
    BW = blockproc(G, blocksize, fungsi);
    BW = imclearborder(BW);
    %figure, imshow(BW), title('Binary Image');

    %closing
    %BWd = bwmorph(BW, 'close', Inf);
    BWd = BW;
    %figure, imshow(BWd), title('Opening');

    %regionprops
    BWr = regionprops(BWd, 'BoundingBox', 'PixelIdxList');
    %figure, imshow(BWd), title('Region Props');
    %hold on;

    hw = vertcat(BWr(:).BoundingBox);
    BWrmv = BWd;
    for i=1:size(BWr,1)
        %rectangle('Position', BWr(i).BoundingBox,'edgecolor','red');
        if (hw(i, 3)>40 && hw(i,4)>40) || (hw(i, 3)<10  && hw(i,4)<10) || hw(i, 4)<10 || hw(i,4)>40 || hw(i,3)<5 || hw(i,3)>30
            BWrmv(BWr(i).PixelIdxList) = 0;
        end
    end
    %figure, imshow(BWrmv), title('Removed Unwanted Small Object');

    BWr2 = regionprops(BWrmv, 'BoundingBox', 'PixelIdxList');
    hw = vertcat(BWr2(:).BoundingBox);
    mean_w = sum(hw(:,3))/size(hw,1);
    mean_h = sum(hw(:,4))/size(hw,1);

    for i=1:size(BWr2, 1)
        if (hw(i,3) < (.9*mean_w) && hw(i,4) < (mean_h)) || hw(i,4) < .9*mean_h
            BWrmv(BWr2(i).PixelIdxList) = 0;
        end
    end
    BWrmv = imclose(BWrmv, strel('diamond', 1));
    axes(handles.axes2);
    imshow(BWrmv);
    
    segmentation_folder = '_SegmentedImage\';
    S = regionprops(BWrmv, 'BoundingBox', 'Image');
    for i=1:size(S,1)
%         fh = fopen('ResultFile.txt','w');
        namafile = strcat('objek',int2str(i),'.jpg');
        imwrite(~S(i).Image,strcat(segmentation_folder,namafile),'jpg');
        
    end
    global countobj;
    countobj = size(S,1);
%     figure, imshow(BWrmv);
    %figure, imshow(BWrmv), title('Removed Unwanted Small Object');


% --- Executes on button press in segmentasi_btn.
function segmentasi_btn_Callback(hObject, eventdata, handles)
% hObject    handle to segmentasi_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%regionprops

segmentation_folder = imageDatastore('_SegmentedImage');
% dirOutput = dir(fullfile(segmentation_folder,'*.jpg'));
segNames = segmentation_folder.Files;
mon = montage(segNames, 'Size', [1 8]);

axes(handles.pb3);
imshow(mon);

% --- Executes on button press in klasifikasi_btn.
function klasifikasi_btn_Callback(hObject, eventdata, handles)
% hObject    handle to klasifikasi_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global classifier;
global cellSize;
global countobj;
testDir = '_SegmentedImage';

testSet = imageDatastore(testDir);
numImages_test = numel(testSet.Files);
% trainingFeatures = zeros(numImages, hogFeatureSize, 'single');

for i = 1:countobj
    test_img = readimage(testSet, i);
    test_img = imresize(test_img, [33 16]);
%     test_img = imadjust(test_img, [.55 1], []);
%     test_img = imadjust(test_img);
%     test_img = rgb2gray(test_img);
%     test_img = ~imbinarize(test_img);  
%     test_img = bwmorph(test_img, 'thin', Inf);
  
    TestFeatures = extractHOGFeatures(test_img,'CellSize',cellSize); 
    predictedLabels(i) = predict(classifier, TestFeatures);
    val(i) = sprintf('%s', predictedLabels(i));
    
    
end
set(handles.cl_txt, 'String', val);

% --- Executes on button press in recognition_btn.
function recognition_btn_Callback(hObject, eventdata, handles)
% hObject    handle to recognition_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exit_btn.
function exit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to exit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in training_btn.
function training_btn_Callback(hObject, eventdata, handles)
% hObject    handle to training_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global classifier;
global cellSize;
trainingDir = 'dataset';


trainingSet = imageDatastore(trainingDir,   'IncludeSubfolders', true, 'LabelSource', 'foldernames');

cellSize = [2 2];
hogFeatureSize = 3780;

numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');

for i = 1:numImages
    train_img = readimage(trainingSet, i);
    train_img = imresize(train_img, [33 16]);
%     train_img = rgb2gray(train_img);
%     train_img = imadjust(train_img, [.55 1], []);
%     train_img = imadjust(train_img);
%     train_img = ~imbinarize(train_img);  
    trainingFeatures(i, :) = extractHOGFeatures(train_img, 'CellSize', cellSize);  
end

trainingLabels = trainingSet.Labels;

classifier = fitcecoc(trainingFeatures, trainingLabels);
