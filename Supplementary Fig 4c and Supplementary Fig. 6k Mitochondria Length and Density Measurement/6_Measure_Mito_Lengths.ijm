Output = getDirectory("image");
getDimensions(width, height, channels, slices, frames);
sw = 15 //straightened width
n_dendrites = height/sw;
n = roiManager("count");
d = 1;
for (i = 0; i < n; i++) {
    roiManager("select", i);
    run("Measure");
    Roi.getCoordinates(xpoints, ypoints);
    setResult("X", i, xpoints[0]);
    setResult("Y", i, ypoints[0]);  
    
    for (j = 0; j < height; j=j+sw) {
		if (ypoints[0] > j  && ypoints[0] < j+sw) {
			setResult("Dendrite", i, (j+sw)/sw);  
		}

	}

}

saveAs("Results", Output+"Mito Lengths.csv");
