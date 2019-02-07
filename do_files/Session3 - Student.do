************************************
* PP297: Stata for Policy Analysts *
* Session 3: Data Management I Cont*
* Created by: Aaron Scherf         *
* Instructor Edition               *
************************************

*********************
* Today's Commands: *
*********************

* tostring, destring
* in, sort, by
* egen, xtile
* corr, t-test
* tab (chi2)

************************
* Review of Session 2: *
************************
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19"

use "data\PP297_Survey.dta", clear

gen ave_score = . // Create an "empty" variable called ave_score
replace ave_score = (statisticsskill + empiricalresearchskill + computerskill) // Replace ave_score with the sum of the other 3 scores
replace ave_score = ave_score / 3 // Divide the ave_score by 3

label var ave_score "Average of Skill Scores"

gen sex = 0
replace sex = 1 if pronouns == "He, him, his"
replace sex = 2 if pronouns == "She, her, hers"
replace sex = 3 if pronouns == "They, them, theirs" 
* The data didn't have any non-binary respondents, but since it was a survey option it's good to include it, in case you collect new data later.

label var sex "Gender Identity"
label define sex_lab 1 "Male" 2 "Female" 3 "Non-binary" // Create a label for the sex variable's data
label values sex sex_lab // Assign that label to the sex variable

recode sex (1 = 0) (2 = 1) (3 = 0), gen(female) // Use the sex variable to create a female dummy variable

label var female "Female Dummy"

drop sex // Remove the sex variable

save "data\PP297_Survey_Update.dta"


************************
* tostring and destring: *
************************

use "data\PP297_Survey_Update.dta", clear

* Strings refer to a type of data with character text, as opposed to some form of number.
* If you open the data browser, string data will be colored red.
* You can also see in the properties window that the "Type" starts with str and a number.
	* The number refers to the max length of data in the string.
	
* The "tostring" command converts non-string data to a string:	
	
	
	
* Changing strings to numeric data is more common, usually because you're importing data from something that kept it as strings.
		
		
		

********************
* in, sort and by: *
********************

* Load in the American Community Survey dataset, clearing the survey data.
use "data\ACS_17_Basics.dta", clear

* in is an option on many commands that allows you to specify particular observations


use "data\ACS_17_Basics.dta", clear // Reload the data so we don't drop any observations.


* sort changes the order of observations in the dataset; typically only useful in combination with other commands like by

browse // Opens the data browser



* by is like a pre-command option; it lets you apply commands to different groups that don't have a by() option like tabstat


* But you need to sort the data first!

sort poverty_bin


save "data\ACS_17_Basics_Update.dta", replace


*********
* egen: *
*********

* egen can create new variables based on mathematical operators and other expressions
* It's Stata's cheap way of storing summary values (another way is macros, but we don't learn those till March)




* Bonus: xtile and tab, gen()
* xtile creates a new variable based on percentiles, as specified by the n(#). Very similar to the egen cut(), group(#).



* tab can also be used to generate dummy variables, as we just saw.


* You can use egen in a lot of complex ways. To see all the functions availabe with egen check out its help file.

help egen



*****************************
* Correlations and T-Tests: *
*****************************

* Correlations are a quick way to check for relationships between variables
	* Remember the golden rule of statistics: they don't imply much of anything on their own!
	
* You can run correlations between two variables of interest:



* Or between a ton of variables using pwcorr



	* We can also run correlations on sub-samples:
	

		
	
* T-Tests run hypothesis tests on the difference in mean values
		* Either for one variable's mean against a given value (one-sample)
		* Or between two variables testing for a difference in their means (two-sample)

* One sample t-test:
	* Let's see if there is an "even gender split" in the data.
	
	* First check if our sex variable has the mean we would expect under the null hypothesis:
	
tabstat sex, s(n, mean) // Nope, the sex variable still needs to be recoded.

	recode sex (1 = 0) (2 = 1), gen(female) // Use the sex variable to create a female dummy variable
	label var female "Female Dummy"
	tabstat female, s(n, mean)
	
* Now try the one sample t-test:
	

	
	* Interpreting t-test output is a bit tricky.
	* The important things to look at are:
		* Mean: .5106063
		* t-statistic: 37.8957
		* Null Hypothesis: Ho: mean = 0.5  
		* Alternative Hypothesis: Ha: mean != 0.5
		* Alt. Hyp. P-Value: Pr(|T| > |t|) = 0.0000 
		
	* What can we say about the gender balance of the ACS data?
	
	* If you want to adjust the confidence level of your test, use the option level(#)
	

	


*Two sample t-test (independent):
	* Check whether two groups have equivalent mean values for another variable.
	
	*Let's test if males and females have equivalent personal income levels.
	

	
	
* Important note: If the variance of the two groups is dissimilar, include the option "unequal"



	
	
	
* Remember you can only run t-tests on binary dummy variables; two groups only.
	
ttest inctot, by(edu_simple)	// Results in error. We would need to make dummies.



* It also makes little sense to run a t-test using a binary and categorical variable:

ttest marst, by(female)	// What does it mean to be 3.6 units married? Not much.
	
	
	
* Two sample t-test (dependent):
		* Checks whether the means of two sets of data are significantly different
		* Only works for dependent samples; ie observations from one sample can be paired with the other

		* Test whether family income is equal to individual income (kind of silly but that's the best option in our data)
		
		
		
		
* Sneak peak of graphing, since Dr. Raphael brought it up, here are the density plots overlaid:
	
twoway kdensity ftotinc || kdensity inctot // It takes a while and isn't super informative, but with more similar data it is more useful.
	
	* For more help in interpreting t-test output: https://stats.idre.ucla.edu/stata/output/t-test/
	
********************
* Chi-Square Test: *
********************

* What if we did want to test the relationship between categorical variables?

* "The chi-square independence test is a procedure for testing if two 
	*categorical variables are related in some population."
	* https://www.spss-tutorials.com/chi-square-independence-test/
	
* "The null hypothesis for a chi-square independence test is that
	* two categorical variables are independent in some population."
	
* How do we run such a complex test in Stata? 



	* The important output to note is the p-value:

	

	
********************************
* Bonus Sneak Peak: Regression *
********************************

* Many tests, especially two-sample t-tests, can be run using a simple regression

regress inctot female	

ttest inctot, by(female)	

* Notice how the regression output includes the mean difference, p-value, and t-value from the t-test.

* This makes less sense for categorical variables, so it can't be used for chi-square tests of independence.
regress marst female // This may run, but it isn't a good test, because marital status is categorical.

* regress should only be used with continuous dependent variables. More on this next week!

