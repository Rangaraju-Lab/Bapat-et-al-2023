/*
 * Run this code after opening a CZI file as hyperstack.
 * This code asks user to make ROIs to Crop
 * Ouput: Cropped images from both channels will be saved in folder "Crop"
 * Note: Repeat for All CZI Images you want to analyze with Coloc2 later
*/

Main = getDirectory("image");
name = File.nameWithoutExtension();

getDimensions(width, height, channels, slices, frames);
run("Split Channels");
//setTool("rectangle");
selectWindow("C1-"+name+".czi");
//setTool("freehand");
waitForUser("Make ROI to Crop \nPress t to add to ROI Manager \nClick OK when all ROIs are added");


Output = Main+"Crop/"
File.makeDirectory(Output);
roiManager("Save", Main+name+".zip");

for (i = 0; i < channels; i++) {
	n = roiManager("count");
	for (j = 0; j < n; j++) {
   		roiManager("select", j);
   		run("Duplicate...", "use");
   		
   		//Turn on when selection is freehand
   		
		run("Make Inverse");
		run("Set...", "value=0");
		run("Select None");
		  		
   		saveAs("Tiff", Output+"C"+i+"_Roi"+j+1+"_"+name);
   		close();
	}
	close();
}

close("Roi Manager");