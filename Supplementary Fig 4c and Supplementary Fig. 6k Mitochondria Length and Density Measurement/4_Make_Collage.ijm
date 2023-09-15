/*
 * This code iterates over multiple folders, opens the image with label "Straightened".
 * Measures length of dendrite i.e. length of straightened window.
 * Creates a collage of all straightened dendrites.
 * Output: Collage Image and Dendrite Length csv file. Saved automatically in the parent folder.
*/


Parent = "Z:/DATA/Monil/Ojasee_Mito Content Newly Imaged/VAPKO/"
newImage("Combined Stacks", "16-bit black", 1, 1, 1);
folderlist = getFileList(Parent);
nr = 0
for (i1 = 0; i1 < lengthOf(folderlist); i1++) {
	print(folderlist[i1]);
	filelist = getFileList(Parent+folderlist[i1]);
	
	for (j1 = 0; j1 < lengthOf(filelist); j1++) {
		print(filelist[j1]);
	    if (endsWith(filelist[j1], ".tif")  && indexOf(filelist[j1], "Straightened") >= 0)  {
	    	open(Parent+folderlist[i1]+filelist[j1]);
	    	name = filelist[j1];
	    	getPixelSize(unit, pixelWidth, pixelHeight);
	    	getDimensions(width, height, channels, slices, frames);
	    	setResult("Dendrite_Length", nr, width*pixelWidth);
	    	setResult("image_id", nr, folderlist[i1]);
	    	nr = nr + 1;
	    	run("Select All");
	    	run("Combine...", "stack1=[Combined Stacks] stack2=["+ name +"] combine");
	    	run("Set Scale...", "distance=1 known="+ pixelWidth +" unit="+ unit +"");
	    	//print(filelist[j]);
	     	}
	    }
    }

getDimensions(width, height, channels, slices, frames);
makeRectangle(0, 1, width, height);
run("Crop");

saveAs("Results", Parent+"Dendritic Lengths.csv");
saveAs("tif", Parent+"Collage");