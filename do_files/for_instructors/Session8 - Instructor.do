****************************************
* PP297: Stata for Policy Analysts     *
* Session 8: Intro Stata Programming   *
* Created by: Aaron Scherf             *
* Instructor Edition                   *
****************************************

*******************
* Today's Topics: *
*******************
* Review: Reshape, Macros, Loops
* Preserve / Restore
* Collapse
* Clustered Errors
* Testing Heteroskedasticity
* Robustness Checks
* RCT's and Randomization Tests (if time allows)

*************************
* Loading in PSID Data: *
*************************

set more off

* First set your command directory to the data folder:
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19"

* Then bring in the data file with use:
use "data\PSID_Long_Update.dta", clear 
* I included the data folder here as we want to use our main directory more later.

******************************************
* Review: Reshape, Macros, and For Loops *
******************************************

* First let's store all of our non-ID variables in a global macro:

global varlist_years Ind_RELEASENUMBER_ Ind_1968INTERVIEWNUMBER_ Ind_PERSONNUMBER68_ Ind_SEXINDIVIDUAL_ Fam_RELEASENUMBER_ Fam_CURRSTATE_ Fam_A8ACTUALROOMS_ Fam_A19OWNRORWHAT_ Fam_A20HOUSEVALUE_ Fam_A25MNTHLYPMTSMOR1_ Fam_W38BWTRHASSTUDLOANS_ Fam_W39B1AMOUNTSTUDLOANS_ Fam_H1HEALTHSTATUSHEAD_ Fam_H22WTINPOUNDSHEAD_ Fam_H1HEALTHSTATUSSPOUSE_ Fam_H22WTINPOUNDSSPOUSE_ Fam_IMPWEQUITY2_ Fam_HOUSINGEXP_ Fam_REXP_ Fam_CURRREGION_ Fam_IMMIGFAMWTNUMBER1_ Ind_INTERVIEWNUMBER_ Ind_SEQUENCENUMBER_ Ind_AGEINDIVIDUAL_ Ind_EMPLOYMSTATUS_ Ind_YEARSCOMPLETEDEDU_ Ind_G76NUMBERJOBSINPY_ Ind_TOTALLABORINCOME_ Ind_TOTALTAXABLEINCOME_ Ind_IMMINDIVIDUALWT_ Fam_FAMWT_ Ind_FEMALE_ Ind_GOODHEALTH_

* Last session we discussed reshaping between wide and long data formats:
	* Wide data typically refers to having more variables and fewer observations
	* Long data refers to having more observations and fewer variables
	* Both use a unique ID for the observations
		* But in long format, the ID may repeat over multiple rows
		* This is because there is a secondary variable that identifies them as unique, such as year
		
* Stata's reshape command can transform data from one type to the other, using the unique id (i) and secondary variable (j)

* ----------------------------------------------------------------------------- *
* Challenge 1: Reshape to the wide format using the UniqueID and year variables *
* ----------------------------------------------------------------------------- *

reshape wide Ind_RELEASENUMBER_ - Ind_GOODHEALTH_, i(UniqueID) j(year)	
	
* Notice the changes to the varlist and number of observations	
	
* And now we can switch back to long with the global macro we made!
	* Be sure to use a $ in front of the macro name, surrounded by quotes!


* --------------------------------------------------------------------------------------------- *
* Challenge 2: Reshape to the long format using a global macro, the UniqueID and year variables *
* --------------------------------------------------------------------------------------------- *	
	
reshape long "$varlist_years", i(UniqueID) j(year)

	* For more on reshape: https://stats.idre.ucla.edu/stata/modules/reshaping-data-wide-to-long/
	
* --------------------------------------------------------------------------------------------------------------------------------------- *	

* Local macros, meanwhile, are only stored within a set of specific commands.
	* If you run two lines together from a do-file, the local will apply.
	* But if you run them separately they won't!
	* So if you are just running the whole do-file you can use a local, but if you want to run it in pieces you would need a global.
	
local time_warp = "time is fleeting"

	* But calling them is different:
	
display "`time_warp'"

	* Notice the ` at the beginning and ' at the end, all surrounded by double quotes.
	* But you'll notice if you tried to run those separately it won't display.
	* Run the following two lines together (highlight both and hit "do")

local time_warp = "time is fleeting"
display "`time_warp'" 

* For more on macros: https://jearl.faculty.arizona.edu/sites/jearl.faculty.arizona.edu/files/Intro%20to%20loops,%20Year%202.pdf
	* https://data.princeton.edu/stata/programming
	
* ----------------------------------------------------------------------------------------------------------------------------------------------------- *	

* For loops allow you to make Stata do something repetitive automatically.
	* If you are doing a lot of pointing and clicking or copying and pasting, for loops are your friend
	
* There are two kinds of for-loops:
		* foreach runs commands over a list of things
		* forvalues runs commands over a set of numbers
		
* Both use locals inside of the loop to replace a placeholder with the list items.

foreach var of varlist Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ {
summ `var'
}

* The term "var" is a local macro!
		* When calling it within the loop, be sure to use backticks(`) at the beginning and apostrophes (') at the end
		* Note that you don't need to include quotes around the local when you call it, since it's a variable name rather than character string		

* We can use for loops to run lots of summary statistics:

* ---------------------------------------------------------------------------- *
* Challenge 3: Use a foreach loop to tabstat Age and Years of Education by Sex *
* ---------------------------------------------------------------------------- *
	
foreach var of varlist Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ {
tabstat `var', by(Ind_SEXINDIVIDUAL_) s(n mean median sd)
}


* Here is an example of a for-loop that saves a density plot for each of the variables specified.
	* You can export them using the graph export command, then include the variable name in the filepath 
		* to make sure you differentiate a new file for each graph
			
mkdir "Graphs" // Creates a new directory inside your WD called "Graphs"			
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19\Graphs"		
		
foreach var of varlist  Fam_A8ACTUALROOMS_ Fam_A20HOUSEVALUE_ Fam_A25MNTHLYPMTSMOR1_ Fam_W39B1AMOUNTSTUDLOANS_ Fam_H22WTINPOUNDSHEAD_ Fam_H22WTINPOUNDSSPOUSE_ Fam_HOUSINGEXP_ Fam_REXP_ {
kdensity `var'
graph export "kdensity_`var'.png", as(png) replace
}

* As you can imagine, you can do this for summary stats too:

cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19"		

mkdir "Summary_Tables"

* You can also set your command directory via a global macro:

global path "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19"

cd "$path\Summary_Tables"

* Then a loop with the estpost and esttab commands

foreach var of varlist Fam_H22WTINPOUNDSHEAD_ Fam_H22WTINPOUNDSSPOUSE_ {
estpost summ `var'
esttab using "summ_`var'.rtf", cells("mean sd count") noobs label replace
eststo clear
}

* Though you can produce nice tables of multiple variables with estpost without loops:

estpost summ Fam_H22WTINPOUNDSHEAD_ Fam_H22WTINPOUNDSSPOUSE_ 
esttab using "summ_weight_both.rtf", cells("mean sd count") noobs label replace
eststo clear

help estpost // For more details on estpost


* For more on loops: https://data.library.virginia.edu/stata-basics-foreach-and-forvalues/	
	* https://www.ssc.wisc.edu/sscc/pubs/stata_prog1.htm

* For more on outputting to Windows: https://www.cpc.unc.edu/research/tools/data_analysis/statatutorial/misc/exporting_results


**********************
* Preserve / Restore *
**********************

* Have you ever worried about dropping variables or observations that you want back later?
* Clearly you can get around this by re-using the data:

cd "$path"
use "data\PSID_Long_Update.dta", clear	

* But a quicker way is to use preserve and restore!
	
* Run all of the three lines together (not one at a time!):
	
preserve
keep UniqueID year
restore

* It didn't do anything? Or so it would seem.

* Try again, running all the following lines together:

preserve
drop if year != 1997
tab year
restore

* Preserve saves your data as it is, then restore brings it back to that point.
* You can put anything you want in between them, as long as you run it all together.

* If you try running things one at a time you'll get an error in restore:

preserve

drop year

restore

* Yet if you just type the same things into the console Stata will do it.
	* Weird.
	
* But importantly, you can use this to make calculations or export statistics without 
	* having to re-load in the data each time you want to go back to the original.
	
* This may be faster than adding a lot of conditions to your commands if you want to restrict
	* your data on a lot of variables, then later go back and use the whole dataset.
	
* It's also a big help for the magical collapse command!	

************
* Collapse *
************

* Collapse can pick out variables for various summary statistics to make tables
	* or run analyses on aggregated data.
	
* This can be particularly helpful for summary stat tables and graphics.	

use "data\PSID_Long_Update.dta", clear	// Notice my WD is not just the data folder, but I add it in the use command

* We can always pull summary stats by group using our normal methods:

tabstat Fam_A20HOUSEVALUE_, by(year) s(n median)

* Or we can make a whole dataset with only these summary stats:

preserve
collapse (median) Fam_medhouseval = Fam_A20HOUSEVALUE_, by(year)
restore 

browse

* Notice that all of our variables are gone but year and the newly generated median house value!
* Plus we only have 11 observations!

* Why would we ever want this?

* Well now you can easily export just this table as a .csv

export delimited using "Median_House_Values_by_Year.csv", replace

* Admittedly this file isn't that better than exporting a summary stats table.
* But you can combine collapse across as many variables and statistics as you want!
* That makes it a lot faster than summary stat tables for many things.

* Bring the original data back in:
use "data\PSID_Long_Update.dta", clear	

* Now let's get more complex, using a preserve and restore wrapper and more statistics:

preserve
drop if Ind_AGEINDIVIDUAL_ == .
drop if Ind_FEMALE_ == .
collapse (count) Count_Age = Ind_AGEINDIVIDUAL_ ///
(mean) Mean_Age = Ind_AGEINDIVIDUAL_ ///
(median) Med_Age = Ind_AGEINDIVIDUAL_ ///
(sd) SD_Age = Ind_AGEINDIVIDUAL_, by(year Ind_FEMALE_)
export delimited using "Age_by_Year_by_Gender.csv", replace
restore

* ------------------------------------------------------------------------- *
* Challenge 4: Do the same summary tables for several variables using a loop! *
* ------------------------------------------------------------------------- *

* And again inside a loop to do it for many variables!
	* And let's make our varlist a macro just for fun.
	* Notice that the global macro isn't in quotes here,
		* likely because it's a varlist rather than character string.
	* General rule: If a macro doesn't work, try adding / removing quotes first.

global variables Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ Ind_G76NUMBERJOBSINPY_ Ind_TOTALLABORINCOME_ Ind_TOTALTAXABLEINCOME_
foreach var of varlist $variables {
preserve
drop if `var' == .
drop if Ind_FEMALE_ == .
collapse (count) Count_`var' = `var' ///
(mean) Mean_`var' = `var' ///
(median) Med_`var' = `var' ///
(sd) SD_`var' = `var', by(year Ind_FEMALE_)
export delimited using "`var'_by_Year_by_Gender.csv", replace
restore
}

* ------------------------------------------------------------------------------------------------------------------- *

* Okay cool, we can make fun tables. But what is collapse really good for?

* The best reason to use it is when you want to aggregate your data and change the level of observation.

* You'll notice our data has variables for family and individual level.
* What if we wanted to go up to the family level?

* First make a family ID variable from the unique ID
egen FamID = ends(UniqueID), punct("_") head
destring FamID, replace
label var FamID "Family ID"

save "data\PSID_Long_Update_2.dta", replace	


* Then we can make a new dataset of family variables:

preserve
collapse (firstnm) Fam_State = Fam_CURRSTATE_ ///
Fam_Region = Fam_CURRREGION_ ///
(median) Fam_Rooms = Fam_A8ACTUALROOMS_ ///
Fam_OwnershipStatus = Fam_A19OWNRORWHAT_ ///
Fam_HouseVal = Fam_A20HOUSEVALUE_ ///
Fam_Mortgage = Fam_A25MNTHLYPMTSMOR1_ ///
Fam_Wealth = Fam_IMPWEQUITY2_ ///
Fam_HousingExp = Fam_HOUSINGEXP_ ///
Fam_RentExp = Fam_REXP_ ///
(mean) Fam_Av_Age = Ind_AGEINDIVIDUAL_ ///
Fam_Av_Edu = Ind_YEARSCOMPLETEDEDU_ ///
Fam_Av_Jobs = Ind_G76NUMBERJOBSINPY_ ///
(sum) Fam_Sum_LaborIncome = Ind_TOTALLABORINCOME_ ///
Fam_Sum_TaxIncome = Ind_TOTALTAXABLEINCOME_ ///
Fam_NFemale = Ind_FEMALE_ ///
(count) Fam_NMembers = Ind_PERSONNUMBER68_, by(year FamID)
label values Fam_State fips_state_lab
label values Fam_OwnershipStatus ER66030L
label values Fam_Region ER71530L
save "PSID_Fam_Housing.dta", replace
restore


/* Quick Note: Ideally you should use weights to ensure the families maintain 
	 their representativeness of the population. Here the family weight variable 
	 was incomplete (due to my faulty data compiling) and skewed a few variables.
	 The reason I left it out is a bit complicated but just know that ideally you
	 should use it when aggregating. */
	

* Let's take a look!

use "PSID_Fam_Housing.dta", clear

browse

* Notice a lot of data is missing. This could be PSID's original data being sparse.
* Or it's because we've done a lot to this data: merged, reshaped, and collapsed it.
* It's not surprising that in the process a lot of data went missing.

* In a real project you would want to be careful to preserve as much data as possible.

codebook Fam_HouseVal
codebook Fam_State

* For more on collapse: https://stats.idre.ucla.edu/stata/modules/collapsing-data-across-observations/

********************
* Clustered Errors *
********************

/* Does our level of aggregation affect our analysis at all?

 What if we were worried that the relationships between people within families
	 may be causing some effect on each other's incomes?
 
 Does it seem feasible that rich parents are likelier to have rich children?

 Or what if we were worried about people within certain cities, or even states affecting each other?

 Not accounting for these relationships can bias our results!
 
 Normally we assume all observations are independent (a crucial assumption of OLS regression!)
 But there could be connections between observations.
 This could introduce correlations between their errors, screwing up the math behind OLS regression.

 To account for this possibility we use clustered errors.
 Basically, we just account for correlations between observations based on a grouping variable. */

 
* So if we start by regressing house value on wealth, education, and income:

regress Fam_HouseVal Fam_Wealth Fam_Av_Edu Fam_Sum_TaxIncome

* Not a bad regression, but it is being affected by clustering at the state level?

regress Fam_HouseVal Fam_Wealth Fam_Av_Edu Fam_Sum_TaxIncome, vce(cluster Fam_State)

	/* vce stands for variance-covariance estimation, and is the common option for accounting for
		 potential issues with standard errors introduced by non-independent observations or uneven variances
		
	 cluster is the sub-option which tells regress to account for variance correlation at the state level	

	 Since the outputs of the two regressions are largely the same, we suspect that state level
		 correlation isn't very important and we don't need to worry about it.
	 If it did have significantly different standard errors we would need to include it though.	*/
		
* But what about family level correlation?

* Let's return to our individual dataset:

use "data\PSID_Long_Update_2.dta", clear

* Now we can regress income on some covariates with clustering at the family level:

regress Ind_TOTALLABORINCOME_ Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ Ind_G76NUMBERJOBSINPY_ i.Ind_FEMALE_ i.year

regress Ind_TOTALLABORINCOME_ Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ Ind_G76NUMBERJOBSINPY_ i.Ind_FEMALE_ i.year, vce(cluster FamID)
		
* Okay, we see that family clustering doesn't seem to matter terribly much here either.
		
* But it's a good thing to check for!		

* I haven't found any good simple guides to clustering, but here are some econometric papers:

* Practitioners Guide: http://cameron.econ.ucdavis.edu/research/Cameron_Miller_JHR_2015_February.pdf
* Abadie, Athey, Imbens, and Wooldridge on Clustering: https://economics.mit.edu/files/13927
	* Quick note: Abadie, Imbens, and Wooldridge are like econometric gods. If you ever really want to learn fancy econometrics just read their books.
	
* And some slides: https://www.stata.com/meeting/13uk/nichols_crse.pdf
		
******************************
* Testing Heteroskedasticity *
******************************

* What if we suspected there were correlated errors based on some other variable?
* For example, what if people with higher education tend to have higher incomes,
	* BUT it's not a linear relationship? 
	* It's not even logarithmic or properly quadratic. It's just heteroskedastic.

preserve // Because we drop high income earners who are distorting our graph.
drop if Ind_TOTALLABORINCOME_ > 500000
scatter Ind_TOTALLABORINCOME_ Ind_YEARSCOMPLETEDEDU_
restore

/* See how the scatterplot gets "bigger" towards higher levels of education?
 We can visualize that the variance is increasing from low to high levels of education.
 In other words, our variance is not constant across observations,
	 which means our errors in a regression would not be independent.
		
 The effect we see here is called heteroskedasticity.

 We would say that the relationship between income and education is heteroskedastic;
	 income variance depends on the level of education.
	
 Intuitively we can understand this to mean that with less education,
	 people's incomes are more tightly distributed,
	 but at higher levels of education they are more spread out.
 High school graduates are only earning between $0 - $100k or so.
 But people with higher levels of education can earn between $0 - $700k. */

* Observe the increase in standard deviation at higher levels of education.

label drop ER34548L // Just to get rid of the label on education.
tabstat Ind_TOTALLABORINCOME_, by(Ind_YEARSCOMPLETEDEDU_) s(n mean median var sd)

* If we regress this we can look for the difference in our standard errors with the inclusion of the vce(robust) option

regress Ind_TOTALLABORINCOME_ Ind_YEARSCOMPLETEDEDU_

regress Ind_TOTALLABORINCOME_ Ind_YEARSCOMPLETEDEDU_, vce(robust)

* Now we see a significant difference in our standard errors, though not enough to affect our p-values.

* We can actually plot the residuals against their fitted values.
	* This also checks for heteroskedasticity in a less noisy way than our original scatterplot.


quietly regress Ind_TOTALLABORINCOME_ Ind_YEARSCOMPLETEDEDU_
rvfplot

quietly regress Ind_TOTALLABORINCOME_ Ind_YEARSCOMPLETEDEDU_, vce(robust)
rvfplot	
	
* Clearly heteroskedasticity isn't completely gone but we've accounted for it as much as a bivariate linear model allows.	

* But isn't there a numerical, statistical definition of heterosk.?
	* Why are we just "looking for it" in plots?
	
* Something called White's General Test for Heteroskedasticity is an easy post-estimation command:	
	
imtest, white	

* We see a large chi-squared statistic and a p-value of 0.000 for heterosk.
	* This tells us we definitely have issues of heterosk. in our model.
	
* For more on heterosk. and testing: https://www3.nd.edu/~rwilliam/stats2/l25.pdf	
* And some slides: http://www.ucdenver.edu/academics/colleges/PublicHealth/resourcesfor/Faculty/perraillon/perraillonteaching/Documents/week%2010%20heteroskedasticity.pdf
	
* ------------------------------------------------------------------------------------------------------------------------- *	

* But wouldn't we expect that only certain levels of education matter? Like having a high school or college degree?
* Should we cluster the education variable by levels of education?

* We could, but it is unusual to cluster by something so broad as education level.
	* We could cluster by school, district, or even college, but we wouldn't cluster by education level.

* Typically we would either transform the variable or try to introduce other controls to account for the shifting variance.	
	* The first thing to do about heterosk. is try to respecify the model, with controls or transformations.
	
* Let's see if a categorical variable of education specifies better:	

gen Ind_Edu_Cat = .
replace Ind_Edu_Cat = 0 if Ind_YEARSCOMPLETEDEDU_ >= 1 & Ind_YEARSCOMPLETEDEDU_ <= 8 & Ind_YEARSCOMPLETEDEDU_ != .
replace Ind_Edu_Cat = 1 if Ind_YEARSCOMPLETEDEDU_ >= 9 & Ind_YEARSCOMPLETEDEDU_ <= 12 & Ind_YEARSCOMPLETEDEDU_ != .
replace Ind_Edu_Cat = 2 if Ind_YEARSCOMPLETEDEDU_ >= 13 & Ind_YEARSCOMPLETEDEDU_ <= 14 & Ind_YEARSCOMPLETEDEDU_ != .
replace Ind_Edu_Cat = 3 if Ind_YEARSCOMPLETEDEDU_ >= 15 & Ind_YEARSCOMPLETEDEDU_ <= 16 & Ind_YEARSCOMPLETEDEDU_ != .
replace Ind_Edu_Cat = 4 if Ind_YEARSCOMPLETEDEDU_ > 16 & Ind_YEARSCOMPLETEDEDU_ != .

label var Ind_Edu_Cat "Individual Education Category"
label define Edu_Cat_Lab 0 "1 to 8 Years" 1 "9 to 12 years" 2 "13 to 14 Years" 3 "15 to 16 Years" 4 "More than 16 Years"
label values Ind_Edu_Cat Edu_Cat_Lab

regress Ind_TOTALLABORINCOME_ i.Ind_Edu_Cat
rvfplot // However we can see that there is still some heterosk. plus the model is less accurate
imtest, white // Yup, still heterosk.

regress Ind_TOTALLABORINCOME_ i.Ind_Edu_Cat, robust
rvfplot
imtest, white

* Or we can try a quadratic term:

gen Edu_2 = Ind_YEARSCOMPLETEDEDU_ * Ind_YEARSCOMPLETEDEDU_

regress Ind_TOTALLABORINCOME_ Ind_YEARSCOMPLETEDEDU_

regress Ind_TOTALLABORINCOME_ Ind_YEARSCOMPLETEDEDU_ Edu_2
rvfplot
imtest, white

regress Ind_TOTALLABORINCOME_ Ind_YEARSCOMPLETEDEDU_ Edu_2, robust
rvfplot
imtest, white

* How about a log of income?

gen log_LaborIncome = .
replace log_LaborIncome = ln(Ind_TOTALLABORINCOME_) 
	* Notice how many values we lost. This is because logs can't take 0's.

regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ Edu_2, robust
rvfplot
imtest, white

* So we still have heterosk. and our model is really complex. But it has a higher r-squared.

* In any case, we can see that the relationship between income and education can't be fully
	* specified in a bivariate model. There are just too many other factors.
* The best thing to do is keep adding more variables as controls to try and account for the variance change.


*********************
* Robustness Checks *
*********************

* Robustness refers generally to how well a relationship or model holds up to various changes.
	* Correcting for heterosk. and clustering are two changes that we want to be robust to.
	* Mostly though we care about the inclusion or exclusion of certain control variables.
	* We want to see how stable a coefficient and its p-value is over several model variants,
		* each with different sets of control variables.
		
* Let's start with our crazy log-income education quadratic model, and start eststo to build a model.
eststo clear
eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ Edu_2, robust

* What controls might be helpful?
	* What affects income?
	* Jobs are a good place to start:
	
eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ Edu_2 i.Ind_G76NUMBERJOBSINPY_, robust

* Plus age:
eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ Edu_2 i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_, robust

* And region:
eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ Edu_2 i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ i.Fam_CURRREGION_, robust

* How about gender:
eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ Edu_2 i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ i.Fam_CURRREGION_ i.Ind_FEMALE_, robust

* And then a year fixed effect just in case (considering the post-2008 recovery this is probably important)
eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ Edu_2 i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ i.Fam_CURRREGION_ i.Ind_FEMALE_ i.year, robust


esttab using "Log_Income_Edu2_Robust.rtf", label replace title("Robustness on Controls") r2 ar2
eststo clear

* Now you can look at the whole table in Word and look across models to see what happens to the 
	* primary variables of interest as more controls are added.


* You can also test robustness in the other direction:

eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ Edu_2 i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ i.Fam_CURRREGION_ i.Ind_FEMALE_ i.year, robust

* It looks like our quadratic education term isn't stable, let's get rid of it first

eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_  i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ i.Fam_CURRREGION_ i.Ind_FEMALE_ i.year, robust

* Our regions aren't particularly significant either:

eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ i.Ind_FEMALE_ i.year, robust

* But what if we think that age might actually not affect income in a linear way?
	* Log or quadratic?
		* The "standard answer" is quadratic:
		
gen Age_2 = Ind_AGEINDIVIDUAL_ * Ind_AGEINDIVIDUAL_

eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ Age_2 i.Ind_FEMALE_ i.year, robust

* And just confirm that our results are robust to the removal of year effects

eststo: regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ Age_2 i.Ind_FEMALE_, robust

esttab using "Log_Income_Edu2_Age2_Robust.rtf", label replace title("Robustness on Controls") r2 ar2
eststo clear

* After inspecting the table in Word, it looks like our best model is:

regress log_LaborIncome Ind_YEARSCOMPLETEDEDU_ i.Ind_G76NUMBERJOBSINPY_ Ind_AGEINDIVIDUAL_ Age_2 i.Ind_FEMALE_ i.year, robust


* But what sin have we just committed?
	* We just started adding variables and removing them, transforming them at will, until our r-squared was high and p-values low.
	* This may be a good model but it was created in a non-scientific way.
	* We had no a-priori hypothesis about how income is determined. We just went off intuition of what variables are important.
	* This is a form of p-hacking, by which we just test a bunch of models until we find one that has good statistics.

	* It also, of course, doesn't tell us anything about a causal effect. Maybe higher incomes allow people to go back to school?
	* Even if we assume there is no reverse causality (income can't affect age, yet),
		* there is likely still plenty of omitted variable bias, confounding between variables, and possibly heteroskedasticity.
		
* Let's run some of our post-estiation tests:		
		
rvfplot
imtest, white // White's test for heteroskedasticity
test Ind_YEARSCOMPLETEDEDU_ // You can also run f-tests on individual variables or groups of variables
test Ind_AGEINDIVIDUAL_ Age_2 // Here we test for the joint significance of the linear and quadratic term


* Introductory Paper exploring robustness checks: https://ftp.cs.ucla.edu/pub/stat_ser/r449.pdf
* Fun (but long) guide on regression modelling with robustness: http://www.gvptsites.umd.edu/uslaner/robustregression.pdf
* Interesting paper on how researchers approach robustness wrong: https://pdfs.semanticscholar.org/6b4e/2ebc08edebf8e51099355d5b47f9a91badd0.pdf
