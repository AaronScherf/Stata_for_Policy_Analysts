************************************
* PP297: Stata for Policy Analysts *
* Session 2: Data Management I     *
* Created by: Aaron Scherf         *
* Instructor Edition               *
************************************

*********************
* Today's Commands: *
*********************

* gen, drop, keep, replace
* display, mathematical operators, logical operators, count
* label variable, label define, label values
* codebook, recode

************************
* Review of Session 1: *
************************
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19"

use "data\PP297_Survey.dta", clear

tab hoursperweek

tab hoursperweek, m // Notice the missing data point, given by a "."

tabstat hoursperweek, by(pronouns) s(n, mean, median)

tab statisticsskill empiricalresearchskill

tabstat statisticsskill, by(empiricalresearchskill) s(n, mean, median)

tab computerskill pronouns

tabstat computerskill, by(pronouns) s(n, mean, median, sd, var)

************************
* Variable Management: *
************************

* Load in the American Community Survey dataset
use "data\ACS_17_Basics.dta", clear

* Create a new variable, "minor" with all values of 0
gen minor = 0

tab minor

* Replace the values for "minor" based on the "age" variable
replace minor = 1 if age <= 18 

tab minor

* What does the year variable tell us? What should we do with it?
tab year // Notice there is only one survey year.

drop year // Therefore the variable is not helpful for us.

* What about the other variables? Which are useful for us?
keep sex age marst educ educd inctot ftotinc poverty poverty_bin edu_simple // Likewise, many other variables aren't important right now

* What does the poverty variable look like?
tab poverty // Not what we usually expect from a poverty variable!

* How would we rather have "poverty" look?
replace poverty = poverty_bin // You can completely overwrite variables with other variables, but remember the original "poverty" variable is gone forever!

tab poverty

drop poverty_bin

***************************************
* Mathematical and Logical Operators: *
***************************************

* Mathematical Operators:

* Add 2+2
display 2+2 // Stata is really just the world's most unnecessarily complex calculator

* Calculate 2^2
display 2^2 // Exponentials

* Calculate the absolute value of -2
display abs(-2) // Absolute value

* Calculate the square root of 16
display sqrt(16) // Square root

* Calculate the max value of the set (1,2,3)
display max(1,2,3) // Max value

*Calculate the natural log of 1
display ln(1) // Natural log

* What is the closest integer below 4.5?
display floor(4.5) // Rounded down to nearest integer

* What is the closest integer to 4.5?
display round(4.6) // Rounded to nearest integer

* What is the closest integer above 4.5?
display ceil(4.5) // Rounded up to nearest integer

* How do we check for other mathematical operators?
help math_functions


* Logical Operators:

* Is 1 equal to 1?
display 1 == 1

* Is 1 equal to 0?
display 1 == 0

* Is 2 greater than 3?
display 2 > 3

* Is 1 not equal to 5,424,526?
display 1 != 5424526


* Using logical operators in summary statistics:

* Count the number of minors in the sample.
count if age < 18 // Return number of minors

* How can we check that we're right?
tabstat minor, s(n) // Should have the same number of minors!

* How much education do those living below the poverty line have?
tab edu_simple if poverty == 1

* What if we wanted to compare the poor and non-poor by education level?
tabstat edu_simple, by(poverty) s(n, mean, median) // Categorical variables don't work well with summary stats

tab edu_simple poverty, column // Two-way tables can be more helpful!

* What about poverty breakdown for males? For females?
summarize poverty if sex == 1, det

tabstat poverty, by(sex) s(n, mean, median, sd, var)

*****************************
* Variable and Value Labels *
*****************************

* How do we change the label for a variable?
label variable edu_simple "Simplified Education"

label variable minor "Age <= 18"

* What if we wanted to change the labels of the values inside the variable (all the 1's and 2's, etc.)?
label define MinorLab 0 "Adult" 1 "Minor"

label values minor MinorLab

* What if we forget how to label stuff?
help label

* What if for some reason we want to know all the labels associated with a dataset?
label dir

**********************************
* Variable Codebook and Recoding *
**********************************

* What if we wanted to know how labels and values correspond for a particular variable? 
codebook sex // Plus summary statistics and other fun stuff!

* What about changing categorical values, or even making new variables with different values?
recode sex (1 = 0) (2 = 1), gen(female) // Recoding the sex variable into a "female" dummy variable

* Alternatively, gen female = (sex > 1) would also work to create female dummy variable.

label variable female "Dummy for Female"

label define FemaleLab 0 "Male" 1 "Female"

label values female FemaleLab

save "data\ACS_17_Basics_Update.dta", replace

*****************************
* Missing Data and Outliers *
*****************************

* Missing Values:

use "data\PP297_Survey.dta", clear

* Does our data contain any missing values? For example for country1 or hoursperweek?
tab country1
tab country1, m //Notice that 9 observations are missing, giving blank values

tab hoursperweek
tab hoursperweek, m //Notice that 1 observation is missing, giving an "." or NA

* Note: Many datasets don't use "." by default, they have their own special value for missing responses, like "-2"
	* Always check your data for missing values through tab!
	
	* To read more on Missing Values: https://www.reed.edu/data-at-reed/resources/Stata/missing-values.html
	* More advanced guide with Stata commands: https://stats.idre.ucla.edu/stata/modules/missing-values/
	* Even more advanced guide with Python commands: https://towardsdatascience.com/how-to-handle-missing-data-8646b18db0d4
	
	
* Outliers:

* Notice the response of 20 hours of work expected per week (real response!)
* Is this an outlier? Should we leave it in the data?

* From Wolfram Alpha: "A convenient definition of an outlier is a point which falls more than 1.5 
	* times the interquartile range above the third quartile or below the first quartile."
	
tabstat hoursperweek, s(p25, p75, iqr)
display 1.5*1.5 //Interquartile range times 1.5
display 3+1.5 //Third quartile plus interquartile range times 1.5 (outlier limit)

display 20 >= 4.5
	*Yes, it is an outlier! But do we want it in our data?
	* Depends whether it is an outlier due to an error; assuming it isn't, we should keep it!

* Or, another way to calculate the same thing, looking ahead to next week's egen command:

egen hour_iqr = iqr(hoursperweek)
gen hour_outlier_test = hour_iqr*1.5

egen hour_max = max(hoursperweek)
display hour_max >= hour_outlier_test

* If we did want to eliminate it, should we remove the single data point or the entire observation? How would we going about doing either?

replace hoursperweek = . if hoursperweek >= 4.5 // To change the single data points to missing values

tab hoursperweek, m

drop if hoursperweek >= 4.5 // To eliminate all observations with "outlier" hours (entire row of data)

tab hoursperweek, m

* Again, the answer is no, don't remove anything unless you think there is an error.

* If you do have to remove it, consider if it was an honest mistake (incorrect bubble on survey) or a biased respondent
	* If it was an isolated mistake, remove the single data point.
	* If it was biased reporting, you may need to remove the entire observation. But you lose sample size quickly!

	* To read more on outliers: https://www.theanalysisfactor.com/outliers-to-drop-or-not-to-drop/

	
********************************************
* Fun Stata Fact for the Quant Problem Set *
********************************************

* There are ways in Stata to create output tables for summary statistics across multiple variables.
* We'll get into them later in the Stata course, 
	* but in the Quant Problem Set 1 you have to run a hypothesis test for almost 20 variables...
	
* Without getting "fancy" with Stata and running for loops or using saved output (both things we'll do later),
	* you can also use Stata with Excel by copying table output in an Excel friendly format.
		
* In the Stata Output window, highlight the entire table you want to copy, right click to open the menu,
	* and hit "Copy table". Then paste this into Excel as is.
	
* It's not the fastest way to do it but without more advanced Stata skills this should help with the problem set.	
