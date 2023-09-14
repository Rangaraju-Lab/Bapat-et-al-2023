/*
 * This code asks the user to make a spine ROI on an open image of mito channel.
 * The image outside a 45 um radius from the spine is set to zero (referred to as cropped image)
 * The user is then asked to trace the dendrite manually.
 * Output: Cropped Image and Manually marked spine ROI and dendrite trace zip file.
 * Output files are tagged "Crop"
 * [Note: The image must be open before running the code. Output will be saved in the same folder as the image.]
*/

Output = getDirectory("image");
getPixelSize(unit, pixelWidth, pixelHeight);
r = 45 / pixelWidth;
name = File.nameWithoutExtension;
spine = 1
setTool("oval");
waitForUser("Circle Spine and then Press OK");
roiManager("Add");
roiManager("Show All");
roiManager("select", 0);
roiManager("Rename", "Spine");

setTool("multipoint");
waitForUser("Mark Point on Dendrite Underneath Spine and then Press OK");
roiManager("Add");
roiManager("select", 1);
roiManager("rename", "d_centre");

getSelectionCoordinates(x, y);
resetMinAndMax();
makeOval(x[0]-r, y[0]-r, 2*r, 2*r);
run("Make Inverse");
run("Set...", "value=0 stack");
run("Select None");

setTool("polyline");
waitForUser("Trace Dendrite \nVector orientation from cell body to distal end \nand then Press OK");
roiManager("Add");
roiManager("select", 2);
roiManager("Rename", "User's Trace");

run("Select None");
run("Remove Overlay");
roiManager("Show None");
roiManager("Save", Output+"Trace.zip");
saveAs("Tif", Output+"Crop_"+name+".tif");
//roiManager("Save", Output + name +"_"+ spine + ".zip");
//wait(1000);
//close("*");
//close("Roi Manager");
