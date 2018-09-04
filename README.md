PAVE (Parent ion Annotation and Verification Engine) is a set of matlab code for untargeted metabolites identification from LC-MS data using 13C and 15N isotopic labelings.

Instructions for using PAVE and running the example (requirement: Matlab 2015a or later):

1. Download or make a clone of the entire repository. (Note: due to large file size restrictions, the example LC-MS data are not included here, see step 2)
2. Follow the link below to download the LC-MS data files and save them in the folder "\example"
 https://drive.google.com/open?id=1C7gwniCSwdk2Povc0KpA_BBLbuCkzMRo
   There are two large files: "M_neg_yeast.mat" and "M_CID_neg_yeast.mat", which are generated from the original .mzXML files using the code in \tools\parse_neg.m and are required to run the PAVE example. 
   There's also a folder named "raw" which contains all the original .mzXML files for generating the above two files.   
3. Go to the folder "\example" and run PAVE_ini. This will initialize settings and load required data and configurations. (see PAVE workflow documentation for details)
   There are two files: "Peaklist_yeast_neg.csv" and "CID_neg_yeast.csv", which are generated using Peak detection function in El-maven software package.
4. Run PAVE_main (Stepwise batch runs for all the peaks). This will take a few hours. After the run is completed, please find "pks" in the workspace, which contains all the annotation results.
   Can use copy & paste or convert it into a table typing: tb = struct2table(pks) first and then save it as a excel spreadsheet using xlswrite().
5. Alternatively, for quick testing, select a single peak or a few peaks (e.g., type in the matlab commond line: i=3, or i=[5,7,13], or else) and then Run PAVE_main_single. This will work on the selected peaks only. Please find "pk" in the workspace for the results. 
6. (optional) type PAVE_stat to find out the statistics of features and adducts of all categories.
7. (optional) use atomcount_disp(M,pk,settings,rep) to visualize and verify the labeling pattern matching for C/N atomcount of a single pk.

PAVE_main goes through the following steps for each peak:
1) pave_find_dup.m -- remove duplicate peaks within the list
2) pave_atomcount.m -- Solve Carbon and Nitrogen counts for biological peaks. Those cannot be solved are background peaks
3) pave_junkremover.m -- annotate isotopes, adducts, multicharged and dimers
4) pave_identify_frag.m -- annotate fragments subject to CID enhancement
5) pave_find_lowC.m -- annotate high mass peaks with unsually low Carbon number (possible adducts)
6) pave_dbsearch.m -- formula match with the database

Please refer to the PAVE workflow documentation for the details of each function. 

