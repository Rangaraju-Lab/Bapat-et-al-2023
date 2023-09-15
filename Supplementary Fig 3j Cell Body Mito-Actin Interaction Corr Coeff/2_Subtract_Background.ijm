/*
 * This code asks user to make Background ROI and subtracts background in cropped images.
 */
 
Main = "path-to-raw-images-folder";

//Find Input file location using any opened image from the folder
Input = Main+"Crop/"
//Make Output Directory within Input file location
Output = Main+"BgS/"
File.makeDirectory(Output);
//Get list of all files from Input
filelist = getFileList(Input);

for (i = 0; i < lengthOf(filelist)/2; i++) {
    if (endsWith(filelist[i], ".tif")) {
    	if (indexOf(filelist[i], "C0") >= 0) {
    		
    		open(Input+"/"+filelist[i]);
    		resetMinAndMax();
    		C0  = getTitle();
    		
    		open(Input+"/"+filelist[i+(lengthOf(filelist)/2)]);
    		resetMinAndMax();
			C1  = getTitle();

			run("Merge Channels...", "c1=["+C0+"] c2=["+C1+"] keep");
			
    		waitForUser("Select Background ROI");
    		Roi.getBounds(x, y, width, height);
      		close();
      		
      		open_images = getList("image.titles");
    		for (j = 0; j < lengthOf(open_images); j++) {
    			selectImage(open_images[j]);
      			name = open_images[j];
      			makeRectangle(x, y, width, height);	
      			run("Measure");
      			run("Select None");
      			bg = getResult("Mean", 0);
      			run("Subtract...", "value="+bg);
      			saveAs("Tiff", Output+name);
      			close();
      			close("Results");
	    	}
   		}
	}
}