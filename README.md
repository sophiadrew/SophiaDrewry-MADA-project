

# Fall 2021 MADA Class Project Repository: Sophia Drewry
### Overview
This is the landing page for my fall 2021 MADA Class Project.
I am looking to see if the El Niño and La Niña weather phenomena can be used as a predictor of arboviral disease transmission, specifically dengue in Iquitos, Peru. 

# For Dr. Handel
Here is where the work for each project "part" can be found. Also included a little recap of what was done or previous files that were edited. Data analysis is a cyclical process after all! Updated 11/12
- Part 1: Project proposal found in `Proposal`
- Part 2: Data cleaning/processing found in Code/processing_code/`processingscript.R` & `processingscript2.R`
          EDA found in Code/analysis_code/`exploratoryscript`
          Manuscript updated in Products/`manuscript`
- Part 3: Decided to merge all data files after all in `processingscript.R` & `processingscript2.R` (There was a good bit done here. I             kept both Final merged data file as well as cleaned individual file because in the EDA, I did a small analysis of each data              set) 
          Added EDA models found in `exploratoryscript.Rmd`This was done on merged final data set. I also changed it from .R to .Rmd file
          Manuscript updated in Products/`manuscript`, added citations and figures
- Part 4:Manuscript updated in Products/`manuscript`. `processingscript2.R` updated as well with Poisson regression model, SARIMA, GAM and  LASSO model. I am a little ong on subsetting data and turning into a non time series 
- Part 5:

# Template structure

* All data goes into the subfolders inside the `data` folder.
* All code goes into the `code` folder or subfolders. `readme.md` provides more detail on data
* All results (figures, tables, computed values) go into `results` folder or subfolders.
* Manuscript is housed int the `products` subfolder.

# Order of operations for reproducable analysis

1) Raw data obtained from various sources is housed in the `raw_data` folder. 
2) Code/processing_code folder contains:
  - `processingscript.R` which processes data from Dengue Forecasting Project
  - `processingscript2.R` which processes data from NOAA and merges all data sets together
  Processed data is save to `processed_data`
3) Code/analysis_code/`exploratoryscript` contains an R script which loads the processed data and does some exploratory data analysis
  Tables and figures are saved to results/`exploratoryfigures` and used in the manuscript. Exploratory modeling are done in here as well
4) Code/analysis_code/`analysisscript`is the final model 
  Tabled and figures saved in the `results` folder.
5) Products/`manuscript` folder contains main Rmd document for the manuscript. 

This project is for my Fall 2021 [Modern Applied Data Science course](https://andreashandel.github.io/MADAcourse/), taught my Dr. Andreas Handel.


