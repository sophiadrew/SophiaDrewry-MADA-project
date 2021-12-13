

# Fall 2021 MADA Class Project Repository: Sophia Drewry
### Overview
This is the landing page for my fall 2021 MADA Class Project.
I am looking to see if the El Niño and La Niña weather phenomena can be used as a predictor of arboviral disease transmission, specifically dengue in Iquitos, Peru. 

## Order of operations for reproducable analysis
1) Raw data obtained from various sources is housed in the `raw_data` folder. 
2) Code/processing_code folder contains:
  - `processingscript.R` which processes data from Dengue Forecasting Project
  - `processingscript2.R` which processes data from NOAA and merges all data sets together
  Processed data is save to `processed_data`
3) Code/analysis_code/`exploratoryscript` contains an R script which loads the processed data and does some exploratory data analysis
  Tables and figures are saved to results/`exploratoryfigures` and used in the manuscript. Exploratory modeling are done in here as well
4) Code/analysis_code/`Analysis #1.Rmd`is the final model 
  Tabled and figures saved in the `results` folder.
5) Code/analysis_code/`Analysis #2.Rmd` is supplemental time series model attempts 
  Tabled and figures saved in the `results` folder.
6) Products/`manuscript` folder contains main Rmd document for the manuscript.
7) All figures not used in manuscript are in the /products/`Supplementary.Rmd` 


# Template structure

* All data goes into the subfolders inside the `data` folder.
* All code goes into the `code` folder or subfolders. `readme.md` provides more detail on data
* All results (figures, tables, computed values) go into `results` folder or subfolders.
* Manuscript is housed int the `products` subfolder.


This project is for my Fall 2021 [Modern Applied Data Science course] (https://andreashandel.github.io/MADAcourse/), taught Dr. Andreas Handel.


