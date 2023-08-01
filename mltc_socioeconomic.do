//Do the associations between risk factors and MLTCs status differ according to socio-economic status?

**************************************
use "filepath\taskB.dta"

describe 

tab MLTC
tab smoking 
tab alcohol
tab phys_act
tab obesity
tab sex
tab ethnicity
tab wealth 
tab cohabitation 

summ age //mean = 61.6 
hist age //right skewed, long right tail 

summ age if MLTC == 0 //mean = 60.0
summ age if MLTC == 1 //mean = 63.4 

**Visuals
tab unhealth_num MLTC, r 

gen unhealth_num = smoking + alcohol + phys_act + obesity
tab unhealth_num // very low percentage in 3 and 4 counts, roll up to 2
replace unhealth_num = 3 if unhealth_num == 4
replace unhealth_num = 2 if unhealth_num ==3
label define unhealth_num 0 "0 unhealthy counts" 1 "1 unhealthy count" 2 "2 or more unhealthy counts"
label value unhealth_num unhealth_num 

tab unhealth_num //significant sample counts in each category

**Converting Date Times for Follow-Up
gen origin_time =  mdy(origin_month, 15, origin_year)
gen event_time = mdy(event_month, 15, event_year) 
replace event_time = mdy(5, 15, 2015) if event_time ==.
format origin_time event_time %d

**Generating Follow-Up Time
gen time = event_time - origin_time

**Set-up for Survival Analysis 
stset event_time, id(id) fail(MLTC) origin(origin_time) scale(365.25)
stsum 

summ time 
summ time if MLTC == 0 
summ time if MLTC == 1 //3.53 years


drop if time ==. 
**Descriptive Stats
tab smoking MLTC, col
tab alcohol MLTC, col
tab phys_act MLTC, col
tab obesity MLTC, col

tab ethnicity MLTC, col
tab wealth MLTC, col
tab cohabitation MLTC, col

**Mantel-Cox Test
sts test unhealth_num
**significant differences, p-value = 0.0002

stcox i.unhealth_num //significant
**1 count, HR = 1.31 p-value <0.001, 
**2+ count, HR = 1.36 p-value = 0.003

**Testing proportional hazards (Passes)
stcox i.unhealth_num, schoenfeld(sc_c*) scaledsch(ssc_c*)
estat phtest, log detail
**none of the p-value are significant 
**1 count p-value = 0.69
**2+ count p-value = 0.79

**Visual
sts graph,gwood by (unhealth_num) ytitle("Proportion surviving") xtitle("Time since MLTC diagnosis") title("Kaplan-Meier plot of survival, by Unhealthy Behaviour Count") xlabel(0(1)7)  ylabel(.4(.1)1)


//B.What happens to the results found in a) when sociodemographic (age, sex, cohabitation, ethnicity) and socio-economic factors (wealth) are accounted for?
summ age //mean = 61.6
hist age //right skewed
gen agec = age - 60  

**Sociodemographic and socioeconomic factors with  stcox i.unhealth_num
**Age Linearity Assumption with outcome (Fails) 
gen agecsq = agec*agec
stcox  c.agec c.agecsq
est store a 
stcox c.agec
est store b 
lrtest a b 
**significant p-value = 0.03
gen agecat = age 
recode agecat min/55 = 0 55.1/60 = 1 60.1/65 = 2 65.1/max = 3 
label variable agecat "Age categorical: 0 = 50-55, 1 = 55.1-60, 2 = 60.1-65, 3 = 65.1-max"
tab agecat

stcox i.unhealth_num i.agecat i.sex i.cohabitation i.ethnicity i.wealth
**Cohabitation not significant: p-value = 0.88
**ethnicity not significant: p-value = 0.55
**wealth: middle p-value = 0.07, highest p-value = 0.006

**LRT
**Cohabitation (No)
stcox i.unhealth_num i.agecat i.sex i.cohabitation i.ethnicity i.wealth
est store a 
stcox i.unhealth_num i.agecat i.sex i.ethnicity i.wealth
est store b 
lrtest a b 
**not significant: p-value =0.88, remove

**Ethnicity (No)
stcox i.unhealth_num i.agecat i.sex i.ethnicity i.wealth
est store a 
stcox i.unhealth_num i.agecat i.sex i.wealth
est store b 
lrtest a b 
**not significant: p-value=0.53, remove

**Wealth (Yes)
stcox i.unhealth_num i.agecat i.sex i.wealth
est store a 
stcox i.unhealth_num i.agecat i.sex
est store b 
lrtest a b 
**significant: p-value=0.0.018, keep

**Linear Trends
**unhealth_num (Yes Linear Trend)
stcox i.unhealth_num i.agecat i.sex i.wealth
est store a 
stcox unhealth_num i.agecat i.sex i.wealth
est store b
lrtest a b
**not significant: p-value = 0.057, evidence of trend

**Wealth (Yes Linear Trend)
stcox i.unhealth_num i.agecat i.sex i.wealth
est store a 
stcox i.unhealth_num i.agecat i.sex wealth
est store b
lrtest a b
**not significant: p-value=0.53, trend

**Agecat (Yes Linear Trend)
stcox i.unhealth_num i.agecat i.sex i.wealth
est store a 
stcox i.unhealth_num agecat i.sex i.wealth
est store b
lrtest a b
**not significant: p-value = 0.45, trend

**Final Model: 
stcox i.unhealth_num i.agecat i.sex i.wealth
**linear trend for both wealth and agecat

**Proportional Hazards Assumption using Schoenfeld
stcox i.unhealth_num i.sex i.wealth i.agecat , schoenfeld(sc_c*) scaledsch(ssc_c*)
estat phtest, log detail
**No significant p-value, all variables show evidence of proportional hazards 
**Lowest p-value = 0.27 for 55-60 agecat

**Graph for Testing the proportional hazards assumption for this model: 
stphplot, strata(unhealth_num) adjust(i.sex i.wealth i.agecat) saving(unhealth_num)
stphplot, strata(sex) adjust(i.unhealth_num i.wealth i.agecat) saving(sex)
stphplot, strata(wealth) adjust(i.unhealth_num i.sex i.agecat) saving(wealth)
stphplot, strata(agecat) adjust(i.unhealth_num i.wealth i.sex) saving(agecat)
gr combine unhealth_num.gph sex.gph wealth.gph agecat.gph

**KM Plot for unhealth_num, adjusting for risk factors 
sts graph, strata(unhealth_num) adjust(i.sex i.wealth i.agecat) xlabel(0(1)7)  ylabel(.4(.1)1)
