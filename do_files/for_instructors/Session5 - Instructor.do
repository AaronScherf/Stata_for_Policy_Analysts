****************************************
* PP297: Stata for Policy Analysts     *
* Session 5: Analysis and Visualiation *
* Created by: Aaron Scherf             *
* Instructor Edition                   *
****************************************

*******************
* Today's Topics: *
*******************
* e()
* r()
* estout
* outreg2 
* predict
* histograms
* kdensity graphs
* distributions (modality, skew) 
* bar graphs and line graphs
* natural log transformations
* log plots

*******************************************
* Loading in UN Labor and Migration Data: *
*******************************************

* First set your command directory to the data folder:
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19\data"

* Then bring in the data file with use:
use "UNSD_Labor_Migration_Student_Update.dta", clear

*****************************
* Data Results: e() and r() *
*****************************

* Let's use the same multivariate regression as last session:
gen unemploy_prop_both2018 = unemploy_rate_both2018 / 100	// First we want to set our unemployment variable as a proportion

regress unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 perc_pop_concern2018 ///
if surface_area > 30

* What if we wanted to manipulate the output of this regression? 
* Meaning, if we are interetsed in the coefficients, p-values, etc. can we use them in Stata without typing them out?
	
* Briefly, yes, you can call the output of most statistical tests using the e() command.
* To see what output stats are available, open the help file and scroll to "Stored results" at the bottom	
help regress

* regress has stored results for the following categories:
	* Scalars - individual numbers, such as the number of observations, r-squared, and adjusted r-squared values
	* Macros - parameters of the model which you decide when running the command. We don't use these much at the beginner level.
	* Matrices - collections of numbers, such as the coefficient values or variance-covariance matrix. Mostly we want the coefficients.
	
* So after running the regress command, you can specify particular outputs by calling:

ereturn list // For all stored estimates

display e(N) // Number of observations
display e(r2) // r-squared
display e(r2_a) // adjusted r-squared

matrix list e(b) // Coefficient vector; Note: we can't use display since it's a special matrix form
matrix b = e(b) // We can, however, turn the output matrix into a regular matrix
display b[1,1] // Then display pieces of it
display _b[perc_refugees2018] // Or you can use the special _b[] format

*Note: this is not typically something you would do, since the regression table has all this info
	
* Some commands use another command, r(), to accomplish the same thing:

summarize perc_refugees2018, detail

return list // For all stored results

display r(N)
display r(mean)
display r(min)
display r(max)

display r(max) - r(min)

gen perc_refugees_mean = .
replace perc_refugees_mean = r(mean)

gen refugee_mean_diff = .
replace refugee_mean_diff = ///
	(perc_refugees2018 - perc_refugees_mean) / perc_refugees2018

* Which use r() and which use e()? 
	* r() is typically for descriptive "results"
	* e() is more for analysis "estimates"
	* You can also check the help file for the command in question to be sure.
	
	* Here are two useful online resources on the subject: 
	* http://wlm.userweb.mwn.de/Stata/wstatres.htm
	* https://stats.idre.ucla.edu/stata/faq/how-can-i-access-information-stored-after-i-run-a-command-in-stata-returned-results/
	
* Why would we want to do this?
		* To use results in further manipulations (like egen commands) or for output tables.
		
***********************************************		
* Output Tables Made Easy: estout and outreg2 *
***********************************************	
	
* Guide to the estout package: http://repec.sowi.unibe.ch/stata/estout/
* Guide to esttab: http://repec.sowi.unibe.ch/stata/estout/esttab.html

* Installing estout
ssc install estout, replace

* First, run your regression:

regress unemploy_prop_both2018 perc_refugees2018 ///
if surface_area > 30

* Then you can estout in Stata:

estout // Not that impressive yet.

* But when we use esttab:

esttab // Much better!

* How about labels and output to a word file?

esttab using "est_reg.rtf", label replace

* Or a .csv file?

esttab using "est_reg_excel.csv", label replace

* The biggest advantage of esttab over outreg2 is the eststo command:

eststo: quietly regress unemploy_prop_both2018 perc_refugees2018 if surface_area > 30

eststo: quietly regress unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 if surface_area > 30

eststo: quietly regress unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 perc_pop_concern2018 if surface_area > 30

esttab using "large_table.rtf", label replace title("Full Regression Table") mtitle("Model 1" "Model 2" "Model 3") r2 ar2
		
eststo clear // Make sure to clear the estimates after so you don't use them in future regression tables!

* Bonus: estpost

estpost summarize unemploy_prop_both2018
esttab, cells("count mean sd min max")

*------------------------------------------------------------------------------------------------------------*		
				
* Quick Guide to outreg2: http://goodliffe.byu.edu/328/outreg2steps.pdf	
* More detailed guide: https://www.princeton.edu/~otorres/Outreg2.pdf

* Installing outreg2
ssc install outreg2, replace	
		
* Don't forget to run your regression again, so Stata knows to use the latest output
regress unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 perc_pop_concern2018 ///
if surface_area > 30
		
* Then output your regression to an external file, in this case a word document:
outreg2 using "reg_output", word replace

* To see your output table, open the word file created in your working directory.

* The replace option overwrites any previously existing file of the same name.
* But what if we want to include multiple regressions into a single table?
	* This is standard practice for many research journals and papers.
	
regress unemploy_prop_both2018 perc_refugees2018 ///
if surface_area > 30
	
outreg2 using "reg_output", word append	

* Typically we want to start with the most simple regression (the primary independent variable) and add more variables:

regress unemploy_prop_both2018 perc_refugees2018 ///
if surface_area > 30
	
outreg2 using "reg_output", word ctitle("Model 1") replace

regress unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 ///
if surface_area > 30

outreg2 using "reg_output", word ctitle("Model 2") append	

regress unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 perc_pop_concern2018 ///
if surface_area > 30
		
outreg2 using "reg_output", word ctitle("Model 3") append	
		
		* Note: You can set the column title for each appended column with ctitle("Column Title")
		
* Other useful options include output as an excel file:

outreg2 using "reg_output.xls", excel replace

* outreg2 using "reg_output.xls", replace // You can also just change the file extension.

* Using variable labels rather than names:

outreg2 using "reg_output_labs", word label replace

* Reporting adjusted r-squared:

outreg2 using "reg_output_adj_r2", word adjr2 replace

* For more options, of course:
help outreg2		
		
* outreg2 is also useful for creating quick tables of summary stats:
outreg2 using "sum_stats.doc", replace sum(log)
		
		
		
* I prefer estout for its formatting options and ability to make large tables without appending over multiple commands.
* But it's good to know both in case you work with someone else who uses a different package.		
		
		

********************		
* Predicted Values *
********************

* We know that the regression model generates a "line of best fit" based on our data.
* In other words, for given values of the independent variable, it predicts values of the dependent variable.
* Mathematically, this follows the regression equations we see:

* Yi = B0 + B1 * Xi + Ei

	* Where Yi is our dependent, B0 the intercept (constant), B1 the regression coefficient, and Xi the independent.
		* Ei is an error term indicating the residual for the given observation.

* To estimate the values of Yi for any value of Xi, we can use predict after a regression command:

regress unemploy_prop_both2018 perc_refugees2018 if surface_area > 30

* Challenge 1: Create a new variable containing predicted values for unemployment, only for countries with a surface area over 30
predict unemploy_predictions if surface_area > 30

* Challenge 2: Summarize your predictions.
summ unemploy_predictions // These predictions are stored as another variable in your data.

* You can see for yourself that the residuals are the difference between predicted and observed data:

gen residual = (unemploy_prop_both2018 - unemploy_predictions) if surface_area > 30 & perc_refugees2018 != .
gen residual2 = residual * residual // Residuals squared
egen est_ess = sum(residual2) // Residual sum of squares
display est_ess

quietly regress unemploy_prop_both2018 perc_refugees2018 if surface_area > 30 // The quietly pre-command just tells Stata not to show the output
display e(rss)
		
* You can also plot the predictions to see your line of fit:

scatter unemploy_predictions perc_refugees2018 || lfit unemploy_prop_both2018 perc_refugees2018 if surface_area > 30
	
* You can also just plot the predicted points on top of the original ones to see the difference:	
		
scatter unemploy_predictions perc_refugees2018 || scatter unemploy_prop_both2018 perc_refugees2018 if surface_area > 30		
		
* Question 1: Does this look like a good set of predictions based on the data?	
	* Not at all. The regression wasn't significant to begin with.
	* Plus we have that clustering of observations with near 0 refugees, that have a wide spread of unemployment values.
	* This violates one of the assumptions of OLS regression: homoskedasticity. More on this later.
		
* Predictions are often helpful for creating a set of predicted outocome values for a standard set of inputs.
	* For example, you may have be interested in the effect of age on wages.
		* But your sample may only contain ages from 25 - 50, and it is likely distributed unevenly.
		* Assuming the relationship is linear (which it very likely isn't, but we haven't talked about other options)
			* then you can model a relationship based on the sample data,
			* then predict the values for all ages 18 - 75 using another set of age data.
					* You can make this "empty" set of age data in Stata or Excel.
		* You can also include controls in your regression model (like education)
			* then your prediction "controls" for these based on the age-wage relationship you specified.
		* So the prediction gives the expected wage for each age "holding education constant"
			* meaning the new dataset that you are making predictions from must have an education variable too.
			
* Predictions can be more useful for regression models with binary dependent variables, like probit or logit models.
		* But we also haven't learned about these yet.
		
* The concept of a prediction also transfers over to the more "data science" side of things,
	* where making accurate predictions based on previous data is typically the focus,
	* rather than understanding the relationship between variables.
		
* Remember, Stata doesn't care if your regression is significant or not!
* It will do predictions, plots, etc. as if you had a perfect model.
* It's up to you to decide if your regression model is any good.
		
*******************************************************	
* Distribution and Skew: Histograms and Density Plots *
*******************************************************	

* Let's go back to the original UN Labor and Migration data, that included multiple years:

use "UNSD_Labor_Migration.dta", clear

* Let's say we're only interested in how unemployment rates change over time:

keep regioncode surface_area unemploy_rate*

* Then use that foreach loop to restrict just to countries:

foreach val in 1 2 5 9 11 13 14 15 17 18 21 30 34 35 39 143 145 151 154 155 202 419 {
drop if regioncode == `val'
}


* Histograms:

* Challenge 3: Make a histogram for the unemployment rate in 2005.
histogram unemploy_rate_both2005 

* Histograms can be overlaid, but there are no transparency options (in older Stata)
twoway histogram unemploy_rate_both2005, color(blue) fintensity(inten50) || histogram unemploy_rate_both2010, color(red) fintensity(inten50)
	
	* Apprently Stata 15 introduces transparency: https://www.stata.com/new-in-stata/transparency-in-graphs/
	* Try: twoway histogram unemploy_rate_both2005, color(blue%20) || histogram unemploy_rate_both2010, color(red%20)
	
* Histograms can also include distributions:
histogram unemploy_rate_both2005, normal
hist unemploy_rate_both2005, kdensity

* Generally, I prefer frequency distributions expressed in density plots rather than histograms:

kdensity unemploy_rate_both2005, normal // This plot tells us the frequency distribution and that it's not a normal distribution

* In fact, we can tell the modality and skew from this plot as well.

* Question 2: What modality and skew does the distribution of our unemployment data from 2005 have?

	* Modality refers to the number of "humps" the frequency distribution has.
		* Here we have unimodal data - there is one prominent mode (most frequent value, or bin of values)
		* Sometimes we can get bimodal data if there are two "peaks" in our curve
			* Think about the distribution of heights in a classroom - there may be two peaks: one for the average male height and one for average female.
			* Bimodal distributions can often tell us it may be helpful to split data into groups; in this case, by gender
	* Skew refers to distribution that doesn't conform to a symmetric "normal" bell shape.
		* Right skew has more concentration in lower values, with some high outliers (the graph "clumps" on the left)
		* Left skew has more concentration in higher values, with some low outliers (the graph "clumps" on the right)
		* It is indeed exactly the opposite of what you might expect.
		* So our unemployment data is right skewed, which means most observations have "lower" levels with a few outliers on the right.
		
* Quick guide to Shape of Distribution: http://homepage.divms.uiowa.edu/~rdecook/stat1010/notes/Section_4.2_distribution_shapes.pdf
		

******************************************************		
* Data Visualization Cont: Bar Graph and Line Graphs *
******************************************************

* Let's plot the unemployment rates for the top five countries as a bar graph:

* First sort our observations on unemployment.
sort unemploy_rate_both2005 // But remember sort only does ascending values, so our first observations are the lowest rates...

* One option is to try specifying the last values manually:

graph bar unemploy_rate_both2005 in 205/209, over(regioncode) // The over() option specifies we want to group by regioncode
	
* But where is our data?

* List quickly gives values for a variable. The -5/L tells it to take the last 5 observations.
list unemploy_rate_both2005 in -5/L // This keeps us from having to "hard code" the observation numbers.

* But we see they are all missing values! That explains our missing graph data!
	
* What if we specify we don't want missing values?
list unemploy_rate_both2005 in -5/L if unemploy_rate_both2005 != .	

*This runs, but it doesn't show us anything, since all 5 were missing.

* Let's extend our search and hope for the best:
list unemploy_rate_both2005 in -10/L if unemploy_rate_both2005 != . // Hooray, data points!

* Let's try graphing it again with those restrictions:
graph bar unemploy_rate_both2005 in -10/L if unemploy_rate_both2005 !=. , over(regioncode)

* But what if we want them in order of unemployment?
graph bar unemploy_rate_both2005 in -10/L if unemploy_rate_both2005 !=. , over(regioncode, sort(1) reverse) //



* What if we wanted to show unemployment rates over time?

graph bar unemploy_rate_both2005 unemploy_rate_both2010 unemploy_rate_both2015 in -10/L if unemploy_rate_both2005 !=. , over(regioncode)


*-------------------------------------------------------------------------------------------------------------------*

* What is another good way to show unemployment over time? Particularly if we want to display more data?
	* Line graphs!

* Let's try a line graph with the data we have.

* Challenge 4: Make a line graph of unemployment rates from 2005 to 2010.

twoway line unemploy_rate_both2005 unemploy_rate_both2010

* Whoa, what is that? Clearly line graphs aren't as easy or intuitive as scatter or bar plots.
	* The best way to think of line graphs are as scatterplots, with all the points connected.
	* So you need to organize your data by variables in order for a traditional line graph to make sense.
	
	
* Let's take a sneak peek of reshaping data to create a "year" variable by making our data in the "long" format:

keep regioncode unemploy_rate_both* // First we should cut out the gender-specific variables to avoid confusing Stata.

reshape long unemploy_rate_both, i(regioncode) j(year)

sort regioncode year

browse // Check out our new "long" data!

* Now we can make a better line graph.

* Challenge 5: Make a line graph showing the unemployment rates in Brazil over our 4 years of data.

twoway line unemploy_rate_both year if regioncode == 76 // Unemployment trends in Brazil

* What if we wanted to compare countries though?
* We can always overlay multiple graphs:

twoway (line unemploy_rate_both year if regioncode == 76, legend(label(1 "Brazil"))) ///
		(line unemploy_rate_both year if regioncode == 152, legend(label(2 "Chile")))
	* But this gets tedious quickly.
	
* It's a bit much for this many countries, but you can separate a variable into new variables by category:
	separate unemploy_rate_both, by(regioncode)

graph twoway line unemploy_rate_both76 unemploy_rate_both152 unemploy_rate_both170 year, ///
legend(label(1 "Brazil") label(2 "Chile") label(3 "Colombia"))	

* You can easily graph large numbers of categories this way:

graph twoway line unemploy_rate_both4-unemploy_rate_both32 year

* But the labels are kind of long. Here is a quick loop to rename the variables to improve the legend label:

foreach var of varlist unemploy_rate_both4-unemploy_rate_both894 {

local vname : var label `var'
local newname = subinstr("`vname'","unemploy_rate_both, regioncode ==", "", .)
label variable `var' "`newname'"
}

* Now our multi-country graph has nice labels:
graph twoway line unemploy_rate_both4-unemploy_rate_both32 year

* In summary:
* Line graphs work best with time series that have more observations and fewer categories.
* Here is a guide that better shows the difference of using separate: http://www.michaelnormanmitchell.com/stow/line-graphs-for-separate-groups.html

**************************************	
* Log Transformations and Log Plots  *
**************************************

* Load in the system standard gapminder data:

sysuse gapminder, clear		

* Now remember what the scatterplot of GDP per Capita and Life Expectancy looked like?

scatter lifeexp gdppercap

* Challenge 5: Create new variables for both gdppercap and lifeexp that apply a natural logarithmic transformation.

gen lifeexp_log = ln(lifeexp)
gen gdppercap_log = ln(gdppercap)

* Compare the log transformed values to the originals:
summ lifeexp_log
summ lifeexp

* Question 3: How would the scatterplot change for the log transformed versions of both variables?

scatter lifeexp_log gdppercap_log

* The relationship becomes much more linear (and therefore more appropriate for a linear regression)

* It's more obvious with a line of best fit:

twoway scatter lifeexp_log gdppercap_log || lfit lifeexp_log gdppercap_log
twoway scatter lifeexp gdppercap || lfit lifeexp gdppercap

* So let's compare regression outputs using eststo and esttab:

eststo: quietly regress lifeexp_log gdppercap_log 

eststo: quietly regress lifeexp gdppercap
 
esttab, r2 ar2 // Check out that t-stat and r2 difference!

eststo clear // Make sure to clear the estimates after so you don't use them in future regression tables!

* Question 4: What does the log transformation mean for our interpretation?

	* So for the original variables, our regression model says:
		* "For every 1 unit change in GDP per Capita, Life Expectancy changes by 0.000765. 
			* "So for every $1,000 change in GDP per Capita, Life Expectancy increases by 0.765, or approximately 9 months."
	* For the log transformed variables, however, the regression interpretation would now be:
		* "For every 1% change in GDP per Capita, Life Expectancy changes by 0.147%"
			* "So if a country increases from $1,000 GDP per Cap to $2,000 (100%), Life Expectancy should increase by 14.7%."
			* "If Life Expectancy was 50, it would now be predicted to be 57.35."
		* Clearly the expected change is far more contextually dependent on previous levels, which fits more with our framework for growth effects on health.
		
	* Log-log models are slightly more difficult to explain, but a much more accurate statement given the r-squared value and conceptual framework.
	* If you've studied elasticity models in economics, they often use log-log regressions to estimate price sensitivity.
	
* We can also just use one log-transformed variable, to create "log-level" or "level-log" models.

scatter lifeexp_log gdppercap // "log-level"
scatter lifeexp gdppercap_log // "level-log"

* I like the level-log model here:

regress lifeexp gdppercap_log

	* We could interpret: "For every 1% change in GDP per Capita, Life Expectancy is predicted to increase by 0.084 years."
		* "So if GDP per Capita changed from $10,000 to $20,000 (100%), Life Expectancy is expected to increase by 8.4 years."
		* "Or, a doubling of GDP per Capita is expected to increase life expectancy by 8.4 years, on average."
	* The interpretation of the coefficient changes depending on the model! 
	* To keep track of which is which, I like the following table:

* Short Online Explanation with linked videos: http://www.cazaar.com/ta/econ113/interpreting-beta

* For a more academic, mathematically oriented explanation: https://www.cscu.cornell.edu/news/statnews/stnews83.pdf

