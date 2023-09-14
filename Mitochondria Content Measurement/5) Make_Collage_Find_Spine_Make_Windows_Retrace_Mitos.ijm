/*
 * This code iterates over multiple folders, opens the image with label "Straightened".
 * Creates a collage of all straightened dendrites.
 * Finds coordinates of spine.
 * Creates 15 um windows on both side of the spine.
 * Output: Collage Image and ROIset with mitochondrial segments per window of 15 um until 45 um on both sides of spine. DOES  NOT save output automatically.
*/

//Location of Parent folder with each subfolder representing one spine.
Parent = "Z:/DATA/Monil/Ojasee_Mito Content Newly Imaged/Controls/"
//Location of ROISet file containing manual traces for each mitochondira over the collage image.
Manual_ROISet = "Z:/DATA/Monil/Ojasee_Mito Content Newly Imaged/Controls/RoiSet.zip"

//Set measurements to area, mean and centroid. These measurements are required within the code.
run("Set Measurements...", "area mean centroid redirect=None decimal=3");
//Create a dummy single pixel image to allow initiating combining multiple straightened images.
newImage("Combined Stacks", "16-bit black", 1, 1, 1);

//Create Collage of all straightened dendrites.
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
	    	setThreshold(0, 0, "raw");
			setOption("BlackBackground", false);
			run("Convert to Mask");
	    	run("Create Selection");
			roiManager("Add");
			close();
			open(Parent+folderlist[i1]+filelist[j1]);
	    	
	    	
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

//Find Spine Coordinates
Dendrite_Length = Table.getColumn("Dendrite_Length");
getDimensions(width, height, channels, slices, frames);
makeRectangle(0, 1, width, height);
run("Crop");

getPixelSize(unit, pixelWidth, pixelHeight);
n = roiManager("count");
for (i = 0; i < n; i++) {
    roiManager("select", i);
    roiManager("Measure");
    Roi.getCoordinates(xpoints, ypoints);
    x = getResult("X", 0);
    y = getResult("Y", 0) + (i*15);
    x = x/pixelWidth;
    
    close("Results");
    //makeRectangle(x, y, 1, 1);
    makePoint(x, y);
    roiManager("add");
    roiManager("deselect");
    // process roi here
}

for (i = 0; i < n; i++) {
    roiManager("select", 0);
    roiManager("delete");
}
close("Results");




//Create 15 um Windows
n_win0 = roiManager("count");
getPixelSize(unit, pixelWidth, pixelHeight);
n = roiManager("count");
roiManager("show all");



//Create 0 to 15 um windows on both sides of spine
win_015 = newArray(1);
win_150 = newArray(1);
for (i = 0; i < n; i++) {
    roiManager("select", i);
    Roi.getCoordinates(xpoints, ypoints);
    x = xpoints[0];
    y = ypoints[0];
    

    width = 15/pixelWidth;
    height = 15;
    
    rx1 = x - 15/pixelWidth;
    ry1 = i*15;
    makeRectangle(rx1, ry1, width, height);
    run("Measure");
    rmean = getResult("Mean", 0);
    Roi.getCoordinates(rxpoints, rypoints);
    
    if (rxpoints[0] > 0 && rxpoints[1] < Dendrite_Length[i]/pixelWidth) {
    	roiManager("Add");
    	win_150[i] =  "win_015";
    }
    else {
    	win_150[i] = 0;
    }
	close("Results");
     
    
    rx1 = x;
    ry1 = i*15;    
    makeRectangle(rx1, ry1, width, height);
    run("Measure");
    rmean = getResult("Mean", 0);
    Roi.getCoordinates(rxpoints, rypoints);
    if (rxpoints[0] > 0 && rxpoints[1] < Dendrite_Length[i]/pixelWidth) {
    	roiManager("Add");
    	win_015[i] =  "win_015";
    }
    else {
    	win_015[i] = 0;
    }
	close("Results");
    
    
}

//Create 15 to 30 um windows on both sides of spine
win_1530 = newArray(1);
win_3015 = newArray(1);
for (i = 0; i < n; i++) {
    roiManager("select", i);
    Roi.getCoordinates(xpoints, ypoints);
    x = xpoints[0];
    y = ypoints[0];
    

    width = 15/pixelWidth;
    height = 15;
    
    rx1 = x - 2*15/pixelWidth;
    ry1 = i*15;
    makeRectangle(rx1, ry1, width, height);
    run("Measure");
    rmean = getResult("Mean", 0);
    Roi.getCoordinates(rxpoints, rypoints);
    if (rxpoints[0] > 0 && rxpoints[1] < Dendrite_Length[i]/pixelWidth) {
    	roiManager("Add");
    	win_3015[i] =  "win_1530";
    }
    else {
    	win_3015[i] = 0;
    }
	close("Results");
    
    
    rx1 = x+15/pixelWidth;
    ry1 = i*15;    
    makeRectangle(rx1, ry1, width, height);
    run("Measure");
    rmean = getResult("Mean", 0);
    Roi.getCoordinates(rxpoints, rypoints);
    if (rxpoints[0] > 0 && rxpoints[1] < Dendrite_Length[i]/pixelWidth) {
    	roiManager("Add");
    	win_1530[i] =  "win_1530";
    }
    else {
    	win_1530[i] = 0;
    }
	close("Results");
     
}

//Create 30 to 45 um windows on both sides of spine
win_3045 = newArray(1);
win_4530 = newArray(1);
for (i = 0; i < n; i++) {
    roiManager("select", i);
    Roi.getCoordinates(xpoints, ypoints);
    x = xpoints[0];
    y = ypoints[0];
    

    width = 15/pixelWidth;
    height = 15;
    
    rx1 = x - 3*15/pixelWidth;
    ry1 = i*15;
    makeRectangle(rx1, ry1, width, height);
    run("Measure");
    rmean = getResult("Mean", 0);
    Roi.getCoordinates(rxpoints, rypoints);
    if (rxpoints[0] > 0 && rxpoints[1] < Dendrite_Length[i]/pixelWidth) {
    	roiManager("Add");
    	win_4530[i] =  "win_3045";
    }
    else {
    	win_4530[i] = 0;
    }
	close("Results");
    
    rx1 = x+2*15/pixelWidth;
    ry1 = i*15;    
    makeRectangle(rx1, ry1, width, height);

    Roi.getCoordinates(rxpoints, rypoints);
    if (rxpoints[0] > 0 && rxpoints[1] < Dendrite_Length[i]/pixelWidth) {
    	roiManager("Add");
    	win_3045[i] =  "win_3045";
    }
    else {
    	win_3045[i] = 0;
    }
	close("Results");
    
}


n_winn = roiManager("count");

roiManager("Open", Manual_ROISet);

n_mito = roiManager("count");

print(n_win0);
print(n_winn);
print(n_mito);




//Function to find the point of intersection between the edge of window and manual mitochondria trace
function interceptor(x1,y1,x2,y2, rx,ry) { 
	x1 = x1 - rx;
	y1 = y1 - ry;
	x2 = x2 - rx;
	y2 = y2 - ry;
	m = ((y2-y1)/(x2-x1));
	c = y1 - m*x1;
	return c;

}




n = roiManager("count");
roiManager("show all");


win0 = n_win0;
winn = n_winn;
mito0 = n_winn;
miton = n_mito;



/*Iterate over all windows and all mitochondria to find if the mitochondria are within the within.
*If yes, find if they intersect the edge of the window.
*If yes, find intersection points and re trace mitochondrial segment present just within the window and add to ROI manager.
*/
nmito_len = newArray(1);
//for all windows
for (win = win0; win < winn; win++) {
    roiManager("select", win);
    run("Clear Results");
    run("Measure");
    area = getResult("Area", 0);
    win_len = area/(15*pixelWidth);
    run("Clear Results");
    
    old_mitos = roiManager("count");
    
    //for all mitos
    for (mito = mito0; mito < miton; mito++) {
    	roiManager("select", mito);
    	
		roiarr = newArray(2);
		roiarr[0] = win;
		roiarr[1] = mito;
		
		roiManager("select", roiarr);
		roiManager("AND");
		st = selectionType();
		run("Select None");
		if( st != -1 ){ 
			
			roiManager("select", mito);
			Roi.getCoordinates(xpoints, ypoints);
			
			roiManager("select", win);
			Roi.getCoordinates(rxpoints, rypoints);
			rx1 = rxpoints[0] - 0.5;
			ry1 = rypoints[0];
			rx2 = rxpoints[1] - 0.5;
			ry2 = rypoints[1];
			
			
			
			for (i = 0; i < lengthOf(xpoints) - 1; i++) {
					x1 = xpoints[i];
					y1 = ypoints[i];
					x2 = xpoints[i+1];
					y2 = ypoints[i+1];
					
					if (x1 < rx1 && x2 > rx1 ){
						nxf = rx1;
						nyf = interceptor(x1,y1,x2,y2, rx1,ry1) + ry1;
						oxi1 = i;
						break;
					}
					else{
						nxf = xpoints[0];
						nyf = ypoints[0];
						oxi1 = 0;
					}
			}	
			for (i = 0; i < lengthOf(xpoints) - 1; i++) {
					x1 = xpoints[i];
					y1 = ypoints[i];
					x2 = xpoints[i+1];
					y2 = ypoints[i+1];
					
					if (x1 < rx2 && x2 > rx2 ){
						nxl = rx2;
						nyl = interceptor(x1,y1,x2,y2, rx2,ry2) + ry2;
						oxi2 = i+1;
						break;
					}
					else{
						nxl = xpoints[lengthOf(xpoints)-1];
						nyl = ypoints[lengthOf(ypoints)-1];
						oxi2 = lengthOf(xpoints)-1;
					}
			}	
			
			//print(oxi1, oxi2);
			
			
			xpoints[oxi1] = nxf;
			xpoints[oxi2] = nxl;
			nxpoints = Array.slice(xpoints,oxi1,oxi2+1);
			
			ypoints[oxi1] = nyf;
			ypoints[oxi2] = nyl;
			nypoints = Array.slice(ypoints,oxi1,oxi2+1);
			
			makeSelection("polyline", nxpoints, nypoints);
			roiManager("add");
			
		}
			
		
	}
	new_mitos = roiManager("count");
	select_mito = Array.getSequence(new_mitos-old_mitos);
	for (i = 0; i < lengthOf(select_mito); i++) {
		select_mito[i] = select_mito[i] + old_mitos;
	}
	roiManager("select", select_mito);
	roiManager("measure");
	roiManager("deselect");
	mito_len = Table.getColumn("Length");
	sum_mito_len = 0;
	for (i = 0; i < lengthOf(mito_len); i++) {
		sum_mito_len += mito_len[i];
	}
	nsum_mito_len = sum_mito_len/win_len;
	nmito_len[win - win0] = nsum_mito_len;
	//print(sum_mito_len, win_len, nsum_mito_len);

}

roiManager("select", Array.getSequence(n_win0));
roiManager("delete");
  

//Table.setColumn("win_150", win_150);
//Table.setColumn("win_015", win_015);
//Table.setColumn("win_3015", win_3015);
//Table.setColumn("win_1530", win_1530);
//Table.setColumn("win_4530", win_4530);
//Table.setColumn("win_3045", win_3045);
//Table.setColumn("Dendrite_Length", Dendrite_Length);
//Table.update;

win1 = Array.concat(win_150,win_015);
win2 = Array.concat(win_3015,win_1530);
win3 = Array.concat(win_4530,win_3045);

win12 = Array.concat(win1,win2);
win123 = Array.concat(win12, win3);

win_id = newArray(1);
t_win = 0
for (i = 0; i < lengthOf(win123); i++) {
	if (win123[i] != 0) {
		win_id[t_win] = win123[i];
		t_win += 1;
	}
}
run("Clear Results");
Table.setColumn("win_id", win_id);
Table.setColumn("n_mito_len", nmito_len);
Table.update;









