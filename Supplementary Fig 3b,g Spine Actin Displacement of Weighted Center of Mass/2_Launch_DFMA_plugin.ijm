/* This code converts oval ROI selections to ploygon selections required for DFMA plugin and then launches the DFMA plugin.
 * User must manually adjust threshold, save weighted image and save coordinates for center of mass.
 */

Main = "path-to-background-subtracted-folder";
name = File.nameWithoutExtension; 
setOption("ScaleConversions", true);
run("8-bit");

//run("Set Measurements...", "centroid redirect=None decimal=3");
n = roiManager("count");
for (i = 0; i < n; i++) {
    roiManager("select", i);
    run("Convex Hull");
    roiManager("Add");
    //Roi.getCoordinates(xpoints, ypoints);
    //makeRectangle(xpoints[0]-10, ypoints[0]-10, 20, 20);
    //roiManager("add");
    // process roi here
}
for (i = 0; i < n; i++) {
    roiManager("select", 0);
    roiManager("delete");
}
run("Select None");
//saveAs("Tiff", Main+name+"_weighted.tif");
run("Dendritic Filopodia Motility Analyser");