/*
 * This code generates mitochondrial masks and calculates Pearson's Correlation Coefficient.
 */


Main = "path-to-raw-images-folder";

//Find Input file location using any opened image from the folder
Input = Main+"BgS/"
//Make Output Directory within Input file location
Output = Main+"ROIs/"
Output2 = Main+"PCC/"
File.makeDirectory(Output);
File.makeDirectory(Output2);
//Get list of all files from Input
filelist = getFileList(Input);


for (i = 0; i < lengthOf(filelist)/2; i++) {
    if (endsWith(filelist[i], ".tif")) {
    	if (indexOf(filelist[i], "C0") >= 0) {
    		
    		
    		open(Input+"/"+filelist[i]);
    		resetMinAndMax();
    		C0  = getTitle();   		
			run("Auto Threshold", "method=Default white");
			run("Convert to Mask");
			run("Create Selection");
			roiManager("Add");
			close();
			   		
    		open(Input+"/"+filelist[i+(lengthOf(filelist)/2)]);
    		resetMinAndMax();
			C1  = getTitle();
    		/*run("Auto Threshold", "method=Otsu white");
			run("Convert to Mask");    		
    		run("Create Selection");
    		roiManager("Add");			

			roiManager("Select", newArray(0,1));
			roiManager("Combine");
			roiManager("Add");
			roiManager("Select", 0);
			roiManager("Delete");*/
			
			close("*");
			roiManager("Save", Output+"C0_"+C1+".roi");
			
			
    		open(Input+"/"+filelist[i]);
    		resetMinAndMax();
    		C0  = getTitle();
    		
    		open(Input+"/"+filelist[i+(lengthOf(filelist)/2)]);
    		resetMinAndMax();
			C1  = getTitle();
			
			run("Coloc 2", "channel_1=["+C0+"] channel_2=["+C1+"] roi_or_mask=[ROI Manager] threshold_regression=Costes manders'_correlation 2d_intensity_histogram costes'_significance_test psf=3 costes_randomisations=100");
			//run("Coloc 2", "channel_1=["+C0+"] channel_2=["+C1+"] roi_or_mask=<None> threshold_regression=Bisection manders'_correlation 2d_intensity_histogram costes'_significance_test psf=3 costes_randomisations=100");
			saveAs("Text", Output2+"C0_"+C1+".txt");
			
			close("Roi Manager");
			close("*");
			close("Log");
			    		
    		
    	}
    }
}


//roiManager("Open", "C:/Users/shahm/Desktop/VapKO Review coloc2/BgS/roi.roi");