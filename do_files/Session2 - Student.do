************************************
* PP297: Stata for Policy Analysts *
* Session 2: Data Management I     *
* Created by: YOUR NAME HERE       *
* Student Edition                  *
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


* Replace the values for "minor" based on the "age" variable


* What does the year variable tell us? What should we do with it?


* What about the other variables? Which are useful for us?


* What does the poverty variable look like?


* How would we rather have "poverty" look?



***************************************
* Mathematical and Logical Operators: *
***************************************

* Mathematical Operators:

* Add 2+2


* Calculate 2^2


* Calculate the absolute value of -2


* Calculate the square root of 16


* Calculate the max value of the set (1,2,3)


*Calculate the natural log of 1


* What is the closest integer below 4.5?


* What is the closest integer to 4.5?


* What is the closest integer above 4.5?


* How do we check for other mathematical operators?



* Logical Operators:

* Is 1 equal to 1?


* Is 1 equal to 0?


* Is 2 greater than 3?


* Is 1 not equal to 5,424,526?



* Using logical operators in summary statistics:

* Count the number of minors in the sample.


* How can we check that we're right?


* How much education do those living below the poverty line have?


* What if we wanted to compare the poor and non-poor by education level?


* What about poverty breakdown for males? For females?


*****************************
* Variable and Value Labels *
*****************************

* How do we change the label for a variable?


* What if we wanted to change the labels of the values inside the variable (all the 1's and 2's, etc.)?


* What if we forget how to label stuff?


* What if for some reason we want to know all the labels associated with a dataset?


**********************************
* Variable Codebook and Recoding *
**********************************

* What if we wanted to know how labels and values correspond for a particular variable? 


* What about changing categorical values, or even making new variables with different values?



save "data\ACS_17_Basics_Update.dta", replace

*****************************
* Missing Data and Outliers *
*****************************

* Missing Values:

use "data\PP297_Survey.dta", clear

* Does our data contain any missing values? For example for country1 or hoursperweek?



* Note: Many datasets don't use "." by default, they have their own special value for missing responses, like "-2"
	* Always check your data for missing values through tab!
	
	* To read more on Missing Values: https://www.reed.edu/data-at-reed/resources/Stata/missing-values.html
	* More advanced guide with Stata commands: https://stats.idre.ucla.edu/stata/modules/missing-values/
	* Even more advanced guide with Python commands: https://towardsdatascience.com/how-to-handle-missing-data-8646b18db0d4
	
	
* Outliers:

* Notice the response of 20 hours of work expected per week (real response!)
* Is this an outlier? Should we leave it in the data?



* If we did want to eliminate it, should we remove the single data point or the entire observation? How would we do either?



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
