************************************
* PP297: Stata for Policy Analysts *
* Session 4: Intro to Analysis     *
* Created by: Aaron Scherf         *
* Instructor Edition               *
************************************

*********************
* Today's Commands: *
*********************

* ttest
* correlation
* regress
* kdensity
* scatter
* lfit
* predict

*******************************************
* Loading in UN Labor and Migration Data: *
*******************************************

* First set your command directory to the data folder:
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19\data"

* Then bring in the data file with use:
use "UNSD_Labor_Migration_Student.dta", clear


*******************************
* Cleaning Data for Analysis: *
*******************************

* Take a look at the data with the browser:
browse


* Wow that's a lot of variables... But lots of them seem repetitive, just for different years.
	* This is common in so-called "wide format" data, where each observation is unique but there is data that would repeat.
	* So called "long-format" would have a variable for "year" and only one variable for "lab_part_female" (female labor force participation).

* What if we were only interested in a single year of data? 
* How could we reduce our dataset to variables that have data for 2018?
	* Hint: You can individually select variables that end with an 18
	* OR you can make use of the "wildcard" option in variable lists: an asterisk *
	* To do this (much faster) way, use "*18" to indicate all variables that end in 18
	* Don't forget to keep your regioncode variable so you know what the observations are!
	* Also, there is a "surface_area" variable that doesn't have a year associated. Keep that too!
	
keep regioncode surface_area *18

* Browse your data again to check it out:
browse

* What do you notice about the variable format for the migration related variables?
	* They are all string variables, noticeable because they show up in the Browser as red.

* Use a command to convert the migration related variables to a more useful format.
		* Hint: use the options "force replace"
		* Hint2: You can specify a range of variables by writing the first variable, a hyphen, and the last variable:
			* So instead of typing out all the variables, use "asyl_incl_pending2018-tot_refugees2018"
destring asyl_incl_pending2018-tot_refugees2018, force replace		

* You can now use the following labels to make the data easier to read:

label var perc_lab_part_female2018 "Female Labor Force Participation (%)"
label var perc_lab_part_male2018 "Male Labor Force Participation (%)"
label var perc_lab_part_both2018 "Total Labor Force Participation (%)"
label var unemploy_rate_female2018 "Female Unemployment Rate"
label var unemploy_rate_male2018 "Male Unemployment Rate"
label var unemploy_rate_both2018 "Total Unemployment Rate"
label var surface_area "Surface Area"
label var perc_pop_zero_fourteen2018 "Percentage of Population Age 0 to 14"
label var per_pop_sixty_plus2018 "Percentage of Population Age 60+"
label var pop_density2018 "Population Density"
label var pop_estimate_mill2018 "Population Estimate (Millions)"
label var female_pop_estimate_mill2018 "Female Population Estimate (Millions)"
label var male_pop_estimate_mill2018 "Male Population Estimate (Millions)"
label var sex_ratio2018 "Sex Ratio"
label var asyl_incl_pending2018 "Asylum Seekers incl. Pending Cases"
label var perc_migrant_both2018 "Percent International Migrants"
label var tot_migrant_both2018 "Number International Migrants"
label var perc_migrant_female2018 "Percent Female Migrants"
label var perc_migrant_male2018 "Percent Male Migrants"
label var tot_pop_concern2018 "Total Population of Concern to UNHCR"
label var tot_refugees2018 "Total Population of Refugees"

* Much better! Now we can start analyzing this data!

* But hang on, did you notice that some observations aren't countries at all, but rather regions?
	* For example, regioncode == 1 is the total for the world.
	* May be helpful, but not if we want to compare countries.
	* Let's drop those observations that aren't countries.
	* I made a foreach loop to give a preview of future commands:
	
foreach val in 1 2 5 9 11 13 14 15 17 18 21 30 34 35 39 143 145 151 154 155 202 419 {
drop if regioncode == `val'
}

	* I don't understand the UN system of region codes, but yes I just had to look up each manually.
	* Ideally you would have a list of which codes are for countries and which aren't but I couldn't find one online.
	* If anyone ends up working for the UN please fix this.

************************
* Variable Management: *
************************

* Our data has most variables in percentage terms, which is good for cross-country comparison.
* However, the variables for "Total Population of Concern to UNHCR" and "Total Population of Refugees" are not.
* Let's turn these into percentages so we can compare countries accounting for total population size.

* Before we do though, what's the problem with our total population variable, compared to the refugee variables?
	* It's in millions, while refugees are in single (regular) numbers.
	
* Create new population variables to account for this mismatch:

gen pop_estimate2018 = pop_estimate_mill2018 * 1000000
gen female_pop_estimate2018 = female_pop_estimate_mill2018 * 1000000
gen male_pop_estimate2018 = male_pop_estimate_mill2018 * 1000000	

label var pop_estimate2018 "Population Estimate"
label var female_pop_estimate2018 "Female Population Estimate"
label var male_pop_estimate2018 "Male Population Estimate"

* Now let's drop the original population variables so we don't get confused:

drop pop_estimate_mill2018 female_pop_estimate_mill2018 male_pop_estimate_mill2018
	
* Generate two new variables for percentage of population for the two variables above:

gen perc_pop_concern2018 = tot_pop_concern2018 / pop_estimate2018
gen perc_refugees2018 = tot_refugees2018 / pop_estimate2018

label var perc_pop_concern2018 "Percentage of Population of Concern to UNHCR"
label var perc_refugees2018 "Percentage of Population Refugees"

* What country / region has the highest share of refugees relative to their population?
	* Hint1: You can use egen with tab.
	* Hint2: You can use if statements with tab.

	egen max_refugee_perc = max(perc_refugees2018)
	tab regioncode if perc_refugees2018 == max_refugee_perc

* These are going to be helpful, but we may want to subset data later based on refugee intake.
		* For example, in a regression it may be useful to eliminate countries that take virtually no refugees relative to their population.

* Let's make a categorical variable for quartiles of refugee as a percentage of population:
	* Hint: You can use either egen new_var = cut(perc_refugees2018), group(#) or xtile

egen perc_refugees_quart = cut(perc_refugees2018), group(4)	
label var perc_refugees_quart "Quartiles of Percentage Refugee Population"

* Then let's make dummy variables for each quartile with tab, gen():

tab perc_refugees_quart, gen(perc_refugees_dummy)	

* While we're at it, let's go ahead and make another dummy variable split at the median:
	* Note: There are a lot of coutries with missing values for refugee data.
	* egen and tab, gen() maintained these as missing values, but if you gen a variable default to 0 it won't.
	* So if you use gen be sure to default to . and replace with a 0 for non-missing observations.

gen perc_refugees_high = .
replace perc_refugees_high = 0 if perc_refugees_quart == 0 | perc_refugees_quart == 1
replace perc_refugees_high = 1 if perc_refugees_quart == 2 | perc_refugees_quart == 3

tab perc_refugees_high, m

* You could also do this with:
	* sum perc_refugees2018, det
	* gen perc_refugees_high = (perc_refugees2018 > r(p50)) // This way doesn't include missing values though!
	* replace perc_refugees_high = . if perc_refugees2018 == . // Make sure to bring them back in!

* Which countries are in the high refugee rate group?

tab regioncode if perc_refugees_high == 1

* Save your new dataset, just in case.

save "UNSD_Labor_Migration_Student_Update.dta", replace

****************************************************
* Data Exploration: Refugee Share and Unemployment *
****************************************************

* Now we have clean data with some good variables to run tests on.

* What if we were interested in whether the unemployment rates of countries are different
	* based on refugee rates?
	
* First, look at both variable's summary stats to ensure we're comparing like things:

tabstat unemploy_rate_both2018, s(n, mean, median, sd, var)
tabstat perc_refugees2018, s(n, mean, median, sd, var)

	* Definitely not on the same scale. Refugee rates are in proportion (0.004 = 0.4%) while unemployment is in percentage (7.72 = 7.72%)
	* Let's start by bringing unemployment rates into proportion (you could go the other way, doesn't matter).
	
gen unemploy_prop_both2018 = unemploy_rate_both2018 / 100	
	
tabstat unemploy_prop_both2018, s(n, mean, median, sd, var)
	
* Now run a t-test of total unemployment rate, split by our perc_refugees_high variable.

ttest unemploy_prop_both2018, by(perc_refugees_high)

* Which has a higher unemployment rate, countries with relatively lower refugee proportions or higher ones?
	* Is the difference statistically significant? At what level? How do you know?
	
	* Higher refugee proportion countries have higher unemployment rates, by 1.32 percentage points.
	* The difference, however, is not statistically significant at the 95% confidence level.
	* The t-statistic is -1.4135, so its absolute value is less than 1.96.
	* The p-value of the two-sided alternative Ha: diff != 0 is 0.1596.
	* So if we wanted to give it a significance level, it would only be at 84.04% significance.

* Let's get into more detail on this question. Run a correlation between the unemployment rate
	* and percentage of refugees of the population.
	* Hint: Use the continuous variable for this, not the categorical or binary refugee variables we created.
	
corr perc_refugees2018 unemploy_prop_both2018 

* Is there any correlation between refugee intake and unemployment rate?
	* Not really.
	
* What if we ran a correlation using the quartiles and dummy variables we made for refugee levels above?

pwcorr  perc_refugees2018 perc_refugees_quart perc_refugees_high unemploy_prop_both2018

* What does this tell us about the value of finer detail data (continuous variables) over grouped data?

	* Coarse data in grouped variables like quartiles can be misleading, as it may insinuate a relationship exists in aggregate when it doesn't hold up at finer levels of detail.
		* That said, there may only be noticeable effects on unemployment from more extreme differences in refugee rates.
		* Or it reflects what type of countries are hosting large numbers of refugees, rather than anything about the relationship between them.
			* This would indicate some omitted third variable driving both (such as geographic location).
			
* Do we learn anything new from a bivariate regression of unemployment rates on our high refugee rate dummy?

regress unemploy_prop_both2018	perc_refugees_high

	* The output has some more information, but for the most part it tells the same story: the difference is small and non-significant.

* What about a bivariate regression of unemployment rates on our continuous refugee rate variable?

regress unemploy_prop_both2018 perc_refugees2018

	* Again, we see that the relationship between the two at the country level is almost nonexistent.
	* We probably could have guessed this from the very weak correlation.
	
* Looking at the data, though, a lot of countries represented are tiny islands, who understandably have few refugees.

* What if we wanted to run our bivariate regression on the continuous refugee rate variable without islands?
* What variable would most readily identify islands (or other small countries, like Lichtenstein)?

tab surface_area, m

* Run the regression of continuous variables again, this time only on a sub-sample of countries with surface area greater than 30

regress unemploy_prop_both2018 perc_refugees2018 if surface_area > 30

* How did the number of observations, coefficient, and statistical significance change?

	* We lost around 30 observations but the coefficient on percent refugees jumped from 0.009 to 0.658
		* The t-statistic for the refugee variable went from 0.03 to 0.225, and the p-value from 0.977 to 0.225
		* This is huge difference! But still not a statistically significant finding at the 95% level, or even the 80% level.
		
* What can this change in results tell us about the relationship between refugee share and unemployment?
	* There is more reasons to suspect that there may be some relationship.
	* But we still have no idea which direction it is: does high unemployment lead to refugee intake, or refugee intake to high unemployment?
	* Or are both caused by some third factor, or set of factors?
		* Such as proximity to conflict zones, relative prosperity (GDP), etc.
	* In any case, even if the relationship were significant, we haven't shown any causal evidence, just a fancier correlation.
	
* What if we wanted to "control" for other variables, 
	* such as the percentage of international migrants or percentage of population of concern to the UNHCR?

* First, check for the correlation between the four variables: unemploy_rate_both2018 perc_refugees2018 perc_migrant_both2018 perc_pop_concern2018

pwcorr unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 perc_pop_concern2018

* What does the correlation table tell us?
	* There is almost no correlation between unemployment and refugee rates.
	* There is a slight negative correlation between international migrant rates and unemployment rates.
	* There is a slightly stronger positive correlation between refugee rates and migrant rates.
	* There is a small correlation between concern population and unemployment, but a fairly strong correlation between concern and refugees.
	
* How does this change if we take out those small countries again?	
	
pwcorr unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 perc_pop_concern2018 ///
if surface_area > 30

		* The refugee rate and unemployment correlation became stronger.
		* The migrant rate and unemployment rate became weakly positively correlated
		* The migrant and refugee rates are even more strongly correlated.
		* The population of concern rate is more strongly correlated to unemployment, but less correlated to refugee rate.
		
* Now try a multivariate regression using the same variables, removing small countries again.

regress unemploy_prop_both2018 perc_refugees2018 perc_migrant_both2018 perc_pop_concern2018 ///
if surface_area > 30

* How would you interpret the output of this regression?

	* The percentage of refugees and percentage of migrants are not statistically significant at all.
	* The population of concern to the UNHCR is significant at the 10% level, with a coefficient of 0.1795
	* This could be read as "For every 1 percentage point change in the population of concern to the UNHCR,
		* the unemployment rate increases by 17.95%"
	* That would be a pretty huge finding! If it were meaningful.
	
	* But, again, this is nothing but a correlation. 
	* It's much more likely that countries with high unemployment rates and 
		* high proportions of their population at concern to the UNHCR are experiencing both
		* due to other factors, like economic performance, conflict, etc.
		
	* Besides, the R-squared on our regression model was just 0.0347, 
		* which tells us that this model doesn't explain much of the variation in the data.
		

	* More importantly, there is no causal identification here. 
	* For that we would need either a randomized sample or quasi-experiment.
	* We'll learn about both later!
	
	* In general, cross-country data is pretty useless for everything besides summary statistics.
	* Regressions tell us almost nothing new, really.
	
*****************************************************	
* Data Visualization: Scatterplots and Lines of Fit *
*****************************************************	

* So we haven't found much in terms of regression so far, but let's take a look at our data anyways.

* We already saw how to look at frequency distributions of individual variables

kdensity perc_refugees2018

kdensity unemploy_prop_both2018

* You can overlay graphs using the twoway option, which is a generic "wrapper" for graphs in Stata
	* Then separate the two plots with a double ||

twoway kdensity perc_refugees2018 || kdensity unemploy_prop_both2018

* We see that there is a huge concentration of countries with almost no refugees.

* Let's explore how these two variables are related visually:

scatter perc_refugees2018 unemploy_prop_both2018 

	* Not much of a positive relationship to observe. Let's check with a line of best fit.
	
scatter perc_refugees2018 unemploy_prop_both2018 || lfit perc_refugees2018 unemploy_prop_both2018 
	
* What if all those zeros are preventing a relationship from being expressed?	
	
scatter perc_refugees2018 unemploy_prop_both2018 if perc_refugees_quart > 1 & perc_refugees_quart != .	

	* Even removing many of the near-zero refugee countries the relationship is flat, with a few outliers.
	
* Let's add a line of best fit again just to be sure.	
	
scatter perc_refugees2018 unemploy_prop_both2018 if perc_refugees_quart > 1 & perc_refugees_quart != . ///
	|| lfit perc_refugees2018 unemploy_prop_both2018 if perc_refugees_quart > 1 & perc_refugees_quart != .
	
* You can think of the lfit line as a visualization of the regression:

regress perc_refugees2018 unemploy_prop_both2018 if perc_refugees_quart > 1 & perc_refugees_quart != .

	* The coefficient is slightly negative but almost 0, while the intercept is around 0.01
	* The lack of significance is reflected in how disperse the points are from the line.
	
**************************************	
* Analysis with Significant Findings *
**************************************

* So our big takeaway from the UN data is that cross country analyses are rarely helpful,
		* and refugee data is too sparse at the country level to have much meaningful correlation with unemployment.
		
* Let's take a look at some regressions, plots, and predictions with more useful microdata.
* Load in the system standard gapminder data:

sysuse gapminder, clear		

* Regress lifeexp on gdppercap:

regress lifeexp gdppercap

	* What does the regression output tell us?
		* For every 1 unit change in GDP per capita, the change in life expectancy is 0.00765 years.
		* The "base" life expectancy is the intercept coefficient: 53.956
		* The relationship is significant at the 99.99% level with a p-value of 0.000
		* Is this economically significant?
			* GDP per capita is most likely in dollars, so a $1 change isn't much.
				* Think of a $100 change; that would be associated with 0.765 year change, around 9 months!

	* What implications do these findings have for the development of countries?
		* GDP per capita is correlated with higher life expectancy, but does this tell us anything about causality?
		* Again, cross country panels don't mean much in practice. 
		* Should we take this as an argument to focus on economic development, and higher life expectancy will follow?
			* Perhaps not. Perhaps people living longer increases economic output. Perhaps something else, like education, is driving both.
			* Never assess causality or impact from a basic regression without an identification framework (more on this later).
	
* What if we wanted to subset to countries in Africa?

regress lifeexp gdppercap if continent == "Africa"	

	* The intercept dropped to 45.844, and the coefficient is smaller, if still significant.
	* The interpretation again would be that for every $1 change in per capita GDP, life expectancy increases by 0.0014 years.
	
* What if we wanted to simultaneously see the "fixed effect" of being in each continent?

regress lifeexp gdppercap continent	// Oh no, we lost all our data? No, regress just doesn't like string variables.

* Generally, if you want to create "factor variables" in a regression you have to start it with an i.var

regress lifeexp gdppercap i.continent	// But again we see strings are bad.

* Make a categorical variable for the continents using the old school gen-replace technique:

gen continent_cat = .
replace continent_cat = 1 if continent == "Americas" // I chose Americas first not from some Western hemisphere pride, order matters for regressions with factor variables.
replace continent_cat = 2 if continent == "Africa"
replace continent_cat = 3 if continent == "Asia"
replace continent_cat = 4 if continent == "Europe"
replace continent_cat = 5 if continent == "Oceania"

label var continent_cat "Continents"
label define continent_cat_lab 1 "Americas" 2 "Africa" 3 "Asia" 4 "Europe" 5 "Oceania"
label val continent_cat continent_cat_lab

* Now regress life expectancy on GDP per capita again with a factor variable for continents as a control:

regress lifeexp gdppercap i.continent_cat

* We see that Africa and Asia have "negative effects" on life expectancy, while Europe and Oceania have "positive effects"
* But where are the Americas?
	* Stata automatically drops the first category to use as a baseline, it doesn't even show up in the output.
	* This is to avoid the statistical issue of multicolinearity, whereby one independent variable explains all the variation in the dependent variable.
	* Stata won't let multicolinearity happen; if it seems like it might Stata will give an error or remove a category.
	
	
* What if we want to plot this regression as a line?
	
scatter lifeexp gdppercap || lfit lifeexp gdppercap i.continent_cat	

	* Stata doesn't like to include factor variables in lines of fit...

scatter lifeexp gdppercap || lfit lifeexp gdppercap

* Since the line of fit uses the regression without the categorical variable "continent_cat", the intercept is 
	* at the original regression point of 53.95, not the "new" intercept of 61.48
* This shows how the introduction of controls changes the intercept and coefficient of your "main relationship of interest".

* But what if we did want to plot our line from the regression with controls?

* We can use predict to generate the predicted values based on our full regression model.
		* First run the regression again, so Stata knows that is the model we're predicting from.
		
regress lifeexp gdppercap i.continent_cat

		* Then predict a new variable
		
predict lifeexp_pred1		

scatter lifeexp_pred1 gdppercap // We see our "lines" predicted for each continent!

scatter lifeexp gdppercap || lfit lifeexp_pred1 gdppercap

* So now we have the line from our regression over the data. But we know the lines are different based on continent group.

* How can we graph the lines for each continent separately?

scatter lifeexp gdppercap || lfit lifeexp_pred1 gdppercap if continent_cat == 1 // Separate line of fit for the Americas

* Let's make lines for the Americas, Africa, and Asia

scatter lifeexp gdppercap || lfit lifeexp_pred1 gdppercap if continent_cat == 1 || lfit lifeexp_pred1 gdppercap if continent_cat == 2 || lfit lifeexp_pred1 gdppercap if continent_cat == 3

	* But Stata doesn't automatically read in labels...
	
	
* We have to manually set labels in Stata with the rather confusing set of plot options: legend(label(# "Label"))
scatter lifeexp gdppercap || lfit lifeexp_pred1 gdppercap if continent_cat == 1, legend(label(2 "Fit: Americas")) || lfit lifeexp_pred1 gdppercap if continent_cat == 2, legend(label(3 "Fit: Africa")) || lfit lifeexp_pred1 gdppercap if continent_cat == 3, legend(label(4 "Fit: Asia"))

****************
* Final Notes: *
****************

* Regress is a basic ordinary least squares regression, so by default it approximates a linear line to the data given.
* You can input quadratic terms to explore non-linear relationships, but the regression itself is still a straight line.
* You can also explore logarithmic relationships (which the gapminder data would be perfect for) by transforming variables with log functions.

* However, it only works for continuous dependent variables (the first variable after regress).
* Binary (dummy) variables cannot be used, nor can categorical (factor) variables.

* For those you need more advanced commands like logit, probit, or ologit.
* Be careful though, because the output for these advanced regression commands is not as straightforward as linear regression.
