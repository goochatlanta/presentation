library(tidyr)
library(dplyr)
library(ggplot2)
require(grid)
library(gridExtra)
library(reshape2)
library(stargazer)
library(ggrepel)
setwd("H:/presentation")

#Gross social production value for China, 1949-69
agriculture <- c(326,384, 420, 461, 510, 535, 575, 610, 537, 566, 497, 457, 559, 584, 642, 720, 833, 910, 924, 928, 948)
industry <- c(140, 191, 264, 349, 450, 515, 534, 642, 704, 1083, 1483, 1637, 1062, 920, 993, 1164, 1402, 1624, 1382, 1285, 1665)
construction <- c(4, 13, 24, 57, 85, 82, 86, 146, 118, 202, 235, 248, 90, 74, 97, 151, 177, 197, 155, 132, 222)
transportation <- c(19, 19, 24, 35, 42, 48, 50, 56, 60, 90, 121, 131, 76, 62, 66, 72, 91, 102, 86, 83, 99)
commerce <- c(68, 76, 88, 113, 154, 166, 170, 185, 187, 197, 212, 206, 191, 160, 158, 161, 192, 229, 227, 220, 250)
year <-  factor(c(49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69))

# manual size https://www.reddit.com/r/rstats/comments/7zz2xk/anyone_know_how_to_have_one_line_in_my_ggplot/

output <- data.frame(year, agriculture, industry, construction, transportation, commerce)
outputl <- melt(output, id="year")
base<- ggplot(outputl, aes(year, value))
p <- base + geom_line(aes(group=variable, color=variable),size=1) + labs(y = "RMB (10,000)", x = "year")  +
  theme(legend.position="top") + theme(legend.title=element_blank()) +
  geom_vline(xintercept = which(outputl$year=='58'), linetype="dashed") +
  geom_vline(xintercept = which(outputl$year=='61'), linetype="dashed") +
  annotate("text", x='55', y = 1600, label = "   Great") +
  annotate("text", x='55', y = 1500, label = "   Leap") +
  annotate("text", x='56', y = 1400, label = " Forward \u2192") +
  annotate("text", x='56', y = 1300, label = "(1958-61)") +
  ggsave("assets/img/production.png",height=5,width=6, dpi = 300) 
p

#Visualization of OI decisions - could use a graph or could map them. 
spromotion <- c("Yes", "No","Yes", "Yes", "Yes", "No", "Yes", "Yes", "Yes", "Yes", "No", "No", "Yes", "No","Yes", "Yes", "No")
dining59 <- c(90.5, 67.2, 47.7, 77.6, 81, 92.6, 74.4, 97.8, 68.2, 97.6, 56, 61, 96.7, 60.8, 35.5, 96.5, 81.6)
oi59 <- c(154.24, 98.65, 194.99, 192.11, 95.73, 71.43, 168.62, 177.47, 127.96, 83.3, 102.7, 50.94, 100.36, 31, 307.83, 214.81, 102.79)
province <- (c("Anhui", "Fujian", "Gansu", "Guangdong", "Guangxi", "Guizhou", "Hebei", "Henan", "Hubei", "Hunan", "Jiangsu", "Jiangxi",  "Sichuan", "Shaanxi", "Shandong", "Yunnan", "Zhejiang"))

glf <- data.frame("province"=as.factor(province), oi59)

p4<- ggplot(glf, aes(x=oi59,y=reorder(province, -oi59))) + geom_point(size=3) +
  geom_vline(xintercept = 100, linetype="dashed") +
  theme(axis.title.y = element_blank()) +
  labs(x= "Inflation rate of grain output by local officials, 1959")
  
ggsave("assets/img/adventurism.png",height=5,width=6, dpi = 300)
p4

# Correlation across all my outcomes - the heatmap might be a good way
# http://www.sthda.com/english/wiki/correlation-matrix-a-quick-start-guide-to-analyze-format-and-visualize-a-correlation-matrix-using-r-software

#------------------
# CREATE DATA FRAME
#------------------
v3 <- read.csv(file="H:/glflegacy/glflegacy_data/v3_data.csv", header=TRUE, sep=",")

# select variables v1, v2, v3
myvars <- c("ln_gdppc2010", "ln_rur2010", "lnf", "lnri", "lnac", "lnglfyrs1", "lne", "lnmm", "lnim", "lnii", "lno", "lnam", "lnfu", "lnglosem")
v3_fu <- v3[which(v3$cao_sample==1),] 
v3_outcomes <- v3_fu[myvars]

library(data.table)
setnames(v3_outcomes, old=c("ln_gdppc2010","ln_rur2010", "lnf", "lnri", "lnac", "lnglfyrs1", "lne", "lnmm", "lnim", "lnii", "lno", "lnam", "lnfu", "lnglosem"), new=c("gdp2010", "rural2010","aglabor", "indlabor", "cultivation", "EDR", "hospyear", "elec", "marriage", "inmigrate", "illiteracy", "agoutput", "agmachinery", "fertilizer", "erosion"))

cormat <- round(cor(v3_outcomes, use = "na.or.complete"),2)

head(cormat)

# Get lower triangle of the correlation matrix
get_lower_tri<-function(cormat){
  cormat[upper.tri(cormat)] <- NA
  return(cormat)
}
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}

upper_tri <- get_upper_tri(cormat)


reorder_cormat <- function(cormat){
  # Use correlation between variables as distance
  dd <- as.dist((1-cormat)/2)
  hc <- hclust(dd)
  cormat <-cormat[hc$order, hc$order]
}
# Reordered correlation data visualization :
  
  # Reorder the correlation matrix
  cormat <- reorder_cormat(cormat)
upper_tri <- get_upper_tri(cormat)
# Melt the correlation matrix
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Create a ggheatmap
library(ggplot2)

ggheatmap <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1),
        axis.title.x = element_blank(), 
        axis.title.y = element_blank())   +
  coord_fixed()
# Print the heatmap
ggsave("assets/img/heatmap.png",height=5,width=6, dpi = 300)

print(ggheatmap)

###############################
# Table of p.adjust p-values

# "ln_gdppc2010", "ln_rur2010", "lnf", "lnri", "lnac", "lnglfyrs1", "lne", "lnmm", "lnim", "lnii", "lno", "lnam", "lnfu", "lnglosem"
pvalues<- c(0.018, 0.021, 0.002, 0.387,  0.096, 0.603, 0.002,  0.110, 0.035, 0.082, 0.001, 0.045, 0.032, .00010195)

BONF<-p.adjust(pvalues,method="bonferroni")

BH<-p.adjust(pvalues,method="BH")

outcome<-c("GDP, 2010", "Rural income, 2010","Ag. labor force", "Ind. labor force", "Cultivated area/ag. laborer", "Hospital years", "Electricity", "Marriage", "Inmigration", "Illiteracy", "Ag. output/ag. laborer", "Ag. machinery/ag. laborer", "Fertilizer/ag. laborer", "Erosion")

x = data.frame("pvalue" = pvalues, "outcome"  = as.factor(outcome))
y = data.frame("pvalue" = BONF, "outcome"  = as.factor(outcome))
z = data.frame("pvalue" = BH, "outcome"  = as.factor(outcome))

w = data.frame( "outcome"  = as.factor(outcome), "unadjusted" = round(pvalues,4), "Benjamini-Hochberg" = round(BH,4),"Bonferroni" = round(BONF,4))
# x$type<-"unadjusted"
# y$type<-"Bonferroni"
# z$type<-"Benjamini-Hochberg"
# 
# res <- rbind(x, y)
# res1 <- rbind(res, z)
# 
# p <- ggplot() + geom_point(aes(y = outcome, x = pvalue, shape = type, color = type),
#                            data = res1, stat="identity")
# p1 <- p + geom_vline(xintercept=0.05, linetype="dashed")
# p1
# 
# par(mar=c(1,1,1,1))
# matplot(res, ylab="p-values", xlab="sorted outcomes")
# abline(h=0.05, lty=2)
# matlines(res)
# legend(1, .9, legend=c("Bonferroni", "Benjamini-Hochberg", "Unadjusted"), 
#        col=c(3, 2, 1), lty=c(3, 2, 1), cex=0.7)

#Install the relevant libraries - do this one time

# install.packages("data.table")
# 
# install.packages("dplyr")
# 
# install.packages("formattable")
# 
# install.packages("tidyr")

#Load the libraries

library(data.table)

library(dplyr)

library(formattable)

library(tidyr)

#4) Add sign formatter to improvement over time

customRed = "#a6aba8"

customGreen = "#181a19"

# improvement_formatter <- formatter("span", style = x ~ style(font.weight = "bold", color = ifelse(x <= 0.05, customGreen, ifelse(x > 0.05, customRed, "black"))))
# 
# w1<- formattable(w, align =c("l", "c", "c", "c"), list(outcome = formatter("span", style = ~ style(color = "grey",font.weight = "bold")), Bonferroni = improvement_formatter, Benjamini.Hochberg = improvement_formatter, unadjusted = improvement_formatter))

# install.packages("kableExtra")
library(kableExtra)

w %>%
  mutate(
    Bonferroni = cell_spec(Bonferroni, "latex", align = "c", color = ifelse(Bonferroni > 0.05, customRed, customGreen)),
    Benjamini.Hochberg = cell_spec(Benjamini.Hochberg, "latex", align = "c", color = ifelse(Benjamini.Hochberg > 0.05, customRed, customGreen)),
    unadjusted = cell_spec(unadjusted, "latex", align = "c", color = ifelse(unadjusted > 0.05, customRed, customGreen))
  ) %>%
  select(outcome, everything()) %>%
  kable("latex", escape = F, booktabs = T) %>%
  kable_styling() %>%
  add_header_above(c(" ", "p-values" = 3)) %>%
  save_kable("assets/img/padjust_kable.tex", self_contained = FALSE, keep_tex = TRUE)
