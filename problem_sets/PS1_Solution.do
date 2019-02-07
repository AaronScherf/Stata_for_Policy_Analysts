************************************
* PP297: Stata for Policy Analysts *
* Problem Set 1: Basics of Data    *
* Created by: Aaron Scherf         *
* Instructor Edition               *
************************************

*********************
* Today's Commands: *
*********************

* cd
* infile (similar to import)
* label variable
* gen
* sum
* tab
* label values
* tabstat
* save
* export

***************************
* Loading in School Data: *
***************************

* Import the "school_data_1990.raw" file using the infile command
	* Note: If you use the point-and-click method make sure to copy the command into the do-file!
 
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19\Stata PS"

infile id fips enroll expp frevp dropout hsgrad somecol black hispanic inpov owner hhinc using "school_data_1990.raw", clear

* Label the variables: id fips enroll expp frevp dropout hsgrad somecol black hispanic inpov owner hhinc
	* You can use the labels from the Quant Problem Set.

label var id "school id number"
label var fips "2 digit state code"
label var enroll "fall enrollment"
label var expp "expenditures per pupil, real 1992"
label var frevp "federal revenues per pupil"
label var dropout "% aged 25+ that are hs dropouts"
label var hsgrad "% aged 25+ that are hs grads"
label var somecol "% aged 25+ that are have some college"
label var black "% pop is black"
label var hispanic "% pop is hispanic"
label var inpov "% families in poverty"
label var owner "% owner occupied homes in district"
label var hhinc "median household income, real 1992"

* Why did the Quant Problem Set include semi-colons?
* https://www.stata.com/manuals13/m-2semicolons.pdf
* tl;dr: You don't need them, they're for fancy programming tasks in Stata. In fact they may cause you errors.

************************
* Variable Management: *
************************

* Generate a new variable for total federal reveues per district, called revtotal, and label it

gen revtotal = frevp*enroll
label var revtotal "total fed rev for district"

* Now create a dummy variable called "high_owner" with a value of 1 for districts with % owner occupied homes greater than the median for all districts,
	* and a 0 for districts with % owner occupancy less than the median
	* Hint: You'll need to use another command to find the median first!
* Label the variable with a sensible description

sum owner, det
gen high_owner = (owner >= r(p50)) // The r(p50) uses the output of sum. You can also type out the median by hand.
label var high_owner "% owner occupied more than median"

*************************************
* Exploring Data - Federal Revenues *
*************************************

* What command will tell you how many school districts are in the sample for a given state?

tab fips, m

* Why is this less than helpful?
	* I for one don't have fips codes memorized.

* Use the label provided below to label the values of the fips variable (yes I typed it out by hand, you're welcome)

label define fips_state_lab 1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" 15 "HI" 16 "ID" 17 "IL" 18 "IN" ///
19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" 25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" ///
37 "NC" 38 "ND" 39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY"

label values fips fips_state_lab

* Now find the number of observations, mean, median, variance, and standard deviation of the total federal revenue for each state:

tabstat revtotal, by(fips) s(n, mean, median, var, sd)

* Which "state" has the highest average total federal revenue?
	* You can just look at the table above and find the average total revenues by state.
	
	* Or, you can make a variable for the average revenues by state using egen:
egen state_rev_av = mean(revtotal), by(fips)	
	* Now each district has a value associated with the average federal revenue total for its state.

	* There are probably faster ways to do this, but you can then egen a variable for the max of the state_rev_av:
egen max_state_rev = max(state_rev_av)
tab max_state_rev // This will tell you the amount of the revenue, but we want to know the state associated with it

	* The last step in this admittedly overcomplicated process is to tab a subset of the states, specifically the one where the state_rev_av is equal to the max
tab fips if state_rev_av == max_state_rev

	
	* The answer I found was Washington, DC; $11,400,000 (scientific notation: 1.14e+07)

* Why do you think that "state" has the highest federal revenue?
	* Could be due to only having a single observation (outlier effect), 
		* could be that schools in DC are federally (not state) funded, 
		* could be corrupt Congresspeople spending money nearby,
		* whatever you said is likely a right interpretation.
	* Fact is we can't say much without more information.

	
**************************************
* Exploring Data - Spending and Race *
**************************************

* Let's say we're interested in how spending per pupil is related to the % hispanic population in the district

* What command would tell you the number of observations, mean, and median of expenditures grouped 
	* by the percentage of the population which is hispanic?
	* Hint: Run the following first:
	set more off

tabstat expp, by(hispanic) s(n, mean, median) // Clearly this big of a table is not telling us much.

* To avoid the problems in the last command, make a categorical variable splitting the sample into quartiles based on % hispanic population
	* First use a sum command to determine the quartiles (p25, p50, p75) (Hint: use the option ", det")
	* Then create a new variable, using "replace" with "if" statements to code for the 4 quartiles
	
sum hispanic, det

gen hispanic_bin = 0
replace hispanic_bin = 1 if (r(p25) > hispanic <= r(p50))
replace hispanic_bin = 2 if (r(p50) > hispanic <= r(p75))
replace hispanic_bin = 3 if (hispanic > r(p75))

	* The r(p25), r(p50), etc. are results from the sum command, which is a shortcut we'll learn later!
	* They do what you might expect, taking statistics from the sum command and storing them as temporary values
	* In this case they are for the 25th, 50th, and 75th percentile of the hispanic variable
	* You could have "hard-coded" the same numbers by copying values from the table, but that is slower and bad coding practice
	

* Then label the new categorical variable and its values

label var hispanic_bin "Quartiles of % Population Hispanic"
label define Quartiles 0 "First Quartile" 1 "Second Quartile" 2 "Third Quartile" 3 "Fourth Quartile"
label values hispanic_bin Quartiles

* How can we quickly check to see if our categorical variable is correct?

tabstat hispanic, by(hispanic_bin) s(n, mean, median)

* Now run the same summary of (n, mean, median) for the expenditure per pupil grouped by the quartiles of hispanic population

tabstat expp, by(hispanic_bin) s(n, mean, median)

* What initial hypothesis might you make based on these summary statistics?

	* Expenditure seems to be increasing as the hispanic percentage of the district population is increasing.
	
* What policy implications, if any, would you draw from this data?

	* Currently none, the level of aggregation in these summary statistics is too high to draw any real conclusions. 
		* Besides, any relationship is correlation until proven otherwise.
	
*****************************	
* Saving and Exporting Data	*
*****************************

* Save the data you've been working on as a .dta file in the command directory	
	
save "school_data_1990.dta", replace

* For all your non-Stata friends, also export the file as a .csv
	* Note: If you use the point-and-click method be sure to copy the code over to the do-file

export delimited using "school_data_1990.csv", replace
	
	
******************************************
* Bonus: ttest and correlation, kdensity *
******************************************

* In the Quant Problem Set, you are asked to perform tests of hypotheses and correlation.
* We will do these in our 3rd session (2/6/19) but to give you a preview:

* 2 variable t-test of difference in mean of student expenditure by owner occupancy dummy
ttest expp, by(high_owner)

	* The output shows the average expenditure value for each group, high rates of owner occupancy and low rates of owner occupancy.
	* It also has the difference in the means, 119.5099, which shows that expenditure was higher in lower occupancy areas
	
	* Is this difference statistically significant? 
		* Check the t-statistic; if it is greater than 1.96 or less than -1.96 it is a significant difference at the 95% confidence level
		* Check the p-values on the Ha hypothesis tests; the output "Pr(|T| > |t|) = 0.0002" shows you that the alternative hypothesis  "Ha: diff != 0" is significant
		
* Correlation between hispanic and expenditure
corr expp hispanic

	* The output table shows 3 values: 1.0000,  0.0219, and 1.0000
	* The 0.0219 is the correlation between those two variables.
	* 1 is perfect correlation, 0 is no correlation.
	* So 0.0219 is a pretty weak relationship (in a linear sense)
	* Seems like we were justified in not making assumptions based on the summary statistics above.
	
* Kernel density plot
kdensity expp	

	* This command quickly creates a frequency distribution curve for the variable specified
	* It's a good visual way to inspect for central tendency and outliers!
