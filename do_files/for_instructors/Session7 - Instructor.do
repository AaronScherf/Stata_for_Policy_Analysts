****************************************
* PP297: Stata for Policy Analysts     *
* Session 7: Intro Stata Programming   *
* Created by: Aaron Scherf             *
* Instructor Edition                   *
****************************************

*******************
* Today's Topics: *
*******************
* Review: Data Types & Exploration
* reshape
* global macros
* local macros
* foreach loops
* forvalue loops
* Panel Study on Income Dynamics

*************************
* Loading in PSID Data: *
*************************

set more off

* First set your command directory to the data folder:
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19\data"

* Then bring in the data file with use:
use "PSID_Long.dta", clear

**********************************
* Review: Processing Survey Data *
**********************************

* Let's see what variables we have:

summarize

* It's common in survey data to have a lot of codes that don't fit the "standard Stata" format.
* In this data there are a few different codes for missing that we need to recode.
* The only way to do this in Stata is go one by one through the variables.

* tab Ind_SEXINDIVIDUAL_, m
* tab Ind_SEXINDIVIDUAL_, m nolab
	* We can see that our missing value is coded as a 9 rather than a .
	
recode Ind_SEXINDIVIDUAL_ (1 = 0) (2 = 1) (9 = .), gen(Ind_FEMALE_) // Best to recode as a binary dummy

label var Ind_FEMALE_ "Female Dummy"
label define Female_Lab 0 "Male" 1 "Female"
label val Ind_FEMALE_ Female_Lab

* codebook Fam_CURRSTATE_ // Ah those damn FIPS codes

* tab Fam_CURRSTATE_, m // Well those labels are extremely unhelpful.

* tab Fam_CURRSTATE_, nolab m // I wonder if our previous FIPS codes will work?


label define fips_state_lab 0 "Other" 1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" 15 "HI" 16 "ID" 17 "IL" 18 "IN" ///
19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" 25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" ///
37 "NC" 38 "ND" 39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY"

label values Fam_CURRSTATE_ fips_state_lab

recode Fam_CURRSTATE_ (99 = .)

* tab Fam_A8ACTUALROOMS_, m
* tab Fam_A8ACTUALROOMS_, m nolab

recode Fam_A8ACTUALROOMS_ (98 = .) (99 = .) // Recoding our missing values again


* tab Fam_A19OWNRORWHAT_, m

recode Fam_A19OWNRORWHAT_ (9 = .)

* tab Fam_A20HOUSEVALUE_, m

recode Fam_A20HOUSEVALUE_ (9999998 = .) (9999999 = .) 
* Judging by the decline in values leading up to $9m, it seems unlikely this many people had multimillion dollar homes.
	* More likely that this was another label for missing data

* tab Fam_A25MNTHLYPMTSMOR1_, m

recode Fam_A25MNTHLYPMTSMOR1_ (9999998 = .) (9999999 = .) 
	
* tab Fam_W38BWTRHASSTUDLOANS_, m
* tab Fam_W38BWTRHASSTUDLOANS_, m nolab

recode Fam_W38BWTRHASSTUDLOANS_ (8 = .) (9 = .)

* tab Fam_W39B1AMOUNTSTUDLOANS_, m 
	
recode Fam_W39B1AMOUNTSTUDLOANS_ (9999998 = .) (9999999 = .) 

recode Fam_H1HEALTHSTATUSHEAD_ (9 = .) (8 = .) (0 = .)

* tab Fam_H22WTINPOUNDSHEAD_, m

recode Fam_H22WTINPOUNDSHEAD_ (0 = .) (998 = .) (999 = .)

recode Fam_H1HEALTHSTATUSSPOUSE_ (9 = .) (8 = .) (0 = .)

recode Fam_H22WTINPOUNDSSPOUSE_ (0 = .) (998 = .) (999 = .)

replace Fam_HOUSINGEXP_ = . if Fam_HOUSINGEXP_ < 0 // Not sure how people have negative housing expenses... Rental income? Subsidies?
replace Fam_REXP_ = . if Fam_REXP_ < 0 // Not sure how people have negative housing expenses... Rental income? Subsidies?

recode Fam_CURRREGION_ (0 = .) (9 = .)

* tab Ind_RELATIONTOHEAD_, m // Oh jeez, this is because the labels were so different across different years. Let's just ignore this variable.
drop Ind_RELATIONTOHEAD_

* tab Ind_AGEINDIVIDUAL_, m
recode Ind_AGEINDIVIDUAL_ (0 = .) (999 = .) // Somehow I doubt that over 40% of respondents were infants.

recode Ind_EMPLOYMSTATUS_ (0 = .) (9 = .)

recode Ind_YEARSCOMPLETEDEDU_ (0 = .) (98 = .) (99 = .)

recode Ind_HEALTHGOOD_ (0 = .) (9 = .) (1 = 0) (5 = 1), gen(Ind_GOODHEALTH_) // Let's make a binary that makes sense.

label var Ind_GOODHEALTH_ "Good Health Dummy"
label define Health_Lab 0 "Poor Health" 1 "Good Health"
label values Ind_GOODHEALTH Health_Lab

drop Ind_HEALTHGOOD_

* tab Ind_H62COVBYINSIN_ , m // What is going on here? Let's ignore this variable again.
drop Ind_H62COVBYINSIN_

recode Ind_G76NUMBERJOBSINPY_ (0 = .) (5 = .) (8 = .) (9 = .)

replace Ind_TOTALLABORINCOME_ = . if Ind_TOTALLABORINCOME_ < 0

replace Ind_TOTALTAXABLEINCOME_ = . if Ind_TOTALTAXABLEINCOME_ < 0

* Now we're ready to start working with the data!

save "PSID_Long_Update.dta", replace

**************************
* reshape: wide and long *
**************************

* Last session we discussed wide and long data formats:
	* Wide data typically refers to having more variables and fewer observations
	* Long data refers to having more observations and fewer variables
	* Both use a unique ID for the observations
		* But in long format, the ID may repeat over multiple rows
		* This is because there is a secondary variable that identifies them as unique, such as year
		
* Stata's reshape command can transform data from one type to the other, using the unique id (i) and secondary variable (j)

* What format is our PSID data currently in?

help reshape

	* It looks like we're in a long format, since we have a variable for year and there are multiple copies of the unique ID, distinguished by different years.
	* This confirms our standard for long data in which the unique ID is split systematically over multiple variables.

* Let's reshape it into a wide format:

reshape wide Ind_RELEASENUMBER_ - Fam_FAMWT_, i(UniqueID) j(year)	
	
	* The - between variables tells Stata to include all variables in the list between those two
	* The i() is for the unique identifier and the j() for the secondary variable that we want to split the other variables on.
		
* Take a look at our new varlist and observation count.

* As you can see, our variable list grew dramatically, while our observation count dropped

* As long as all of our variables have a _year attached (the stub), we can transform back to long
* You can list out all of those variables, but you need to chop off the year to get to the "stub" that j() needs.
	* Intuitively you might think you can use the wildcard * to account for this.
	* But you can't combine this with the "-" separator to account for multiple variables like below. Stata isn't that smart.

reshape long Ind_RELEASENUMBER_* - Fam_FAMWT_*, i(UniqueID) j(year)

	* Oh no, errors!
	* It turns out that Stata doesn't know to automatically cut off our years for the intervening variables, even with the wildcard (*)
	
	* How do we get around this?
	
	* One option might be to list each variable with the years chopped off:
	
reshape long Ind_RELEASENUMBER_ Ind_1968INTERVIEWNUMBER_ Ind_PERSONNUMBER68_ Ind_SEXINDIVIDUAL_ Fam_RELEASENUMBER_ Fam_CURRSTATE_ Fam_A8ACTUALROOMS_ Fam_A19OWNRORWHAT_ Fam_A20HOUSEVALUE_ Fam_A25MNTHLYPMTSMOR1_ Fam_W38BWTRHASSTUDLOANS_ Fam_W39B1AMOUNTSTUDLOANS_ Fam_H1HEALTHSTATUSHEAD_ Fam_H22WTINPOUNDSHEAD_ Fam_H1HEALTHSTATUSSPOUSE_ Fam_H22WTINPOUNDSSPOUSE_ Fam_IMPWEQUITY2_ Fam_HOUSINGEXP_ Fam_REXP_ Fam_CURRREGION_ Fam_IMMIGFAMWTNUMBER1_ Ind_INTERVIEWNUMBER_ Ind_SEQUENCENUMBER_ Ind_AGEINDIVIDUAL_ Ind_EMPLOYMSTATUS_ Ind_YEARSCOMPLETEDEDU_ Ind_GOODHEALTH_ Ind_G76NUMBERJOBSINPY_ Ind_TOTALLABORINCOME_ Ind_TOTALTAXABLEINCOME_ Ind_IMMINDIVIDUALWT_ Fam_FAMWT_, i(UniqueID) j(year)

	* But that takes a lot of copying, pasting, and editing text, which we prefer to avoid.
	* If we have to do it, we would rather just do it once and have it saved. But how can Stata do this? Macros!
	
	* For more on reshape: https://stats.idre.ucla.edu/stata/modules/reshaping-data-wide-to-long/
	
****************************	
* Macros: global and local *
****************************	

* Ever wanted to avoid typing something out over and over? Use macros!

help macro

* First we need our variable list from the long format. Let's go back to our original data to save time:

use "PSID_Long_Update.dta", clear

global varlist_years Ind_RELEASENUMBER_ Ind_1968INTERVIEWNUMBER_ Ind_PERSONNUMBER68_ Ind_SEXINDIVIDUAL_ Fam_RELEASENUMBER_ Fam_CURRSTATE_ Fam_A8ACTUALROOMS_ Fam_A19OWNRORWHAT_ Fam_A20HOUSEVALUE_ Fam_A25MNTHLYPMTSMOR1_ Fam_W38BWTRHASSTUDLOANS_ Fam_W39B1AMOUNTSTUDLOANS_ Fam_H1HEALTHSTATUSHEAD_ Fam_H22WTINPOUNDSHEAD_ Fam_H1HEALTHSTATUSSPOUSE_ Fam_H22WTINPOUNDSSPOUSE_ Fam_IMPWEQUITY2_ Fam_HOUSINGEXP_ Fam_REXP_ Fam_CURRREGION_ Fam_IMMIGFAMWTNUMBER1_ Ind_INTERVIEWNUMBER_ Ind_SEQUENCENUMBER_ Ind_AGEINDIVIDUAL_ Ind_EMPLOYMSTATUS_ Ind_YEARSCOMPLETEDEDU_ Ind_GOODHEALTH_ Ind_G76NUMBERJOBSINPY_ Ind_TOTALLABORINCOME_ Ind_TOTALTAXABLEINCOME_ Ind_IMMINDIVIDUALWT_ Fam_FAMWT_

display "$varlist_years"

* Then we can reshape back to wide:

reshape wide Ind_RELEASENUMBER_ - Fam_FAMWT_, i(UniqueID) j(year)	

* And now we can switch back to long with the macro we made!
	* Be sure to use a $ in front of the macro name, surrounded by quotes!

reshape long "$varlist_years", i(UniqueID) j(year)

* Global macros are stored in Stata as long as it's open. You can call them again and again for different things:

global addition = 2+2

display "$addition"

global go_bears = "panda grizzly koala"

display "$go_bears"


* Local macros, meanwhile, are only stored within a set of specific commands.
	* If you run two lines together from a do-file, the local will apply.
	* But if you run them separately they won't!
	* So if you are just running the whole do-file you can use a local, but if you want to run it in pieces you would need a global.
	
* Locals use a different grammar than globals:
	* Storing them works the same way:

local time_warp = "time is fleeting"

	* But calling them is different:
	
display "`time_warp'"

	* Notice the ` at the beginning and ' at the end, all surrounded by double quotes.
	* But you'll notice if you tried to run those separately it won't display.
	* Run the following two lines together (highlight both and hit "do")

local time_warp = "time is fleeting"
display "`time_warp'" 

* So locals may be helpful if we are running a whole do-file, but why not just use globals all the time?
	* Locals are more often used inside of loops and other multi-line commands, where their temporal nature allows you to use a lot of them over and over quickly.

* For more on macros: https://jearl.faculty.arizona.edu/sites/jearl.faculty.arizona.edu/files/Intro%20to%20loops,%20Year%202.pdf
	* https://data.princeton.edu/stata/programming

	
************************************
* For Loops: foreach and forvalues *
************************************

* For loops allow you to make Stata do something repetitive automatically.
	* If you are doing a lot of pointing and clicking or copying and pasting, for loops are your friend
	
* There are two kinds of for-loops:
		* foreach runs commands over a list of things
		* forvalues runs commands over a set of numbers
		
* Both use locals inside of the loop to replace a placeholder with the list items.
* Below I use "var" as a local name, then replace it with variable names using the local `var' inside.

* The syntax of forloops is somewhat confusing!
	* You need to specify a local name (var), then "of varlist" followed by  list of variables (you can use global macros here!)
	* Then comes a curly bracket {
	* Followed by your commands on the following line(s)
	* And ending with a closing curly bracket on the last line }
	
* The term "var" is a local macro!
		* When calling it within the loop, be sure to use backticks(`) at the beginning and apostrophes (') at the end
		* Note that you don't need to include quotes around the local when you call it, since it's a variable name rather than character string		

* var disappears after the loop is done, so you can recycle it in other parts of the code without fear of accidentally calling the wrong thing
	* Global macros will overwrite if you use the same name in a different place, but this may cause issues if you jump around your do-file
				
	
help foreach	

foreach var of varlist Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ {
display `var'
}

* We can use for loops to run lots of summary statistics:
	
foreach var of varlist Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ {
tabstat `var', by(Ind_SEXINDIVIDUAL_) s(n mean median sd)
}

* Or, more helpfully, we can run a lot of tests or regressions and store their results iteratively, to make a larger table.
* We can do this with our estout package:

foreach var of varlist Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ {
eststo: quietly regress `var' Ind_SEXINDIVIDUAL_
}

esttab using "loop_regress.rtf", label replace title("Full Regression Table")r2 ar2
eststo clear // Make sure to clear the estimates after so you don't use them in future regression tables!

* Or you can append to the bottom of a table:

foreach var of varlist Ind_AGEINDIVIDUAL_ Ind_YEARSCOMPLETEDEDU_ {
eststo: quietly regress `var' Ind_SEXINDIVIDUAL_
esttab using "loop_regress_append.rtf", label append title("Full Regression Table Appended") r2 ar2
eststo clear
}

* Typically I would recommend the top option, since estout has code to build large tables without appending.
* But other tests may be better appended, like tabstat or a ttest.

* foreach also allows the option of "in" rather than "of"
* They typically do the same thing but "in" is more general

* For example, you can call in several files and run commands over them.
	* Below is an arbitrary example that doesn't run, but gives you an idea of what can be done

foreach file in data1.dta data2.dta data3.dta {
use `file', clear
do "cleaning_file.do"
save "new_`file'", replace
}

* This loop would apply the stored do-file, "cleaning_file.do", to all three data files in the list, then save a new data file.
* This can be helpful if you have a lot of similar data sets that you want to apply the same commands to.


* ------------------------------------------------------------------------------------------------------------------------------- *

* forvalues is another form of loop, which uses a list of numbers rather than variables			
			
forvalues num = 1/5 {
display `num'
}


* Note the number list is using the shorthand form "#/#", where it will run all numbers between 1 and 5 in steps of 1.

* This can help if you want to repeat a calculation or command several times with different input parameters as numbers:

recode Ind_SEXINDIVIDUAL_ (1 = 0) (2 = 1) (9 = .), gen(Ind_FEMALE_)

forvalues num = 0(0.1)0.5 {
ttest Ind_FEMALE_ = `num'
}

* Here we ran ten one sided t-tests on the gender variable, to see if any are non-significant in their difference from the gender ratio.
* We use a different number list shorthand #(#)# in which we go from 0 to 0.5 in steps of 0.1

* As you can imagine, you can combine these loops in countless ways, including with regressions and table outputs as well as file imports and saves.
* You can also put loops inside of loops!

forvalues num = 100(100)300 {
foreach var of varlist Fam_H22WTINPOUNDSHEAD_ Fam_H22WTINPOUNDSSPOUSE_ {
ttest `var' == `num'
}
}

* Just don't forget to use two brackets at the end to close out the command!
* Note the order in which the results will run!
	* The foreach loop is inside the forvalues loop, so it will run both t-tests for the 100 number before moving onto the 200, then 300.
	
* For more on loops: https://data.library.virginia.edu/stata-basics-foreach-and-forvalues/	
	* https://www.ssc.wisc.edu/sscc/pubs/stata_prog1.htm
	
************************************************************	
* Challenge: Explore the PSID Data using Loops and Macros! *
************************************************************

* Take 30 minutes to apply all the concepts we've learned in exploring and testing the PSID variables.
		* Try running summary statistics using for loops!

* Here is an example of a for-loop that saves a density plot for each of the variables specified.
	* You can export them using the graph export command, then include the variable name in the filepath to make sure you differentiate a new file for each graph
			
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19\Graphs"		
		
foreach var of varlist  Fam_A8ACTUALROOMS_ Fam_A20HOUSEVALUE_ Fam_A25MNTHLYPMTSMOR1_ Fam_W39B1AMOUNTSTUDLOANS_ Fam_H22WTINPOUNDSHEAD_ Fam_H22WTINPOUNDSSPOUSE_ Fam_HOUSINGEXP_ Fam_REXP_ {
kdensity `var'
graph export "kdensity_`var'.png", as(png) replace
}

* As you can imagine, you can do this for regressions too:

* But first we should make a new folder for the output files.
* If you would rather not make a new directory by hand, you can do so in Stata with mkdir

cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19"		

mkdir "Regression"	

* You can also set your command directory via a global macro:

global path "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19"

cd "$path\Regression"

* Now our regression output loop:

eststo clear // Just in case you had leftover results stored

foreach var of varlist Fam_A19OWNRORWHAT_ Fam_W38BWTRHASSTUDLOANS_ Fam_H1HEALTHSTATUSHEAD_ Fam_CURRREGION_ Ind_EMPLOYMSTATUS_ Ind_FEMALE_ {
eststo: quietly regress Fam_HOUSINGEXP_ i.`var'
esttab using "loop_regress_housing_`var'.rtf", label replace title("Regress Housing Expense on `var'") r2 ar2
eststo clear
}

* You can also do loops for summary statistics using estpost and esttab:

cd "$path"

mkdir "Summary_Tables"

cd "$path\Summary_Tables"

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

* For more on outputting to Windows: https://www.cpc.unc.edu/research/tools/data_analysis/statatutorial/misc/exporting_results



