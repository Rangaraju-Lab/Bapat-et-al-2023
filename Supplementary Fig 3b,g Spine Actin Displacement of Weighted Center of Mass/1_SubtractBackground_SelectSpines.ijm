/*
 * This code asks user to select a background the mean backgroud intensity from the image.
 * User is then prompted to mark Spine ROIs using the oval selection tool.
 * Output: Background subtracted image and Spine ROI zip file
 * Note: Background subtracted image overwrites the raw image.
 */

Main = "Z:/DATA/Monil/Spine actin dynamics to analyze/Control vs VAP KO/";
Output = Main
name = File.nameWithoutExtension; 
//Subtract background from Images
setTool("rectangle");
waitForUser("Background Subtraction", "Make Background ROI and press OK");
run("Set Measurements...", "mean redirect=None decimal=3");
run("Measure Stack...");
run("Select None");
for (i = 1; i <= nSlices; i++) {
    setSlice(i);
    bg = getResult("Mean", i-1);
	run("Subtract...", "value="+bg);
}
run("Save");
close("Results");
resetMinAndMax();
setTool("oval");
waitForUser("Mark Spines ", "Make Spine ROI. \nPress t to add to ROI Manager. \nPress OK once all spines are added.");
roiManager("Save", Output+name+".zip");
close("*");
close("ROI Manager");