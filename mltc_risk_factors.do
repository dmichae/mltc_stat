**BPWK1-Appendix

**************************************
****************Task A****************
**************************************
use "filepath\taskA.dta", clear

** Data Overview
codebook 
describe 
**Outcome = MLTC
**9 Risk factors 

inspect MLTC age bmi sex ethnicity wealth cohabitation smoking alcohol phys_act

tab MLTC
tab sex 
tab ethnicity //6 missing
tab wealth  
tab cohabitation 
tab smoking 
tab alcohol //5 missing 
tab phys_act 


**Proportional of each categorical risk factor, with and without MLTC
tab sex MLTC, col
tab ethnicity MLTC, col
tab wealth MLTC, col
tab cohabitation MLTC, col
tab smoking MLTC, col
tab alcohol MLTC, col
tab phys_act MLTC, col

summ age if MLTC ==0 
summ age if MLTC ==1

**Continuous risk factors descriptors
summ age //mean = 65.7
hist age //distribution is right skewed, long right tail
gen agec = age-65
label variable agec "age centered at 65 years old"
label value agec agec  

summ bmi if MLTC ==0
summ bmi if MLTC ==1

summ bmi //mean = 27.56
hist bmi //follows a mostly normal distribution, longer right tail
gen bmic = bmi - 27
label variable bmic "BMI centered at 27 kg/m2"
label value bmic bmic 

//1.Which risk factors are associated with living with MLTCs among older adults living in England?
**Risk Factors: sex, ethnicity, wealth, cohabitation, smoking, alcohol, phys_act, age (agec), bmi (bmic)

**Collinearity
corr sex age ethnicity wealth cohabitation smoking alcohol phys_act bmi 
**Absence of collinearity holds

**Sex (Yes)
logistic MLTC i.sex, or //significant: p-value <0.001, 95% CI (1.21, 1.49)

**Ethnicity (No)
logistic MLTC i.ethnicity, or //not signficant: p-value = 0.468, 95% CI (0.78, 1.70)

**Wealth (Yes)
logistic MLTC i.wealth, or //significant: p-value <0.001, 95% CI (0.60, 0.78)

**Cohabitation (Yes)
logistic MLTC i.cohabitation, or  //significant: p-value <0.001, 95% CI (0.49, 0.62)

**Smoking (Yes)
logistic MLTC i.smoking, or 
**ex-smoking significant: p-value <0.001, 95% CI (1.16, 1.6)
**never smoker not significant: p-value = 0.68, 95% CI (1.14, 1.51)

**Alcohol (No)
logistic MLTC i.alcohol, or //not significant: p-value = 0.74, 95% CI (0.91, 1.15)

**Phys_act (Yes)
logistic MLTC i.phys_act, or 
**moderate significant: p-value <0.001, 95% CI (0.32, 0.47)
**active significant: p-value <0.001, 95% CI (0.2, 0.29)

**Agec (Yes)
logistic MLTC c.agec, or //significant: p-value <0.001, 95% CI (1.09, 1.11)

**Linearity assumption using quadratic term 
gen agecsq = agec*agec
logistic MLTC c.agec c.agecsq
est store a 
logistic MLTC c.agec 
est store b 
lrtest a b 
**not significant: p-value = 0.28, linearity assumption holds 

**BMIc (Yes)
logistic MLTC c.bmic, or //significant: p-value <0.001, 95% CI (1.05, 1.07)

**Linearity assumption using quadratic term 
gen bmicsq = bmic*bmic
logistic MLTC c.bmic c.bmicsq
est store a 
logistic MLTC c.bmic 
est store b 
lrtest a b 
**not significant: p-value = 0.46, linearity assumption holds 

**Risk factors with strong evidence of association: sex, wealth, cohabitation, smoking, phys_act, agec, bmic 


**Building the Model:
logistic MLTC i.sex i.wealth i.cohabitation i.smoking i.phys_act c.agec c.bmic, or
**Cohabitation and Smoking show signs of insignificant associations

**Testing Cohabitation
logistic MLTC i.sex i.wealth i.cohabitation i.smoking i.phys_act c.agec c.bmic, or
est store a 
logistic MLTC i.sex i.wealth i.smoking i.phys_act c.agec c.bmic, or
est store b 
lrtest a b 
**Not significant: p-value = 0.19, removed from model

**Testing Smoking 
logistic MLTC i.sex i.wealth i.smoking i.phys_act c.agec c.bmic, or
est store a
logistic MLTC i.sex i.wealth i.phys_act c.agec c.bmic, or
est store b 
lrtest a b 
**significant: p-value = 0.0002, keep in model 

**Testing Linearity Assumptions Final Modeling
**Age
logistic MLTC i.sex i.wealth i.phys_act i.smoking c.agec c.agecsq c.bmic, or
est store a 
logistic MLTC i.sex i.wealth i.phys_act i.smoking c.agec c.bmic, or
est store b 
lrtest a b 
**borderline: p-value = 0.0511, just passes

**BMI Linearity
logistic MLTC i.sex i.wealth i.phys_act i.smoking c.agec c.bmicsq c.bmic, or
est store a 
logistic MLTC i.sex i.wealth i.phys_act i.smoking c.agec c.bmic, or
est store b 
lrtest a b 
**not significant: p-value = 0.81, passes


**Final Associations: 
logistic MLTC i.sex i.wealth i.phys_act i.smoking c.agec c.bmic, or

**Checking Linearity Trends for Ordinal Variables
**Wealth (No Trend)
logistic MLTC i.sex i.wealth i.phys_act i.smoking c.agec c.bmic, or
est store a 
logistic MLTC i.sex wealth i.phys_act i.smoking c.agec c.bmic, or
est store b 
lrtest a b 
**significant: p-value of 0.019, no evidence of linear trend 

**Phys_act (No Trend)
logistic MLTC i.sex i.wealth i.phys_act i.smoking c.agec c.bmic, or
est store a 
logistic MLTC i.sex i.wealth phys_act i.smoking c.agec c.bmic, or
est store b 
lrtest a b 
**significant: p-value = 0.0348, no evidence of linear trend


**Final Model: 
logistic MLTC i.sex i.wealth i.phys_act i.smoking c.agec c.bmic, or














