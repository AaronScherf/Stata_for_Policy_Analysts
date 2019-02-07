* PP297: Stata for Policy Analysts
* Session 1: Intro Stata
* Created by: Aaron Scherf
* Student Edition

* Today's Commands: 
* cd, dir
* clear, use, sysuse
* import, export
* describe
* summarize, tab, tabstat (mean, p50, variance, sd)

* Entering Data:

* Check Command Directory
cd

* List files in Directory
dir

* Set Command Directory
cd "C:\Users\Aaron\Desktop\Intro to Data Science\Stata\PP297.S19" // Note: Mac directories use "/" instead

* Clear Environment
clear

* Import Data from csv format
import delimited "data\PP297_Survey.csv", clear 

* Save as Stata .dta file
save "data\PP297_Survey.dta", replace

*Load in Data (.dta format)
use "data\PP297_Survey.dta", clear

* System Directory Data
sysuse auto, clear


* Descriptive Statistics:

*Summary Statistics
summarize price

sum price, detail

* Frequency Tables - One Way
tabulate mpg

tab foreign, summarize(mpg)

* Frequency Tables - Two Way
tab mpg foreign

tab mpg foreign, row

tab mpg foreign, column

* Tabstat
tabstat mpg, s(mean)

tabstat mpg, by(weight) s(mean, p25, p75 p50, var, sd)

