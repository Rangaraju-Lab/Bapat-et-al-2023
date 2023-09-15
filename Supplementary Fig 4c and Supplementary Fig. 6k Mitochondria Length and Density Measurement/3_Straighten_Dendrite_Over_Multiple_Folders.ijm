/*
 * This code iterates over multiple folders, opens the image with label "BgS" in the filename and the corresponding ROI .zip file with "Trace" in the filename.
 * Manually traced ROI of the dendrite is interpolated to have more vertices.
 * Each vertex is snapped to local maxima to fit the dnedrite better.
 * [First and last vertex are anchored i.e. kept the same to avoid changing user defined start and end points] 
 * The fitted trace is used to straighten the dendrite.
 * Output: Straightened image and fitted ROI. Saved in respective subfolders.
 * Note: Output files have a label "Straightened" tagged at the end of filename. 
 * Output files also carry the label "BgS"...
 * Hence, DO NOT run the code twice without deleting the output files generated by previous run.
*/


//Location of Parent folder with each subfolder representing one spine.
Parent = "path-to-raw-images-folder"
folderlist = getFileList(Parent);

//Iterate over all subfolders
for (i1 = 0; i1 < lengthOf(folderlist); i1++) {
	print(folderlist[i1]);
	filelist = getFileList(Parent+folderlist[i1]);
	
	//Iterate over each file in subfolder
	for (j1 = 0; j1 < lengthOf(filelist); j1++) {
		print(filelist[j1]);
		
		//Open files containing "BgS" and "Trace" in filename
		if (indexOf(filelist[j1], "BgS") >= 0)  {
			open(Parent+folderlist[i1]+filelist[j1]);
			name =  File.nameWithoutExtension;
		}
		if (indexOf(filelist[j1], "Trace") >= 0)  {
			open(Parent+folderlist[i1]+filelist[j1]);
			
			//Select Manual Trace of the dendrite
			roiManager("select", 2);
			
			//Interpolation Interval
			intp_intv = 20;
			//Vertex Fit Radius
			vfrx = 3;
			vfry = 3;
			//Vertex Search Radius
			vsrx = 3;
			vsry = 3;
			//Vertex Circle Coordinate offset
			vccox = (vfrx-1)/2;
			vccoy = (vfrx-1)/2;
			
			//Vertex Interpolation
			run("Interpolate", "interval="+intp_intv+" smooth adjust");
			roi_slice = roiManager("count");
			Roi.getCoordinates(xpoints, ypoints);
			x_len = xpoints.length;
			new_xpoints = xpoints;
			new_ypoints = ypoints;
			
			// Anchor First Vertex
			vx = xpoints[0];
			vy = ypoints[0];
			new_xpoints[0] = vx;
			new_ypoints[0] = vy;
			
			//Find Maxima's around intermediate vertices
			for (i = 1; i < x_len-1; i++) {
				roi_count = roiManager("count");
				vx = xpoints[i] - vccox;
				vy = ypoints[i] - vccoy;
				for (j = vx-vsrx; j <= vx+vsrx; j++) {
					for (k = vy-vsry; k <= vy+vsry; k++) {
						j = round(j); //Silence for subpixel accuracy
						k = round(k); //Silence for subpixel accuracy
						makeOval(j, k, vfrx, vfry);
						roiManager("Add");
					}
				}
				roiManager("Deselect");
				roiManager("Measure");
				Mean_Table = Table.getColumn("Mean");
				close("Results");
				Mean_Table = Array.slice(Mean_Table, roi_count, lengthOf(Mean_Table));
				ind_max_res = Array.findMaxima(Mean_Table, 0);
				ind_max_roi = ind_max_res[0] + roi_count;
				roiManager("deselect");
				roiManager("select", ind_max_roi);
				Roi.getBounds(vx, vy, vbboxw, vbboxh);
				vx = vx + vccox;
				vy = vy + vccoy;
				new_xpoints[i] = vx;
				new_ypoints[i] = vy;
				roiManager("deselect");
				all_fits = Array.getSequence(roiManager("count"));
				all_fits = Array.slice(all_fits, roi_count, lengthOf(all_fits));
				unfits = Array.deleteValue(all_fits, ind_max_roi);
				roiManager("select", unfits);
				roiManager("Delete");
				roiManager("deselect");
			}
			
			// Anchor Last Vertex
			vx = xpoints[x_len-1];
			vy = ypoints[x_len-1];
			new_xpoints[x_len-1] = vx;
			new_ypoints[x_len-1] = vy;	
			
			//Make Fit Line using Updated Vertices
			makeSelection( "polyline", new_xpoints, new_ypoints );
			//Roi.setStrokeWidth(15);
			roiManager("Add");
			
			//Delete Vertex Fits
			vert_fits = Array.getSequence(roiManager("count"));
			vert_fits = Array.slice(vert_fits, roi_slice, vert_fits.length - 1);
			roiManager("select", vert_fits);
			roiManager("Delete");
			
			
			
			
			
			//Straightner
			run("32-bit");
			roiManager("Select", 0);
			run("Set...", "value=-1 stack");
			roiManager("select", 3);
			run("Straighten...", "title=Straightened_"+name+".tif line=15");
			setThreshold(-1000, -1);
			run("Create Selection");
			roiManager("Add");
			resetThreshold();
			run("Select None");
			run("16-bit");
			saveAs("Tif", Parent+folderlist[i1]+"Straightened_"+name+".tif");
			roiManager("deselect");
			roiManager("Save", Parent+folderlist[i1]+"Fit.zip");
			
			
			close("*");
			close("Roi Manager");
			close("Results");

		}
		
	}
	
}

