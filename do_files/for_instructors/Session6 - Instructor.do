****************************************
* PP297: Stata for Policy Analysts     *
* Session 6: Survey Data Management    *
* Created by: Aaron Scherf             *
* Instructor Edition                   *
****************************************

*******************
* Today's Topics: *
*******************
* Review: Data Exploration
* IPUMS Survey Data
* Survey Weights
* Data Types: Cross-Section, Longitudinal, Panel
* append
* merge
* Review: Building a Regression Model
* Bonus: Interaction Terms

* Required packages:
* ssc install estout, replace

************************************
* Loading in IPUMS Household Data: *
************************************

set more off

* First set your command directory to the data folder:
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19\data"

* Then bring in the data file with use:
use "CPS.dta", clear

*********************************
* Review: Exploring Survey Data *
*********************************

* Let's see what variables we have:

summarize

	* Immediately you can tell that month is rather useless, since everyone has a value of 3
	
drop month	

* Family income also looks odd...

tab faminc, m	// Now we know it's a categorical variable, not an actual measure of income.
	
* Several variables' meaning aren't obvious: cpsidp, asecwt, classwkr
	
summarize cpsidp // Looks like an ID

summarize asecwt // These are survey weights. We'll discuss these soon.

tab classwkr, m	// Categorical, though no idea what "NIU" means.
	* Time to ask Google: https://cps.ipums.org/cps-action/variables/CLASSWKR#codes_section
		* Turns out it means "Not in Universe", so samples for that year weren't asked or didn't have responses recorded.
		* Seems to me a bit like an NA, since we don't have any info about them, but...
		* They weren't made missing at random. There was a reason they were coded that way, so we can't delete the data in good faith.
		
		
* Then take a look at some of the other variables (used a variety of commands just as a review):

tab year, m

tab statefip, m

table year, contents(n faminc mean faminc median faminc sd faminc)

tabstat age, by(year) s(n mean median sd)

codebook race, m

codebook marst, m

tab empstat, m

tab labforce, m 

tab uhrsworkt, m // This is funny to me because the German word for clock is "Uhr"

tab wkstat, m

codebook educ

******************************************
* Live Example of Downloading IPUMS Data *
******************************************

* Go to: https://www.ipums.org/

* Navigate to the Current Population Survey (CPS) and prepare a data download.

* Use the included Stata do-file text to convert the .dat to a .dta file

******************************
* Survey Weights in Analysis *
******************************

* All data that has been sampled to reflect a wider population should come with "weights"
	* These reflect the lack of perfect randomization in sampling (usually impossible to fully randomize)
	* They help account for under or over represented respondents, so the sample more accurately reflects the population

* Stata can easily incorporate weights into most commands with weight options:
help weight	

* There are 4 main types of weights: 
	* pweight (sampling or probability),
	* fweight (frequency), 
	* aweight (analytic), 
	* and iweight (importance)
	* For more: https://www.cpc.unc.edu/research/tools/data_analysis/statatutorial/sample_surveys/weight_syntax

	* BUT! Not all weights can be used with all commands.
	* There are a lot of statistical details involved here.
	* For this brief intro, all we need to know is that pweight is generally preferred.
	* When not available (as in summarize) we can use aweight.
	* For more details: https://www.stata.com/support/faqs/statistics/weights-and-summary-statistics/

summarize age

summarize age [aweight=asecwt]	// Notice the difference in mean and sd values

* The key statistical difference is that weights attempt to balance a sample to better reflect the population.
* Without weights, the summary statistics only reflect information on that sample.
	
tabstat age, by(sex) s(n mean median sd)

tabstat age [aweight=asecwt], by(sex) s(n mean median sd)

ttest age, by(sex)

ttest age [aweight=asecwt], by(sex) // T-Tests don't like weights

regress age sex

regress age sex [pweight=asecwt] // But seemingly identical bivariate regressions do?

	* Given that the regression is different with weights, that means we can't use the ttest to describe the population.

	* Review of Sampling Methods: https://stattrek.com/survey-research/sampling-methods.aspx

	* Quick summary on types of Data: https://en.wikibooks.org/wiki/Econometric_Theory/Data
	* Slides on Panel Data vs Pooled Cross Section: http://staff.utia.cas.cz/barunik/files/Econometrics/Econometrics_Lecture_5_print.pdf
	
*********	
* Merge *
*********

* Merging: Adding variables to a data file based on a unique ID variable
	* The observations may be the exact same (1:1), though you can also match uneven data by ID's (1:m or m:1)
	
* As an illustration, let's split up our dataset:
	
* But first, what ID variable uniquely identifies each observation?

* There are a lot of ID variables in the dataset. 
	* I explored several options and eventually found that a combo of serial, pernum, and year covered everyone.

* So let's combine them into a string:

egen serial_pernum_year = concat(serial pernum year), punct("_")

histogram serial_pernum_year // This is what a unique identifier should do--only one example of each observation.

codebook serial_pernum_year // Also shows us a count of unique values

save "CPS.dta", replace // So our original data has the unique Id.

keep serial_pernum_year uhrsworkt wkstat educ // Let's keep a subset of variables, including our unique ID

save "CPI_subset.dta", replace // Save the subset in a different file.

use "CPS.dta", clear // Bring back our original data.

drop uhrsworkt wkstat educ // Remove the variables from our subset (just to prove that we can merge them back in)

* Now we can use merge to bring those variables back into our dataset using the unique ID
	
help merge 	
	
merge 1:1 serial_pernum_year using "CPI_subset.dta"

* Successful merge! Our old variables are back in the data!
	
* Merge outputs the number of observations matched successfully and records this info in a variable, "_merge"
		* Since we had a perfect match, we can get rid of the _merge variable
		
drop _merge		
	
**********	
* Append *
**********

* Append is similar to merge, but instead of adding new variables based on a unique ID,
	* append adds new observations using the same list of variables
	
* Again, we'll split our original data to demonstrate:

use "CPS.dta", clear // Bring back our original data.

keep if year == 2008 // Drop all observations with year not equal to 2008

save "CPS_2008.dta", replace

use "CPS.dta", clear // Bring back our original data.

drop if year == 2008 // Drop those same observations from the original data.

append using "CPS_2008.dta"	
	
* Now we're back to our original data again!	
	* Remember, order doesn't really matter usually, but if you want to reorganize the data by year:
	
sort year

*************************************************************
* Bonus: Practice with Model Building and Regression Output *
*************************************************************

use "CPS.dta", clear // Bring back our original data.

* First let's see what may be related to each other:
pwcorr age sex race marst empstat labforce classwkr uhrsworkt wkstat educ [aweight=asecwt]

* Second, we know that (for now) we can only run regressions with continuous dependent variables.
		* The only cont. variables are age and uhrsworkt
		* Since we don't tend to think of anything explaining age except time, let's use hours worked.
		
* If we want to treat it as continuous we have to make sure there are no "categories" left:
		
tab uhrsworkt, m
tab uhrsworkt, m nolab	// Clearly 997 and 998 are "categories", no one is working that many hours.

* We can either drop those observations, replace them with missing ".", or just restrict future commands to not include them.
* I like the last option to avoid losing data. However, keep up with how many observations you lose from your tests!

pwcorr uhrsworkt age sex race marst empstat educ [aweight=asecwt] if uhrsworkt < 995
	
* From an initial correlation, hours worked is decently associated with sex, marital status, education, and age.
		* Those sound like good candidates for a regression model.
		
* Let's start our model with a bivariate of the strongest relationship:

regress uhrsworkt sex [pweight=asecwt] if uhrsworkt < 995	// Yay, significant p-values!

* Now let's add the next strongest correlation:

regress uhrsworkt sex marst	[pweight=asecwt] if uhrsworkt < 995	// Still significant, with  higher adj. r-squared

* But wait, what do our coefficients mean?
codebook sex 
	
	* So 1 is male, 2 is female. A 1-unit increase in "sex" would be a change from male to female.
	* So in our last model, females work, on average, 4.78 hours less than males.
	* But what about marital status?

codebook marst	

	* A 1-unit increase from married with spouse present to married spouse absent?
	* Then another 1-unit increase is separated?
	* Then another 1-unit increase is divorced, followed by widowed, and never married?
	
	* Unless you have a really negative outlook on marriage, this scale doesn't make "numeric" sense
	
	* We know it's a categorical variable in which the order doesn't matter, but Stata doesn't.
	* We call this categorical, or more appropriately nominal, as opposed to an ordinal variable.
	* Ordinal variables have a meaningful order: like a scale from 1-5, or a ranking from 1st to 10th.
		* For more info: https://stats.idre.ucla.edu/other/mult-pkg/whatstat/what-is-the-difference-between-categorical-ordinal-and-interval-variables/
		
	* If we want Stata to know our variable is categorical (not continuous), we put an "i." in front of the variable

regress uhrsworkt i.sex i.marst [pweight=asecwt] if uhrsworkt < 995
	
	* Remember though, Stata needs at least one category from each variable to serve as a "baseline" against which other values are measured
	* So our interpretation would be:
	* Females work 4.61 hours less than males on average
	* Married with spouse not present work 0.32 hours less than married with spouse present
	* Separated work 0.706 hours less than married with spouse present
	* Divorced work 0.597 hours more
	* Widowed 3.14 hours less
	* Never married 4.019 hours less
	
	* Is married with spouse present the default we want to compare everything else against?
	* If so, continue. If not, you can recode the categories:
	
	recode marst (6 = 0)
	label define marst_lbl 0 "Never married / Single", modify
	label values marst marst_lbl
	
	tab marst, m
	
	regress uhrsworkt i.sex i.marst [pweight=asecwt] if uhrsworkt < 995
	
	* Suddenly our coefficients on marital status are positive; everyone works more than single people (on average)
		* I assume they don't count education as employment...

	* But what if we were concerned that those marital status variables are just proxying age?	
	
	regress uhrsworkt i.sex i.marst age [pweight=asecwt] if uhrsworkt < 995
	
	* Age is clearly significant, and the marital status values changed, so our intuition seems correct.
	* But we know education status is likely also associated with age.
	
	regress uhrsworkt i.sex i.marst age i.educ [pweight=asecwt] if uhrsworkt < 995

	* Looks like higher education leads to longer working hours... Tough luck for us.
	
	* But we aren't accounting for whether people are employed!
	
	regress uhrsworkt i.sex i.marst age i.educ i.empstat [pweight=asecwt] if uhrsworkt < 995
	
	* Wait a minute...
	
	tab empstat, m // There are more categories here.
	tab empstat if uhrsworkt < 995 // But the data aren't recorded for the unemployed!
	
	* So we inadvertently restricted our sample to the employed earlier with our "if uhrsworkt < 995" condition
	
	* So back to our previous model. But let's see if race has an effect:
	
	regress uhrsworkt i.sex i.marst age i.educ i.race [pweight=asecwt] if uhrsworkt < 995
	
	* Wow, lots of categories. Let's make our lives easier with a dummy:
	tab race, m
	tab race, m nolab
	
	recode race (100 = 0) (200 = 1) (300 = 2) (651 = 3) (652 = 4) (801/830 = 5), gen(race_reduced)
	label define race_reduced_lbl 0 "White only" 1 "Black only" 2 "Native American Only" 3 "Asian Only" 4 "Hawaiian/Pac Island Only" 5 "Two or More"
	label values race_reduced race_reduced_lbl
	
	regress uhrsworkt i.sex i.marst age i.educ i.race_reduced [pweight=asecwt] if uhrsworkt < 995

	* Better! But what if we were concerned about the intersection of race and sex?
	* We can use what we call an interaction term. In Stata this uses ## between variables
	
	regress uhrsworkt i.sex##i.race_reduced i.marst age i.educ [pweight=asecwt] if uhrsworkt < 995

	* Interpreting interaction terms is somewhat tricky.
	* We see that identifying as female reduces working hours by 5.29 on average
	* Identifying as black is associated with working 0.853 hours less on average
	* But identifying as both black and female is associated with 2.96 hours more work on average
	
	* From this, we would say that, on average, women (regardless of race) work fewer hours as a group
	* Likewise, those identifying as black (regardless of gender) work fewer hours
	* But, black women (as an intersection of the two) work more hours (relative to white women)
	
		* To read more on interaction terms: https://hbs-rcs.github.io/2017/02/14/interpreting-interaction-term-in-a-regression-model/
	
	* This is only accounting for "official" hours worked at a formal job, but that's a US Cenus problem

* So let's output these models we built into a table:

* ssc install estout, replace // If you haven't yet installed estout

eststo: quietly regress uhrsworkt i.sex [pweight=asecwt] if uhrsworkt < 995
eststo: quietly regress uhrsworkt i.sex i.marst [pweight=asecwt] if uhrsworkt < 995
eststo: quietly regress uhrsworkt i.sex i.marst age [pweight=asecwt] if uhrsworkt < 995
eststo: quietly regress uhrsworkt i.sex i.marst age i.educ [pweight=asecwt] if uhrsworkt < 995
eststo: quietly regress uhrsworkt i.sex i.marst age i.educ i.race_reduced [pweight=asecwt] if uhrsworkt < 995
eststo: quietly regress uhrsworkt i.sex##i.race_reduced i.marst age i.educ [pweight=asecwt] if uhrsworkt < 995

esttab using "CPS_hours_model.rtf", label replace title("Full Regression Table") mtitle("Reduced Model" "Marital Status" "Age" "Education" "Race" "Race Interaction") r2 ar2
		
eststo clear // Make sure to clear the estimates after so you don't use them in future regression tables!
	
* Looking at the output table, it worked but it seems like too much info to include in a report...
* Fortunately, there is a Stata command to "absorb" categorical controls in a regression: areg

eststo: quietly reg uhrsworkt i.sex [pweight=asecwt] if uhrsworkt < 995
eststo: quietly reg uhrsworkt i.sex i.marst [pweight=asecwt] if uhrsworkt < 995
eststo: quietly reg uhrsworkt i.sex i.marst age [pweight=asecwt] if uhrsworkt < 995
eststo: quietly areg uhrsworkt i.sex i.marst age [pweight=asecwt] if uhrsworkt < 995, absorb(educ)
eststo: quietly areg uhrsworkt i.sex i.marst age i.race_reduced [pweight=asecwt] if uhrsworkt < 995, absorb(educ)
eststo: quietly areg uhrsworkt i.sex##i.race_reduced i.marst age [pweight=asecwt] if uhrsworkt < 995, absorb(educ)

esttab using "CPS_hours_model_red.rtf", label replace title("Full Regression Table") mtitle("Reduced Model" "Marital Status" "Age" "Education" "Race" "Race Interaction") r2 ar2
		
eststo clear // Make sure to clear the estimates after so you don't use them in future regression tables!
	
* Still a pretty big table. You can always delete certain variables from the table manually, or use estout options to suppress them being included.
		* Typically, if a variable isn't the "main relationship of interest", we can get away with not reporting it in the main output table.
		* As long as you mention in a subscript below the table which controls you included but didn't report on.
		* Then include a full table in the appendix of the paper.

* Of course you can also try dropping some variables from the model, but this could reduce your r-squared value if they are significant predictors.		
