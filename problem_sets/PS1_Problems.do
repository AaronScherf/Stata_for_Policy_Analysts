************************************
* PP297: Stata for Policy Analysts *
* Problem Set 1: Basics of Data    *
* Created by: YOUR NAME HERE       *
* Student Edition                  *
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
 
cd "Your/Directory/Here"


* Label the variables: id fips enroll expp frevp dropout hsgrad somecol black hispanic inpov owner hhinc
	* You can use the labels from the Quant Problem Set.



* Why did the Quant Problem Set include semi-colons?
	* https://www.stata.com/manuals13/m-2semicolons.pdf
	* tl;dr: You don't need them, they're for fancy programming tasks in Stata. In fact they may cause you errors if you use them wrong.

************************
* Variable Management: *
************************

* Generate a new variable for total federal reveues per district, called revtotal, and label it


* Now create a dummy variable called "high_owner" with a value of 1 for districts with % owner occupied homes greater than the median for all districts,
	* and a 0 for districts with % owner occupancy less than the median
	* Hint: You'll need to use another command to find the median first!
* Label the variable with a sensible description


*************************************
* Exploring Data - Federal Revenues *
*************************************

* What command will tell you how many school districts are in the sample for a given state?



* Why is this less than helpful?



* Use the label provided below to label the values of the fips variable (yes I typed it out by hand, you're welcome)

label define fips_state_lab 1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" 15 "HI" 16 "ID" 17 "IL" 18 "IN" ///
19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" 25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" ///
37 "NC" 38 "ND" 39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY"


* Now find the number of observations, mean, median, variance, and standard deviation of the total federal revenue for each state:


* Which "state" has the highest average total federal revenue?


* Why do you think that "state" has the highest federal revenue?


	
**************************************
* Exploring Data - Spending and Race *
**************************************

* Let's say we're interested in how spending per pupil is related to the % hispanic population in the district

* What command would tell you the number of observations, mean, and median of expenditures grouped 
	* by the percentage of the population which is hispanic?
	* Hint: Run the following first:
	set more off


	
* To avoid the problems in the last command, make a categorical variable splitting the sample into quartiles based on % hispanic population
	* First use a sum command to determine the quartiles (p25, p50, p75) (Hint: use the option ", det")
	* Then create a new variable, using "replace" with "if" statements to code for the 4 quartiles
	

	
* Then label the new categorical variable and its values (use "label var", "label define", and then "label values")



* How can we quickly check to see if our categorical variable is correct?



* Now run the same summary of (n, mean, median) for the expenditure per pupil grouped by the quartiles of hispanic population



* What initial hypothesis might you make based on these summary statistics?


	
* What policy implications, if any, would you draw from this data?



	
*****************************	
* Saving and Exporting Data	*
*****************************

* Save the data you've been working on as a .dta file in the command directory	
	

	
* For all your non-Stata friends, also export the file as a .csv
	* Note: If you use the point-and-click method be sure to copy the code over to the do-file


	
	
******************************************
* Bonus: ttest and correlation, kdensity *
******************************************

* In the Quant Problem Set, you are asked to perform tests of hypotheses and correlation.
* We will do these in our 3rd session (2/6/19) but to give you a preview:

* 2 variable t-test of difference in mean of student expenditure by owner occupancy dummy
ttest expp, by(high_owner)


		
* Correlation between hispanic and expenditure
corr expp hispanic


	
* Kernel density plot
kdensity expp	

	* This command quickly creates a frequency distribution curve for the variable specified
	* It's a good visual way to inspect for central tendency and outliers!
