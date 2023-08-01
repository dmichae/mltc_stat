# Load necessary packages
library(haven)
library(dplyr)
library(survival)
library(survminer)
library(rms)
library(car)
library(gridExtra)

# Read data
data <- read_dta("filepath/taskB.dta")

# Data Overview
str(data)
summary(data)

# Tabulation
table(data$MLTC)
table(data$smoking)
table(data$alcohol)
table(data$phys_act)
table(data$obesity)
table(data$sex)
table(data$ethnicity)
table(data$wealth)
table(data$cohabitation)

# Summary of age
summary(data$age)
summary(data$age[data$MLTC == 0])
summary(data$age[data$MLTC == 1])

# Histogram of age
hist(data$age)

# Create new variable
data$unhealth_num <- data$smoking + data$alcohol + data$phys_act + data$obesity
data$unhealth_num[data$unhealth_num == 4] <- 3
data$unhealth_num[data$unhealth_num == 3] <- 2
data$unhealth_num <- factor(data$unhealth_num, labels = c("0 unhealthy counts", "1 unhealthy count", "2 or more unhealthy counts"))

table(data$unhealth_num)

# Convert date times for follow-up
data$origin_time <- as.Date(paste(data$origin_year, data$origin_month, "15", sep = "-"))
data$event_time <- as.Date(paste(data$event_year, data$event_month, "15", sep = "-"))
data$event_time[is.na(data$event_time)] <- as.Date("2015-05-15")

# Generating Follow-Up Time
data$time <- as.numeric(difftime(data$event_time, data$origin_time, units = "days") / 365.25)

# Set-up for Survival Analysis
data <- data %>%
  mutate(surv_obj = Surv(time, MLTC))

# Summary of survival time
summary(data$time)
summary(data$time[data$MLTC == 0])
summary(data$time[data$MLTC == 1])

# Descriptive Stats
prop.table(table(data$smoking, data$MLTC), 2)
prop.table(table(data$alcohol, data$MLTC), 2)
prop.table(table(data$phys_act, data$MLTC), 2)
prop.table(table(data$obesity, data$MLTC), 2)
prop.table(table(data$ethnicity, data$MLTC), 2)
prop.table(table(data$wealth, data$MLTC), 2)
prop.table(table(data$cohabitation, data$MLTC), 2)

# Mantel-Cox Test
survdiff(data$surv_obj ~ data$unhealth_num)

# Cox proportional hazards model
cox_model <- coxph(data$surv_obj ~ data$unhealth_num, data = data)
summary(cox_model)

# Testing proportional hazards
cox.zph(cox_model)

# Kaplan-Meier survival plot by unhealth_num
ggsurvplot(survfit(data$surv_obj ~ data$unhealth_num), 
           data = data,
           xlab = "Time since MLTC diagnosis",
           ylab = "Proportion surviving",
           title = "Kaplan-Meier plot of survival, by Unhealthy Behaviour Count")

# Summary of age
summary(data$age)

# Histogram of age
hist(data$age)

# Create new variable
data$agec <- data$age - 60
data$agecsq <- data$agec^2

# Age linearity assumption with outcome (checking with Anova)
cox_model <- coxph(surv_obj ~ agec + agecsq, data = data)
anova(cox_model)

# Categorize age
data$agecat <- cut(data$age, breaks = c(-Inf, 55, 60, 65, Inf), labels = c("0", "1", "2", "3"), right = FALSE)
table(data$agecat)

# Cox proportional hazards model
cox_model <- coxph(surv_obj ~ unhealth_num + agecat + sex + cohabitation + ethnicity + wealth, data = data)
summary(cox_model)

# Likelihood ratio tests
cox_model_full <- coxph(surv_obj ~ unhealth_num + agecat + sex + cohabitation + ethnicity + wealth, data = data)
cox_model_reduced <- coxph(surv_obj ~ unhealth_num + agecat + sex + ethnicity + wealth, data = data)
anova(cox_model_reduced, cox_model_full)  # For cohabitation

cox_model_reduced <- coxph(surv_obj ~ unhealth_num + agecat + sex + wealth, data = data)
anova(cox_model_reduced, cox_model_full)  # For ethnicity

cox_model_reduced <- coxph(surv_obj ~ unhealth_num + agecat + sex, data = data)
anova(cox_model_reduced, cox_model_full)  # For wealth

# Linear trends
cox_model1 <- coxph(surv_obj ~ unhealth_num + agecat + sex + wealth, data = data)
cox_model2 <- coxph(surv_obj ~ agecat + sex + wealth, data = data)
anova(cox_model1, cox_model2)  # For unhealth_num

cox_model1 <- coxph(surv_obj ~ unhealth_num + agecat + sex + wealth, data = data)
cox_model2 <- coxph(surv_obj ~ unhealth_num + agecat + sex, data = data)
anova(cox_model1, cox_model2)  # For wealth

cox_model1 <- coxph(surv_obj ~ unhealth_num + agecat + sex + wealth, data = data)
cox_model2 <- coxph(surv_obj ~ unhealth_num + sex + wealth, data = data)
anova(cox_model1, cox_model2)  # For agecat

# Final Model
cox_model <- coxph(surv_obj ~ unhealth_num + agecat + sex + wealth, data = data)
summary(cox_model)

# Proportional hazards assumption
cox.zph(cox_model)

# Graphs for testing the proportional hazards assumption
plot(cox.zph(cox_model))

# Kaplan-Meier survival plot by unhealth_num, adjusting for risk factors 
ggsurvplot(survfit(surv_obj ~ unhealth_num + sex + wealth + agecat), data = data)