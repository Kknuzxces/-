library(readxl)
library(fitdistrplus)
dat<-read_xlsx('不良事件诱发时间.xlsx')
data<-dat$DAY
data<-data[data!=0]
fit<-fitdist(data, "weibull")
coef(fit)
confint(fit)

resu<-cbind(t(t(coef(fit))),confint(fit))
colnames(resu)[1]<-'coef'
resu

