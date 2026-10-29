macro "COBRA Image Analysis"{
setBatchMode(true);
	run("Close All");
	numChannels = UserInterface_NumChannel();
	UserInterface_COBRAprms(numChannels);	
	}

function UserInterface_NumChannel(){
Dialog.create("COBRA interface 1/2")
Dialog.addNumber("num of channels",1)
Dialog.show();
numChannels = Dialog.getNumber();
return numChannels;
}

function UserInterface_COBRAprms(numChn){
ZstackOpts =  newArray("None", "maxInt", "StDev");

chnNames = newArray(numChn);
preProcFlags = newArray(numChn);
tubeFlags = newArray(numChn);
tubeValues = newArray(numChn);
maskFlag = newArray(numChn);
strTensFlags = newArray(numChn);
strTensValues = newArray(numChn);
ZprojTypes= newArray(numChn);

Dialog.create("COBRA interface 2/2")
for (i=0;i<numChn ;i++){
Dialog.addString("Channel"+(i+1)+":","channelName"+(i+1));
Dialog.addChoice("Z projection", ZstackOpts, "None" );
Dialog.addCheckbox("Preprocessing", true);
Dialog.addCheckbox("Tubeness", true);
Dialog.addSlider("Tubeness radius:", 1,5,1);
Dialog.addCheckbox("Perform LevelSet ",false );
Dialog.addCheckbox("Structure Tensor", true);
Dialog.addSlider("Structure Tensor radius:", 1,10,2);
}

Dialog.show();
print("\\Clear");

for (i=0;i<(numChn) ;i++){
chnNames[i] = Dialog.getString();
ZprojTypes[i] = Dialog.getChoice();
preProcFlags[i] = Dialog.getCheckbox();
tubeFlags[i] = Dialog.getCheckbox();
tubeValues[i] = Dialog.getNumber();
maskFlag[i] = Dialog.getCheckbox();
strTensFlags[i] = Dialog.getCheckbox();
strTensValues[i] = Dialog.getNumber();
}

folder = getDirectory("Choose the directory containing the images");
list = getFileList(folder);

print("START");

run("Clear Results");
print("Num of Files: " + list.length);

// Initialize txt file so that we can write on it later
f = File.open(folder+"COBRAimageJprms.csv");
headerSubString1 = "fileName" + " , " + "channelName" + " , ";
headerSubString2 = "ZprojType" + " , " + "localContrastEnhancer" + " , ";
headerSubString3 = "tubeness" + " , "+ "tubenessPrmValue" + " , " ;
headerSubString4 = "levelSetSegmentation" + " , ";
headerSubString5 = "StructureTensorMethod" + " , "+ "StrTensorPrmValue" + " , " ;
headerSubString6 = "VoxelSizeX" + " , " + "VoxelSizeY" + " , "+ "VoxelSizeZ";

Headers = headerSubString1 + headerSubString2 + headerSubString3 + headerSubString4;
Headers = Headers + headerSubString5 + headerSubString6;

// File.append(Headers,folder+"COBRAimageJprms.txt");
print(f, Headers);
// Analyze each image in the folder 
for (k=0; k<list.length; k++) {
path = folder+list[k];
open(path);
//
title = getTitle();
titleLength = lengthOf(title);
imageBaseName = substring(title,0,titleLength-4);
print(title);
getVoxelSize(voxelWidth, voxelHeight, voxelDepth, voxelUnit);
//setResult("VoxelSizeX",k,voxelWidth);
//setResult("VoxelSizeY",k,voxelHeight);
//setResult("VoxelSizeZ",k,voxelDepth);
//updateResults;
print(voxelWidth);
for (i=0;i<(numChn) ;i++){
headerSubString1 = list[k] + " , " + chnNames[i] + " , "+ ZprojTypes[i] + " , " + preProcFlags[i];
headerSubString2 = " , " + tubeFlags[i] + " , "+ tubeValues[i] + " , " + maskFlag[i];
headerSubString3 = " , " + strTensFlags[i] + " , "+ strTensValues[i]; 
headerSubString4 = " , " + voxelWidth +" , " + voxelHeight + " , " + voxelDepth;
ithStringToSave = headerSubString1 + headerSubString2 + headerSubString3 + headerSubString4;
print(f, ithStringToSave);
// File.append(ithStringToSave,folder+"COBRAimageJprms.txt");
}
if (numChannels > 1) {
run("Split Channels");
}
ChannelID = newArray(numChn);
for (i=0;i<(numChn) ;i++){


if (numChannels > 1) {
selectImage("C"+(i+1)+"-"+title);
}
	ChannelID[i] = getImageID();

}
for (i=0;i<(numChn) ;i++){
ChannelImageID = ChannelID[i];
if (ZprojTypes[i] != "None"){	
	finalZprojID = stdZproj(ChannelImageID,folder, imageBaseName,chnNames[i],ZprojTypes[i]);
	} else{
		finalZprojID = ChannelImageID;
	}
if (preProcFlags[i] == 1){
	contrastEnhancer(finalZprojID);
}

BinImageID = extractBinimage(finalZprojID,folder, imageBaseName,chnNames[i],maskFlag[i]);

if (tubeFlags[i] == 1){	
	CytImageID = extractCytoskComponents(finalZprojID,folder, imageBaseName,chnNames[i],tubeValues[i]);
}
if (strTensFlags[i] == 1){	
strTensorID = StructureTensorEvaluation(CytImageID,folder, imageBaseName,chnNames[i],strTensValues[i]);
}
closeByIDifOpen(ChannelImageID);
closeByIDifOpen(CytImageID);
closeByIDifOpen(finalZprojID);
closeByIDifOpen(BinImageID);
closeByIDifOpen(strTensorID);

}
}
saveAs("Results", folder+"ImageJpreProcessed\\PixelInfo.txt");
print("END OF COMPUTATIONs");
File.close(f);
}


// process Zstack to obtain Zproj
function stdZproj(inputID,path,imageName,ChannelName,ZprojType){
	
//	prefolder = path + ChannelName;
//	File.makeDirectory(prefolder);
	folder = path+"ImageJpreProcessed\\";
	File.makeDirectory(folder);
	string = folder+ imageName + "_" + ChannelName + "_zproj.tif";
	selectImage(inputID);
	rename("stdZprok_input");
	numSlices = nSlices();

if (ZprojType == "StDev"){
run("Z Project...", "start=1 stop=" + numSlices +" projection=[Standard Deviation]");
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
run("16-bit");
ZprojID = getImageID();


run("Duplicate...", "title=DuplicateImage.tif");
run("Make Binary");
run("Dilate");
run("Dilate");
run("Dilate");
run("Close-");
run("Fill Holes");
maskID = getImageID();
imageCalculator("Multiply create 32-bit", ZprojID,maskID);
run("16-bit");
saveAs("Tiff", string);
outputID = getImageID();
closeByID(maskID);
closeByID(ZprojID);
selectImage(outputID);
rename("stdZProj_output");
}else{
run("Z Project...", "start=1 stop=" + numSlices +" projection=[Max Intensity]");
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
run("16-bit");
ZprojID = getImageID();


run("Duplicate...", "title=DuplicateImage.tif");
run("Make Binary");
run("Dilate");
run("Dilate");
run("Dilate");
run("Close-");
run("Fill Holes");
maskID = getImageID();
imageCalculator("Multiply create 32-bit", ZprojID,maskID);
run("16-bit");
saveAs("Tiff", string);
outputID = getImageID();
closeByID(maskID);
closeByID(ZprojID);
selectImage(outputID);
rename("maxZProj_output");
}
return outputID;
}

// extract Binarized images
function extractBinimage(inputID,path,imageName,ChannelName,maskFlag){


//	prefolder = path + ChannelName;
//	File.makeDirectory(prefolder);
	folder = path+"ImageJpreProcessed\\";
	File.makeDirectory(folder);
	string = folder+ imageName + "_" + ChannelName + "_mask.tif";
	selectImage(inputID);
	rename("binImage_input");
run("Duplicate...", "title=DuplicateImage.tif");

run("8-bit");
run("Auto Threshold", "method=Default white");
run("Make Binary");
run("Dilate");
run("Close-");

if (maskFlag==1){
imWidth = getWidth()-4;
imHeight = getHeight()-4;
makeRectangle(2, 2, imWidth, imHeight);
run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=50 distance_threshold=0.50 advection=2.20 propagation=1 curvature=1 grayscale=30 convergence=0.0010 region=inside");
saveAs("Tiff", string);
outputID = getImageID();

selectWindow("DuplicateImage.tif");
close();
selectWindow("Segmentation progress of DuplicateImage.tif");
close();


selectImage(outputID);
rename("binImage_output");
} else{
saveAs("Tiff", string);
outputID = getImageID();
selectImage(outputID);
rename("binImage_output");
}
return outputID;
}
// extract false-colored images based on structure tensor analysis
function extractCytoskComponents(inputID,path, imageName,ChannelName,tubeValue){

//	prefolder = path + ChannelName;
//	File.makeDirectory(prefolder);
	folder = path+"ImageJpreProcessed\\";
	File.makeDirectory(folder);
	string = folder+ imageName + "_" + ChannelName + "_cyt.tif";
	string2 = folder+ imageName + "_" + ChannelName + "_cytMask.tif";
		selectImage(inputID);
	rename("tubenessImage_input");
run("Tubeness", "sigma=" + tubeValue);
run("16-bit");
saveAs("Tiff", string);
outputID = getImageID();
selectImage(outputID);
run("Duplicate...", "title=TubenessOutput.tif");
run("Make Binary");
run("Watershed");
saveAs("Tiff", string2);
//selectImage("TubenessOutput.tif");
close();
return outputID;
}


function StructureTensorEvaluation(inputID,path, imageName,ChannelName,strTenValue){
prefolder = path + ChannelName; 

//	prefolder = path + ChannelName;
//	File.makeDirectory(prefolder);
	folder = path+"ImageJpreProcessed\\";
	string = folder+ imageName + "_" + ChannelName + "_strTen.tif";
		selectImage(inputID);
	contrastEnhancer(inputID);
	
	run("OrientationJ Analysis", "log=0.0 tensor="+ strTenValue+" gradient=0 energy=off coherency=off harris-index=off color-survey=on distribution=off hue=Orientation sat=Coherency bri=Original-Image ");
	outputID = getImageID();
	selectImage(outputID);
	contrastEnhancer(outputID);
	saveAs("Tiff", string);
	return outputID;
}

// HELPER FUNCTIONs

// improve contrast in 2D image
function contrastEnhancer(inputID){
selectImage(inputID);
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
run("Enhance Local Contrast (CLAHE)", "blocksize=63 histogram=1024 maximum=2 mask=*None* fast_(less_accurate)");
outputID = getImageID();
return outputID;
}

// close the image associated with the ID passed as an argument
function closeByID(ID){
selectImage(ID);
close();
}

function closeByIDifOpen(ID){
if (isOpen(ID)==true){
selectImage(ID);
close();
}
}
