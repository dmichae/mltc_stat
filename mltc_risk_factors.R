# Load necessary packages
library(foreign)
library(ggplot2)
library(car)
library(lmtest)

# Read data
data <- read.dta("filepath/taskA.dta")

# Data Overview
str(data)
summary(data)

# Inspect
summary(data[c('MLTC', 'age', 'bmi', 'sex', 'ethnicity', 'wealth', 'cohabitation', 'smoking', 'alcohol', 'phys_act')])

# Tabulation
table(data$MLTC)
table(data$sex)
table(data$ethnicity)
table(data$wealth)
table(data$cohabitation)
table(data$smoking)
table(data$alcohol)
table(data$phys_act)

# Proportional of each categorical risk factor, with and without MLTC
table(data$sex, data$MLTC)
table(data$ethnicity, data$MLTC)
table(data$wealth, data$MLTC)
table(data$cohabitation, data$MLTC)
table(data$smoking, data$MLTC)
table(data$alcohol, data$MLTC)
table(data$phys_act, data$MLTC)

# Continuous risk factors descriptors
summary(data$age[data$MLTC == 0])
summary(data$age[data$MLTC == 1])

# Generate new variables
data$agec <- data$age - 65
data$bmic <- data$bmi - 27
data$agecsq <- data$agec^2
data$bmicsq <- data$bmic^2

# Collinearity
cor(data[c('sex', 'age', 'ethnicity', 'wealth', 'cohabitation', 'smoking', 'alcohol', 'phys_act', 'bmi')])

# Univariate logistic regressions
summary(glm(MLTC ~ sex, data = data, family = binomial(link = "logit")))
summary(glm(MLTC ~ ethnicity, data = data, family = binomial(link = "logit")))
summary(glm(MLTC ~ wealth, data = data, family = binomial(link = "logit")))
summary(glm(MLTC ~ cohabitation, data = data, family = binomial(link = "logit")))
summary(glm(MLTC ~ smoking, data = data, family = binomial(link = "logit")))
summary(glm(MLTC ~ alcohol, data = data, family = binomial(link = "logit")))
summary(glm(MLTC ~ phys_act, data = data, family = binomial(link = "logit")))
summary(glm(MLTC ~ agec, data = data, family = binomial(link = "logit")))
summary(glm(MLTC ~ bmic, data = data, family = binomial(link = "logit")))

# Multivariate logistic regressions
model1 <- glm(MLTC ~ sex + wealth + cohabitation + smoking + phys_act + agec + bmic, data = data, family = binomial(link = "logit"))
model2 <- glm(MLTC ~ sex + wealth + smoking + phys_act + agec + bmic, data = data, family = binomial(link = "logit"))
model3 <- glm(MLTC ~ sex + wealth + phys_act + agec + bmic, data = data, family = binomial(link = "logit"))

# Likelihood ratio tests
lrtest(model1, model2)
lrtest(model2, model3)