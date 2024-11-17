################################################################ References ################################################################
#
# Peter J. Brockwell and Richard A. Davis - Introduction to Time Series and Forecasting (Third Edition)
# Springer Texts in Statistics - Springer Verlag
#
# Robert H. Shumway, David S. Stoffer - Time Series Analysis and Its Applications (with R Examples) 4th Edition
# Springer Texts in Statistics - Springer Verlag
# https://www.stat.pitt.edu/stoffer/tsa4/tsa4.pdf
#
# Rob J Hyndman and George Athanasopoulos - Forecasting: Principles and Practice
# Monash Univeristy, Australia
# https://otexts.com/fpp2/
#
# Stephane Guerrier, Roberto Molinari, Haotian Xu and Yuming Zhang - Applied Time Series Analysis with R
# https://smac-group.github.io/ts/index.html
#
############################################################################################################################################
################################################################## Libraries ###############################################################
# https://www.r-project.org/other-docs.html
library(base)
# https://rdrr.io/r/#base
# https://www.math.ucla.edu/~anderson/rw1001/library/base/html/00Index.html
library(utils)
#
#libreria per leggere dati da excel
library(readxl) 
#
# Carica il pacchetto stringr
library(stringr)
#
library(stats)
#
library(zoo)
# https://cran.r-project.org/web/packages/zoo/zoo.pdf
#
library(quantmod)
# https://cran.r-project.org/web/packages/quantmod/quantmod.pdf
# https://www.rdocumentation.org/packages/quantmod/versions/0.4-15/topics/chartSeries
# http://www.quantmod.com/
#
library(TTR)
#
library(xts)
#
#
library(tibble)
#
library(dbplyr)
#
library(ggplot2)
library(numbers)
#
library(urca)
# https://cran.r-project.org/web/packages/urca/urca.pdf
#
library(lattice)
library(leaps)
library(ltsa)
library(bestglm)
library(FitAR)
#
library(portes)
#
library(testcorr)
#
library(DescTools)
#
library(lmtest)
# https://cran.r-project.org/web/packages/lmtest/lmtest.pdf
# https://cran.r-project.org/web/packages/lmtest/vignettes/lmtest-intro.pdf
#
library(skedastic)
#
library(olsrr)
# https://cran.r-project.org/web/packages/olsrr/olsrr.pdf
# https://cran.r-project.org/web/packages/olsrr/vignettes/heteroscedasticity.html?fbclid=IwAR1ZgOk9EzWV2rEjn5TDFWV_BQklU8mdgmmsOC55kdmXPG1T2iPIhFwXqkU
#
library(whitestrap)
#
library(boot)
library(sandwich)
#
library(tseries)
# https://cran.r-project.org/web/packages/tseries/tseries.pdf
# https://rdrr.io/cran/tseries/man/garch.html
#
library(crayon)
#
library(fBasics)
library(nortest)
#
library(survival)
library(MASS)
library(fitdistrplus)
# https://cran.r-project.org/web/packages/fitdistrplus/fitdistrplus.pdf
# https://cran.r-project.org/web/packages/fitdistrplus/vignettes/paper2JSS.pdf
#
library(EnvStats)
#
library(fGarch)
# https://cran.r-project.org/web/packages/fGarch/fGarch.pdf
#
library(NlcOptim)
library(pracma)
#
library(qqplotr)
# https://cran.r-project.org/web/packages/qqplotr/qqplotr.pdf
library(car)
# https://cran.r-project.org/web/packages/car/car.pdf
library(goftest)
# https://cran.r-project.org/web/packages/goftest/goftest.pdf
#
library(BiocManager)
#library(BiocGenerics)
#library(Biobase)
#library(S4Vectors)
library(stats4)
#library(IRanges)
#library(AnnotationDbi)
#library(GO.db)
library(dynamicTreeCut)
library(fastcluster)
#library(WGCNA)
library(timeDate)
library(timeSeries)
library(fBasics)
library(fOptions)
library("data.table")
library(dplyr)
library(tidyverse)
library(lattice)
###############################################################################################################################################
########################################################## Environmental Setting ##############################################################
###############################################################################################################################################
#
# Removes all items in Global Environment
rm(list=ls())
#
# To store options' default values.
def_options <- options()
options(def_options)
#
# Clears all Plots
try(dev.off(),silent=TRUE)
#
# Clear the Console
cls <- function() cat(rep("\n",100))
cls()
#
# Sets the current directory as the work directory. 
WD <- dirname(rstudioapi::getSourceEditorContext()$path)
show(WD)
setwd(WD)
dir()
###############################################################################################################################################
################################################################# Functions ###################################################################
###############################################################################################################################################
#
na.rm <- function(x){x <- as.vector(x[!is.na(as.vector(x))])}
#

# Definisci la funzione
extract_date_from_filename <- function(file_name) {
  # Estrai la data utilizzando una espressione regolare
  extracted_date <- str_extract(file_name, "\\d{4}-\\d{2}-\\d{2}")
  
  # Controlla se la data è stata trovata
  if (is.na(extracted_date)) {
    warning("Nessuna data trovata nel nome del file.")
    return(NULL)
  }
  
  return(extracted_date)
}

dt_ls <- function(x, m, s, df)	1/s*dt((x-m)/s, df)
pt_ls <- function(q, m, s, df)  pt((q-m)/s, df)
qt_ls <- function(p, m, s, df)  qt(p, df)*s+m
rt_ls <- function(n, m, s, df)  rt(n,df)*s+m

###############################################################################################################################################
#################################################### Caricamento dati storici SP500 ###########################################################
###############################################################################################################################################
datafolder<-""

spx_historical_file<-paste0("SPX_historical_prices_2021-09-23_2024-09-23.xlsx")

spx_historical_file_csv<-paste0("SPX_historical_prices_2021-09-23_2024-09-23.csv")

spx_path<-file.path(WD, datafolder, spx_historical_file)

spx_df<-read_excel(spx_path)

head(spx_df$Date)

# Rimuovi le righe con tutti NA
spx_df <- spx_df[complete.cases(spx_df), ]

# Rimuovi gli spazi bianchi indesiderati nella colonna "Date"
spx_df$Date <- trimws(spx_df$Date)

head(spx_df)

Sys.setlocale("LC_TIME", "C")  # Imposta la lingua su inglese (date in inglese)

# Ora converti la colonna "Date" in formato Date con il formato corretto
spx_df$Date <- as.Date(spx_df$Date, format = "%b %d %Y")

head(spx_df)


class(spx_df$Date)

# Converti tutte le colonne in numeric tranne la colonna "Date"
spx_df[, -which(names(spx_df) == "Date")] <- lapply(spx_df[, -which(names(spx_df) == "Date")], as.numeric)

write.csv(spx_df, spx_historical_file_csv, row.names = FALSE, quote = FALSE)

############################################################################################################################################
############## This first section only illustrates some file input/output techniques and the financial data candlestick plot ###############
############################################################################################################################################
#
# We convert the spx_df data.frame class object into a zoo class object to draw a candlestick plot.
# library(zoo)
spx_zoo <- zoo::read.zoo(spx_df)
spx_zoo <- zoo(spx_df[, -1], order.by = spx_df$Date)
class(spx_zoo)
head(spx_zoo)
tail(spx_zoo)
# Apri un dispositivo PNG e specifica il percorso per il salvataggio
png("plots/spx_candlestick_plot.png", width = 1000, height = 600)
# library(quantmod)
quantmod::chartSeries(spx_zoo, type="auto", theme=chartTheme('white'))
#
#chartSeries(spx_zoo, type="auto", subset="2018-04-17::2023-05-31", theme=chartTheme('white'))
#
# Chiudi il dispositivo
dev.off()
quantmod::chartSeries(spx_zoo, type="auto", theme=chartTheme('white'))
#
#chartSeries(spx_zoo, type="auto", subset="2018-04-17::2023-05-31", theme=chartTheme('white'))
# We might also convert the spx_zoo zoo class object into an xts class object to draw a candlestick plot.
# library(xts)
spx_xts <- xts::as.xts(spx_zoo)
class(spx_xts)
head(spx_xts)
tail(spx_xts)
# library(quantmod)
quantmod::chartSeries(spx_xts, type="auto", theme=chartTheme('white'))
#
#chartSeries(spx_xts, type="auto", subset="2018-04-17::2023-05-31", theme=chartTheme('white'))
#

############################################################################################################################################
####################################### Scatter and Line plot of the SPX Daily Adjusted Close Price ########################################
############################################################################################################################################
spx_df <- read.csv(spx_historical_file_csv, header=TRUE)
class(spx_df)
head(spx_df)
tail(spx_df)
# We check whether the Date column is in "Date" format. In case it is not, we change the format to "Date".
class(spx_df$Date)
spx_df$Date <- as.Date(spx_df$Date, format="%Y-%m-%d")
class(spx_df$Date)
head(spx_df)
tail(spx_df)

spx_df$index<-1:nrow(spx_df)

spx_df<-spx_df[,c("index", names(spx_df[-ncol(spx_df)]))]

# We draw a scatter and a line plot of the SP500 Daily Adjusted Close Price from Apr-17-2018 to May-31-2023.
# The scatter plot
Data_df <- spx_df
head(Data_df)
# library(dbplyr)
Data_df <- dplyr::rename(Data_df, x=index, y=Adj_Close)
sum(is.na(Data_df$y)) # We check whether we have NA in the spx adjusted close price data set and how many NA we have.
# 0
DS_length <- length(Data_df$y)
show(DS_length)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[DS_length])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 Metodi Probabilistici e Statistici per i Mercati Finanziari 2023-2024",
                             paste("SP500 Daily Adjusted Close Price from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/historical"
subtitle_content <- bquote(paste("Data set length - ", .(DS_length), " sample points. Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# library(numbers)
# numbers::primeFactors(DS_length-1)
x_breaks_num <- tail(numbers::primeFactors(DS_length-1), n=1) # (deduced from primeFactors(DS_length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("adjusted close prices (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_b <- bquote("daily Adj_ close prices")
line_red  <- bquote("LOESS curve")
line_green  <- bquote("regression line")
leg_labs <- c(point_b, line_red, line_green)
leg_cols <- c("point_b"="blue", "line_red"="red", "line_green"="green")
leg_breaks <- c("point_b", "line_red", "line_green")
# library(ggplot2)
spx_Adj_Close_sp <- ggplot2::ggplot(Data_df) +
  geom_smooth(aes(x=x, y=y, color="line_green"), method="lm", formula=y ~ x, alpha=1, linewidth=0.8, linetype="solid",
              se=FALSE, fullrange=FALSE) +
  geom_smooth(aes(x=x, y=y, color="line_red"), method="loess", formula=y ~ x, alpha=1, linewidth=0.8, linetype="dashed",
              se=FALSE, fullrange=FALSE) +
  geom_point(alpha=1, size=0.6, shape=19, aes(x=x, y=y, color="point_b")) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_breaks,
                      guide=guide_legend(override.aes=list(shape=c(19,NA,NA), linetype=c("blank", "dashed", "solid")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# Salvare il grafico in PNG
png("plots/spx_daily_adj_price_sp.png", width = 1000, height = 600)

plot(spx_Adj_Close_sp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_Adj_Close_sp)
#
# The line plot
line_blue  <- bquote("daily Adj_ close prices")
line_red  <- bquote("LOESS curve")
line_green  <- bquote("regression line")
leg_labs <- c(line_blue, line_red, line_green)
leg_cols <- c("line_blue"="blue", "line_red"="red", "line_green"="green")
leg_breaks <- c("line_blue", "line_red", "line_green")
spx_Adj_Close_lp <- ggplot2::ggplot(Data_df) +
  geom_smooth(aes(x=x, y=y, color="line_green"), method="lm", formula=y ~ x, alpha=1, linewidth=0.8, linetype="solid",
              se=FALSE, fullrange=FALSE) +
  geom_smooth(aes(x=x, y=y, color="line_red"), method="loess", formula=y ~ x, alpha=1, linewidth=0.8, linetype="dashed",
              se=FALSE, fullrange=FALSE) +
  geom_line(aes(x=x, y=y, color="line_blue", group=1), alpha=1, linewidth=0.6, linetype="solid") +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_breaks,
                      guide=guide_legend(override.aes=list(linetype=c("solid", "dashed", "solid")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")

# Salvare il grafico in PNG
png("plots/spx_daily_adj_price_lp.png", width = 1000, height = 600)

plot(spx_Adj_Close_lp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_Adj_Close_lp)

#
# With the goal of building a model for forecasting we split the data set in a training set, about $92\%$ of the data set, and a test set, 
# about $8\%$ of the data set.
# We consider the scatter plot of the SPX daily adjusted close prices training set and the test set
Data_df <- spx_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=Adj_Close)
head(Data_df)
DS_length <- length(Data_df$y)
show(DS_length)
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# Calcolare la posizione del 92%
position_92 <- round(0.92 * nrow(Data_df))
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
TrnS_length <- length(Data_df$Date[which(Data_df$Date<=as.Date(TrnS_Last_Day))])
show(TrnS_length)
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
TstS_length <- length(Data_df$Date[which(Data_df$Date>=TstS_First_Day)])
show(TstS_length)
# 60
TstS_length == DS_length-TrnS_length
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Metodi Probabilistici e Statistici per i Mercati Finanziari \u0040 Ingegneria Informatica Magistrale 2023-2024",
                             paste("SP500 Daily Adjusted Close Price - Training and Test Sets - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/spx-USD?p=spx-USD"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(length-1)
x_breaks_num <- tail(numbers::primeFactors(DS_length-1), n=1) # (deduced from primeFactors(length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("adjusted close prices (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily Adj_ close prices - training set")
point_b <- bquote("daily Adj_ close prices - test set")
line_green <- bquote("regression line (training set)")
line_red <- bquote("LOESS curve (training set)")
leg_point_labs <- c(point_black, point_b)
leg_point_cols <- c("point_black"="black", "point_b"="blue")
leg_point_breaks <- c("point_black", "point_b")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_Adj_Close_TrnS_TstS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], linewidth=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), method="lm" , formula=y ~ x, 
              alpha=1, linewidth=0.9, linetype="solid", se=FALSE, fullrange=FALSE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), method="loess", formula=y ~ x, 
              alpha=1, linewidth=0.9, linetype="dashed", se=FALSE, fullrange=FALSE) +
  geom_point(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19) + 
  geom_point(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.7, shape=19) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, 19, NA, NA), linetype=c("blank", "blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")

# Salvare il grafico in PNG
png("plots/spx_daily_adj_price_TrnS_TstS_sp.png", width = 1200, height = 600)

plot(spx_Adj_Close_TrnS_TstS_sp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_Adj_Close_TrnS_TstS_sp)

#
# The line plot
spx_Adj_Close_TrnS_TstS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], linewidth=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), method="lm" , formula=y ~ x, 
              alpha=1, linewidth=0.9, linetype="solid", se=FALSE, fullrange=FALSE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), method="loess", formula=y ~ x,
              alpha=1, linewidth=0.9, linetype="dashed", se=FALSE, fullrange=FALSE) +
  geom_line(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, linewidth=0.7, linetype="solid") +
  geom_line(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, linewidth=0.7, linetype="solid") +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# Salvare il grafico in PNG
png("plots/spx_daily_adj_price_TrnS_TstS_lp.png", width = 1200, height = 600)

plot(spx_Adj_Close_TrnS_TstS_lp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_Adj_Close_TrnS_TstS_lp)
#
# From the inspection of the scatter and line  plot, we have visual evidence for an increasing trend with some sharp falls. Comparing the 
# LOESS curve with the regression line, the overall trend does not appear to be linear. Eventually, if it weren't for the sharp decline since 
# October 2021 it would appear exponential, as predicted by the most reputed stock market models. 
# We do not have visual evidence for seasonality. Typically, stock market time series cannot have a pronounced seasonal component due to the
# very nature of the stock market. It is even difficult to define a seasonal period. Stock markets are usually closed on Saturday and Sunday.
# This would lead to thinking over five days trading days. However, stock markets also close on national and some local holidays. This makes
# managing a five-day period complicated. Moreover, since stock price movements are due to the market traders' continuous buying and selling
# of the stock based on their expectations about stock future returns, and these expectations depend on the incoming erratic economic,
# political, and social news, it is not straightforward to conceive of a seasonal mechanism behind stock price movement. Nevertheless, some 
# evidence of hourly seasonality can be revealed on trading days. We would need intra-day data to manage it, though.
# The spread of the points of the training set around the LOESS, does not appear to be homogeneous throughout the LOESS path. We have 
# visual evidence for heteroscedasticity.
###############################################################################################################################################
# For simplicity, we build a data frame containing only the training set data, before pursuing a quantitative analysis
spx_train_df <- spx_df[1:position_92-1,]
head(spx_train_df)
tail(spx_train_df)
#
# We consider the autocorrelograms of the training set. Of course, due to the clear trend, we expect a strong visual evidence for 
# autocorrelation.
# Autocorrelogram of the training set of the SP500 daily adjusted close prices.
Data_df <- spx_train_df
y <- Data_df$Adj_Close
TrnS_length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjhyndman.com/hyndsight/ljung-box-test/
Aut_Fun_y <- stats::acf(y, lag.max=max_lag, type="correlation", plot=FALSE)
# Aut_Fun_y <- TSA::acf(y, lag.max=max_lag, type="correlation", plot=TRUE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_095 <- qnorm((1+0.95)/2)/sqrt(T)
ci_099 <- qnorm((1+0.99)/2)/sqrt(T)
Aut_Fun_y_df <- data.frame(lag=Aut_Fun_y$lag, acf=Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Metodi Probabilistici e Statistici per i Mercati Finanziari \u0040 Ingegneria Informatica Magistrale 2023-2024",
                             paste("Autocorrelogram of the SP500 Daily Adjusted Close Price - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Lags ", .(max_lag), ". Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
Aut_Fun_y_plot <- ggplot(Aut_Fun_y_df, aes(x=lag, y=acf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), linewidth=1, col="black") +
  #geom_col(mapping=NULL, data=NULL, position="dodge", width=0.1, col="black", inherit.aes=TRUE) + 
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), linewidth=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_095, color="CI_095"), linewidth=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_095, color="CI_095"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_099, color="CI_099"), linewidth=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_099, color="CI_099"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_095="blue", CI_099="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# Salvare il grafico in PNG
png("plots/spx_aut_fun_y_plot.png", width = 1000, height = 600)

plot(Aut_Fun_y_plot)

# Chiudere il dispositivo PNG
dev.off()
plot(Aut_Fun_y_plot)
#
# The autocorrelogram provides visual evidence for autocorrelation in a typical form due to non-stationarity.
#
#Partial autocorrelogram of the training set of the NASDAQ Composite daily adjusted close prices.
Data_df <- spx_train_df
y <- Data_df$Adj_Close
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjhyndman.com/hyndsight/ljung-box-test/)
Part_Aut_Fun_y <- stats::pacf(y, lag.max=max_lag, type="correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_950 <- qnorm((1+0.95)/2)/sqrt(T)
ci_990 <- qnorm((1+0.99)/2)/sqrt(T)
Part_Aut_Fun_y_df <- data.frame(lag=Part_Aut_Fun_y$lag, pacf=Part_Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Partial Autocorrelogram of the SP500 Daily Adjusted Close Price - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
Part_Aut_Fun_y_plot <-ggplot(Part_Aut_Fun_y_df, aes(x=lag, y=pacf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=pacf), linewidth=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), linewidth=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_095, color="CI_095"), linewidth=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_095, color="CI_095"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_099, color="CI_099"), linewidth=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_099, color="CI_099"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="pacf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_095="blue", CI_099="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# Salvare il grafico in PNG
png("plots/spx_part_aut_fun_y_plot.png", width = 1000, height = 600)

plot(Part_Aut_Fun_y_plot)

# Chiudere il dispositivo PNG
dev.off()
plot(Part_Aut_Fun_y_plot)
#
# The partial autocorrelogram reveals the autocorrelation of the time series is essentially due to a strong correlation between the time 
# series and its one-lagged copy. Consequently, combining autocorrelogram and partial autocorrelogram provides visual evidence for a random
# walk component (unit root).
############################################################################################################################################
# We apply the Augmented Dickey-Fuller (ADF) test to validate (to not reject) the null hypothesis of a stochastic trend component (random
# walk) in the time series generating process against the alternative hypothesis that the time series can be thought of as a path of an 
# autoregressive process, possibly with drift and linear trend. Furthermore, we apply the Kwiatowski-Phillips-Schmidt-Shin (KPSS) test to
# reject the null hypothesis that the time series is generated by an autoregressive process, possibly with drift and linear trend, against 
# the alternative that the time series can be thought of as a path of a process with a stochastic trend component.
#
# More precisely, the ADF test assumes that the time series is generated by a stochastic process with a random walk component. This null 
# hypothesis leads to refer to the ADF test as a unit root test. In addition, three alternative hypotheses are considered:
# 1) the time series can be thought of as a path of an autoregressive process, with no drift and no linear trend;
# 2) the time series can be thought of as a path of an autoregressive process, with drift and no linear trend;
# 3) the time series can be thought of as a path of an autoregressive process, with drift and linear trend.
# For more details, see Equations (12.65)-(12.67) in Essentials of Time Series.
#
# For optimal performance of the ADF test, the choice of the maximum number of lags in the linear models used for the test, described in
# Equations (12.65)-(12.67), is crucial. If the maximum number of lags is too small, then the linear model's residuals will likely be
# affected by autocorrelation, which biases the test. On the contrary, if the maximum number of lags is too large, then the power of the 
# test will suffer. Typically, two rules of thumb are used to determine a small and a large number of lags, respectively. In addition, AIC 
# and BIC can be used to determine a more optimal number of lags. Nevertheless, an important issue is that the residuals of the linear model
# used for the test should not show autocorrelation. 
# We start testing the unit root hypothesis against the alternative hypothesis of autoregressive process with drift and linear trend by 
# choosing a fixed number of lags. Then, we will select the number of lags by the Akaike and the Bayes information criteria while 
# considering the issue of no autocorrelation in the linear model's residuals for the test.
#
Data_df <- spx_train_df
y <- Data_df$Adj_Close
length(y)
#
# We start with considering the ADF test with 0 lags, which is actually the original Dickey-Fuller test.
lag_num <- 0
# library(urca)
y_ADF_ur.df_trend_0_lags <- urca::ur.df(y, type="trend", lags=lag_num, selectlags="Fixed")
class(y_ADF_ur.df_trend_0_lags)
lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]])
# Call: lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]])
# Coefficients: (Intercept)      z.lag.1           tt  
#                 20.590722    -0.005979     0.020653  
nobs(lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]]))
# 692
n_obs <- length(y)-(lag_num+1)
show(n_obs)
# 692
n_coeffs <- nrow(y_ADF_ur.df_trend_0_lags@testreg[["coefficients"]])
show(n_coeffs)
# 3
df.residual(lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]])) 
# 689
df_res <- n_obs-n_coeffs
show(df_res)
# 689
summary(y_ADF_ur.df_trend_0_lags)
############################################### 
# Augmented Dickey-Fuller Test Unit Root Test # 
############################################### 
# Test regression trend
# Call:
#   lm(formula = z.diff ~ z.lag.1 + 1 + tt)
#
# Residuals:
#   Min       1Q   Median       3Q      Max 
# -178.773  -28.049   -0.362   27.898  203.716
#
# Coefficients:
#              Estimate Std. Error t value Pr(>|t|)  
# (Intercept) 20.590722  19.264363   1.069   0.2855  
# z.lag.1     -0.005979   0.004705  -1.271   0.2042  
# tt           0.020653   0.010219   2.021   0.0437 *
#
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#
# Residual standard error: 46.85 on 689 degrees of freedom
# Multiple R-squared:  0.006044,	Adjusted R-squared:  0.003158 
# F-statistic: 2.095 on 2 and 689 DF,  p-value: 0.1239
#
# Value of test-statistic is: -1.2709 1.6288 2.0946 
#
# Critical values for test statistics: 
#       1pct  5pct 10pct
# tau3 -3.96 -3.41 -3.12
# phi2  6.09  4.68  4.03
# phi3  8.27  6.25  5.34
#
# TODO: risultati

#
y_res <- as.vector(y_ADF_ur.df_trend_0_lags@testreg[["residuals"]])
n_obs <- nobs(lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]]))
max_lag <- ceiling(min(10, n_obs/4))    # Hyndman (for data without seasonality, see https://robjhyndman.com/hyndsight/ljung-box-test/)
show(max_lag)
# 10
n_coeffs <- nrow(y_ADF_ur.df_trend_0_lags@testreg[["coefficients"]])
show(n_coeffs)
# 3
n_pars <- n_coeffs
show(n_pars)
# 3
#fit_df <- min(min(max_lag, n_pars), max_lag-1)
#y_res_LB <- Box.test(y_res, lag=max_lag, fitdf=fit_df, type="Ljung-Box")
#show(y_res_LB)

############################################### 
#               Box-Ljung test                # 
############################################### 
#
# data:  y_res
# X-squared = 8.786, df = 7, p-value = 0.2684
#
# The function FitAR::LjungBoxTest() switches from the value n_pars to LB_fit_df automatically. Interestingly, FitAR::LjungBoxTest() yields
# also the results of the Ljung-Box test for lags smaller than max_lag. This form of the Ljung_box test test is described in detail in Wei 
# (2006, p.153, eqn. 7.5.1). The df are given by h-k, where h is the lag, running from StartLag to lag.max, and k	is the number of ARMA 
# parameters, default k=0. When h-k < 1, it is reset to 1. This is ok, since the test is conservative in this case.
# library(FitAR)
FitAR::LjungBoxTest(y_res, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE) #RIGA 761
# m   Qm    pvalue
# 1 0.13 0.7222634
# 2 1.80 0.1796175
# 3 1.96 0.1620247
# 4 1.98 0.1596372
# 5 1.98 0.3719973
# 6 2.80 0.4228018
# 7 3.15 0.5338560
# 8 3.62 0.6050029
# 9 7.54 0.2734018
# 10 8.79 0.2683891
#
# Tutti i p-value riportati sono superiori a 0.05, il che significa che non ci sono evidenze di autocorrelazione significativa nei residui fino al lag massimo di 10.
#
# TODO: controllare risultati
#
# We plot the autocorrelograms of the residuals of the linear model used for the DF test. RIGA 898
y_res <- as.vector(y_ADF_ur.df_trend_0_lags@testreg[["residuals"]])
n_obs <- nobs(lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]]))
T <- n_obs
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10, T/4))     # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12, T/5)) # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Aut_Fun_y_res <- TSA::acf(y_res, lag.max=max_lag, type= "correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Aut_Fun_y_res <- data.frame(lag=Aut_Fun_y_res$lag, acf=Aut_Fun_y_res$acf)
# First_Date <- paste(Data_df$Month[1],Data_df$year[1])
# Last_Date <- paste(Data_df$Month[T],Data_df$year[T])
First_Date <- as.character(Data_df$Date[1])
Last_Date <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Metodi Probabilistici e Statistici per i Mercati Finanziari \u0040 Ingegneria Informatica Magistrale 2023-2024", 
                             paste("Autocorrelogram of the Residuals of the Linear Model for the DF Test (ADF Test with 0 Lags) on the SP500 Daily Adjusted Close from ", .(First_Date), " to ", .(Last_Date))))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ",.(T)," sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- Aut_Fun_y_res$lag
x_labs <- format(x_breaks, scientific=FALSE)
Plot_Aut_Fun_y_res <- ggplot(Aut_Fun_y_res, aes(x=lag, y=acf))+
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), linewidth=1, col= "black") +
  # geom_col(mapping=NULL, data=NULL, position= "dodge", width=0.1, col= "black", inherit.aes=TRUE)+
  geom_hline(aes(yintercept=-ci_090, color= "CI_090"), show.legend=TRUE, linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_090, color= "CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color= "CI_95"), show.legend=TRUE, linewidth=0.8, lty=2)+
  geom_hline(aes(yintercept=-ci_95, color= "CI_95"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color= "CI_99"), show.legend=TRUE, linewidth=0.8, lty=4) +
  geom_hline(aes(yintercept=ci_99, color= "CI_99"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name= "acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name= "Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linety_respe=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# theme(plot.title=element_blank(), 
#       plot.subtitle=element_blank(),
#       plot.caption=element_text(hjust=1.0),
#       legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# Salvare il grafico in PNG
png("plots/spx_aut_fun_y_res.png", width = 1000, height = 600)

plot(Plot_Aut_Fun_y_res)

# Chiudere il dispositivo PNG
dev.off()
plot(Plot_Aut_Fun_y_res)

# L'evidenza visiva dell'autocorrelogramma dei residui del modello lineare utilizzato per il test DF 
# conferma il rifiuto dell'ipotesi nulla di nessuna autocorrelazione.
# TODO: Rivedere grafico RIGA 952

# We also consider the Breusch-Godfrey test for autocorrelation.
# Note that the Breusch-Godfrey test applies to the residuals from a linear regression. Therefore, applying the Breusch-Godfrey test to the 
# residuals of the linear model used for the DF test is pretty natural. Eventually, the test can be applied to the linear model
lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]])
# Call: lm(formula = y_ADF_ur.df_trend_0_lags@testreg[["terms"]])
# Coefficients: (Intercept)      z.lag.1           tt  
#                 20.590722    -0.005979     0.020653
#
lmtest::bgtest(lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]]), order=10, type="Chisq", fill=NA)
# Breusch-Godfrey test for serial correlation of order up to 10
# data: lm(formula = y_ADF_ur.df_trend_0_lags@testreg[["terms"]])
# LM test = 10.005, df = 10, p-value = 0.44
# 
# This version of the test uses the Lagrange Multipliers (LM) statistics $nR^{2}$, where $n$ is the number of the observations and $R^{2}$
# is the coefficient of determination of the linear regression used in the Breusch_Godfrey test 
# (see https://real-statistics.com/multiple-regression/autocorrelation/breusch-godfrey-test/).
# The LM statistic is asymptotically $\Chi^{p}$-distributed, where $p$ is the order of the correlation that we want to test. In this case
# $p=10$, since we are considering up to 10 lags in analyzing the autocorrelation of the residuals. Another version of the Breusch-Godfrey 
# test uses the F statistic.
lmtest::bgtest(lm(formula=y_ADF_ur.df_trend_0_lags@testreg[["terms"]]), order=10, type="F", fill=NA)
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  lm(formula = y_ADF_ur.df_trend_0_lags@testreg[["terms"]])
# LM test = 0.99605, df1 = 10, df2 = 669, p-value = 0.4452
#
# In both cases the null of no autocorrelation is rejected at the $1\%$ significance level.
#
# It may be interesting to show how the linear model used in the DF test is built.
# From the time series $\left(y_{t}\right)_{t=1}^{T}$, 
y <- Data_df$Adj_Close #RIGA 982
head(y)
# 4448.98 4455.48 4443.11 4352.63 4359.46 4307.54
length(y)
# 693
# We define the differenced time series $\left(z_{t}\right)_{t=1}^{T-1}$, given by $z_{t}\overset{\text{def}}{=}\left(y_{t+1}-y_{t}\right), for
# every $t=1,\dots,T-1$.
z=diff(y,differences=1)
head(z)
# 6.50 -12.37 -90.48   6.83 -51.92  49.50
length(z)
# 692
# Note that the differenced time series $\left(z_{t}\right)_{t=1}^{T-1}$ is one term shorter than the original time series. 
# $\left(y_{t}\right)_{t=1}^{T}$.  
# We define the time variable in the regression
tt=c(1:(length(y)-1))
# We define the one-lag lagged time series $\left(y^{\left(lag1\right)}_{t}\right)_{t=1}^{T-1}$, given by 
# $y^{\left(lag1\right)_{t}\overset{\text{def}}{=}y_{t-1}, for every $t=1,\dots,T-1$
y.lag.1=y[-length(y)]
#
# The data frame used in the DF test, whose residuals are tested in the Breusch-Godfrey test is the given by.
DF_LM_df <- data.frame(z, tt, y.lag.1)
head(DF_LM_df)
tail(DF_LM_df)
# The linear regression used in the DF test is
lm(z~tt+y.lag.1, data=DF_LM_df)
# Call: lm(formula = z ~ tt + y.lag.1, data = DF_LM_df)
# Coefficients: (Intercept)      tt         y.lag.1
#                20.590722     0.020653    -0.005979  
#
# Note that the coefficients of the linear regression are exactly the same as the coefficients in the linear regression used in the DF test.
# Clearly,
lmtest::bgtest(lm(z~tt+y.lag.1, data=DF_LM_df), order=10, type="Chisq", fill=NA) #RIGA 1014
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  lm(z ~ tt + y.lag.1, data = DF_LM_df)
# LM test = 10.005, df = 10, p-value = 0.44
#
# Note also that the forecast::checkresiduals() function should be able to perform both the Ljung-Box and Breusch-Godfrey test. However,
# there are slightly differences in the results.
forecast::checkresiduals(lm(z~tt+y.lag.1, data=DF_LM_df), lag=10, test="LB", plot=TRUE)
# Ljung-Box test
# data:  Residuals
# Q* = 8.786, df = 10, p-value = 0.5525
# Model df: 0.   Total lags used: 10
#
forecast::checkresiduals(lm(z~tt+y.lag.1, data=DF_LM_df), lag=10, test="BG", plot=TRUE)
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  Residuals
# LM test = 9.3886, df = 10, p-value = 0.4957
#
# TODO: conclusione

# The main issue with the above autocorrelation analysis on the residuals of the linear model used in the DF test is that the tests we
# applied lose power when the residuals are affected by conditional heteroscedasticity. Dalla, Giraitis, and Phillips (see Dalla V., 
# Giraitis L., Phillips, P.C.B., Robust Tests for White Noise and Cross-Correlation, Cambridge University Press, 21 September 2020, 
# https://www.cambridge.org/core/journals/econometric-theory/article/robust-tests-for-white-noise-and-crosscorrelation/4D77C12C52433F4C6735E584C779403A)
# have provided robust versions of autocorrelation tests to overcome this issue. Moreover, they have built suitable R functions to perform
# these robust versions of autocorrelation tests (see https://cran.r-project.org/web/packages/testcorr/vignettes/testcorr.pdf; see also
# https://cran.r-project.org/web/packages/testcorr/testcorr.pdf). A line plot of the residuals yields clear visual evidence for conditional
# heteroscedasticity. #RIGA 1047
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
Data_df <- add_column(Data_df, DF_y_res=c(NA,as.vector(y_ADF_ur.df_trend_0_lags@testreg[["residuals"]])), .after="Adj_Close")
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=DF_y_res)
TrnS_length <- length(Data_df$Adj_Close)
show(TrnS_length)
# 693
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Metodi Probabilistici e Statistici per i Mercati Finanziari \u0040 Ingegneria Informatica Magistrale 2023-2024",
                             paste("Residuals of the Linear Model for the DF Test on the SP500 Daily Adjusted Close Price - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/spx-USD?p=spx-USD"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length)
x_breaks_num <- tail(numbers::primeFactors(TrnS_length)-2, n=1) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[(TrnS_length)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("residuals of the linear model")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_ACP_TrnS_DF_res_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA), linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# Salvare il grafico in PNG
png("plots/spx_ACP_TrnS_DF_res_sp.png", width = 1000, height = 600)

plot(spx_ACP_TrnS_DF_res_sp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACP_TrnS_DF_res_sp)
#
# The line plot
spx_ACP_TrnS_DF_res_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="point_black"), alpha=1, linewidth=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACP_TrnS_DF_res_lp.png", width = 1000, height = 600)

plot(spx_ACP_TrnS_DF_res_lp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACP_TrnS_DF_res_lp) 
#RIGA 1134
# Therefore, we consider the application of the testcorr::ac.test() function.
# library(testcorr)
y_res <- as.vector(y_ADF_ur.df_trend_0_lags@testreg[["residuals"]])
testcorr::ac.test(y_res, max.lag = 10, alpha = 0.05, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)
#   | Lag|     AC|  Stand. CB(95%)|  Robust CB(95%)| Lag|      t| p-value| t-tilde| p-value| Lag|    LB| p-value| Q-tilde| p-value|
#   |---:|------:|---------------:|---------------:|---:|------:|-------:|-------:|-------:|---:|-----:|-------:|-------:|-------:|
#   |   1|  0.013| (-0.075, 0.075)| (-0.083, 0.083)|   1|  0.355|   0.723|   0.317|   0.751|   1| 0.126|   0.722|   0.101|   0.751|
#   |   2| -0.049| (-0.075, 0.075)| (-0.084, 0.084)|   2| -1.290|   0.197|  -1.139|   0.255|   2| 1.801|   0.406|   1.398|   0.497|
#   |   3| -0.015| (-0.075, 0.075)| (-0.090, 0.090)|   3| -0.392|   0.695|  -0.323|   0.747|   3| 1.955|   0.582|   1.503|   0.682|
#   |   4|  0.006| (-0.075, 0.075)| (-0.087, 0.087)|   4|  0.149|   0.881|   0.127|   0.899|   4| 1.978|   0.740|   1.519|   0.823|
#   |   5|  0.000| (-0.075, 0.075)| (-0.088, 0.088)|   5|  0.009|   0.993|   0.007|   0.994|   5| 1.978|   0.852|   1.519|   0.911|
#   |   6| -0.034| (-0.075, 0.075)| (-0.091, 0.091)|   6| -0.904|   0.366|  -0.743|   0.458|   6| 2.804|   0.833|   2.070|   0.913|
#   |   7|  0.022| (-0.075, 0.075)| (-0.087, 0.087)|   7|  0.580|   0.562|   0.495|   0.620|   7| 3.145|   0.871|   2.316|   0.940|
#   |   8| -0.026| (-0.075, 0.075)| (-0.086, 0.086)|   8| -0.686|   0.493|  -0.592|   0.554|   8| 3.622|   0.890|   2.666|   0.954|
#   |   9|  0.075| (-0.075, 0.075)| (-0.092, 0.092)|   9|  1.965|   0.049|   1.598|   0.110|   9| 7.545|   0.581|   5.221|   0.815|
#   |  10| -0.042| (-0.075, 0.075)| (-0.088, 0.088)|  10| -1.105|   0.269|  -0.931|   0.352|  10| 8.786|   0.553|   6.087|   0.808|
#
# From the above table and the associated plot, we have computational evidence that the robust Q-tilde statistic does not reject the
# null hypothesis of autocorrelation at the $5\%$ significance level. Nevertheless, the robust $95\%$ confidence bands yield visual evidence 
# for rejecting the null hypothesis at the $5\%$ significance level. Note that, regarding the Ljung-Box statistic, the test is executed  
# under the option fitdf=0.

# Cause the mixed evidences about the possible autocorrelation in the residuals of the linear model used for the DF test, we consider the
# ADF test in which we use a linear model with a large number of lags (with "long" lags), according to the Schwert formula (1989).
long_lags <- floor(12*(length(y)/100)^(1/4)) # the Schwert formula
show(long_lags)
# 19
y_ADF_ur.df_trend_long_lags <- ur.df(y, type="trend", lags=long_lags, selectlags="Fixed")
lm(formula=y_ADF_ur.df_trend_long_lags@testreg[["terms"]])
# Call: lm(formula = y_ADF_ur.df_trend_long_lags@testreg[["terms"]])
# Coefficients: (Intercept)       z.lag.1            tt   z.diff.lag1   z.diff.lag2   z.diff.lag3   z.diff.lag4   z.diff.lag5   z.diff.lag6  
#                  18.513441     -0.005807      0.023921      0.025697     -0.069015      0.005055     -0.009309      0.004527     -0.035437  
#                                 z.diff.lag7   z.diff.lag8   z.diff.lag9  z.diff.lag10  z.diff.lag11  z.diff.lag12  z.diff.lag13  z.diff.lag14  z.diff.lag15  
#                                 0.026773     -0.034133      0.073592     -0.053591      0.054368     -0.048031      0.034572     -0.014610     -0.048114  
#                                 z.diff.lag16  z.diff.lag17  z.diff.lag18  z.diff.lag19  
#                                 -0.035584     -0.017685      0.052257      0.013740  
lag_num <- long_lags
show(lag_num)
# 19
nobs(lm(formula=y_ADF_ur.df_trend_long_lags@testreg[["terms"]]))
# 673
n_obs <- length(y)-(lag_num+1)
show(n_obs)
# 673
n_coeffs <- nrow(y_ADF_ur.df_trend_long_lags@testreg[["coefficients"]])
show(n_coeffs)
# 22
df.residual(lm(formula=y_ADF_ur.df_trend_long_lags@testreg[["terms"]]))
# 651
df_res <- n_obs-n_coeffs
show(df_res)
# 651
summary(y_ADF_ur.df_trend_long_lags)
############################################### 
# Augmented Dickey-Fuller Test Unit Root Test # 
############################################### 
# Test regression trend
# Call: lm(formula = z.diff ~ z.lag.1 + 1 + tt + z.diff.lag)
#
# Residuals:
#      Min       1Q   Median       3Q      Max 
# -170.234  -27.059    0.753   29.013  194.993 
#
# Coefficients:
#             Estimate Std. Error t value Pr(>|t|)  
# (Intercept)  18.513441  20.617449   0.898   0.3695  
# z.lag.1      -0.005807   0.005039  -1.153   0.2495  
# tt            0.023921   0.010880   2.199   0.0283 *
# z.diff.lag1   0.025697   0.039289   0.654   0.5133  
# z.diff.lag2  -0.069015   0.039245  -1.759   0.0791 .
# z.diff.lag3   0.005055   0.039336   0.129   0.8978  
# z.diff.lag4  -0.009309   0.039269  -0.237   0.8127  
# z.diff.lag5   0.004527   0.039164   0.116   0.9080  
# z.diff.lag6  -0.035437   0.039144  -0.905   0.3656  
# z.diff.lag7   0.026773   0.039164   0.684   0.4945  
# z.diff.lag8  -0.034133   0.039111  -0.873   0.3831  
# z.diff.lag9   0.073592   0.039098   1.882   0.0602 .
# z.diff.lag10 -0.053591   0.039127  -1.370   0.1713  
# z.diff.lag11  0.054368   0.039092   1.391   0.1648  
# z.diff.lag12 -0.048031   0.039079  -1.229   0.2195  
# z.diff.lag13  0.034572   0.039066   0.885   0.3765  
# z.diff.lag14 -0.014610   0.039019  -0.374   0.7082  
# z.diff.lag15 -0.048114   0.039002  -1.234   0.2178  
# z.diff.lag16 -0.035584   0.039043  -0.911   0.3624  
# z.diff.lag17 -0.017685   0.038962  -0.454   0.6500  
# z.diff.lag18  0.052257   0.038892   1.344   0.1795  
# z.diff.lag19  0.013740   0.038968   0.353   0.7245   # RIGA 1245
#
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#
# Residual standard error: 47.01 on 651 degrees of freedom
# Multiple R-squared:  0.03523,	Adjusted R-squared:  0.004108 
# F-statistic: 1.132 on 21 and 651 DF,  p-value: 0.3085
#
# Value of test-statistic is: -1.1525 1.8417 2.4292 
#
# Critical values for test statistics: 
#       1pct  5pct 10pct
# tau3 -3.96 -3.41 -3.12
# phi2  6.09  4.68  4.03
# phi3  8.27  6.25  5.34
#
# Poiché la statistica del test (-1.1525) è superiore ai valori critici per tutti i livelli (1%, 5%, 10%), 
# non possiamo rifiutare l'ipotesi nulla. Ciò significa che non abbiamo prove sufficienti per concludere che 
# la serie è stazionaria; al contrario, è probabile che la serie abbia una radice unitaria.
y_res <- as.vector(y_ADF_ur.df_trend_long_lags@testreg[["residuals"]])
max_lag <- ceiling(min(10, n_obs/4))    # Hyndman (for data without seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
n_pars <- n_coeffs
LB_fit_df <- min(min(max_lag, n_pars), max_lag-1)
show(LB_fit_df)
# 9
Box.test(y_res, lag=max_lag, fitdf=LB_fit_df, type="Ljung-Box")
# Box-Ljung test
# data:  y_res
# X-squared = 0.15491, df = 1, p-value = 0.6939

# The result of the test is confirmed by applying the FitAR::LjungBoxTest() function.
FitAR::LjungBoxTest(y_res, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
#  m   Qm    pvalue
#  1 0.00 0.9806140
#  2 0.01 0.9161490
#  3 0.01 0.9159031
#  4 0.03 0.8647885
#  5 0.03 0.8635097
#  6 0.04 0.8504782
#  7 0.07 0.7851142
#  8 0.09 0.7605902
#  9 0.11 0.7374953
# 10 0.15 0.6938851 #RIGA 1294

# We plot the autocorrelograms of the residuals of the linear model used for the DF test.
y_res <- as.vector(y_ADF_ur.df_trend_long_lags@testreg[["residuals"]])
n_obs <- nobs(lm(formula=y_ADF_ur.df_trend_long_lags@testreg[["terms"]]))
T <- n_obs
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10, T/4))     # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12, T/5)) # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Aut_Fun_y_res <- TSA::acf(y_res, lag.max=max_lag, type= "correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Aut_Fun_y_res <- data.frame(lag=Aut_Fun_y_res$lag, acf=Aut_Fun_y_res$acf)
# First_Date <- paste(Data_df$Month[1],Data_df$year[1])
# Last_Date <- paste(Data_df$Month[T],Data_df$year[T])
First_Date <- as.character(Data_df$Date[1])
Last_Date <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024", 
                             paste("Autocorrelogram of the Residuals of the Linear Model with", " \"Long\" ", "Lags for the ADF Test for the SP500 Daily Adjusted Close from ", .(First_Date), " to ", .(Last_Date))))
# link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
# subtitle_content <- bquote(paste("Data set size ",.(TrnS_length)," sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- Aut_Fun_y_res$lag
x_labs <- format(x_breaks, scientific=FALSE)
Plot_Aut_Fun_y_res <- ggplot(Aut_Fun_y_res, aes(x=lag, y=acf))+
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), linewidth=1, col= "black") +
  # geom_col(mapping=NULL, data=NULL, position= "dodge", width=0.1, col= "black", inherit.aes=TRUE)+
  geom_hline(aes(yintercept=-ci_090, color= "CI_090"), show.legend=TRUE, linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_090, color= "CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color= "CI_95"), show.legend=TRUE, linewidth=0.8, lty=2)+
  geom_hline(aes(yintercept=-ci_95, color= "CI_95"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color= "CI_99"), show.legend=TRUE, linewidth=0.8, lty=4) +
  geom_hline(aes(yintercept=ci_99, color= "CI_99"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name= "acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name= "Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linety_respe=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
  # theme(plot.title=element_blank(), 
  #       plot.subtitle=element_blank(),
  #       plot.caption=element_text(hjust=1.0),
  #       legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_Aut_Fun_y_lags_res.png", width = 1000, height = 600)

plot(Plot_Aut_Fun_y_res)

# Chiudere il dispositivo PNG
dev.off()
plot(Plot_Aut_Fun_y_res) #RIGA 1435

# From the autocorrelogram we have clear visual evidence of no autocorrelation in the residuals.

# We again consider the Breusch-Godfrey test for autocorrelation. Applying the test to the residuals of the linear model used for the ADF 
# test also seems natural in this case. Hence, we apply the test to this linear model similarly to what we have done above.
lm(formula=y_ADF_ur.df_trend_long_lags@testreg[["terms"]])
# Call: lm(formula = y_ADF_ur.df_trend_long_lags@testreg[["terms"]])
# Coefficients:  (Intercept)     z.lag.1            tt     z.diff.lag1   z.diff.lag2   z.diff.lag3   z.diff.lag4   z.diff.lag5   z.diff.lag6   
#                 34.771230     -0.002470      0.024961     -0.019871      0.012292      0.030042      0.026443      0.014041      0.032416     
#                                                          z.diff.lag7   z.diff.lag8   z.diff.lag9  z.diff.lag10  z.diff.lag11  z.diff.lag12
#                                                           -0.057108    -0.038416      0.088120      0.033385     -0.001773     -0.056122
#                                                         z.diff.lag13  z.diff.lag14  z.diff.lag15  z.diff.lag16  z.diff.lag17  z.diff.lag18 
#                                                            0.036488     -0.003435     -0.029077     -0.015045      0.025051     -0.007098 
#                                                         z.diff.lag19  z.diff.lag20  z.diff.lag21  z.diff.lag22  z.diff.lag23  z.diff.lag24  
#                                                           -0.061448      0.050838     -0.011420      0.015215     -0.045323      0.077784
# From the autocorrelogram we have no visual evidence for autocorrelation till the 10th lag. Therefore, we apply the Breusch-Godfrey test to
# check the presence of autocorrelation till the 10th order.
lmtest::bgtest(lm(formula=y_ADF_ur.df_trend_long_lags@testreg[["terms"]]), order=10, type="Chisq", fill=NA)
#
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  lm(formula = y_ADF_ur.df_trend_long_lags@testreg[["terms"]])
# LM test = 43.274, df = 10, p-value = 4.443e-06
#
# The Breusch-Godfrey test rejects the null of no autocorrelation at the $1\%$ significance level. This contradicts the computational
# evidence from the Ljung-Box test and the visual evidence from the autocorrelogram. Note also that the lmtest::bgtest() function yields
# a slightly different result from the forecast::checkresiduals() function. #RIGA 1460
# 

# A plot of the residuals shows a clear visual evidence for heteroscedasticity. #RIGA 1796
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
length(as.vector(y_ADF_ur.df_trend_long_lags@testreg[["residuals"]]))
# 1695
Data_df <- add_column(Data_df, ADF_Long_lag_y_res=c(rep(NA,20),as.vector(y_ADF_ur.df_trend_long_lags@testreg[["residuals"]])), .after="Adj_Close")
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=ADF_Long_lag_y_res)
TrnS_length <- length(Data_df$Adj_Close)
show(TrnS_length)
# 1720
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Residuals of the Linear Model with", " \"Long\" ", "Lags for the ADF Test on the SP500 Daily Adjusted Close Price - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length)
x_breaks_num <- 40 # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[(TrnS_length)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("residuals of the linear model")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_ACP_TrnS_Long_Lags_ADF_res_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA), linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACP_TrnS_Long_Lags_ADF_res_sp.png", width = 1000, height = 600)

plot(spx_ACP_TrnS_Long_Lags_ADF_res_sp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACP_TrnS_Long_Lags_ADF_res_sp)
#
# The line plot
spx_ACP_TrnS_Long_Lags_ADF_res_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="point_black"), alpha=1, linewidth=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACP_TrnS_Long_Lags_ADF_res_lp.png", width = 1000, height = 600)

plot(spx_ACP_TrnS_Long_Lags_ADF_res_lp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACP_TrnS_Long_Lags_ADF_res_lp) #RIGA 1884

#
# However, as also suggested by Baum and Schaffer (see Baum, C.F. & Schaffer, M.E., A General Approach to Testing for 
# Autocorrelation, Stata Conference, New Orleans, July 2013, slide 11/44) the Breusch-Godfrey can be applied to a singe time series by 
# regressing the series on a constant. In this case, the regressor (the unit vector) is strictly exogenous. Eventually, creating a 
# fictitious linear regression by setting 
# 
y_res <- as.vector(y_ADF_ur.df_trend_long_lags@testreg[["residuals"]])
lmtest::bgtest(lm(y_res~1), order=10, type="Chisq")
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  triv_y_lm
# LM test = 0.27544, df = 10, p-value = 1
#
lmtest::bgtest(lm(y_res~1), order=10, type="F")
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  triv_y_lm
# LM test = 0.027369, df1 = 10, df2 = 1684, p-value = 1
#
# In addition, the robust version of the test firmly confirm the lack of autocorrelation in the residuals of the linear model with "long" 
# lags used for the ADF test.
y_res <- as.vector(y_ADF_ur.df_trend_long_lags@testreg[["residuals"]])
testcorr::ac.test(y_res, max.lag = 10, alpha = 0.05, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)
#   | Lag|     AC|  Stand. CB(95%)|  Robust CB(95%)| Lag|      t| p-value| t-tilde| p-value| Lag|    LB| p-value| Q-tilde| p-value|
#   |---:|------:|---------------:|---------------:|---:|------:|-------:|-------:|-------:|---:|-----:|-------:|-------:|-------:|
#   |   1|  0.000| (-0.048, 0.048)| (-0.074, 0.074)|   1| -0.012|   0.990|  -0.008|   0.994|   1| 0.000|   0.990|   0.000|   0.994|
#   |   2| -0.001| (-0.048, 0.048)| (-0.076, 0.076)|   2| -0.042|   0.967|  -0.026|   0.979|   2| 0.002|   0.999|   0.001|   1.000|
#   |   3| -0.004| (-0.048, 0.048)| (-0.069, 0.069)|   3| -0.169|   0.866|  -0.116|   0.908|   3| 0.030|   0.999|   0.014|   1.000|
#   |   4| -0.002| (-0.048, 0.048)| (-0.084, 0.084)|   4| -0.100|   0.921|  -0.057|   0.955|   4| 0.040|   1.000|   0.017|   1.000|
#   |   5|  0.006| (-0.048, 0.048)| (-0.079, 0.079)|   5|  0.245|   0.806|   0.148|   0.883|   5| 0.101|   1.000|   0.039|   1.000|
#   |   6| -0.003| (-0.048, 0.048)| (-0.082, 0.082)|   6| -0.142|   0.887|  -0.082|   0.934|   6| 0.121|   1.000|   0.046|   1.000|
#   |   7| -0.005| (-0.048, 0.048)| (-0.085, 0.085)|   7| -0.221|   0.825|  -0.124|   0.901|   7| 0.170|   1.000|   0.061|   1.000|
#   |   8|  0.007| (-0.048, 0.048)| (-0.089, 0.089)|   8|  0.287|   0.774|   0.154|   0.878|   8| 0.253|   1.000|   0.085|   1.000|
#   |   9| -0.004| (-0.048, 0.048)| (-0.078, 0.078)|   9| -0.149|   0.881|  -0.091|   0.927|   9| 0.276|   1.000|   0.094|   1.000|
#   |  10|  0.000| (-0.048, 0.048)| (-0.076, 0.076)|  10|  0.007|   0.994|   0.005|   0.996|  10| 0.276|   1.000|   0.094|   1.000|
#
# From what we have shown above, we can conclude that the residuals in the linear model with "long" lags used for the ADF test do not show 
# evidence for autocorrelation. Hence, we cannot reject the null hypothesis of the presence of a unit root in the SP500 adjusted 
# close price time series.
# More generally, regarding the statistical investigation approach, the above results highlight how important it is to check the validity of
# the hypotheses that allow the successful application of statistical tests and the need to combine different tests to accumulate clear 
# evidence regarding the desired result. 
# 
# We continue the analysis of the ADF test by considering the ADF test with a small number of lags (with "short" lags). However, in what
# follows, we will no longer use the functions portes::LjungBox(), forecst::checkresiduals(), stats::Box.test() with Hyndman's lag option 
# H_max_lag = max(max_lag,(n_pars+3))
#
short_lags <- floor(4*(length(y)/100)^(1/4))
y_ADF_ur.df_trend_short_lags <- ur.df(y, type="trend", lags=short_lags, selectlags="Fixed")
lm(formula=y_ADF_ur.df_trend_short_lags@testreg[["terms"]])
# Call: lm(formula=y_ADF_ur.df_trend_short_lags@testreg[["terms"]])
# Coefficients:
#   (Intercept)      z.lag.1         tt      z.diff.lag1  z.diff.lag2  z.diff.lag3  z.diff.lag4  z.diff.lag5  z.diff.lag6  z.diff.lag7  
#    36.801945     -0.002132     0.014606   -0.033085     0.007996     0.024106     0.041637     0.012625     0.026784   -0.047602     
#                                            z.diff.lag8
#                                            -0.045321 
nobs(lm(formula=y_ADF_ur.df_trend_short_lags@testreg[["terms"]]))
# 1711
n_obs <- length(y)-(short_lags+1)
show(n_obs)
# 1711
n_coeffs <- nrow(y_ADF_ur.df_trend_short_lags@testreg[["coefficients"]])
show(n_coeffs)
# 11
df.residual(lm(formula=y_ADF_ur.df_trend_short_lags@testreg[["terms"]]))
# 1700
df_res <- n_obs-n_coeffs
show(df_res)
# 1700
summary(y_ADF_ur.df_trend_short_lags)
############################################### 
# Augmented Dickey-Fuller Test Unit Root Test # 
############################################### 
# Test regression trend 
# Call: lm(formula=z.diff ~ z.lag.1 + 1 + tt + z.diff.lag)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -7451.0 -223.7  -18.8   204.1  7186.7 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)  
# (Intercept) 36.801945  50.117357   0.734   0.4629  
#   z.lag.1   -0.002132   0.001928  -1.106   0.2691  
#     tt       0.014606   0.067447   0.217   0.8286  
# z.diff.lag1 -0.033085   0.024244  -1.365   0.1725  
# z.diff.lag2  0.007996   0.024222   0.330   0.7414  
# z.diff.lag3  0.024106   0.024217   0.995   0.3197  
# z.diff.lag4  0.041637   0.024223   1.719   0.0858 .
# z.diff.lag5  0.012625   0.024226   0.521   0.6024  
# z.diff.lag6  0.026784   0.024222   1.106   0.2690  
# z.diff.lag7 -0.047602   0.024231 - 1.965   0.0496 *
# z.diff.lag8 -0.045321   0.024241  -1.870   0.0617 .
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1027 on 1700 degrees of freedom
# Multiple R-squared:  0.009067,	Adjusted R-squared:  0.003238 
# F-statistic: 1.556 on 10 and 1700 DF,  p-value: 0.1142
# 
# Value of test-statistic is: -1.1056 0.5805 0.8535 
# 
# Critical values for test statistics: 
#       1pct  5pct 10pct
# tau3 -3.96 -3.41 -3.12
# phi2  6.09  4.68  4.03
# phi3  8.27  6.25  5.34
#
# The impossibility of rejecting the null hypothesis against the three alternatives at $10\%$ significance level is confirmed.
# However, to validate the test, we need to check again the possible presence of autocorrelation in the residuals of the linear model used
# for the ADF test.
#
y_res <- as.vector(y_ADF_ur.df_trend_short_lags@testreg[["residuals"]])
max_lag <- ceiling(min(10, n_obs/4))    # Hyndman (for data without seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
n_pars <- n_coeffs
fit_df <- n_pars
LB_fit_df <- min(min(max_lag, n_pars), max_lag-1)
show(LB_fit_df)
# 9
y_res_LB <- Box.test(y_res, lag=max_lag, fitdf=LB_fit_df, type="Ljung-Box")
show(y_res_LB)
# Box-Ljung test
# data:  y_res
# X-squared=13.699, df=1, p-value=0.0002146
#
FitAR::LjungBoxTest(y_res, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
#  m    Qm       pvalue
#  1  0.03 0.8674283701
#  2  0.07 0.7963572633
#  3  0.07 0.7960059750
#  4  0.09 0.7613210413
#  5  0.14 0.7033825779
#  6  0.14 0.7033713326
#  7  0.16 0.6886836091
#  8  0.17 0.6781488854
#  9 12.74 0.0003573020
# 10 13.70 0.0002146015
#
n_pars_seq <- rep(NA,max_lag)
for(l in 1:max_lag){
  if(l-n_pars<0) n_pars_seq[l] <- l-1
  else n_pars_seq[l] <- n_pars
}
show(n_pars_seq)
# 0 1 2 3 4 5 6 7 8 9
#
Box_test_ls <- list()
for(l in 1:max_lag){
  Box_test_ls[[l]] <- Box.test(y_res, lag=l,   fitdf=n_pars_seq[l], type="Ljung-Box")
  show(Box_test_ls[[l]])
}
# Box-Ljung test
# data:  y_res
# X-squared=0.027864, df=1, p-value=0.8674
# X-squared=0.066597, df=1, p-value=0.7964
# X-squared=0.066832, df=1, p-value=0.796
# X-squared=0.092262, df=1, p-value=0.7613
# X-squared=0.14498,  df=1, p-value=0.7034
# X-squared=0.14499,  df=1, p-value=0.7034
# X-squared=0.16051,  df=1, p-value=0.6887
# X-squared=0.17222,  df=1, p-value=0.6781
# X-squared=12.7430   df=1, p-value=0.0003573
# X-squared=13.6990,  df=1, p-value=0.0002146
#
# We plot the autocorrelogram
y_res <- as.vector(y_ADF_ur.df_trend_short_lags@testreg[["residuals"]])
T <- n_obs
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10, T/4))     # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12, T/5)) # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Aut_Fun_y_res <- TSA::acf(y_res, lag.max=max_lag, type= "correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Aut_Fun_y_res <- data.frame(lag=Aut_Fun_y_res$lag, acf=Aut_Fun_y_res$acf)
# First_Date <- paste(Data_df$Month[1],Data_df$year[1])
# Last_Date <- paste(Data_df$Month[T],Data_df$year[T])
First_Date <- as.character(Data_df$Date[1])
Last_Date <-  as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024", 
                             paste("Autocorrelogram of the Residuals of the Linear Model with", " \"Short\" ", "Lags for the ADF Test for the SP500 Daily Adjusted Close from ", .(First_Date), " to ", .(Last_Date))))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ",.(TrnS_length)," sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- Aut_Fun_y_res$lag
x_labs <- format(x_breaks, scientific=FALSE)
Plot_Aut_Fun_y_res <- ggplot(Aut_Fun_y_res, aes(x=lag, y=acf))+
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), linewidth=1, col= "black") +
  # geom_col(mapping=NULL, data=NULL, position= "dodge", width=0.1, col= "black", inherit.aes=TRUE)+
  geom_hline(aes(yintercept=-ci_090, color= "CI_090"), show.legend=TRUE, linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_090, color= "CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color= "CI_95"), show.legend=TRUE, linewidth=0.8, lty=2)+
  geom_hline(aes(yintercept=-ci_95, color= "CI_95"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color= "CI_99"), show.legend=TRUE, linewidth=0.8, lty=4) +
  geom_hline(aes(yintercept=ci_99, color= "CI_99"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name= "acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name= "Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linety_respe=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# theme(plot.title=element_blank(), 
#       plot.subtitle=element_blank(),
#       plot.caption=element_text(hjust=1.0),
#       legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACP_TrnS_Short_Lags_ADF_res_aut.png", width = 1000, height = 600)

plot(Plot_Aut_Fun_y_res)

# Chiudere il dispositivo PNG
dev.off()
plot(Plot_Aut_Fun_y_res)
#
# The Visual evidence from the autocorrelogram supports the computational result of the Ljung-Box test with the conservative correction for 
# the difference between the lag and fitdf parameters.
#
# We again consider the Breusch-Godfrey test for autocorrelation. Applying the test to the residuals of the linear model used for the ADF 
# test also seems natural in this case. Hence, we apply the test to this linear model similarly to what we have done above.
lm(formula=y_ADF_ur.df_trend_short_lags@testreg[["terms"]])
# Call: lm(formula=y_ADF_ur.df_trend_short_lags@testreg[["terms"]])
# Coefficients:
#   (Intercept)      z.lag.1         tt      z.diff.lag1  z.diff.lag2  z.diff.lag3  z.diff.lag4  z.diff.lag5  z.diff.lag6  z.diff.lag7  
#    36.801945     -0.002132     0.014606   -0.033085     0.007996     0.024106     0.041637     0.012625     0.026784   -0.047602     
#                                            z.diff.lag8
#                                            -0.045321 
#
lmtest::bgtest(lm(formula=y_ADF_ur.df_trend_short_lags@testreg[["terms"]]), order=10, type="Chisq")
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  lm(formula = y_ADF_ur.df_trend_short_lags@testreg[["terms"]])
# LM test = 21.584, df = 10, p-value = 0.01737
#
# The result of the test confirms the rejection of the null hypothesis of no autocorrelation at the $5\%$ significance level. On the other
# hand, considering again the residuals of the linear model used for the ADF test, setting the fictitious linear regression against the 
# units vector, and reapplying the Breusch-Godfrey test we obtain
y_res <- as.vector(y_ADF_ur.df_trend_short_lags@testreg[["residuals"]])
lmtest::bgtest(lm(y_res~1), order=10, type="Chisq")
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  triv_y_lm
# LM test = 13.551, df = 10, p-value = 0.1945
# 
# The result contradicts the rejection of the null-hypothesis. However, a plot of the residuals shows a clear visual evidence for 
# heteroscedasticity and advocates the robust tests for autocorrelation.
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
length(as.vector(y_ADF_ur.df_trend_short_lags@testreg[["residuals"]]))
# 1711
Data_df <- add_column(Data_df, ADF_Long_lag_y_res=c(rep(NA,7),as.vector(y_ADF_ur.df_trend_short_lags@testreg[["residuals"]])), .after="Adj_Close")
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=ADF_Long_lag_y_res)
TrnS_length <- length(Data_df$Adj_Close)
show(TrnS_length)
# 1720
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Residuals of the Linear Model with", " \"Short\" ", "Lags for the ADF Test on the SP500 Daily Adjusted Close Price - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length)
x_breaks_num <- tail(numbers::primeFactors(TrnS_length), n=1)-2 # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[(TrnS_length)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("residuals of the linear model")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_ACP_TrnS_Short_Lags_ADF_res_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA), linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACP_TrnS_Short_Lags_ADF_res_sp.png", width = 1000, height = 600)

plot(spx_ACP_TrnS_Short_Lags_ADF_res_sp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACP_TrnS_Short_Lags_ADF_res_sp)
#
# The line plot
spx_ACP_TrnS_Short_Lags_ADF_res_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="point_black"), alpha=1, linewidth=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACP_TrnS_Short_Lags_ADF_res_lp.png", width = 1000, height = 600)
plot(spx_ACP_TrnS_Short_Lags_ADF_res_lp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACP_TrnS_Short_Lags_ADF_res_lp)
#
y_res <- as.vector(y_ADF_ur.df_trend_short_lags@testreg[["residuals"]])
testcorr::ac.test(y_res, max.lag = 10, alpha = 0.05, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)
# Tests for zero autocorrelation of x
#   | Lag|     AC|  Stand. CB(95%)|  Robust CB(95%)| Lag|      t| p-value| t-tilde| p-value| Lag|     LB| p-value| Q-tilde| p-value|
#   |---:|------:|---------------:|---------------:|---:|------:|-------:|-------:|-------:|---:|------:|-------:|-------:|-------:|
#   |   1|  0.004| (-0.047, 0.047)| (-0.072, 0.072)|   1|  0.167|   0.868|   0.110|   0.913|   1|  0.028|   0.867|   0.012|   0.913|
#   |   2|  0.005| (-0.047, 0.047)| (-0.077, 0.077)|   2|  0.197|   0.844|   0.121|   0.904|   2|  0.067|   0.967|   0.027|   0.987|
#   |   3|  0.000| (-0.047, 0.047)| (-0.070, 0.070)|   3| -0.015|   0.988|  -0.010|   0.992|   3|  0.067|   0.995|   0.027|   0.999|
#   |   4| -0.004| (-0.047, 0.047)| (-0.085, 0.085)|   4| -0.159|   0.874|  -0.089|   0.929|   4|  0.092|   0.999|   0.035|   1.000|
#   |   5| -0.006| (-0.047, 0.047)| (-0.080, 0.080)|   5| -0.229|   0.819|  -0.136|   0.892|   5|  0.145|   1.000|   0.053|   1.000|
#   |   6|  0.000| (-0.047, 0.047)| (-0.081, 0.081)|   6|  0.003|   0.997|   0.002|   0.998|   6|  0.145|   1.000|   0.053|   1.000|
#   |   7| -0.003| (-0.047, 0.047)| (-0.090, 0.090)|   7| -0.124|   0.901|  -0.065|   0.948|   7|  0.161|   1.000|   0.058|   1.000|
#   |   8|  0.003| (-0.047, 0.047)| (-0.090, 0.090)|   8|  0.108|   0.914|   0.057|   0.955|   8|  0.172|   1.000|   0.061|   1.000|
#   |   9|  0.085| (-0.047, 0.047)| (-0.082, 0.082)|   9|  3.534|   0.000|   2.042|   0.041|   9| 12.743|   0.175|   4.231|   0.896|
#   |  10|  0.024| (-0.047, 0.047)| (-0.074, 0.074)|  10|  0.974|   0.330|   0.625|   0.532|  10| 13.699|   0.187|   4.622|   0.915|
# 
# The visual evidence from the robust confidence bands contradicts the computational evidence of the robust Q-tilde statistic. However, it
# seems that the test does not account for the degrees of freedom the linear model uses. Eventually, the results of the Ljung-Box test are 
# the same as those obtained by the stats::Box.test() function with the fitdf=0 option.
Box_test_ls <- list()
for(l in 1:max_lag){
  Box_test_ls[[l]] <- Box.test(y_res, lag=l,   fitdf=0, type="Ljung-Box")
  show(Box_test_ls[[l]])
}
# Box-Ljung test
# data:  y_res
# X-squared = 0.027864, df = 1,  p-value = 0.8674
# X-squared = 0.066597, df = 2,  p-value = 0.9672
# X-squared = 0.066832, df = 3,  p-value = 0.9955
# X-squared = 0.092262, df = 4,  p-value = 0.999
# X-squared = 0.14498,  df = 5,  p-value = 0.9996
# X-squared = 0.14499,  df = 6,  p-value = 0.9999
# X-squared = 0.16051,  df = 7,  p-value = 1
# X-squared = 0.17222,  df = 8,  p-value = 1
# X-squared = 12.7430,  df = 9,  p-value = 0.1746
# X-squared = 13.6990,  df = 10, p-value = 0.1872
#
# For this reason, we keep examining other linear models for the ADF test.
# We consider the ADF test with an optimal number of lags according to the AIC.
#
y_ADF_ur.df_trend_AIC_lags <- ur.df(y, type="trend", lags=long_lags, selectlags="AIC")
lm(formula=y_ADF_ur.df_trend_AIC_lags@testreg[["terms"]])
# Call: lm(formula=y_ADF_ur.df_trend_long_lags@testreg[["terms"]])
# Coefficients: (Intercept)       z.lag.1            tt       z.diff.lag1   z.diff.lag2   z.diff.lag3   z.diff.lag4   z.diff.lag5    
#                34.771230     -0.002470         0.024961    -0.019871      0.012292      0.030042      0.026443      0.014041       
#                                                             z.diff.lag6   z.diff.lag7   z.diff.lag8   z.diff.lag9   z.diff.lag10
#                                                               0.032416    -0.057108    -0.038416      0.088120      0.033385 
#                                                              z.diff.lag11  z.diff.lag12  z.diff.lag13  z.diff.lag14  z.diff.lag15  
#                                                             -0.001773    -0.056122      0.036488    -0.003435    -0.029077
#                                                              z.diff.lag16  z.diff.lag17  z.diff.lag18  z.diff.lag19  z.diff.lag20
#                                                              -0.015045      0.025051   -0.007098    -0.061448      0.050838 
#                                                              z.diff.lag21  z.diff.lag22  z.diff.lag23  z.diff.lag24  
#                                                              -0.011420      0.015215    -0.045323      0.077784  
#
# It turns out that the AIC-selected best linear model to perform the ADF test on the SP500 Adjusted Price is the linear model with the
# number of lags given by the Schwert formula.
#
# We also consider the ADF test with an optimal number of lags according to the BIC.
y_ADF_ur.df_trend_BIC_lags <- ur.df(y, type="trend", lags=long_lags, selectlags="BIC")
lm(formula=y_ADF_ur.df_trend_BIC_lags@testreg[["terms"]])
# Call: lm(formula=y_ADF_ur.df_trend_BIC_lags@testreg[["terms"]])
# Coefficients: (Intercept)      z.lag.1           tt   z.diff.lag  
#                38.917248   -0.002063     0.011021   -0.030747 
# 
# The BIC-selected best linear model to perform the ADF test on the SP500 Adjusted Price is the linear model with one lag.
#
# One might wonder how to determine the minimum AIC or BIC from an ur.df object. A possible solution is in waht follows. 
# Preliminary, note that, as the number of lags increases, the linear models to compare with the AIC or BIC have to be estimated with a
# smaller number of observation. This affects the corresponding values of the corresponding AIC and BIC. Therefore, we need to level the 
# number of observations to the number of observations available for the model with the largest number of lags. To this, we cut a suitable 
# number of initial observations for the models with smaller numbers of lags than the largest.
#
head(Data_df)
y <- Data_df$Adj_Close
length(y)
sum(is.na(y))
#
long_lags <- floor(12*(length(y)/100)^(1/4))  # Fixing the maximum number of lags with the Schwert formula
n_obs <- length(y)-(long_lags+1)
show(n_obs)
y_ADF_ur.df_trend_lags_ls <- list()                     # Creating an empty list
y_ADF_ur.df_trend_lags_AIC_vec <- rep(NA,(long_lags+1)) # Creating an empty vector to store AIC for different lags
y_ADF_ur.df_trend_lags_BIC_vec <- rep(NA,(long_lags+1)) # Creating an empty vector to store BIC for different lags
for (l in 0:long_lags){
  y_ADF_ur.df_trend_lags_ls[[l+1]] <- ur.df(y[-c(1:(long_lags-l+1))], type="trend", lags=l, selectlags="Fixed")
  show(y_ADF_ur.df_trend_lags_ls[[l+1]])
  show(nobs(lm(formula=y_ADF_ur.df_trend_lags_ls[[l+1]]@testreg[["terms"]])))
  y_ADF_ur.df_trend_lags_AIC_vec[l+1] <- AIC(lm(formula=y_ADF_ur.df_trend_lags_ls[[l+1]]@testreg[["terms"]]))
  show(y_ADF_ur.df_trend_lags_AIC_vec[l+1])
  y_ADF_ur.df_trend_lags_BIC_vec[l+1] <- BIC(lm(formula=y_ADF_ur.df_trend_lags_ls[[l+1]]@testreg[["terms"]]))
  show(y_ADF_ur.df_trend_lags_BIC_vec[l+1])
}
show(y_ADF_ur.df_trend_lags_AIC_vec)
# 28328.01 28328.41 28330.33 28331.54 28330.99 28332.81 28333.45 28331.86 28330.43 28320.19 28321.13 28322.83 28318.14 28318.36 28320.34
# 28321.45 28323.02 28324.38 28326.37 28321.43 28318.79 28320.61 28322.10 28320.27 28312.00
#
show(y_ADF_ur.df_trend_lags_BIC_vec)
# 28349.75 28355.58 28362.94 28369.58 28374.47 28381.72 28387.80 28391.64 28395.65 28390.84 28397.22 28404.35 28405.09 28410.75 28418.17
# 28424.71 28431.72 28438.51 28445.94 28446.43 28449.23 28456.48 28463.40 28467.01 28464.18
#
# We draw an "elbow" plot to show the AIC and BIC values as functions of the lags.
margins <- par("mar")
par(mar=c(1,1,1,1))
par(mfrow=c(2,1))
png("plots/df_tren_lags_AIC_vec.png", width = 1000, height = 600)
plot(y_ADF_ur.df_trend_lags_AIC_vec)

# Chiudere il dispositivo PNG
dev.off()
plot(y_ADF_ur.df_trend_lags_AIC_vec, type="b", pch=19, col=4)
png("plots/df_trend_lags_BIC_vec.png", width = 1000, height = 600)
plot(y_ADF_ur.df_trend_lags_BIC_vec)

# Chiudere il dispositivo PNG
dev.off()
plot(y_ADF_ur.df_trend_lags_BIC_vec, type="b", pch=19, col=4)
par(mfrow=c(1,1))
par(mar=margins)
#
# We compute the minimum values of AIC and BIC and show the lag where the minimum values are attained and and the minimum values themselves.
min_AIC_lag <- which(y_ADF_ur.df_trend_lags_AIC_vec==min(y_ADF_ur.df_trend_lags_AIC_vec))
show(c((min_AIC_lag-1),y_ADF_ur.df_trend_lags_AIC_vec[min_AIC_lag]))
# 24 28312
#
min_BIC_lag <- which(y_ADF_ur.df_trend_lags_BIC_vec==min(y_ADF_ur.df_trend_lags_BIC_vec))
show(c((min_BIC_lag-1),y_ADF_ur.df_trend_lags_BIC_vec[min_AIC_lag]))
# 0.00 28464.18
#
# We sort the AIC and BIC values in increasing order.
AIC_lag_sort <- sort(y_ADF_ur.df_trend_lags_AIC_vec, index.return=TRUE, decreasing=FALSE)
show(AIC_lag_sort)
# $x (the sorted values)
# 28312.00 28318.14 28318.36 28318.79 28320.19 28320.27 28320.34 28320.61 28321.13 28321.43 28321.45 28322.10 28322.83 28323.02 28324.38
# 28326.37 28328.01 28328.41 28330.33 28330.43 28330.99 28331.54 28331.86 28332.81 28333.45
#
# $ix (the lags of the sorted values)
# 25 13 14 21 10 24 15 22 11 20 16 23 12 17 18 19  1  2  3  9  5  4  8  6  7 
#
BIC_lag_sort <- sort(y_ADF_ur.df_trend_lags_BIC_vec, index.return=TRUE, decreasing=FALSE)
show(BIC_lag_sort)
# $x (the sorted values)
# 28349.75 28355.58 28362.94 28369.58 28374.47 28381.72 28387.80 28390.84 28391.64 28395.65 28397.22 28404.35 28405.09 28410.75 28418.17
# 28424.71 28431.72 28438.51 28445.94 28446.43 28449.23 28456.48 28463.40 28464.18 28467.01
# 
# $ix (the lags of the sorted values)
# 1  2  3  4  5  6  7 10  8  9 11 12 13 14 15 16 17 18 19 20 21 22 23 25 24
#
# Since AIC and BIC values contrast somewhat with each other, we try to determine an optimal combination mixing them by summing their 
# positions in the sorted sequences.
AIC_BIC_pos_pnt <- vector(mode="integer", length=(long_lags+1))
for(p in 1:(long_lags+1)){
  AIC_BIC_pos_pnt[p] <- (which(AIC_lag_sort$ix==p)+which(BIC_lag_sort$ix==p))
}
show(AIC_BIC_pos_pnt)
# 18 20 22 26 26 30 32 32 30 13 20 25 15 17 22 27 31 33 35 30 25 30 35 31 25
#
# Then we choose the number of lags which produces the smallest sum.
AIC_BIC_pos_pnt_sort <- sort(AIC_BIC_pos_pnt, index.return=TRUE, decreasing=FALSE)
show(AIC_BIC_pos_pnt_sort)
# $x (the sums sorted in increasing order)
# 13 15 17 18 20 20 22 22 25 25 25 26 26 27 30 30 30 30 31 31 32 32 33 35 35
# 
# $ix (the lags of the sorted sums)
# 10 13 14  1  2 11  3 15 12 21 25  4  5 16  6  9 20 22 17 24  7  8 18 19 23
# 
# The "mixed" optimal combination is achieved at p=10 which corresponds to nine lags (p=1 corresponds to zero lags).
#
# Note that in the "elbow" plot at the value p=10 of the lag variable both AIC and BIC paths attain a local minimum (elbow).
# In light of what we have presented above, we perform the ADF test considering nine lags.
l <- 9
y_ADF_ur.df_trend_9_lags <- ur.df(y, type="trend", lags=l, selectlags="Fixed")
lm(formula=y_ADF_ur.df_trend_9_lags@testreg[["terms"]])
# Call: lm(formula=y_ADF_ur.df_trend_9_lags@testreg[["terms"]])
# Coefficients:  (Intercept)    z.lag.1        tt       z.diff.lag1  z.diff.lag2  z.diff.lag3  z.diff.lag4  z.diff.lag5  z.diff.lag6   
#                 33.086555   -0.002487     0.026755   -0.028698     0.012242     0.022141     0.040945     0.009404     0.024969      
#                                                       z.diff.lag7  z.diff.lag8  z.diff.lag9  
#                                                      -0.047953   -0.042174      0.085065  
nobs(lm(formula=y_ADF_ur.df_trend_9_lags@testreg[["terms"]]))
# 1710
n_obs <- length(y)-(l+1)
show(n_obs)
# 1710
n_coeffs <- nrow(y_ADF_ur.df_trend_9_lags@testreg[["coefficients"]])
show(n_coeffs)
# 12
df.residual(lm(formula=y_ADF_ur.df_trend_9_lags@testreg[["terms"]])) 
# 1698
df_res <- n_obs-n_coeffs
show(df_res)
# 1698
summary(y_ADF_ur.df_trend_9_lags)
############################################### 
# Augmented Dickey-Fuller Test Unit Root Test # 
############################################### 
# Call: lm(formula=z.diff ~ z.lag.1 + 1 + tt + z.diff.lag)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -7468.1 -225.7  -15.0   215.0  7208.3 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) 33.086555  50.026146   0.661 0.508455    
# z.lag.1    -0.002487   0.001925 -1.292 0.196541    
# tt           0.026755   0.067368   0.397 0.691307    
# z.diff.lag1 -0.028698   0.024204  -1.186 0.235909    
# z.diff.lag2  0.012242   0.024183   0.506 0.612768    
# z.diff.lag3  0.022141   0.024148   0.917 0.359334    
# z.diff.lag4  0.040945   0.024149   1.695 0.090164 .  
# z.diff.lag5  0.009404   0.024169   0.389 0.697247    
# z.diff.lag6  0.024969   0.024154   1.034 0.301406    
# z.diff.lag7 -0.047953   0.024156  -1.985 0.047294 *  
# z.diff.lag8 -0.042174   0.024184  -1.744 0.081360 .  
# z.diff.lag9  0.085065   0.024192   3.516 0.000449 ***
#  ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1024 on 1698 degrees of freedom
# Multiple R-squared:  0.01621,	Adjusted R-squared:  0.009839 
# F-statistic: 2.544 on 11 and 1698 DF,  p-value: 0.003441
# 
# Value of test-statistic is: -1.292 0.6939 1.0282 
# 
# Critical values for test statistics: 
#   1pct  5pct 10pct
# tau3 -3.96 -3.41 -3.12
# phi2  6.09  4.68  4.03
# phi3  8.27  6.25  5.34
#
# The null hypothesis cannot be rejected against the three alternatives at the $10\%$ significance level.
# However, to validate the test, we need to check the possible presence of autocorrelation in the residuals of the model used for the test.
y_res <- as.vector(y_ADF_ur.df_trend_9_lags@testreg[["residuals"]])
nobs(lm(formula=y_ADF_ur.df_trend_9_lags@testreg[["terms"]]))
max_lag <- ceiling(min(10, n_obs/4))    # Hyndman (for data without seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
show(max_lag)
# 10
n_coeffs <- nrow(y_ADF_ur.df_trend_9_lags@testreg[["coefficients"]])
show(n_coeffs)
# 12
n_pars <- n_coeffs
show(n_pars)
# 12
fit_df <- n_pars
LB_fit_df <- min(min(max_lag, n_pars), max_lag-1)
show(LB_fit_df)
# 9
y_res_LB <- Box.test(y_res, lag=max_lag, fitdf=LB_fit_df, type="Ljung-Box")
show(y_res_LB)
# Box-Ljung test
# data:  y_res
# X-squared=1.9316, df=1, p-value=0.1646
#
FitAR::LjungBoxTest(y_res, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
#  m  Qm    pvalue
#  1 0.01 0.9320035
#  2 0.01 0.9316027
#  3 0.10 0.7519338
#  4 0.16 0.6928563
#  5 0.16 0.6871187
#  6 0.19 0.6630801
#  7 0.19 0.6611990
#  8 0.20 0.6577588
#  9 0.20 0.6541153
# 10 1.93 0.1645825
#
n_pars_seq <- rep(NA,max_lag)
for(l in 1:max_lag){
  if(l-n_pars<0) n_pars_seq[l] <- l-1
  else n_pars_seq[l] <- n_pars
}
show(n_pars_seq)
# 0 1 2 3 4 5 6 7 8 9
#
Box_test_ls <- list()
for(l in 1:max_lag){
  Box_test_ls[[l]] <- Box.test(y_res, lag=l,   fitdf=n_pars_seq[l], type="Ljung-Box")
  show(Box_test_ls[[l]])
}
# Box-Ljung test
# data:  y_res
# X-squared=0.0072802, df=1, p-value=0.932
# X-squared=0.0073665, df=1, p-value=0.9316
# X-squared=0.099913,  df=1, p-value=0.7519
# X-squared=0.15601,   df=1, p-value=0.6929
# X-squared=0.16222,   df=1, p-value=0.6871
# X-squared=0.1898,    df=1, p-value=0.6631
# X-squared=0.19207,   df=1, p-value=0.6612
# X-squared=0.19626,   df=1, p-value=0.6578
# X-squared=0.20075,   df=1, p-value=0.6541
# X-squared=1.9316,    df=1, p-value=0.1646
#
y_res <- as.vector(y_ADF_ur.df_trend_9_lags@testreg[["residuals"]])
T <- n_obs
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10, T/4))     # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12, T/5)) # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Aut_Fun_y_res <- TSA::acf(y_res, lag.max=max_lag, type= "correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Aut_Fun_y_res <- data.frame(lag=Aut_Fun_y_res$lag, acf=Aut_Fun_y_res$acf)
# First_Date <- paste(Data_df$Month[1],Data_df$y_resear[1])
# Last_Date <- paste(Data_df$Month[T],Data_df$y_resear[T])
First_Date <- as.character(Data_df$Date[1])
Last_Date <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024", 
                             paste("Autocorrelogram of the Residuals of the Linear Model with AIC-BIC Selected Nine (9) Lags for the ADF Test for the SP500 Daily Adjusted Close from ", .(First_Date), " to ", .(Last_Date))))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ",.(TrnS_length)," sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- Aut_Fun_y_res$lag
x_labs <- format(x_breaks, scientific=FALSE)
Plot_Aut_Fun_y_res <- ggplot(Aut_Fun_y_res, aes(x=lag, y=acf))+
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), linewidth=1, col= "black") +
  # geom_col(mapping=NULL, data=NULL, position= "dodge", width=0.1, col= "black", inherit.aes=TRUE)+
  geom_hline(aes(yintercept=-ci_090, color= "CI_090"), show.legend=TRUE, linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_090, color= "CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color= "CI_95"), show.legend=TRUE, linewidth=0.8, lty=2)+
  geom_hline(aes(yintercept=-ci_95, color= "CI_95"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color= "CI_99"), show.legend=TRUE, linewidth=0.8, lty=4) +
  geom_hline(aes(yintercept=ci_99, color= "CI_99"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name= "acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name= "Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linety_respe=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# theme(plot.title=element_blank(), 
#       plot.subtitle=element_blank(),
#       plot.caption=element_text(hjust=1.0),
#       legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/aut_res_AIC-BIC_9_lags_ADF.png", width = 1000, height = 600)
plot(Plot_Aut_Fun_y_res)

# Chiudere il dispositivo PNG
dev.off()
plot(Plot_Aut_Fun_y_res)
#
# We consider the Breusch-Godfrey test for autocorrelation.
lm(formula=y_ADF_ur.df_trend_9_lags@testreg[["terms"]])
# Call: lm(formula=y_ADF_ur.df_trend_short_lags@testreg[["terms"]])
# Coefficients:
#   (Intercept)      z.lag.1         tt      z.diff.lag1  z.diff.lag2  z.diff.lag3  z.diff.lag4  z.diff.lag5  z.diff.lag6  z.diff.lag7  
#    33.086555      -0.002487     0.026755   -0.028698     0.012242     0.022141     0.040945     0.009404     0.024969    -0.047953     
#                                            z.diff.lag8  z.diff.lag9  
#                                             -0.042174    0.085065
#
lmtest::bgtest(lm(formula=y_ADF_ur.df_trend_9_lags@testreg[["terms"]]), order=10, type="Chisq")
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  lm(formula = y_ADF_ur.df_trend_short_lags@testreg[["terms"]])
# LM test = 13.982, df = 10, p-value = 0.1738
#
lmtest::bgtest(lm(formula=y_ADF_ur.df_trend_9_lags@testreg[["terms"]]), order=10, type="F")
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  lm(formula = y_ADF_ur.df_trend_9_lags@testreg[["terms"]])
# LM test = 1.3916, df1 = 10, df2 = 1688, p-value = 0.178
#
# The result of the two versions of the Breusch-Godfrey test confirms the non-rejection of the null hypothesis of no autocorrelation at the
# $10\%$ significance level.
# 
# Nevertheless, a plot of the residuals shows a clear visual evidence for heteroscedasticity and advocates the robust tests for 
# autocorrelation.
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
length(as.vector(y_ADF_ur.df_trend_9_lags@testreg[["residuals"]]))
# 1711
Data_df <- add_column(Data_df, ADF_Long_lag_y_res=c(rep(NA,10),as.vector(y_ADF_ur.df_trend_9_lags@testreg[["residuals"]])), .after="Adj_Close")
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=ADF_Long_lag_y_res)
TrnS_length <- length(Data_df$Adj_Close)
show(TrnS_length)
# 1720
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Residuals of the Linear Model with AIC-BIC Selected Nine (9) Lags for the ADF Test on the SP500 Daily Adjusted Close Price - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length)
x_breaks_num <- 40 # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[(TrnS_length)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("residuals of the linear model")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_ACP_TrnS_9_Lags_ADF_res_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA), linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACP_TrnS_9_Lags_ADF_res_sp.png", width = 1000, height = 600)
plot(spx_ACP_TrnS_9_Lags_ADF_res_sp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACP_TrnS_9_Lags_ADF_res_sp)
#
# The line plot
spx_ACP_TrnS_9_Lags_ADF_res_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="point_black"), alpha=1, linewidth=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACP_TrnS_9_Lags_ADF_res_lp.png", width = 1000, height = 600)
plot(spx_ACP_TrnS_9_Lags_ADF_res_lp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACP_TrnS_9_Lags_ADF_res_lp)
#
y_res <- as.vector(y_ADF_ur.df_trend_9_lags@testreg[["residuals"]])
testcorr::ac.test(y_res, max.lag = 10, alpha = 0.10, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)

############################################################################################################################################
# We consider the *KPSS* test, which assumes the null hypothesis that the time series can be considered a path of an autoregressive process. 
# In terms of the null hypothesis, the test allows us to specify an autoregressive process with drift, type="mu", or an autoregressive 
# process with drift and linear trend, type="tau".
#   
# Focusing on the type "tau", the *KPSS* test contained in the library *urca*, also allows different possibilities for the number of lags.
# More specifically, we have
#
head(Data_df)
y <- Data_df$Adj_Close
#
y_KPSS_ur_tau_nil <- ur.kpss(y, type="tau", lags="nil")
summary(y_KPSS_ur_tau_nil)
####################### 
# KPSS Unit Root Test # 
#######################
# Test is of type: tau with 0 lags. 
# Value of test-statistic is: 14.398 
# Critical value for a significance level of: 
#                10pct  5pct 2.5pct  1pct
#critical values 0.119 0.146  0.176 0.216
#
# When the null hypothesis consists of an autoregressive model with drift, linear trend, and a small number of lags, we still have a 
# rejection of the null hypothesis in favor of the alternative at $1\%$ significance level, but the rejection is weaker than the case with 
# zero lags.
#
y_KPSS_ur_tau_short <- ur.kpss(y, type="tau", lags="short")
summary(y_KPSS_ur_tau_short)
####################### 
# KPSS Unit Root Test # 
####################### 
# Test is of type: tau with 5 lags. 
# Value of test-statistic is: 0.2588 
# Critical value for a significance level of: 
#                10pct  5pct 2.5pct  1pct
#critical values 0.119 0.146  0.176 0.216
#
# When the null hypothesis consists of an autoregressive model with drift, linear trend, and a small number of lags, we still have a 
# rejection of the null hypothesis in favor of the alternative at $1\%$ significance level, but the rejection is weaker than the case with 
# zero lags.
#
y_KPSS_ur_tau_long <- ur.kpss(y, type="tau", lags="long") # the Schwert formula
summary(y_KPSS_ur_tau_long)
####################### 
# KPSS Unit Root Test # 
####################### 
# Test is of type: tau with 19 lags. 
# Value of test-statistic is: 0.7719 
# Critical value for a significance level of: 
#                 10pct  5pct 2.5pct  1pct
# critical values 0.119 0.146  0.176 0.216
#
# When the null hypothesis consists of an autoregressive model with drift, linear trend, and a large number of lags, we still have a
# rejection of the null hypothesis in favor of the alternative at $1\%$ significance level, but the rejection is weaker than the case with
# a small number of lags.
#
# On increasing the number of lags of the lagged autoregressive model with drift and linear trend considered as the null hypothesis,
# rejecting the null hypothesis in favor of the alternative at $1\%$ significance level becomes weaker but cannot be avoided.
#
# In light of the results of the *ADF* and *KPSS* we have to think of the SP500 Daily Adjusted Close Price as a path of a process containing a 
# random walk component.
############################################################################################################################################
# In the presence of a random walk component, the strategy to render a time series stationary is differencing it. However, in the case of a
# time series representing a stock price in a financial market, the standard procedure prescribes applying the logarithm transformation
# before differencing. This is because by differencing the logarithm transformation of a stock price time series, we obtain the time series
# of the logarithm returns of the stock, which is the time series of genuine interest for a financial analyst.
# Note that by the logarithm transformation, we eliminate a likely exponential deterministic trend, which is evidenced by the structure 
# of the first part of the LOESS curve in the scatter and line plot of the data. This exponential trend is a natural component of the price
# of financial assets due to the time value of the money. On the other hand, by differencing, we eliminate a random walk component in the 
# log-transformed stock price. A random walk is also a natural component of a stock price time series since the stock prices in financial 
# markets are continuously updated by the buying and selling activity due to the erratic arrival of price-sensitive news, which modifies the 
# investors' perception of the value of the stocks. Last, but not the least, a logarithm transformation, which is a particular Box-Cox 
# transformation caan significantly reduce the heteroscedasticity in the time series.
# We consider logarithm transformation and differencing separately, but it is pretty standard practice to consider the two transformations
# at once.
#RIGA 2859
############################ Logarithm transformation of the SP500 Daily Adjusted Close Price  ###########################################
# We create the logarithm transformation of the Adj_Close column in the spx_df data frame adding it to the spx_df data frame itself.
head(spx_df)
spx_df <- add_column(spx_df, Adj_Close_log.=log(spx_df$Adj_Close), .after="Adj_Close")
head(spx_df)
tail(spx_df)
# Hence we consider the scatter and line plot of the log-transformed training and test set
Data_df <- spx_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=Adj_Close_log.)
head(Data_df)
DS_length <- length(Data_df$y)
show(DS_length)
# 1871
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(Data_df$Date[which(Data_df$Date<as.Date(Data_df$Date[position_92]))])
show(TrnS_length)
# 1720
TstS_First_Day <- as.character(Data_df$Date[which(Data_df$Date==as.Date(Data_df$Date[position_92]))])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(Data_df$Date[which(Data_df$Date>=as.Date(Data_df$Date[position_92]))])
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Adjusted Close Price Logarithm - Training and Test Sets - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(DS_length-1)
x_breaks_num <- tail(numbers::primeFactors(DS_length-1), n=1) # (deduced from primeFactors(DS_length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily adjusted close price logarithms (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily close price logs (US $) training set")
point_b <- bquote("daily close price logs (US $) test set")
line_green <- bquote("regression line (training set)")
line_red <- bquote("LOESS curve (training set)")
leg_point_labs <- c(point_black, point_b)
leg_point_cols <- c("point_black"="black", "point_b"="blue")
leg_point_breaks <- c("point_black", "point_b")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_Adj_Close_log._TrnS_TstS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], linewidth=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE) +
  geom_point(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19) + 
  geom_point(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.7, shape=19) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, 19, NA, NA), linetype=c("blank", "blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_Adj_Close_log_TrnS_TstS_sp.png", width = 1200, height = 600)
plot(spx_Adj_Close_log._TrnS_TstS_sp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_Adj_Close_log._TrnS_TstS_sp)
#
# The line plot
spx_Adj_Close_log._TrnS_TstS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], linewidth=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, linewidth=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, linewidth=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE) +
  geom_line(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, linewidth=0.7, linetype="solid") +
  geom_line(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, linewidth=0.7, linetype="solid") +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_Adj_Close_log_TrnS_TstS_lp.png", width = 1200, height = 600)
plot(spx_Adj_Close_log._TrnS_TstS_lp)

# Chiudere il dispositivo PNG
dev.off()
plot(spx_Adj_Close_log._TrnS_TstS_lp)
#
# From the inspection of the scatter and line plot of the daily adjusted close price logarithm, we have visual evidence of an increasing 
# trend with some falls, milder than the sharp falls of the daily adjusted close price. Clearly, the lack of evidence for seasonality is 
# confirmed. Comparing the LOESS with the regression line, the overall trend does not appear to be linear. Neither does it appear to be 
# exponential. The spread of the points of the training set around the LOESS seems to be more homogeneous throughout the LOESS path. 
# Uncertain visual evidence for heteroscedasticity.
############################################################################################################################################
# We consider again the data frame containing only the training set data.
spx_train_df <- spx_df[1:position_92-1,]
head(spx_train_df)
tail(spx_train_df)
#
# We consider the autocorrelograms of the daily adjusted close price logarithm training set. Of course, due to the clear trend, we expect a
# strong visual evidence for autocorrelation.
# Autocorrelogram of the training set of the SP500 daily adjusted close price logarithm.
Data_df <- spx_train_df
y <- Data_df$Adj_Close_log.
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Aut_Fun_y <- stats::acf(y, lag.max=max_lag, type="correlation", plot=FALSE)
# Aut_Fun_y <- TSA::acf(y, lag.max=max_lag, type="correlation", plot=TRUE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Aut_Fun_y <- data.frame(lag=Aut_Fun_y$lag, acf=Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Autocorrelogram of the SP500 Daily Adjusted Close Price Logarithm - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
plot_aut_fun_y <- ggplot(Plot_Aut_Fun_y, aes(x=lag, y=acf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), linewidth=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), linewidth=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), linewidth=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), linewidth=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")

# Mostra il grafico nella scheda Plots
print(plot_aut_fun_y)

ggsave("plots/spx_aut_adj_close_price_log.png", plot = plot_aut_fun_y, width = 12, height = 6)

#
# The autocorrelogram provides a very strong visual evidence for non-stationarity.
#
# Partial autocorrelogram of the training set of the SP500 Composite daily adjusted close prices.
Data_df <- spx_train_df
y <- Data_df$Adj_Close_log.
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Part_Aut_Fun_y <- stats::pacf(y, lag.max=max_lag, type="correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Part_Aut_Fun_y <- data.frame(lag=Part_Aut_Fun_y$lag, pacf=Part_Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Partial Autocorrelogram of the SP500 Daily Adjusted Close Price Logarithm - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
plot_part_aut_fun_y <- ggplot(Plot_Part_Aut_Fun_y, aes(x=lag, y=pacf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=pacf), size=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), linewidth=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), linewidth=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), linewidth=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="pacf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")

print(plot_part_aut_fun_y)
ggsave("plots/spx_part_aut_adj_close_price_log.png",plot_part_aut_fun_y, width = 12, height = 6)
#
# The partial autocorrelogram provides visual evidence for a unit root.
#
# Despite not necessary, due to the strong visual evidence from the autocorrelograms, we consider the Ljung-Box test
# Ljung-Box test
Data_df <- spx_train_df
head(Data_df)
y <- Data_df$Adj_Close_log.
T <- length(y)
max_lag <- ceiling(min(10,T/4)) # Hyndman (for data without seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
show(max_lag)
# 10
n_pars <- 0
show(n_pars)
# 0
fit_df <- n_pars
y_LB <- Box.test(y, lag=max_lag, fitdf=fit_df, type="Ljung-Box")
show(y_LB)
# Box-Ljung test
# data:  y
# X-squared=17062, df=10, p-value < 2.2e-16
#
FitAR::LjungBoxTest(y, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
#  m       Qm pvalue
#  1  1715.50      0
#  2  3428.17      0
#  3  5138.18      0
#  4  6845.14      0
#  5  8548.98      0
#  6 10249.56      0
#  7 11947.26      0
#  8 13642.12      0
#  9 15334.16      0
# 10 17058.69      0
#
n_pars_seq <- rep(NA,max_lag)
for(l in 1:max_lag){
  if(l-n_pars<0) n_pars_seq[l] <- l-1
  else n_pars_seq[l] <- n_pars
}
show(n_pars_seq)
# 0 0 0 0 0 0 0 0 0 0
#
Box_test_ls <- list()
for(l in 1:max_lag){
  Box_test_ls[[l]] <- Box.test(y, lag=l,   fitdf=n_pars_seq[l], type="Ljung-Box")
  show(Box_test_ls[[l]])
}
# Box-Ljung test
# data:  y
# X-squared = 691, df = 1, p-value < 0.00000000000000022
# X-squared = 3435.5, df = 2, p-value < 0.00000000000000022
# X-squared = 5149.2, df = 3, p-value < 0.00000000000000022
# X-squared = 6860.2, df = 4, p-value < 0.00000000000000022
# X-squared = 8568.2, df = 5, p-value < 0.00000000000000022
# X-squared = 10273, df = 6, p-value < 0.00000000000000022
# X-squared = 11975, df = 7, p-value < 0.00000000000000022
# X-squared = 13673, df = 8, p-value < 0.00000000000000022
# X-squared = 15369, df = 9, p-value < 0.00000000000000022
# X-squared = 17062, df = 10, p-value < 0.00000000000000022
#
# The Ljung-Box test rejects the null hypothesis of no autocorrelation in the SP500 daily adjusted close price logarithms at the $1\%$
# significance level. #RIGA 3224 
############################################################################################################################################
# Also in this case, we should check whether the SP500 adjusted close price logarithm time series contains a unit root (a random walk 
# component). However, we apply here a more direct two step procedure. First, we evaluate the optimal lag for the ADF test by applying the
# AIC+BIC information criterion. Second, we check the validity of the test by evaluating the autocorrelation of the residuals of the linear
# model used for the ADF test.
head(spx_train_df)
Data_df <- spx_train_df
y <- Data_df$Adj_Close_log.
length(y)
# 1720
#
sum(is.na(y))
# 0
#
long_lags <- floor(12*(length(y)/100)^(1/4))  # Fixing the maximum number of lags with the Schwert formula
n_obs <- length(y)-(long_lags+1)
show(n_obs)
y_ADF_ur.df_trend_lags_ls <- list()                     # Creating an empty list
y_ADF_ur.df_trend_lags_AIC_vec <- rep(NA,(long_lags+1)) # Creating an empty vector to store AIC for different lags
y_ADF_ur.df_trend_lags_BIC_vec <- rep(NA,(long_lags+1)) # Creating an empty vector to store BIC for different lags
for (l in 0:long_lags){
  y_ADF_ur.df_trend_lags_ls[[l+1]] <- ur.df(y[-c(1:(long_lags-l+1))], type="trend", lags=l, selectlags="Fixed")
  show(y_ADF_ur.df_trend_lags_ls[[l+1]])
  show(nobs(lm(formula=y_ADF_ur.df_trend_lags_ls[[l+1]]@testreg[["terms"]])))
  y_ADF_ur.df_trend_lags_AIC_vec[l+1] <- AIC(lm(formula=y_ADF_ur.df_trend_lags_ls[[l+1]]@testreg[["terms"]]))
  show(y_ADF_ur.df_trend_lags_AIC_vec[l+1])
  y_ADF_ur.df_trend_lags_BIC_vec[l+1] <- BIC(lm(formula=y_ADF_ur.df_trend_lags_ls[[l+1]]@testreg[["terms"]]))
  show(y_ADF_ur.df_trend_lags_BIC_vec[l+1])
}
show(y_ADF_ur.df_trend_lags_AIC_vec)
# -6317.424 -6320.133 -6321.233 -6319.247 -6321.624 -6320.131 -6318.854 -6318.405 -6318.664 -6316.776 -6317.144 -6315.445 -6313.452 -6313.363
# -6311.372 -6309.389 -6308.079 -6307.660 -6305.903 -6304.057 -6302.123 -6302.123 -6300.530 -6301.362 -6301.821
#
show(y_ADF_ur.df_trend_lags_BIC_vec)
# -6295.685 -6292.959 -6288.624 -6281.203 -6278.145 -6271.218 -6264.506 -6258.621 -6253.445 -6246.123 -6241.056 -6233.922 -6226.495 -6220.971
# -6213.544 -6206.127 -6199.382 -6193.528 -6186.336 -6179.055 -6171.686 -6166.252 -6159.224 -6154.621 -6149.645
#
# We draw an "elbow" plot to show the AIC and BIC values as functions of the lags.
margins <- par("mar")
par(mar=c(1,1,1,1))
par(mfrow=c(2,1))
plot(y_ADF_ur.df_trend_lags_AIC_vec, type="b", pch=19, col=4)
plot(y_ADF_ur.df_trend_lags_BIC_vec, type="b", pch=19, col=4)
par(mfrow=c(1,1))
par(mar=margins)
#
# We compute the minimum values of AIC and BIC and show the lag where the minimum values are attained and and the minimum values themselves.
min_AIC_lag <- which(y_ADF_ur.df_trend_lags_AIC_vec==min(y_ADF_ur.df_trend_lags_AIC_vec))
show(c((min_AIC_lag-1),y_ADF_ur.df_trend_lags_AIC_vec[min_AIC_lag]))
# 4.000 -6321.624
#
min_BIC_lag <- which(y_ADF_ur.df_trend_lags_BIC_vec==min(y_ADF_ur.df_trend_lags_BIC_vec))
show(c((min_BIC_lag-1),y_ADF_ur.df_trend_lags_BIC_vec[min_AIC_lag]))
# 0.000 -6278.145
#
# We sort the AIC and BIC values in increasing order.
AIC_lag_sort <- sort(y_ADF_ur.df_trend_lags_AIC_vec, index.return=TRUE, decreasing=FALSE)
show(AIC_lag_sort)
# $x (the sorted values)
# -6321.624 -6321.233 -6320.133 -6320.131 -6319.247 -6318.854 -6318.664 -6318.405 -6317.424 -6317.144 -6316.776 -6315.445 -6313.452 -6313.363
# -6311.372 -6309.389 -6308.079 -6307.660 -6305.903 -6304.057 -6302.123 -6302.123 -6301.821 -6301.362 -6300.530
#
# $ix (the lags of the sorted values)
# 5  3  2  6  4  7  9  8  1 11 10 12 13 14 15 16 17 18 19 20 22 21 25 24 23 
#
BIC_lag_sort <- sort(y_ADF_ur.df_trend_lags_BIC_vec, index.return=TRUE, decreasing=FALSE)
show(BIC_lag_sort)
# $x (the sorted values)
# -6295.685 -6292.959 -6288.624 -6281.203 -6278.145 -6271.218 -6264.506 -6258.621 -6253.445 -6246.123 -6241.056 -6233.922 -6226.495 -6220.971
# -6213.544 -6206.127 -6199.382 -6193.528 -6186.336 -6179.055 -6171.686 -6166.252 -6159.224 -6154.621 -6149.645
# 
# $ix (the lags of the sorted values)
# 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#
# Since AIC and BIC values contrast somewhat with each other, we try to determine an optimal combination mixing them by summing their 
# positions in the sorted sequences.
AIC_BIC_pos_pnt <- vector(mode="integer", length=(long_lags+1))
for(p in 1:(long_lags+1)){
  AIC_BIC_pos_pnt[p] <- (which(AIC_lag_sort$ix==p)+which(BIC_lag_sort$ix==p))
}
show(AIC_BIC_pos_pnt)
# 10  5  5  9  6 10 13 16 16 21 21 24 26 28 30 32 34 36 38 40 43 43 48 48 48
#
# Then we choose the number of lags which produces the smallest sum.
AIC_BIC_pos_pnt_sort <- sort(AIC_BIC_pos_pnt, index.return=TRUE, decreasing=FALSE)
show(AIC_BIC_pos_pnt_sort)
# $x
# 5  5  6  9 10 10 13 16 16 21 21 24 26 28 30 32 34 36 38 40 43 43 48 48 48
# 
# $ix
# 2  3  5  4  1  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#
# The "mixed" optimal combination is achieved at p=2 which corresponds to one lag (p=1 corresponds to zero lags).
# Note that in the "elbow" plot at the value p=10 of the lag variable both AIC and BIC paths attain a local minimum (elbow).
# AS a consequence we test test for a unit root applying an ADF test wti one lag.
l <- 1
y_ADF_ur.df_trend_1_lags <- ur.df(y, type="trend", lags=l, selectlags="Fixed")
lm(formula=y_ADF_ur.df_trend_1_lags@testreg[["terms"]])
# Call: lm(formula = y_ADF_ur.df_trend_1_lags@testreg[["terms"]])
# 
# Coefficients:  (Intercept)     z.lag.1           tt   z.diff.lag  
#                 38.635382    -0.002069     0.011412    -0.031146  
nobs(lm(formula=y_ADF_ur.df_trend_1_lags@testreg[["terms"]]))
# 1718
n_obs <- length(y)-(l+1)
show(n_obs)
# 1718
n_coeffs <- nrow(y_ADF_ur.df_trend_1_lags@testreg[["coefficients"]])
show(n_coeffs)
# 4
df.residual(lm(formula=y_ADF_ur.df_trend_1_lags@testreg[["terms"]])) 
# 1714
df_res <- n_obs-n_coeffs
show(df_res)
# 1714
summary(y_ADF_ur.df_trend_1_lags)
############################################### 
# Augmented Dickey-Fuller Test Unit Root Test # 
###############################################
# Call: lm(formula = z.diff ~ z.lag.1 + 1 + tt + z.diff.lag)
#
# Residuals: Min        1Q    Median        3Q       Max 
#         -0.042499 -0.008419  0.000834  0.008911  0.053910 
# 
# Coefficients:   Estimate  Std. Error t value Pr(>|t|)   
#  (Intercept)  0.45809414  0.15228383   3.008  0.00284 **
#  z.lag.1     -0.05419855  0.01800765  -3.010  0.00283 **
#  tt          -0.00004029  0.00001544  -2.610  0.00950 **
#  z.diff.lag   0.02481454  0.05622742   0.441  0.65928 
#
# Residual standard error: 0.01402 on 315 degrees of freedom
# Multiple R-squared:  0.02805,	Adjusted R-squared:  0.0188 
# F-statistic: 3.031 on 3 and 315 DF,  p-value: 0.02959
#
# Value of test-statistic is: -3.0098 3.1483 4.5458 
#
# Critical values for test statistics: 
#       1pct  5pct 10pct
# tau3 -3.98 -3.42 -3.13
# phi2  6.15  4.71  4.05
# phi3  8.34  6.30  5.36
#
# The null hypothesis cannot be rejected against the three alternatives at the $10\%$ significance level.
# However, to validate the test, we need to check the possible presence of autocorrelation in the residuals of the model used for the test.
y_res <- as.vector(y_ADF_ur.df_trend_1_lags@testreg[["residuals"]])
nobs(lm(formula=y_ADF_ur.df_trend_1_lags@testreg[["terms"]]))
# 1718
max_lag <- ceiling(min(10, n_obs/4))    # Hyndman (for data without seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
show(max_lag)
# 10
n_coeffs <- nrow(y_ADF_ur.df_trend_1_lags@testreg[["coefficients"]])
show(n_coeffs)
# 4
n_pars <- n_coeffs
show(n_pars)
# 4
fit_df <- n_pars
LB_fit_df <- min(min(max_lag, n_pars), max_lag-1)
show(LB_fit_df)
# 4
y_res_LB <- Box.test(y_res, lag=max_lag, fitdf=LB_fit_df, type="Ljung-Box")
show(y_res_LB)
# Box-Ljung test
# data:  y_res
# X-squared = 25.312, df = 6, p-value = 0.0002988
#
FitAR::LjungBoxTest(y_res, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
#  m    Qm      pvalue
#  y_res <- as.vector(y_ADF_ur.df_trend_1_lags@testreg[["residuals"]])
nobs(lm(formula=y_ADF_ur.df_trend_1_lags@testreg[["terms"]]))
# 1718
max_lag <- ceiling(min(10, n_obs/4))    # Hyndman (for data without seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
show(max_lag)
# 10
n_coeffs <- nrow(y_ADF_ur.df_trend_1_lags@testreg[["coefficients"]])
show(n_coeffs)
# 4
n_pars <- n_coeffs
show(n_pars)
# 4
fit_df <- n_pars
LB_fit_df <- min(min(max_lag, n_pars), max_lag-1)
show(LB_fit_df)
# 4
y_res_LB <- Box.test(y_res, lag=max_lag, fitdf=LB_fit_df, type="Ljung-Box")
show(y_res_LB)
# Box-Ljung test
# data:  y_res
# X-squared = 25.312, df = 6, p-value = 0.0002988
#
FitAR::LjungBoxTest(y_res, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
#  m    Qm      pvalue
#  1 0.00 0.9977508
#  2 0.04 0.8422758
#  3 0.04 0.8396476
#  4 0.05 0.8293045
#  5 0.23 0.6327164
#  6 0.36 0.8337131
#  7 0.48 0.9230113
#  8 0.97 0.9148284
#  9 4.16 0.5267992
# 10 5.47 0.4845350
#
y_res <- as.vector(y_ADF_ur.df_trend_1_lags@testreg[["residuals"]])
T <- n_obs
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10, T/4))     # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12, T/5)) # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Aut_Fun_y_res <- TSA::acf(y_res, lag.max=max_lag, type= "correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Aut_Fun_y_res <- data.frame(lag=Aut_Fun_y_res$lag, acf=Aut_Fun_y_res$acf)
# First_Date <- paste(Data_df$Month[1],Data_df$y_resear[1])
# Last_Date <- paste(Data_df$Month[T],Data_df$y_resear[T])
First_Date <- as.character(Data_df$Date[1])
Last_Date <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024", 
                             paste("Autocorrelogram of the Residuals of the Linear Model with AIC-BIC Selected One (1) Lag for the ADF Test for the SP500 Daily Adjusted Close Logarithm from ", .(First_Date), " to ", .(Last_Date))))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ",.(TrnS_length)," sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- Aut_Fun_y_res$lag
x_labs <- format(x_breaks, scientific=FALSE)
Plot_Aut_Fun_y_res <- ggplot(Aut_Fun_y_res, aes(x=lag, y=acf))+
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), linewidth=1, col= "black") +
  # geom_col(mapping=NULL, data=NULL, position= "dodge", width=0.1, col= "black", inherit.aes=TRUE)+
  geom_hline(aes(yintercept=-ci_090, color= "CI_090"), show.legend=TRUE, linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_090, color= "CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color= "CI_95"), show.legend=TRUE, linewidth=0.8, lty=2)+
  geom_hline(aes(yintercept=-ci_95, color= "CI_95"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color= "CI_99"), show.legend=TRUE, linewidth=0.8, lty=4) +
  geom_hline(aes(yintercept=ci_99, color= "CI_99"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name= "acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name= "Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linety_respe=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
# theme(plot.title=element_blank(), 
#       plot.subtitle=element_blank(),
#       plot.caption=element_text(hjust=1.0),
#       legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/aut_res_AIC-BIC_1_lag_log_adj_close.png", width = 1200, height = 600)
plot(Plot_Aut_Fun_y_res)

# Chiudere il dispositivo PNG
dev.off()
plot(Plot_Aut_Fun_y_res)
#
# From the autocorrelogram we have visual evidence for autocorrelation at the $5\%$ significance level. Not at the $1\%$ significance level,
# though. On the other hand, a plot of the residuals shows a clear visual evidence for heteroscedasticity and advocates the robust tests for 
# autocorrelation.
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
length(as.vector(y_ADF_ur.df_trend_1_lags@testreg[["residuals"]]))
# 1711
Data_df <- add_column(Data_df, ADF_Long_lag_y_res=c(rep(NA,10),as.vector(y_ADF_ur.df_trend_9_lags@testreg[["residuals"]])), .after="Adj_Close")
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=ADF_Long_lag_y_res)
TrnS_length <- length(Data_df$Adj_Close)
show(TrnS_length)
# 1720
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Residuals of the Linear Model with AIC-BIC Selected One (1) Lag for the ADF Test on the SP500 Daily Adjusted Close Price Logarithm - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length)
x_breaks_num <- tail(numbers::primeFactors(TrnS_length),n=1)-2 # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[(TrnS_length)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("residuals of the linear model")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_ACPL_TrnS_1_Lags_ADF_res_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA), linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACPL_TrnS_1_Lags_ADF_res_sp.png", width = 1200, height = 600)
plot(spx_ACPL_TrnS_1_Lags_ADF_res_sp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACPL_TrnS_1_Lags_ADF_res_sp)
#
# The line plot
spx_ACPL_TrnS_1_Lags_ADF_res_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="point_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACPL_TrnS_1_Lags_ADF_res_lp.png", width = 1200, height = 600)
plot(spx_ACPL_TrnS_1_Lags_ADF_res_lp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_ACPL_TrnS_1_Lags_ADF_res_lp)
#
y_res <- as.vector(y_ADF_ur.df_trend_1_lags@testreg[["residuals"]])
testcorr::ac.test(y_res, max.lag = 10, alpha = 0.10, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)
# Tests for zero autocorrelation of x
#   | Lag|     AC|  Stand. CB(90%)|  Robust CB(90%)| Lag|      t| p-value| t-tilde| p-value| Lag|     LB| p-value| Q-tilde| p-value|
#   |---:|------:|---------------:|---------------:|---:|------:|-------:|-------:|-------:|---:|------:|-------:|-------:|-------:|
#   |   1|  0.002| (-0.040, 0.040)| (-0.051, 0.051)|   1|  0.093|   0.926|   0.072|   0.942|   1|  0.009|   0.926|   0.005|   0.942|
#   |   2|  0.043| (-0.040, 0.040)| (-0.046, 0.046)|   2|  1.796|   0.073|   1.536|   0.125|   2|  3.242|   0.198|   2.365|   0.307|
#   |   3|  0.003| (-0.040, 0.040)| (-0.043, 0.043)|   3|  0.106|   0.916|   0.098|   0.922|   3|  3.253|   0.354|   2.374|   0.498|
#   |   4|  0.055| (-0.040, 0.040)| (-0.058, 0.058)|   4|  2.297|   0.022|   1.585|   0.113|   4|  8.549|   0.073|   4.196|   0.380|
#   |   5|  0.016| (-0.040, 0.040)| (-0.045, 0.045)|   5|  0.649|   0.516|   0.576|   0.564|   5|  8.972|   0.110|   4.529|   0.476|
#   |   6|  0.021| (-0.040, 0.040)| (-0.042, 0.042)|   6|  0.887|   0.375|   0.832|   0.406|   6|  9.762|   0.135|   5.220|   0.516|
#   |   7| -0.032| (-0.040, 0.040)| (-0.068, 0.068)|   7| -1.324|   0.186|  -0.773|   0.439|   7| 11.524|   0.117|   5.818|   0.561|
#   |   8| -0.033| (-0.040, 0.040)| (-0.041, 0.041)|   8| -1.364|   0.172|  -1.319|   0.187|   8| 13.397|   0.099|   7.557|   0.478|
#   |   9|  0.013| (-0.040, 0.040)| (-0.039, 0.039)|   9|  0.531|   0.595|   0.538|   0.591|   9| 13.681|   0.134|   7.846|   0.550|
#   |  10|  0.035| (-0.040, 0.040)| (-0.042, 0.042)|  10|  1.465|   0.143|   1.385|   0.166|  10| 15.841|   0.104|   9.765|   0.461|
#
# The robust autocorrelation test does not reject the null hypothesis of no autocorrelation at the $10\%$ significance level. Therefore,
# the linear model with one lag for the ADF test appears to be a good combination in terms of model parsimony and lack of autocorrelation
# in the residuals.
#
# Now, we consider the *KPSS* test, which assumes the null hypothesis that the time series can be considered a path of an autoregressive 
# process. In terms of the null hypothesis, the test allows us to specify an autoregressive process with drift, type="mu", or an 
# autoregressive process with drift and linear trend, type="tau".
#   
# Focusing on the type "tau", the *KPSS* test contained in the library *urca*, also allows different possibilities for the number of lags.
# More specifically, we have
#
head(Data_df)
y <- Data_df$Adj_Close_log.
#
y_KPSS_ur_tau_nil <- ur.kpss(y, type="tau", lags="nil")
summary(y_KPSS_ur_tau_nil)
####################### 
# KPSS Unit Root Test # 
####################### 
# Test is of type: tau with 0 lags. 
# Value of test-statistic is: 14.2279 
#
# Critical value for a significance level of: 
#                 10pct  5pct 2.5pct  1pct
# critical values 0.119 0.146  0.176 0.216
y_KPSS_ur_tau_short <- ur.kpss(y, type="tau", lags="short")
summary(y_KPSS_ur_tau_short)
####################### 
# KPSS Unit Root Test # 
####################### 
# Test is of type: tau with 6 lags. 
# Value of test-statistic is: 2.0856 
#
# Critical value for a significance level of: 
#                 10pct  5pct 2.5pct  1pct
# critical values 0.119 0.146  0.176 0.216
y_KPSS_ur_tau_long <- ur.kpss(y, type="tau", lags="long") # the Schwert formula
summary(y_KPSS_ur_tau_long)
####################### 
# KPSS Unit Root Test # 
####################### 
# Test is of type: tau with 19 lags. 
# Value of test-statistic is: 0.7639 
#
# Critical value for a significance level of: 
#                 10pct  5pct 2.5pct  1pct
# critical values 0.119 0.146  0.176 0.216
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
# Given the above results, we consider the SP500 daily adjusted close price differences, the daily logarithm returns, and the daily 
# logarithm return percentage. The latter is usually the standard time series of interest for financial analysts. This is for two
# main reasons: from the economic point of view, it is more convenient to think in terms of percentages, and from the computational point of
# view, computations with too-small values are avoided.
head(spx_df)
tail(spx_df)
spx_df <- add_column(spx_df, Adj_Close_diff.=c(NA,diff(spx_df$Adj_Close, lag=1, difference=1)), .after="Adj_Close")
head(spx_df)
tail(spx_df)
spx_df <- add_column(spx_df, log.ret.=c(NA,diff(spx_df$Adj_Close_log., lag=1, difference=1)), .after="Adj_Close_log.")
head(spx_df)
#Salvo questi dati in un csv, associandoli prima ad un dataframe contenente la coppia <data, rendimento giornaliero logaritmico>

# Creazione del dataframe dei rendimenti giornalieri
returns_data_log <- data.frame(Data_df$Date, Data_df$Adj_Close_log.)

head(returns_data_log)

# Rinomina le colonne del dataframe
colnames(returns_data_log) <- c("data", "rendimento giornaliero log")

# Salva il dataframe nel file "rendimenti.csv"

# Specifica il nome del file con la data corrente (salvo i dati in dowjones-<dataodierna>)
rendimenti_log_file <- paste("rendimentigiornalieriLOG_", format(Sys.Date(), "%d-%m-%Y"), ".csv", sep = "")


#specifico quindi il path completo del file, che parte dalla directory attuale, va in "data", e salva nel csv precedentemente dichiarato.
rendimenti_log_path <- file.path(WD, datafolder, rendimenti_log_file)

write.csv(returns_data_log, rendimenti_log_path, row.names = TRUE)

tail(spx_df)
spx_df <- add_column(spx_df, log.ret.perc.=100*spx_df$log.ret., .after="log.ret.")
head(spx_df)
tail(spx_df)
############################################################################################################################################
# We consider the scatter plot of the SP500 daily adjusted close price differences training set and the test set
Data_df <- spx_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=Adj_Close_diff.)
DS_length <- length(na.rm(Data_df$y))
show(DS_length)
# 1870
TrnS_First_Day <- as.character(Data_df$Date[min(which(!is.na(Data_df$y)))])
show(TrnS_First_Day)
# "2018-04-18"
TrnS_Last_Day <- as.character(as.character(Data_df$Date[position_92-1]))
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 691
TstS_length <- DS_length-TrnS_length
show(TstS_length)
# 151
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(na.rm(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))]))
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Adjusted Close Price Differences - Training and Test Sets - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(TrnS_First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(length-1)
x_breaks_num <- 34 # (deduced from primeFactors(length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily adjusted close price differences (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily adj. close prices - training set")
point_b <- bquote("daily adj. close prices - test set")
line_green <- bquote("regression line (training set)")
line_red <- bquote("LOESS curve (training set)")
leg_point_labs <- c(point_black, point_b)
leg_point_cols <- c("point_black"="black", "point_b"="blue")
leg_point_breaks <- c("point_black", "point_b")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_Adj_Close_diff._TrnS_TstS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_point(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.6, shape=19, na.rm=TRUE) + 
  geom_point(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.6, shape=19, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, 19, NA, NA), linetype=c("blank", "blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACPD_TrnS_TstS_sp.png", width = 1200, height = 600)
plot(spx_Adj_Close_diff._TrnS_TstS_sp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_Adj_Close_diff._TrnS_TstS_sp)
#
# The line plot
spx_Adj_Close_diff._TrnS_TstS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_ACPD_TrnS_TstS_lp.png", width = 1200, height = 600)
plot(spx_Adj_Close_diff._TrnS_TstS_lp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_Adj_Close_diff._TrnS_TstS_lp)
#
# We also consider the scatter plot of the SP500 daily logarithm returns training and test sets.
Data_df <- spx_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc.)
DS_length <- length(na.rm(Data_df$y))
show(DS_length)
# 1870
TrnS_First_Day <- as.character(Data_df$Date[min(which(!is.na(Data_df$y)))])
show(TrnS_First_Day)
# "2018-04-18"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 691
TstS_length <- DS_length-TrnS_length
show(TstS_length)
# 151
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(na.rm(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))]))
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Logarithm Returns - Training and Test Sets - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(TrnS_First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(length-1)
x_breaks_num <- 34 # (deduced from primeFactors(length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily logarithm returns (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily log. ret. (US $) training set")
point_b <- bquote("daily log. ret. (US $) test set")
line_green <- bquote("regression line (training set)")
line_red <- bquote("LOESS curve (training set)")
leg_point_labs <- c(point_black, point_b)
leg_point_cols <- c("point_black"="black", "point_b"="blue")
leg_point_breaks <- c("point_black", "point_b")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_log.ret._TrnS_TstS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_point(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.6, shape=19, na.rm=TRUE) + 
  geom_point(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.6, shape=19, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, 19, NA, NA), linetype=c("blank", "blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_daily_log_ret_TrnS_TstS_sp.png", width = 1200, height = 600)
plot(spx_log.ret._TrnS_TstS_sp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_log.ret._TrnS_TstS_sp)
#
# The line plot
spx_log.ret._TrnS_TstS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_daily_log_ret_TrnS_TstS_lp.png", width = 1200, height = 600)
plot(spx_log.ret._TrnS_TstS_lp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_log.ret._TrnS_TstS_lp)
#
# In the end, we also draw the scatter and line plot of the SP500 daily logarithm return percentages training and test sets.
Data_df <- spx_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc.)
DS_length <- length(na.rm(Data_df$y))
show(DS_length)
# 1870
TrnS_First_Day <- as.character(Data_df$Date[min(which(!is.na(Data_df$y)))])
show(TrnS_First_Day)
# "2018-04-18"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 691
TstS_length <- DS_length-TrnS_length
show(TstS_length)
# 151
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(na.rm(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))]))
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Logarithm Return Percentage - Training and Test Sets - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(TrnS_First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(length-1)
x_breaks_num <- 34 # (deduced from primeFactors(length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily percentage logaarithm returns (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily perc. log. ret. - training set")
point_b <- bquote("daily perc. log. ret. - test set")
line_green <- bquote("regression line (training set)")
line_red <- bquote("LOESS curve (training set)")
leg_point_labs <- c(point_black, point_b)
leg_point_cols <- c("point_black"="black", "point_b"="blue")
leg_point_breaks <- c("point_black", "point_b")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_log.ret.perc_TrnS_TstS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_point(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.6, shape=19, na.rm=TRUE) + 
  geom_point(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.6, shape=19, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, 19, NA, NA), linetype=c("blank", "blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_daily_log_ret_perc_TrnS_TstS_sp.png", width = 1200, height = 600)
plot(spx_log.ret.perc_TrnS_TstS_sp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_log.ret.perc_TrnS_TstS_sp)
#
# The line plot
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Logarithm Return Percentage - Training and Test Sets - from ", .(First_Day), " to ", .(Last_Day), sep="")))
spx_log.ret.perc_TrnS_TstS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_daily_log_ret_perc_TrnS_TstS_lp.png", width = 1200, height = 600)
plot(spx_log.ret.perc_TrnS_TstS_lp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_log.ret.perc_TrnS_TstS_lp)
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
# We focus on the analysis of the SP500 daily logarithm return percentage.
# We consider again the data frame containing only the training set data.
spx_train_df <- spx_df[1:position_92-1,]
head(spx_train_df)
tail(spx_train_df)
#
# From the scatter and line plot, the stationarity in the mean of the SP500 daily logarithm return percentage time series looks pretty
# evident. It also seems to be evident that the time series is conditionally heteroscedastic. However, we check the heteroscedasticity by
# applying the Breusch-Pagan and White test.
# We start with introducing the linear model used for the Breusch-Pagan test.
Data_df <- spx_train_df
head(Data_df)
y <- na.rm(Data_df$log.ret.perc.)
x <- 1:length(y)
BP_lm <- lm(y~x)
BP_lm_res <- BP_lm[["residuals"]]
#
# We consider the possible heteroscedasticity of the residuals in the linear model used for the Breusch-Pagan test.
def_mar <- par("mar")
par(mfrow=c(2,1), mar=c(1,1,1,1))
plot(BP_lm,1)
plot(BP_lm,3)
par(mfrow=c(1,1), mar=def_mar)
#
# From the Residuals vs Fitted plot, we do not have visual evidence for heteroscedasticity in the residuals. The LOESS curve appears to be 
# flat and the spread of the residuals around the LOESS curve appears to be rather homogeneous. The visual evidence from the Scale-Location
# plot essentially confirms the visual evidence from the Residual vs Fitted plot: an almost flat horizontal LOESS curve (but not as flat as
# the LOESS of the Residuals vs Fitted plot) suggests the absence of non linear forms of heteroscedasticity in the residual time series. 
# However, from the Scale-Location plot we have also visual evidence for conditional heteroscedasticity: the points with similar spread 
# around the LOESS curve appears often very close to each other.
# 
# We check the kurtosis of the residuals in the linear model used for the Breusch-Pagan test.
# library(DescTools)
DescTools::Kurt(BP_lm_res, weights=NULL, method=2, conf.level=0.99, ci.type="classic") 
#   kurtosis    lwr.ci    upr.ci
#  16.0928885 -0.3039169  0.3039169 
#
# The estimated value of the excess kurtosis of the standardized residuals of the estimated GARCH(1,1) model severely conflicts with a 
# possible Gaussian distribution of the residuals at the $1\%$ significance level. We proceed with other non-parametric tests
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.95, ci.type="norm", R=5000) 
#   kurt      lwr.ci    upr.ci 
# 16.092889 -1.491741 37.082153 
#
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.95, ci.type="basic", R=5000) 
#   kurt      lwr.ci    upr.ci 
# 16.092889 -1.030256 29.549973 
#
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="perc", R=5000) 
#   kurt      lwr.ci    upr.ci 
# 16.092889  2.353563 37.370565 
# 
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="bca", R=5000) 
#   kurt      lwr.ci    upr.ci 
# 16.092889  2.765649 44.163968 
# Warning message: In norm.inter(t, adj.alpha) : extreme order statistics used as endpoints
#
set.seed(23451)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="bca", R=50000)
#   kurt     lwr.ci   upr.ci 
# 16.09289  2.79176 46.63326  
# Warning message: In norm.inter(t, adj.alpha) : extreme order statistics used as endpoints
#
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.95, ci.type="bca", R=5000) 
#   kurt      lwr.ci    upr.ci 
# 16.092889  2.927865 40.981653
#
# The bootstrapped confidence intervals of type "norm" and "basic" at the $95\%$ [resp. $99\%$] confidence level does contain zero. Hence, 
# we cannot reject the null hypothesis of mesokurtic residuals in the linear model for the Breusch-Pagan test at the $5\%$ significance 
# level. On the other hand, the $99\%$ bootstrapped confidence intervals of type "perc" and "bca" do not contain zero (the $99\%$ confidence
# intervals of type "bca" use extreme order statistics as endpoints, though) and so does the $95\%$ bootstrapped confidence interval of type
# "bca". Therefore, referring to these confidence intervals, we must reject the null hypothesis of mesokurtic residuals in the linear model 
# for the Breusch-Pagan test at least the $5\%$ significance level. 
# In light of this, we execute the Breusch-Pagan and White test in the Koenker (studentised) modification.
#
# library(lmtest)
lmtest::bptest(BP_lm, varformula=NULL, studentize=TRUE, data=NULL)
# studentized Breusch-Pagan test
# data:  BP_lm
# BP = 0.018308, df = 1, p-value = 0.8924
#
# library(skedastic)
skedastic::breusch_pagan(BP_lm, koenker=TRUE)
# statistic  p.value  parameter       method         alternative
#   0.0183    0.892      1    Koenker (studentised)    greater     
#
# library(olsrr)
olsrr::ols_test_score(BP_lm, fitted_values=TRUE, rhs=FALSE)
# Score Test for Heteroskedasticity
# ---------------------------------
#   Ho: Variance is homogenous
#   Ha: Variance is not homogenous
# 
# Variables: fitted values of y 
# Test Summary          
# -----------------------------
# DF           =   1 
# Chi2         =   0.01830807 
# Prob > Chi2  =   0.8923689 
#
# Confirming the visual evidence from the Residuals vs Fitted plot, we cannot reject the null of homoscedasticity at the %10\%$ significance
# level. 
# We consider the White test.
#
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
y <- na.rm(Data_df$log.ret.perc.)
x <- 1:length(y)
W_lm <- lm(y~x+I(x^2))
#
lmtest::bptest(BP_lm, W_lm, studentize=TRUE, data=NULL)
# studentized Breusch-Pagan (White) test
# data: BP_lm, W_lm
# BP = 3.314, df = 2, p-value = 0.1907
#
#
lmtest::bptest(y~x, y~x+I(x^2), studentize=TRUE, data=NULL)
# studentized Breusch-Pagan (White) test
# data:  y ~ x
# BP = 3.314, df = 2, p-value = 0.1907
#
#
skedastic::white(BP_lm, interactions=FALSE, statonly=FALSE)
# statistic  p.value  parameter       method    alternative
#    3.31     0.191      2         White's Test   greater    
#
# library(whitestrap)
whitestrap::white_test(BP_lm)
# White's test results
# Null hypothesis: Homoskedasticity of the residuals
# Alternative hypothesis: Heteroskedasticity of the residuals
# Test Statistic: 3.31
# P-value: 0.190708
#
# The White test cannot reject the null of homoscedasticity at the $10\%$ significance level.
#
# Autocorrelogram of the training set of the SP500 daily logarithm return percentage.
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
# Aut_Fun_y <- stats::acf(y, lag.max=max_lag, type="correlation", plot=FALSE)
Aut_Fun_y <- TSA::acf(y, lag.max=max_lag, type="correlation", plot=TRUE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Aut_Fun_y <- data.frame(lag=Aut_Fun_y$lag, acf=Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Autocorrelogram of the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
ggplot(Plot_Aut_Fun_y, aes(x=lag, y=acf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), lwd=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
#
# The autocorrelogram provides visual evidence for autocorrelation at the $5\%$ significance level, but no evidence for autocorrelation 
# at the $1\%$ significance level.
#
# Partial autocorrelogram of the training set of the SP500 daily logarithm return percentage.
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Part_Aut_Fun_y <- stats::pacf(y, lag.max=max_lag, type="correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Part_Aut_Fun_y <- data.frame(lag=Part_Aut_Fun_y$lag, pacf=Part_Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Partial Autocorrelogram of the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
ggplot(Plot_Part_Aut_Fun_y, aes(x=lag, y=pacf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=pacf), size=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="pacf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
#
# The partial autocorrelogram also provides visual evidence for autocorrelation at the $5\%$ significance level, but no evidence for 
# autocorrelation at the $1\%$ significance level.
#RIGA 4274
#
# We consider the Ljung-Box test
# Ljung-Box test
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
T <- length(y)
show(T)
max_lag <- ceiling(min(10,T/4)) # Hyndman - https://robjhyndman.com/hyndsight/ljung-box-test/
show(max_lag)
# 10
n_pars <- 0
show(n_pars)
# 0
fit_df <- n_pars
#
FitAR::LjungBoxTest(y, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
#  m    Qm      pvalue
#  1  5.54 0.018582786
#  2  9.27 0.009722311
#  3  9.29 0.025663343
#  4 14.28 0.006455679
#  5 14.48 0.012853974
#  6 15.38 0.017526176
#  7 17.28 0.015668649
#  8 19.02 0.014738216
#  9 19.25 0.023154683
# 10 21.23 0.019559448
#
# WE also consider the Breusch-Godfrey test applied on the fictitious linear regression.
lmtest::bgtest(lm(y~1), order=10, type="Chisq")
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  lm(y ~ 1)
# LM test = 9.536, df = 10, p-value = 0.4821
#
# Note that the Breusch-Godfrey test statistic and p-value are very close to the Ljung-Box statistic and p-value.
#
# The Ljung-Box and  Breusch-Godfrey tests confirm the rejection of the null hypothesis of no autocorrelation in the SP500 daily logarithm 
# return percentage at the $5\%$ significance level and the non-rejection of the null hypothesis at the the $1\%$ significance level. In this
# case, since there are zero degrees of freedom fitted by the model, the robust version of the autocorrelation test can be fully considered 
# in both the confidence bands determination and the computational results. 
testcorr::ac.test(y, max.lag = 10, alpha = 0.05, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)
# Tests for zero autocorrelation of x
#  | Lag|     AC|  Stand. CB(95%)|  Robust CB(95%)| Lag|      t| p-value| t-tilde| p-value| Lag|    LB| p-value| Q-tilde| p-value|
#  |---:|------:|---------------:|---------------:|---:|------:|-------:|-------:|-------:|---:|-----:|-------:|-------:|-------:|
#  |   1|  0.011| (-0.075, 0.075)| (-0.087, 0.087)|   1|  0.280|   0.780|   0.239|   0.811|   1| 0.079|   0.779|   0.057|   0.811|
#  |   2| -0.046| (-0.075, 0.075)| (-0.089, 0.089)|   2| -1.216|   0.224|  -1.023|   0.306|   2| 1.567|   0.457|   1.103|   0.576|
#  |   3| -0.018| (-0.075, 0.075)| (-0.095, 0.095)|   3| -0.479|   0.632|  -0.376|   0.707|   3| 1.798|   0.615|   1.244|   0.742|
#  |   4| -0.003| (-0.075, 0.075)| (-0.091, 0.091)|   4| -0.087|   0.931|  -0.071|   0.943|   4| 1.806|   0.771|   1.249|   0.870|
#  |   5|  0.001| (-0.075, 0.075)| (-0.092, 0.092)|   5|  0.024|   0.981|   0.019|   0.985|   5| 1.806|   0.875|   1.250|   0.940|
#  |   6| -0.036| (-0.075, 0.075)| (-0.096, 0.096)|   6| -0.948|   0.343|  -0.739|   0.460|   6| 2.715|   0.844|   1.796|   0.937|
#  |   7|  0.012| (-0.075, 0.075)| (-0.090, 0.090)|   7|  0.309|   0.757|   0.256|   0.798|   7| 2.812|   0.902|   1.861|   0.967|
#  |   8| -0.022| (-0.075, 0.075)| (-0.090, 0.090)|   8| -0.574|   0.566|  -0.473|   0.636|   8| 3.146|   0.925|   2.085|   0.978|
#  |   9|  0.080| (-0.075, 0.075)| (-0.097, 0.097)|   9|  2.100|   0.036|   1.616|   0.106|   9| 7.627|   0.572|   4.697|   0.860|
#  |  10| -0.046| (-0.075, 0.075)| (-0.092, 0.092)|  10| -1.219|   0.223|  -0.987|   0.324|  10| 9.140|   0.519|   5.671|   0.842|
#
# From the robust autocorrelation tests, we obtain the non-rejection of the null hypothesis of no autocorrelation in the SP500 daily
# logarithm return percentage at the $5\%$ significance level.
############################################################################################################################################
# We consider also the mean of the logarithm return percentage
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
mean(y)
# 0.04299637
# We wonder whether the mean is significantly different from zero. To this we determine the bootstrapped confidence intervals.
d <- data.frame(k=1:length(y), y=y)
head(d)
boot_mean <- function(d, k){
  d2 <- d[k,]
  return(mean(d2$y))
}
boot_mean(d)
# 0.04299637
# turn off set.seed() if you want the results to vary
# library(boot)
set.seed(12345)
booted_mean <- boot::boot(d, boot_mean, R=5000)
class(booted_mean)
show(booted_mean)
# ORDINARY NONPARAMETRIC BOOTSTRAP
# Call: boot(data=d, statistic=boot_mean, R=5000)
# Bootstrap Statistics : original        bias     std. error
#                    t1* 0.04299637 -0.002449327  0.09017207
#
summary(booted_mean)
#    R   original      bootBias     bootSE    bootMed
# 1 5000 0.042996    -0.0024493    0.090172   0.03956
#
mean(booted_mean$t) - booted_mean$t0
# -0.002449327
sd(booted_mean$t)
# 0.09017207
plot(booted_mean)
#
booted_mean.ci <- boot.ci(boot.out=booted_mean, conf=0.80, type=c("norm", "basic", "perc", "bca"))
show(booted_mean.ci)
# 
# BOOTSTRAP CONFIDENCE INTERVAL CALCULATIONS
# Based on 5000 bootstrap replicates
# CALL:  boot.ci(boot.out=booted_mean, conf=0.8, type=c("norm", "basic", "perc", "bca"))
# Intervals: Level      Normal                 Basic         
#             80%   (-0.0701,  0.1610)   (-0.0722,  0.1609)  
#            Level     Percentile               BCa          
#             80%   (-0.0749,  0.1582)   (-0.0695,  0.1631)  
# Calculations and Intervals on Original Scale
#
# In light of the results of the t-test and the bootstrap confidence intervals we cannot reject the null hypothesis that the true value
# of the mean of logarithm returns is zero at the $20\%$ significance level.
#
# We consider the Ljung-Box test for the daily squared logarithm return percentage. In the packages *FitAR* and *portes*, the tests can be
# executed on the logarithm return percentage themselves, just selecting the option *SquaredQ=TRUE* or *sqrd.res=TRUE*, respectively.
FitAR::LjungBoxTest(y, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=TRUE)
#  m    Qm        pvalue
#  1  5.56 0.01842002967
#  2  6.55 0.03783450484
#  3  6.71 0.08170002948
#  4 12.89 0.01184228888
#  5 13.34 0.02035306778
#  6 13.54 0.03518761614
#  7 34.01 0.00001716910
#  8 34.04 0.00004003634
#  9 34.04 0.00008804084
# 10 34.11 0.00017668790
#
# Autocorrelogram of the training set of the SP500 daily squared logarithm return percentage.
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
y <- y^2
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
# Aut_Fun_y <- stats::acf(y, lag.max=max_lag, type="correlation", plot=FALSE)
Aut_Fun_y <- TSA::acf(y, lag.max=max_lag, type="correlation", plot=TRUE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Aut_Fun_y <- data.frame(lag=Aut_Fun_y$lag, acf=Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Autocorrelogram of the SP500 Daily Squared Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
ggplot(Plot_Aut_Fun_y, aes(x=lag, y=acf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), lwd=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
#
# The autocorrelogram provides visual evidence for autocorrelation at the $1\%$ significance level.
#
# Partial autocorrelogram of the training set of the SP500 daily squared logarithm return percentage.
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
y <- y^2
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Part_Aut_Fun_y <- stats::pacf(y, lag.max=max_lag, type="correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Part_Aut_Fun_y <- data.frame(lag=Part_Aut_Fun_y$lag, pacf=Part_Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Partial Autocorrelogram of the SP500 Daily Squared Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
ggplot(Plot_Part_Aut_Fun_y, aes(x=lag, y=pacf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=pacf), size=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="pacf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
#
# The partial autocorrelogram also provides visual evidence for autocorrelation at the $1\%$ significance level.
# We plot the daily squared logarithm return percentage.
Data_df <- spx_df
head(Data_df)
tail(Data_df)
Data_df <- add_column(Data_df, sqrd.log.ret.perc.=Data_df$log.ret.perc.^2, .after="log.ret.perc.")
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=sqrd.log.ret.perc.)
head(Data_df)
DS_length <- length(na.rm(Data_df$y))
show(DS_length)
# 1870
TrnS_First_Day <- as.character(Data_df$Date[min(which(!is.na(Data_df$y)))])
show(TrnS_First_Day)
# "2018-04-18"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 691
TstS_length <- DS_length-TrnS_length
show(TstS_length)
# 151
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(na.rm(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))]))
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Squared Logarithm Return Percentage - Training and Test Sets - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(TrnS_First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(length-1)
x_breaks_num <- 34 # (deduced from primeFactors(length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily squared logarithm return percentage")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily perc. log. ret. - training set")
point_b <- bquote("daily perc. log. ret. - test set")
line_green <- bquote("regression line (training set)")
line_red <- bquote("LOESS curve (training set)")
leg_point_labs <- c(point_black, point_b)
leg_point_cols <- c("point_black"="black", "point_b"="blue")
leg_point_breaks <- c("point_black", "point_b")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_sqrd.log.ret.perc_TrnS_TstS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_point(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.6, shape=19, na.rm=TRUE) + 
  geom_point(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.6, shape=19, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, 19, NA, NA), linetype=c("blank", "blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_daily_sqrd_log_ret_perc_TrnS_TstS_sp.png", width = 1200, height = 600)
plot(spx_sqrd.log.ret.perc_TrnS_TstS_sp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_sqrd.log.ret.perc_TrnS_TstS_sp)
#
# The line plot
spx_sqrd.log.ret.perc_TrnS_TstS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_daily_sqrd_log_ret_perc_TrnS_TstS_lp.png", width = 1200, height = 600)
plot(spx_sqrd.log.ret.perc_TrnS_TstS_lp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_sqrd.log.ret.perc_TrnS_TstS_lp)
#RIGA 4666
# Due to the quite evident presence of conditional heteroscedasticity in the daily squared logarithm return percentage, we consider the
# robust autocorrelation tests
Data_df <- dplyr::rename(Data_df, t=x, sqrd.log.ret.perc.=y)
y <- na.rm(Data_df$sqrd.log.ret.perc.)
testcorr::ac.test(y, max.lag = 10, alpha = 0.05, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)
# Tests for zero autocorrelation of x
#   | Lag|    AC|  Stand. CB(95%)|  Robust CB(95%)| Lag|     t| p-value| t-tilde| p-value| Lag|     LB| p-value| Q-tilde| p-value|
#   |---:|-----:|---------------:|---------------:|---:|-----:|-------:|-------:|-------:|---:|------:|-------:|-------:|-------:|
#   |   1| 0.059| (-0.045, 0.045)| (-0.081, 0.081)|   1| 2.542|   0.011|   1.431|   0.152|   1|  6.472|   0.011|   2.047|   0.152|
#   |   2| 0.025| (-0.045, 0.045)| (-0.027, 0.027)|   2| 1.079|   0.281|   1.788|   0.074|   2|  7.638|   0.022|   5.245|   0.073|
#   |   3| 0.011| (-0.045, 0.045)| (-0.015, 0.015)|   3| 0.459|   0.646|   1.429|   0.153|   3|  7.850|   0.049|   7.286|   0.063|
#   |   4| 0.061| (-0.045, 0.045)| (-0.060, 0.060)|   4| 2.658|   0.008|   2.003|   0.045|   4| 14.937|   0.005|  11.297|   0.023|
#   |   5| 0.018| (-0.045, 0.045)| (-0.016, 0.016)|   5| 0.772|   0.440|   2.236|   0.025|   5| 15.536|   0.008|  16.295|   0.006|
#   |   6| 0.013| (-0.045, 0.045)| (-0.020, 0.020)|   6| 0.548|   0.584|   1.235|   0.217|   6| 15.837|   0.015|  17.821|   0.007|
#   |   7| 0.110| (-0.045, 0.045)| (-0.184, 0.184)|   7| 4.764|   0.000|   1.174|   0.240|   7| 38.643|   0.000|  19.200|   0.008|
#   |   8| 0.006| (-0.045, 0.045)| (-0.018, 0.018)|   8| 0.249|   0.804|   0.636|   0.525|   8| 38.705|   0.000|  19.604|   0.012|
#   |   9| 0.001| (-0.045, 0.045)| (-0.017, 0.017)|   9| 0.027|   0.978|   0.074|   0.941|   9| 38.706|   0.000|  19.610|   0.020|
#   |  10| 0.008| (-0.045, 0.045)| (-0.017, 0.017)|  10| 0.356|   0.722|   0.953|   0.340|  10| 38.833|   0.000|  20.518|   0.025|
# 
# The robust tests confirm the presence of autocorrelation in the daily squared logarithm return percentage.
# Note that some authors choose to consider the absolute logarithm return percentage, rather than the squared logarithm return percentage.
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
FitAR::LjungBoxTest(abs(y), k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
#  m     Qm             pvalue
#  1  26.60 0.0000002507643296
#  2  40.26 0.0000000018138009
#  3  48.39 0.0000000001757383
#  4  85.28 0.0000000000000000
#  5  98.03 0.0000000000000000
#  6 112.28 0.0000000000000000
#  7 149.92 0.0000000000000000
#  8 161.47 0.0000000000000000
#  9 165.41 0.0000000000000000
# 10 168.59 0.0000000000000000
#
# Autocorrelogram of the training set of the SP500 daily absolute logarithm return percentage.
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
y <- abs(y)
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
# Aut_Fun_y <- stats::acf(y, lag.max=max_lag, type="correlation", plot=FALSE)
Aut_Fun_y <- TSA::acf(y, lag.max=max_lag, type="correlation", plot=TRUE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Aut_Fun_y <- data.frame(lag=Aut_Fun_y$lag, acf=Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Autocorrelogram of the SP500 Daily Absolute Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
plot_aut_fun_y <- ggplot(Plot_Aut_Fun_y, aes(x=lag, y=acf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), linewidth=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), linewidth=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), linewidth=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), linewidth=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), linewidth=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), linewidth=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), linewidth=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")

# Mostra il grafico nella scheda Plots
print(plot_aut_fun_y)

ggsave("plots/spx_aut_DALRP.png", plot = plot_aut_fun_y, width = 12, height = 6)

#
# The autocorrelogram yields visual evidence for autocorrelation at the $1\%$ significance level.
# Partial autocorrelogram of the training set of the SP500 daily absolute logarithm return percentage.
Data_df <- spx_train_df
y <- na.rm(Data_df$log.ret.perc.)
y <- abs(y)
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Part_Aut_Fun_y <- stats::pacf(y, lag.max=max_lag, type="correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Part_Aut_Fun_y <- data.frame(lag=Part_Aut_Fun_y$lag, pacf=Part_Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Partial Autocorrelogram of the SP500 Daily Absolute Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
plot_part_aut_fun_y <- ggplot(Plot_Part_Aut_Fun_y, aes(x=lag, y=pacf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=pacf), size=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="pacf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")

# Mostra il grafico nella scheda Plots
print(plot_part_aut_fun_y)

ggsave("plots/spx_part_aut_DALRP.png", plot = plot_part_aut_fun_y, width = 12, height = 6)
#
# The partial autocorrelogram also yields visual evidence for autocorrelation at the $1\%$ significance level.
#
# We plot the SP500 daily squared absolute logarithm return percentage.
Data_df <- spx_df
head(Data_df)
tail(Data_df)
Data_df <- add_column(Data_df, abs.log.ret.perc.=abs(Data_df$log.ret.perc.), .after="log.ret.perc.")
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=abs.log.ret.perc.)
head(Data_df)
DS_length <- length(na.rm(Data_df$y))
show(DS_length)
# 1870
TrnS_First_Day <- as.character(Data_df$Date[min(which(!is.na(Data_df$y)))])
show(TrnS_First_Day)
# "2018-04-18"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 691
TstS_length <- DS_length-TrnS_length
show(TstS_length)
# 151
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(na.rm(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))]))
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Absolute Logarithm Return Percentage - Training and Test Sets - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(TrnS_First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(length-1)
x_breaks_num <- 34 # (deduced from primeFactors(length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily absolute pergentage logarithm returns (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily perc. log. ret. - training set")
point_b <- bquote("daily perc. log. ret. - test set")
line_green <- bquote("regression line (training set)")
line_red <- bquote("LOESS curve (training set)")
leg_point_labs <- c(point_black, point_b)
leg_point_cols <- c("point_black"="black", "point_b"="blue")
leg_point_breaks <- c("point_black", "point_b")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_abs.log.ret.perc_TrnS_TstS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_point(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.6, shape=19, na.rm=TRUE) + 
  geom_point(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.6, shape=19, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, 19, NA, NA), linetype=c("blank", "blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")

png("plots/spx_abs_log_ret_perc_TrnS_TstS_sp.png", width = 1200, height = 600)
plot(spx_abs.log.ret.perc_TrnS_TstS_sp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_abs.log.ret.perc_TrnS_TstS_sp)
#
# The line plot
spx_abs.log.ret.perc_TrnS_TstS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_vline(xintercept=Data_df$x[TrnS_length], lwd=0.5, color="black") +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", 
              method="lm" , formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_smooth(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", 
              method="loess", formula=y ~ x, se=FALSE, na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x<=x[TrnS_length]), aes(y=y, color="point_black"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  geom_line(data=subset(Data_df, Data_df$x>x[TrnS_length]), aes(y=y, color="point_b"), alpha=1, size=0.5, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_daily_abs_log_ret_perc_TrnS_TstS_lp.png", width = 1200, height = 600)
plot(spx_abs.log.ret.perc_TrnS_TstS_lp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_abs.log.ret.perc_TrnS_TstS_lp)
#
# Due to the quite evident presence of conditional heteroscedasticity in the daily absolute logarithm return percentage, we consider the
# robust autocorrelation tests
Data_df <- dplyr::rename(Data_df, t=x, abs.log.ret.perc.=y)
y <- na.rm(Data_df$abs.log.ret.perc.)
testcorr::ac.test(y, max.lag = 10, alpha = 0.10, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)
# Tests for zero autocorrelation of x
#   | Lag|    AC|  Stand. CB(90%)|  Robust CB(90%)| Lag|     t| p-value| t-tilde| p-value| Lag|      LB| p-value| Q-tilde| p-value|
#   |---:|-----:|---------------:|---------------:|---:|-----:|-------:|-------:|-------:|---:|-------:|-------:|-------:|-------:|
#   |   1| 0.132| (-0.038, 0.038)| (-0.062, 0.062)|   1| 5.692|   0.000|   3.504|   0.000|   1|  32.452|   0.000|  12.278|   0.000|
#   |   2| 0.093| (-0.038, 0.038)| (-0.045, 0.045)|   2| 4.026|   0.000|   3.389|   0.001|   2|  48.692|   0.000|  23.766|   0.000|
#   |   3| 0.068| (-0.038, 0.038)| (-0.037, 0.037)|   3| 2.955|   0.003|   3.066|   0.002|   3|  57.447|   0.000|  33.168|   0.000|
#   |   4| 0.150| (-0.038, 0.038)| (-0.058, 0.058)|   4| 6.492|   0.000|   4.228|   0.000|   4|  99.730|   0.000|  51.045|   0.000|
#   |   5| 0.090| (-0.038, 0.038)| (-0.040, 0.040)|   5| 3.872|   0.000|   3.727|   0.000|   5| 114.780|   0.000|  64.937|   0.000|
#   |   6| 0.097| (-0.038, 0.038)| (-0.041, 0.041)|   6| 4.202|   0.000|   3.853|   0.000|   6| 132.516|   0.000|  74.314|   0.000|
#   |   7| 0.148| (-0.038, 0.038)| (-0.082, 0.082)|   7| 6.399|   0.000|   2.959|   0.003|   7| 173.664|   0.000|  83.070|   0.000|
#   |   8| 0.086| (-0.038, 0.038)| (-0.040, 0.040)|   8| 3.705|   0.000|   3.557|   0.000|   8| 187.467|   0.000|  92.504|   0.000|
#   |   9| 0.052| (-0.038, 0.038)| (-0.037, 0.037)|   9| 2.244|   0.025|   2.313|   0.021|   9| 192.531|   0.000|  97.855|   0.000|
#   |  10| 0.051| (-0.038, 0.038)| (-0.036, 0.036)|  10| 2.219|   0.027|   2.369|   0.018|  10| 197.485|   0.000| 103.468|   0.000|
# 
# The robust tests confirm the presence of autocorrelation in the SP500 daily absolute logarithm return percentage at the $1\%$ 
# significance level.
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
# Thanks to the non-rejection of the null of no autocorrelation at the $5\%$ significance level in the SP500 daily percentage logarithm 
# returns and the rejection of the null of no autocorrelation in the squared and absolute logarithm return percentage at the $5\%$ and 
# $1\%$ significance levels, respectively, we can consider an GARCH model for the SP500 daily logarithm return percentage. To this, we
# will use the two popular packages, *tseries* (Trapletti and Hornik, 2018) and *fGarch* (Wuertz and Chalabi, 2016) 
# (see https://cran.r-project.org/web/packages/tseries/tseries.pdf and https://cran.r-project.org/web/packages/fGarch/fGarch.pdf), 
# in which the estimation of the GARCH model is treated, showing similarities and differences, for a better understanding of their use.
# (see also  https://www.math.pku.edu.cn/teachers/heyb/TimeSeries/lectures/garch.pdf). In a forthcoming developments of these notes we will
# introduce also the package *rugarch* (Ghalanos, 2017) (see https://cran.r-project.org/web/packages/rugarch/rugarch.pdf, and
# https://cran.r-project.org/web/packages/rugarch/vignettes/Introduction_to_the_rugarch_package.pdf). In the end, we refer to  
# https://www.erfin.org/journal/index.php/erfin/article/download/64/40/ for a survey on all the above packages.
# 
#RIGA 4989
# Let us start with the *tseries* package.
# library(tseries)
# library(crayon)
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
y <- na.rm(Data_df$log.ret.perc.)
head(y)
# 3.2535928  1.5906496  6.4376485  0.5608363 -1.0523309  1.4483698
T <- length(y)
show(T)
# 691
cons <- file("tseries_GARCH_log.ret.perc_fit.log")
sink(cons, append=TRUE, type=c("output","message"), split=TRUE)
GARCH_log.ret.perc. <-list() # Initializing an empty list where to save the candidate GARCH(p,q) models on varying of the parameters p and q.
cn <- 1                     # Setting a counter to identify the model                              
for (p in 1:3){             # Looping over p
  for(q in 1:3){            # Looping over p
    # ERROR and WARNINGS HANDLING
    tryCatch({
      GARCH_log.ret.perc.[[cn]] <- tseries::garch(y, order=c(p,q), series=NULL, coef=NULL, maxiter=200,
                                                  grad="analytical", trace=TRUE, eps=NULL, 
                                                  abstol=max(1e-20, .Machine$double.eps^2),
                                                  reltol=max(1e-10, .Machine$double.eps^(2/3)), 
                                                  xtol=sqrt(.Machine$double.eps),
                                                  falsetol=1e2 * .Machine$double.eps)
      show(GARCH_log.ret.perc.[[cn]])
      cn <- cn+1
      cat("  \n","  \n")
    }, error=function(e){
      cat(red(sprintf("caught Error: %s", e)))
      cat(red("GARCH parameter p=", p), red("GARCH parameter q=", q))
      cat("\n")
      traceback(1, max.lines=1)
      cat("  \n","  \n")
    }, warning=function (w){
      cat(yellow(sprintf("caught Warning: %s", w)))
      cat(yellow("GARCH parameter p=", p), yellow("GARCH parameter q=", q))
      cat("\n")
      traceback(1, max.lines=1)
      cat("  \n","  \n")
    }
    )
  }
}
closeAllConnections()
# Note that the estimation procedure does not always succeed in converging. Opening the file "tseries_GARCH_log.ret.perc_fit.log" generated
# by the estimation procedure, we can see that we have got seven ** FALSE CONVERGENCE ** messages, one ** RELATIVE FUNCTION CONVERGENCE **
# message and one ** X- AND RELATIVE FUNCTION CONVERGENCE ** message. This binds the choice of the model. However, to present the general
# model selection procedure, we ignore the ** FALSE CONVERGENCE ** message. Hence, for each of the estimated models we compute the AIC and
# BIC.
#
# Preliminary, we extract the likelihood and the order from each model 
GARCH_log.ret.perc_Likeli <- sapply(GARCH_log.ret.perc., function(x) x$n.likeli)
show(GARCH_log.ret.perc_Likeli)
# 3073.048 3070.467 3085.484 3071.646 3107.232 3100.889 3101.715 3100.151 3096.016
#
GARCH_log.ret.perc_order <- sapply(GARCH_log.ret.perc., function(x) x$order)
show(GARCH_log.ret.perc_order)
#      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9]
#  p    1    1    1    2    2    2    3    3    3
#  q    1    2    3    1    2    3    1    2    3
#
# Hence, we compute the AIC and sort the model counters according the decreasing AIC
GARCH_log.ret.perc_AIC <- 2*colSums(GARCH_log.ret.perc_order)-log(GARCH_log.ret.perc_Likeli^2)
show(GARCH_log.ret.perc_AIC)
# -12.060851 -10.059170  -8.068927 -10.059938  -8.082975  -6.078888  -8.079421  -6.078412  -4.075743
#
GARCH_log.ret.perc_sort_AIC <- sort(GARCH_log.ret.perc_AIC, decreasing=FALSE)
show(GARCH_log.ret.perc_sort_AIC)
# -12.060851 -10.059938 -10.059170  -8.082975  -8.079421  -8.068927  -6.078888  -6.078412  -4.075743
#
GARCH_log.ret.perc_incr_AIC <- match(GARCH_log.ret.perc_AIC, GARCH_log.ret.perc_sort_AIC)
show(GARCH_log.ret.perc_incr_AIC)
# 1 3 6 2 4 7 5 8 9
#
# We compute the BIC and sort the model counters according the decreasing BIC
GARCH_log.ret.perc_BIC <- log(T)*colSums(GARCH_log.ret.perc_order)-log(GARCH_log.ret.perc_Likeli^2)
show(GARCH_log.ret.perc_BIC)
# -1.161855  6.289324 13.729065  6.288556 13.715017 21.168602 13.718571 21.169078 28.621245
#
GARCH_log.ret.perc_sort_BIC <- sort(GARCH_log.ret.perc_BIC, decreasing=FALSE)
show(GARCH_log.ret.perc_sort_BIC)
# -1.161855  6.288556  6.289324 13.715017 13.718571 13.729065 21.168602 21.169078 28.621245
#
GARCH_log.ret.perc_incr_BIC <- match(GARCH_log.ret.perc_BIC, GARCH_log.ret.perc_sort_BIC)
show(GARCH_log.ret.perc_incr_BIC)
# 1 3 6 2 4 7 5 8 9
#
# Note that, in the case considered, sorting according to the AIC or BIC produces the same result.
# Now, we estimate again the sorted models until we find the first for which the estimation procedure converges.
# We start by checking the estimation procedure for the model of counter cn=1.
cn_sort_AIC <- GARCH_log.ret.perc_incr_AIC # Setting a counter according to increasing AIC.
show(cn_sort_AIC)
# 1 3 6 2 4 7 5 8 9
#
y <- na.rm(Data_df$log.ret.perc.)
garch.control <- tseries::garch.control(trace=TRUE, start=NULL,  coef=NULL, maxiter=200, grad="analytical",  eps=NULL, abstol=max(1e-20, 
                                                                                                                                  .Machine$double.eps^2), reltol=max(1e-10, .Machine$double.eps^(2/3)), xtol=sqrt(.Machine$double.eps),
                                        falsetol=1e2*.Machine$double.eps)
tseries::garch(y, order=c(GARCH_log.ret.perc.[[cn_sort_AIC[1]]]$order[1], GARCH_log.ret.perc.[[cn_sort_AIC[1]]]$order[2]), series=NULL,
               control=garch.control)
# ***** ESTIMATION WITH ANALYTICAL GRADIENT ***** 
#   I     INITIAL X(I)        D(I)
#   1     1.262054e+01     1.000e+00
#   2     5.000000e-02     1.000e+00
#   3     5.000000e-02     1.000e+00
# 
#  IT   NF      F       RELDF    PRELDF    RELDX   STPPAR   D*STEP   NPRELDF
#  0    1  3.117e+03
#  1    4  3.117e+03  6.47e-05  2.72e-04  8.6e-04  1.8e+03  2.2e-02  2.41e-01
#  2    5  3.117e+03  4.62e-07  6.26e-05  8.5e-04  2.0e+00  2.2e-02  7.49e-03
#  3    6  3.117e+03  2.35e-05  2.36e-05  4.3e-04  2.1e+00  1.1e-02  1.30e-03
#  4    8  3.117e+03  3.18e-06  5.43e-06  1.1e-04  1.6e+01  2.9e-03  9.08e-04
#  5    9  3.117e+03  9.88e-07  1.99e-06  1.1e-04  1.5e+01  2.9e-03  1.11e-04
#  6   15  3.116e+03  1.94e-04  9.65e-05  3.2e-02  0.0e+00  7.8e-01  9.65e-05
#  7   17  3.088e+03  9.18e-03  1.08e-03  5.4e-01  0.0e+00  8.3e+00  1.08e-03
#  8   23  3.088e+03  6.71e-05  3.39e-04  1.6e-03  4.0e+00  1.3e-02  9.95e-01
#  9   24  3.087e+03  1.13e-04  1.16e-04  1.7e-03  2.0e+00  1.3e-02  9.35e-01
# 10   25  3.087e+03  7.71e-05  8.83e-05  3.6e-03  2.0e+00  2.7e-02  9.68e-01
# 11   29  3.078e+03  2.78e-03  6.29e-03  5.8e-01  2.0e+00  2.6e+00  9.89e-01
# 12   33  3.077e+03  4.45e-04  1.84e-03  6.7e-03  6.2e+00  1.4e-02  6.85e-03
# 13   34  3.076e+03  3.40e-04  3.44e-04  6.5e-03  2.0e+00  1.4e-02  7.44e-03
# 14   35  3.075e+03  3.21e-04  3.40e-04  1.2e-02  2.0e+00  2.8e-02  5.29e-03
# 15   36  3.074e+03  2.87e-04  3.58e-04  2.7e-02  1.9e+00  5.6e-02  2.79e-03
# 16   37  3.074e+03  1.23e-04  1.47e-04  2.6e-02  1.7e+00  5.6e-02  9.01e-04
# 17   38  3.073e+03  2.11e-04  2.37e-04  4.8e-02  2.3e-01  1.1e-01  2.44e-04
# 18   39  3.073e+03  6.61e-06  2.42e-05  4.0e-02  0.0e+00  1.0e-01  2.42e-05
# 19   40  3.073e+03  1.03e-05  1.02e-05  9.1e-03  0.0e+00  2.4e-02  1.02e-05
# 20   41  3.073e+03  9.95e-08  7.82e-08  4.4e-04  0.0e+00  1.1e-03  7.82e-08
# 21   42  3.073e+03  4.72e-10  1.15e-11  9.2e-06  0.0e+00  2.4e-05  1.15e-11
# 22   43  3.073e+03  4.87e-11  2.58e-14  9.7e-07  0.0e+00  2.5e-06  2.58e-14
# 23   44  3.073e+03  3.06e-12  9.53e-17  6.1e-08  0.0e+00  1.6e-07  9.53e-17
# 24   45  3.073e+03 -2.37e-15  7.39e-21  7.9e-11  0.0e+00  2.2e-10  7.39e-21
# 
# ***** X- AND RELATIVE FUNCTION CONVERGENCE *****
#   
# FUNCTION     3.073048e+03   RELDX        7.860e-11
# FUNC. EVALS      45         GRAD. EVALS      24
# PRELDF       7.392e-21      NPRELDF      7.392e-21
# 
# I      FINAL X(I)        D(I)          G(I)
# 
# 1    1.272503e+00     1.000e+00     8.383e-08
# 2    9.083005e-02     1.000e+00     6.405e-07
# 3    8.251501e-01     1.000e+00     1.116e-06
# 
# Call: tseries::garch(x=y, order=c(GARCH_log.ret.perc.[[cn_sort_AIC[1]]]$order[1], GARCH_log.ret.perc.[[cn_sort_AIC[1]]]$order[2]), 
#                      Series=NULL, control=garch.control())
# 
# Coefficient(s):
#   a0       a1       b1  
# 1.27250  0.09083  0.82515  
#
# We check the estimation procedure for the model of counter cn=2
y <- na.rm(Data_df$log.ret.perc.)
tseries::garch(y, order=c(GARCH_log.ret.perc.[[cn_sort_AIC[2]]]$order[1], GARCH_log.ret.perc.[[cn_sort_AIC[2]]]$order[2]), series=NULL, 
               control=garch.control())
# ***** ESTIMATION WITH ANALYTICAL GRADIENT ***** 
# I     INITIAL X(I)        D(I)
# 1     1.121826e+01     1.000e+00
# 2     5.000000e-02     1.000e+00
# 3     5.000000e-02     1.000e+00
# 4     5.000000e-02     1.000e+00
# 5     5.000000e-02     1.000e+00
# 
#  IT   NF      F       RELDF    PRELDF    RELDX   STPPAR   D*STEP   NPRELDF
#  0    1  3.108e+03
#  1    3  3.108e+03  7.59e-06  1.94e-03  3.8e-03  6.1e+02  1.0e-01  5.88e-01
#  2    4  3.107e+03  5.17e-04  8.31e-04  1.6e-03  2.3e+00  5.0e-02  1.69e-01
#  3    6  3.106e+03  9.50e-05  2.22e-04  5.4e-04  3.3e+00  1.5e-02  2.54e-01
#  4    7  3.106e+03  3.91e-06  4.44e-05  3.9e-04  2.0e+00  1.5e-02  1.14e-02
#  5    8  3.106e+03  1.42e-05  1.73e-05  2.1e-04  2.0e+00  7.3e-03  2.61e-03
#  6   10  3.106e+03  2.92e-06  6.95e-06  1.3e-04  2.5e+00  3.6e-03  2.96e-03
#  7   11  3.106e+03  4.04e-06  4.90e-06  1.0e-04  2.0e+00  3.6e-03  2.27e-03
#  8   12  3.106e+03  2.82e-06  3.23e-06  1.4e-04  2.0e+00  3.6e-03  1.46e-03
#  9   15  3.106e+03  2.79e-05  4.35e-05  2.2e-03  1.9e+00  4.9e-02  1.43e-03
# 10   16  3.106e+03  5.93e-05  6.12e-05  2.1e-03  2.0e+00  4.9e-02  1.85e-02
# 11   17  3.106e+03  3.67e-05  5.11e-05  2.2e-03  2.0e+00  4.9e-02  1.82e-02
# 12   20  3.105e+03  2.13e-04  3.26e-04  1.5e-02  2.0e+00  3.3e-01  3.29e-02
# 13   21  3.105e+03  2.29e-04  4.91e-04  1.5e-02  2.0e+00  3.3e-01  1.28e-01
# 14   23  3.103e+03  5.73e-04  4.95e-04  1.6e-02  2.0e+00  3.3e-01  6.57e-02
# 15   24  3.102e+03  3.34e-04  5.07e-04  1.6e-02  2.0e+00  3.3e-01  1.61e-01
# 16   26  3.098e+03  1.11e-03  9.84e-04  3.4e-02  2.0e+00  6.5e-01  2.17e-01
# 17   28  3.098e+03  2.03e-04  2.10e-04  7.2e-03  2.0e+00  1.3e-01  1.25e+00
# 18   30  3.096e+03  4.11e-04  4.00e-04  1.5e-02  2.0e+00  2.6e-01  1.23e+00
# 19   32  3.096e+03  1.03e-04  1.18e-04  2.9e-03  2.0e+00  5.2e-02  1.31e+01
# 20   36  3.093e+03  9.30e-04  8.89e-04  3.2e-02  2.0e+00  5.4e-01  1.55e+01
# 21   38  3.093e+03  1.93e-04  1.92e-04  6.6e-03  2.0e+00  1.1e-01  1.19e+03
# 22   40  3.091e+03  3.86e-04  3.87e-04  1.4e-02  2.0e+00  2.1e-01  2.98e+04
# 23   42  3.091e+03  7.96e-05  7.82e-05  2.7e-03  2.0e+00  4.3e-02  2.06e+04
# 24   44  3.091e+03  1.61e-04  1.59e-04  5.5e-03  2.0e+00  8.6e-02  1.09e+05
# 25   47  3.088e+03  8.62e-04  8.83e-04  3.2e-02  2.0e+00  4.8e-01  2.76e+05
# 26   49  3.087e+03  2.09e-04  1.96e-04  6.6e-03  2.0e+00  9.5e-02  3.77e+05
# 27   51  3.086e+03  3.85e-04  3.87e-04  1.4e-02  2.0e+00  1.9e-01  7.96e+05
# 28   53  3.086e+03  7.75e-05  7.75e-05  2.7e-03  2.0e+00  3.8e-02  7.43e+05
# 29   55  3.085e+03  1.52e-04  1.53e-04  5.5e-03  2.0e+00  7.6e-02  7.91e+05
# 30   59  3.085e+03  4.24e-07  4.24e-07  7.9e-06  1.6e+01  1.5e-04  7.94e+05
# 31   61  3.085e+03  7.72e-07  7.73e-07  1.7e-05  3.1e+00  3.0e-04  7.96e+05
# 32   63  3.085e+03  1.45e-07  1.45e-07  3.7e-06  6.0e+01  6.1e-05  7.96e+05
# 33   65  3.085e+03  2.88e-08  2.88e-08  7.6e-07  3.2e+02  1.2e-05  7.95e+05
# 34   67  3.085e+03  5.73e-08  5.73e-08  1.5e-06  4.1e+01  2.4e-05  7.95e+05
# 35   69  3.085e+03  1.13e-07  1.14e-07  3.1e-06  2.2e+01  4.9e-05  7.95e+05
# 36   71  3.085e+03  2.25e-08  2.26e-08  6.2e-07  4.5e+02  9.7e-06  7.95e+05
# 37   73  3.085e+03  4.50e-09  4.51e-09  1.2e-07  2.3e+03  1.9e-06  7.95e+05
# 38   75  3.085e+03  9.00e-09  9.01e-09  2.5e-07  2.9e+02  3.9e-06  7.95e+05
# 39   77  3.085e+03  1.80e-08  1.80e-08  5.0e-07  1.4e+02  7.8e-06  7.95e+05
# 40   79  3.085e+03  3.59e-09  3.60e-09  9.9e-08  2.9e+03  1.6e-06  7.95e+05
# 41   81  3.085e+03  7.18e-10  7.19e-10  2.0e-08  1.5e+04  3.1e-07  7.95e+05
# 42   83  3.085e+03  1.44e-10  1.44e-10  4.0e-09  7.3e+04  6.2e-08  7.95e+05
# 43   85  3.085e+03  2.87e-10  2.88e-10  7.9e-09  9.1e+03  1.2e-07  7.95e+05
# 44   87  3.085e+03  5.74e-11  5.75e-11  1.6e-09  2.0e+00  2.5e-08 -1.98e-03
# 45   90  3.085e+03  4.59e-10  4.60e-10  1.3e-08  5.7e+03  2.0e-07  7.95e+05
# 46   93  3.085e+03  9.19e-12  9.20e-12  2.5e-10  2.0e+00  4.0e-09 -1.98e-03
# 47   96  3.085e+03  1.86e-13  1.84e-13  5.1e-12  2.0e+00  8.0e-11 -1.98e-03
# 48   98  3.085e+03  3.67e-13  3.68e-13  1.0e-11  2.0e+00  1.6e-10 -1.98e-03
# 49  100  3.085e+03  7.27e-14  7.36e-14  2.0e-12  2.0e+00  3.2e-11 -1.98e-03
# 50  102  3.085e+03  1.48e-13  1.47e-13  4.1e-12  2.0e+00  6.4e-11 -1.98e-03
# 51  104  3.085e+03  2.74e-14  2.95e-14  8.1e-13  2.0e+00  1.3e-11 -1.98e-03
# 52  106  3.085e+03  6.12e-14  5.89e-14  1.6e-12  2.0e+00  2.6e-11 -1.98e-03
# 53  108  3.085e+03  9.58e-15  1.18e-14  3.3e-13  2.0e+00  5.1e-12 -1.98e-03
# 54  110  3.085e+03  2.49e-14  2.36e-14  6.5e-13  2.0e+00  1.0e-11 -1.98e-03
# 55  112  3.085e+03  4.27e-15  4.71e-15  1.3e-13  2.0e+00  2.0e-12 -1.98e-03
# 56  114  3.085e+03  1.09e-14  9.43e-15  2.6e-13  2.0e+00  4.1e-12 -1.98e-03
# 57  116  3.085e+03  1.74e-14  1.89e-14  5.2e-13  2.0e+00  8.2e-12 -1.98e-03
# 58  118  3.085e+03  2.80e-15  3.77e-15  1.0e-13  2.0e+00  1.6e-12 -1.98e-03
# 59  120  3.085e+03  4.42e-16  7.54e-16  2.1e-14  2.0e+00  3.3e-13 -1.98e-03
# 60  122  3.085e+03  2.06e-15  1.51e-15  4.2e-14  2.0e+00  6.5e-13 -1.98e-03
# 61  124  3.085e+03  3.83e-15  3.02e-15  8.3e-14  2.0e+00  1.3e-12 -1.98e-03
# 62  126  3.085e+03 -3.24e+06  6.03e-16  1.7e-14  2.0e+00  2.6e-13 -1.98e-03
# 
# ***** FALSE CONVERGENCE *****
#   
# FUNCTION     3.085484e+03   RELDX        1.668e-14
# FUNC. EVALS     126         GRAD. EVALS      62
# PRELDF       6.032e-16      NPRELDF     -1.978e-03
# 
# I      FINAL X(I)        D(I)          G(I)
# 1    6.816715e+00     1.000e+00     6.169e+00
# 2    5.323327e-02     1.000e+00     1.448e+00
# 3    1.905442e-14     1.000e+00     2.861e+00
# 4    1.311923e-01     1.000e+00    -7.789e-01
# 5    3.703548e-01     1.000e+00     1.281e+00
# 
# Call: tseries::garch(x=y, order=c(GARCH_log.ret.perc.[[cn_sort_AIC[2]]]$order[1], GARCH_log.ret.perc.[[cn_sort_AIC[2]]]$order[2]), 
#                      series=NULL, control=garch.control())
# 
# Coefficient(s):
#   a0         a1         a2         a3         b1  
# 6.817e+00  5.323e-02  1.905e-14  1.312e-01  3.704e-01
#
# We check the estimation procedure for the model of counter cn=3
y <- na.rm(Data_df$log.ret.perc.)
tseries::garch(y, order=c(GARCH_log.ret.perc.[[cn_sort_AIC[3]]]$order[1], GARCH_log.ret.perc.[[cn_sort_AIC[3]]]$order[2]), series=NULL, 
               control=garch.control)
# ***** ESTIMATION WITH ANALYTICAL GRADIENT ***** 
# I     INITIAL X(I)        D(I)
# 1     1.051712e+01     1.000e+00
# 2     5.000000e-02     1.000e+00
# 3     5.000000e-02     1.000e+00
# 4     5.000000e-02     1.000e+00
# 5     5.000000e-02     1.000e+00
# 6     5.000000e-02     1.000e+00
# 
#  IT   NF      F       RELDF    PRELDF    RELDX   STPPAR   D*STEP   NPRELDF
#  0    1  3.106e+03
#  1    4  3.104e+03  4.31e-04  8.41e-04  1.0e-03  2.9e+03  3.0e-02  1.22e+00
#  2    5  3.104e+03  1.26e-05  3.49e-04  1.0e-03  3.1e+00  3.0e-02  3.78e-01
#  3    6  3.104e+03  2.01e-04  2.46e-04  3.6e-04  2.3e+00  1.5e-02  6.19e-02
#  4    9  3.102e+03  3.89e-04  3.39e-04  1.8e-03  2.0e+00  6.0e-02  7.02e-02
#  5   11  3.102e+03  1.56e-04  1.11e-04  3.8e-04  2.0e+00  1.2e-02  1.56e+00
#  6   12  3.101e+03  2.27e-04  2.17e-04  7.1e-04  2.0e+00  2.4e-02  1.25e+01
#  7   14  3.101e+03  6.30e-05  6.21e-05  1.9e-04  4.3e+00  4.8e-03  1.22e+01
#  8   16  3.101e+03  1.12e-05  1.12e-05  4.0e-05  4.9e+01  9.6e-04  1.58e+01
#  9   18  3.101e+03  2.19e-05  2.19e-05  8.0e-05  8.8e+00  1.9e-03  1.71e+01
# 10   20  3.101e+03  4.33e-06  4.33e-06  1.6e-05  3.2e+02  3.8e-04  1.73e+01
# 11   22  3.101e+03  8.62e-06  8.62e-06  3.1e-05  4.8e+01  7.7e-04  1.98e+01
# 12   24  3.101e+03  1.72e-06  1.72e-06  6.2e-06  1.3e+03  1.5e-04  2.02e+01
# 13   26  3.101e+03  3.43e-06  3.43e-06  1.2e-05  1.7e+02  3.1e-04  2.20e+01
# 14   28  3.101e+03  6.85e-06  6.85e-06  2.5e-05  9.7e+01  6.2e-04  2.23e+01
# 15   30  3.101e+03  1.37e-06  1.37e-06  4.9e-06  2.5e+03  1.2e-04  2.29e+01
# 16   32  3.101e+03  2.74e-07  2.74e-07  9.9e-07  1.3e+04  2.5e-05  2.54e+01
# 17   34  3.101e+03  5.47e-07  5.47e-07  2.0e-06  1.7e+03  4.9e-05  2.60e+01
# 18   36  3.101e+03  1.09e-06  1.09e-06  4.0e-06  8.7e+02  9.8e-05  2.61e+01
# 19   39  3.101e+03  2.19e-08  2.19e-08  7.9e-08  1.8e+05  2.0e-06  2.62e+01
# 20   41  3.101e+03  4.38e-08  4.38e-08  1.6e-07  2.3e+04  3.9e-06  2.68e+01
# 21   43  3.101e+03  8.75e-08  8.75e-08  3.2e-07  1.1e+04  7.9e-06  2.68e+01
# 22   45  3.101e+03  1.75e-08  1.75e-08  6.3e-08  2.3e+05  1.6e-06  2.68e+01
# 23   47  3.101e+03  3.50e-09  3.50e-09  1.3e-08  1.1e+06  3.2e-07  2.68e+01
# 24   49  3.101e+03  7.00e-10  7.00e-10  2.5e-09  5.7e+06  6.3e-08  2.68e+01
# 25   51  3.101e+03  1.40e-10  1.40e-10  5.1e-10  2.9e+07  1.3e-08  2.68e+01
# 26   53  3.101e+03  2.80e-10  2.80e-10  1.0e-09  3.6e+06  2.5e-08  2.68e+01
# 27   55  3.101e+03  5.60e-10  5.60e-10  2.0e-09  1.8e+06  5.0e-08  2.68e+01
# 28   58  3.101e+03  1.12e-11  1.12e-11  4.0e-11  2.0e+00  1.0e-09 -9.04e-03
# 29   60  3.101e+03  2.24e-11  2.24e-11  8.1e-11  2.0e+00  2.0e-09 -9.04e-03
# 30   63  3.101e+03  4.49e-13  4.48e-13  1.6e-12  2.0e+00  4.0e-11 -9.04e-03
# 31   65  3.101e+03  8.95e-13  8.96e-13  3.2e-12  2.0e+00  8.1e-11 -9.04e-03
# 32   67  3.101e+03  1.79e-13  1.79e-13  6.5e-13  2.0e+00  1.6e-11 -9.04e-03
# 33   70  3.101e+03  1.44e-12  1.43e-12  5.2e-12  2.0e+00  1.3e-10 -9.04e-03
# 34   73  3.101e+03  2.92e-14  2.87e-14  1.0e-13  2.0e+00  2.6e-12 -9.04e-03
# 35   75  3.101e+03  5.70e-14  5.74e-14  2.1e-13  2.0e+00  5.2e-12 -9.04e-03
# 36   77  3.101e+03  1.04e-14  1.15e-14  4.1e-14  2.0e+00  1.0e-12 -9.04e-03
# 37   79  3.101e+03  2.39e-14  2.29e-14  8.3e-14  2.0e+00  2.1e-12 -9.04e-03
# 38   81  3.101e+03  4.55e-15  4.59e-15  1.7e-14  2.0e+00  4.1e-13 -9.04e-03
# 39   83  3.101e+03  9.53e-15  9.18e-15  3.3e-14  2.0e+00  8.3e-13 -9.03e-03
# 40   85  3.101e+03  1.98e-14  1.84e-14  6.6e-14  2.0e+00  1.7e-12 -9.04e-03
# 41   87  3.101e+03  2.05e-15  3.67e-15  1.3e-14  2.0e+00  3.3e-13 -9.04e-03
# 42   89  3.101e+03  5.87e-16  7.34e-16  2.6e-15  2.0e+00  6.6e-14 -9.04e-03
# 43   91  3.101e+03  1.47e-15  1.47e-15  5.3e-15  2.0e+00  1.3e-13 -9.04e-03
# 44   92  3.101e+03 -3.22e+06  2.94e-15  1.1e-14  2.0e+00  2.6e-13 -9.03e-03
# 
# ***** FALSE CONVERGENCE *****
#   
# FUNCTION     3.100889e+03   RELDX        1.060e-14
# FUNC. EVALS      92         GRAD. EVALS      44
# PRELDF       2.937e-15      NPRELDF     -9.031e-03
# 
# I      FINAL X(I)        D(I)          G(I)
# 
# 1    1.049981e+01     1.000e+00     3.829e+00
# 2    4.161838e-02     1.000e+00     1.214e+00
# 3    8.872517e-02     1.000e+00    -8.654e+00
# 4    1.435550e-02     1.000e+00     4.079e+00
# 5    1.625536e-13     1.000e+00     2.901e+01
# 6    1.474573e-01     1.000e+00    -1.543e+01
# 
# Call: tseries::garch(x=y, order=c(GARCH_log.ret.perc.[[cn_sort_AIC[3]]]$order[1], GARCH_log.ret.perc.[[cn_sort_AIC[3]]]$order[2]), 
#                      series=NULL, control=garch.control())
# 
# Coefficient(s):
#   a0         a1         a2         a3         b1         b2  
# 1.050e+01  4.162e-02  8.873e-02  1.436e-02  1.626e-13  1.475e-01 
#
# Therefore, we select the model of counter cn_sort_AIC=1, that is a GARCH(1,1) model.
GARCH_1_1 <- GARCH_log.ret.perc.[[1]]
show(GARCH_1_1)
# Call: tseries::garch(x=y, order=c(p, q), series=NULL, coef=NULL, maxiter=200, grad="analytical", trace=TRUE, eps=NULL,
#                      abstol=max(1e-20, .Machine$double.eps^2), reltol=max(1e-10, .Machine$double.eps^(2/3)), 
#                      xtol=sqrt(.Machine$double.eps), falsetol=100 *.Machine$double.eps)
# 
# Coefficient(s):
#   a0       a1       b1  
# 1.27250  0.09083  0.82515
#
summary(GARCH_1_1)
# Call: tseries::garch(x=y, order=c(p, q), series=NULL, coef=NULL,     maxiter=200, grad="analytical", trace=TRUE, eps=NULL,     abstol=max(1e-20, .Machine$double.eps^2), reltol=max(1e-10,         .Machine$double.eps^(2/3)), xtol=sqrt(.Machine$double.eps),     falsetol=100 * .Machine$double.eps)
# Model: GARCH(1,1)
# Residuals: Min        1Q     Median        3Q       Max 
#        -12.68034  -0.40544   0.02741   0.44842   5.71992 
# 
# Coefficient(s): Estimate  Std. Error  t value Pr(>|t|)    
#           a0   1.27250     0.17990    7.074   1.51e-12 ***
#           a1   0.09083     0.01108    8.196   2.22e-16 ***
#           b1   0.82515     0.02166   38.101    < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Diagnostic Tests: 
# Jarque Bera Test
# data:  Residuals
# X-squared=22642, df=2, p-value < 2.2e-16
# 
# Box-Ljung test
# data:  Squared.Residuals
# X-squared=0.058415, df=1, p-value=0.809
#
# Note that from the diagnostic tests executed within the procedure, we have computational evidence that the residuals of the estimated
# GARCH(1,1) model are not Gaussian distributed. Still, the squared residuals appear to be uncorrelated. This means that the GARCH(1,1)
# model should have been able to account for the conditional heteroscedasticity of the SP500 daily logarithm return percentage training
# set. The estimation procedure also produces some plots.
margins <- par("mar")
par(mar=c(1,1,1,1))
plot(GARCH_1_1)
par(mar=margins)
#
# Since corresponding to cn_sort_AIC=1 we have the best AIC and BIC, before checking the model's residuals, which is a necessary step for 
# the validation of the model, it is unnecessary to consider also the cases cn_sort_AIC=2 and cn_sort_AIC=3. We just showed them for 
# illustrative purposes. However, due to the false convergence result, we already know that we have to discharge them as possible
# alternative models, even if the validation of the GARCH(1,1) model corresponding to the counter cn=1 will fail.
#
# After having determined the best model for which we have convergence in the parameter estimation, we store the estimated coefficients
a0 <- as.numeric(GARCH_1_1$coef[1])
a1 <- as.numeric(GARCH_1_1$coef[2])
b1 <- as.numeric(GARCH_1_1$coef[3])
show(c(a0, a1, b1))
#  1.27250304 0.09083005 0.82515011
#
# Note that we have
a1+b1 < 1 
# TRUE
#
# Hence, the estimated GARCH(1,1) model is stationary.
# We compute the long run variance of the model
long_run_var <- a0/(1-(a1+b1))
show(long_run_var)
# 15.14527
#
# We consider the model's residuals
head(GARCH_1_1[["residuals"]],20)
#         NA  0.4144350  1.7419601  0.1388852 -0.2739446  0.3934785  2.3160671 -2.1750189  0.9879875 -0.6733973  0.8577650  0.1677307
# -0.4519716 -0.3269755  0.3293429  1.4429839 -0.1135800  0.4322909 -0.5793139 -0.8429184
#
mean(na.rm(GARCH_1_1[["residuals"]]))
# 0.009702442
#
var(na.rm(GARCH_1_1[["residuals"]]))
# 1.001107
#
# Despite not being clearly documented (?!), the tseries::garch() function computes the standardized residuals of the model.
# The standardized residuals are defined as the states of the model divided the conditional standard deviation. This definition comes from
# the stochastic equation
# $Z_{t}=\sigma_{t}W_{t}$, where $t=1,\dots,T$
# Given the sequence $\left(Z_{t}\left(\omega\right)\right)_{t=1}^{T}$ of the observed states of the process and computing the realizations 
# of the conditional variance of the process from the stochastic equation
# $\sigma_{t}^{2}=a_{0} + a_{1}Z_{t-1}^{2} + b_{1}\sigma_{t-1}^2, where $t=1,\dots,T$,
# we can write
# $\frac{Z_{t}\left(\omega\right)}{\hat{\sigma}_{t\mid\t-1}\left(\omega\right)}=W_{t}\left(\omega\right), where $t=1,\dots,T$.
# Then, the elements of the sequence $\left(W_{t}\left(\omega\right)\right)_{t=1}^{T} are the standardized residuals of the model.
# The main issue to compute the conditional variance of the process is its initialization, that is the determination of the initial value
# $\hat{\sigma}_{0}^{2}$. This issue is addressed, for instance, in the paper
# https://www.researchgate.net/publication/237530561_VARIANCE_INITIALISATION_IN_GARCH_ESTIMATION
# There are several ways to initialize the conditional variance:
# 1) the value $\hat{\sigma}_{0}^{2}$ can be chosen as the unconditional sample variance;
# $\hat{\sigma}_{0}^{2}=\frac{1}{T}\sum_{t=1}^{T}Z_{t}^2\left(\omega\right)$.
# In our code chunk,
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
y <- na.rm(Data_df$log.ret.perc.)
T <- length(y)
GARCH_sigma0 <- (1/T)*sum(y^2)
show(GARCH_sigma0)
# 14.01651
#
# 2) the value $\hat{\sigma}_{0}^{2}$ can be chosen as the variance of the first ten observations;
# $\hat{\sigma}_{0}^{2}=\frac{1}{10}\sum_{t=1}^{10}Z_{t}^2\left(\omega\right)$.
# In our code chunk,
GARCH_sigma0 <- (1/10)*sum(y[1:10]^2)
show(GARCH_sigma0)
# 24.39334
#
# 3) the value $\hat{\sigma}_{0}^{2}$ can be chosen as the square of the first observation;
# $\hat{\sigma}_{0}^{2}=Z_{1}\left(\omega\right)^2
GARCH_sigma0 <- y[1]^2
show(GARCH_sigma0)
# 10.58587
#
# 4) the value $\hat{\sigma}_{0}^{2}$ can be chosen as the exponential smoothing backcast with parameter $\lambda=0.7$;
# $\hat{\sigma}_{0}^{2}=\lambda^{T}\frac{1}{T}\sum_{t=1}^{T}Z_{t}^2\left(\omega\right)
#                       +(1-\lambda)\sum_{t=0}^{T-1}\lambda^{t}Z_{t+1}^2\left(\omega\right)$
# In our code chunk,
GARCH_sigma0 <- ((0.7)^T)*(1/T)*sum(y^2)+(1-0.7)*sum((0.7)^(0:(T-1))*y^2)
show(GARCH_sigma0)
# 15.23773
#
# 5) the value $\hat{\sigma}_{0}^{2}$ can be chosen as the tong run variance;
# $\hat{\sigma}_{0}^{2}=\frac{a_{0}}{1-\left(a_{1}+b_{1}\right)}
# In our code chunk,
GARCH_sigma0 <- a0/(1-(a1+b1))
show(GARCH_sigma0)
# 15.14527
#
# 6) the value $\hat{\sigma}_{0}^{2}$ becomes an additional parameter with respect to which the log-likelihood is optimized;
#
# 7) the smoothing parameter $\lambda$ becomes an additional parameter with respect to which the log-likelihood is optimized.
#
# Now, we have
GARCH_1_1_resid <- GARCH_1_1[["residuals"]]
head(GARCH_1_1_resid,20)
#         NA  0.4144350  1.7419601  0.1388852 -0.2739446  0.3934785  2.3160671 -2.1750189  0.9879875 -0.6733973  0.8577650  0.1677307
# -0.4519716 -0.3269755  0.3293429  1.4429839 -0.1135800  0.4322909 -0.5793139 -0.8429184
#
# Then, we write the procedure to generate the path of the conditional variance from the initial value $\hat{\sigma}_{0}^{2}$.
# Consider that, due to the way R indexes vectors, we have to shift the starting time from t=0 to t=1.
GARCH_1_1_cond_var_est <- vector(mode="numeric", length=T)
GARCH_1_1_cond_var_est[1] <- a0/(1-(a1+b1))
for(t in 2:T){
  GARCH_1_1_cond_var_est[t] <- a0 + a1*y[t-1]^2 + b1*GARCH_1_1_cond_var_est[t-1]
}
head(GARCH_1_1_cond_var_est,20)
# 15.14527 14.73114 13.65772 16.30647 14.75636 13.54930 12.64325 17.86522 23.69050 22.92115 21.12997 20.12000 17.92594 16.39670 14.96147
# 13.76536 15.23439 13.86101 12.94519 12.34884
#
# From this, we obtain the path of the conditional standard deviation.
head(sqrt(GARCH_1_1_cond_var_est),20)
# 3.891692 3.838116 3.695635 4.038127 3.841400 3.680937 3.555735 4.226727 4.867289 4.787604 4.596735 4.485532 4.233903 4.049284 3.868006
# 3.710170 3.903125 3.723038 3.597943 3.514091
#
# In the end, we obtain the standardized residuals.
GARCH_1_1_stand_res <- y/sqrt(GARCH_1_1_cond_var_est)
head(GARCH_1_1_stand_res,20)
#  0.8360355  0.4144350  1.7419601  0.1388852 -0.2739446  0.3934785  2.3160671 -2.1750189  0.9879875 -0.6733973  0.8577650  0.1677307
# -0.4519716 -0.3269755  0.3293429  1.4429839 -0.1135800  0.4322909 -0.5793139 -0.8429184
#
# To be compared with
head(GARCH_1_1[["residuals"]],20)
#         NA  0.4144350  1.7419601  0.1388852 -0.2739446  0.3934785  2.3160671 -2.1750189  0.9879875 -0.6733973  0.8577650  0.1677307
# -0.4519716 -0.3269755  0.3293429  1.4429839 -0.1135800  0.4322909 -0.5793139 -0.8429184
#
# Actually, we have
identical(GARCH_1_1_stand_res[2:T],GARCH_1_1[["residuals"]][2:T])
# TRUE
#
# Therefore the vector GARCH_1_1[["residuals"]] yields the standardized residuals of the model. 
# Note that the tseries::garch() function also yields the sequence of the conditional standard deviation. In fact, we have
head(GARCH_1_1[["fitted.values"]],20)
#           sigt     -sigt
#  [1,]       NA        NA
#  [2,] 3.838116 -3.838116
#  [3,] 3.695635 -3.695635
#  [4,] 4.038127 -4.038127
#  [5,] 3.841400 -3.841400
#  [6,] 3.680937 -3.680937
#  [7,] 3.555735 -3.555735
#  [8,] 4.226727 -4.226727
#  [9,] 4.867289 -4.867289
# [10,] 4.787604 -4.787604
# [11,] 4.596735 -4.596735
# [12,] 4.485532 -4.485532
# [13,] 4.233903 -4.233903
# [14,] 4.049284 -4.049284
# [15,] 3.868006 -3.868006
# [16,] 3.710170 -3.710170
# [17,] 3.903125 -3.903125
# [18,] 3.723038 -3.723038
# [19,] 3.597943 -3.597943
# [20,] 3.514091 -3.514091
#
# From which,
identical(sqrt(GARCH_1_1_cond_var_est)[2:T],GARCH_1_1[["fitted.values"]][2:T,1])
# TRUE
#
# Note that the GARCH(1,1) model is estimated by the function tseries::garch() under the assumption that the innovation 
# $\left(W_{t}\right)_{t=1}^{T}\equiv W$ is a standard Gaussian strong white noise. In fact, the model is estimated using a Gaussian 
# likelihood function. Consequently, the $68.3\%$ of the realizations $\left(W_{t}\left(\omega\right)\right)_{t=1}^{T}$ of the innovation 
# $W$ are expected in the interval $\left[-1,1\right]$. It follows that the $68.3\%$ of the states of the process 
# $\left(Z_{t}\right)_{t=1}^{T}$ are expected in the interval $\left[-\sigma_{t},\sigma_{t}\right]$. In our code chunk this interval is 
# given by GARCH_1_1[["fitted.values"]][2:T].
#
# To validate the model, we need to check the standardized residuals. We start with plotting them.
head(spx_train_df)
tail(spx_train_df)
spx_train_df <- add_column(spx_train_df, GARCH_1_1_stand_res=c(NA,GARCH_1_1[["residuals"]]), .after="log.ret.perc.")
head(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=GARCH_1_1_stand_res)
head(Data_df)
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 1718
First_Day <- as.character(Data_df$Date[3])
Last_Day <- as.character(Data_df$Date[(TrnS_length+2)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[3]
x_breaks_up <- Data_df$x[(TrnS_length+2)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("standardized residuals (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_GARCH_1_1_stand_res_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA), linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_GARCH_1_1_stand_res_TrnS_sp.png", width = 1200, height = 600)
plot(spx_GARCH_1_1_stand_res_TrnS_sp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_GARCH_1_1_stand_res_TrnS_sp)
#
# The line plot
spx_GARCH_1_1_stand_res_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="point_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_GARCH_1_1_stand_res_TrnS_lp.png", width = 1200, height = 600)
plot(spx_GARCH_1_1_stand_res_TrnS_lp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_GARCH_1_1_stand_res_TrnS_lp)
#
# We superimpose the conditional standard deviation of the tseries::garch() fitted GARCH(1,1) model to the plots of the SP500 daily logarithm return percentage.
# The scatter plot.
head(spx_train_df)
tail(spx_train_df)
spx_train_df <- add_column(spx_train_df, GARCH_1_1_cond_stand_dev=c(NA,GARCH_1_1[["fitted.values"]][,1]), .after="GARCH_1_1_stand_res")
head(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=GARCH_1_1_cond_stand_dev)
head(Data_df)
tail(Data_df)
First_Day <- as.character(Data_df$Date[3])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Standardized Residuals and Conditional Standard Deviation of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- 44 # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[3]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("standardizedd residuals (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
line_magenta <- bquote("GARCH(1,1) cond. stand. dev.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_magenta, line_green, line_red)
leg_line_cols <- c("line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_magenta", "line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_perc_log_ret_GARCH_1_1_cond_stand_dev_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA, NA), linetype=c("blank", "solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_perc_log_ret_GARCH_1_1_cond_stand_dev_TrnS_sp.png", width = 1200, height = 600)
plot(spx_perc_log_ret_GARCH_1_1_cond_stand_dev_TrnS_sp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_perc_log_ret_GARCH_1_1_cond_stand_dev_TrnS_sp)
#
# The line plot.
line_black <- bquote("perc. log. returns")
line_magenta <- bquote("GARCH(1,1) cond. stand. dev.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_black, line_magenta, line_green, line_red)
leg_line_cols <- c("line_black"="black", "line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_black", "line_magenta", "line_green", "line_red")
spx_perc_log_ret_GARCH_1_1_cond_stand_dev_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="line_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
png("plots/spx_perc_log_ret_GARCH_1_1_cond_stand_dev_TrnS_lp.png", width = 1200, height = 600)
plot(spx_perc_log_ret_GARCH_1_1_cond_stand_dev_TrnS_lp)
# Chiudere il dispositivo PNG
dev.off()
plot(spx_perc_log_ret_GARCH_1_1_cond_stand_dev_TrnS_lp)
# 
# Note that we have
length(which(abs(spx_train_df$log.ret.perc.[-c(1,2)])<spx_train_df$GARCH_1_1_cond_stand_dev[-c(1,2)]))/length(spx_train_df$log.ret.perc.[-c(1,2)])
# 0.782305
# This shows that more than the $68.3\%$ of the states of the process $\left(Z_{t}\right)_{t=1}^{T}$ are actually in the interval 
# $\left[-\sigma_{t},\sigma_{t}\right]$
# 
# As we mentioned above, the GARCH(1,1) model is estimated by the function tseries::garch() under the assumption that the innovation 
# $\left(W_{t}\right)_{t=1}^{T}\equiv W$ is a standard Gaussian strong white noise. Therefore, we should expect that the standardized 
# residuals of the GARCH(1,1) model for the SP500 daily logarithm return percentage satisfy the following conditions:
# 1) the standardized residuals are stationary at the $5\%$ significance level, at least;
# 2) the standardized residuals have mean zero and variance one at the $5\%$ significance level, at least;
# 3) the standardized residuals are uncorrelated at the $5\%$ significance level, at least; 
# 4) the standardized residuals are homoscedastic at the $5\%$ significance level, at least; 
# 5) the standardized residuals are Gaussian at the $5\%$ significance level, at least.
#
# From the scatter and line plot, we have clear visual evidence for stationarity in the standardized residuals of the GARCH(1,1) model.
# Hence, we apply to the standardized residuals the ADF test with 0 lags, that is, the DF test, and consider the alternative hypothesis 
# of type "none" (no drift and no linear trend).
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
l <- 0
y_ADF_ur.df_none_0_lags <- ur.df(y, type="none", lags=l, selectlags="Fixed")
summary(y_ADF_ur.df_none_0_lags)
#RIGA 5741
############################################### 
# Augmented Dickey-Fuller Test Unit Root Test # 
############################################### 
# Test regression none 
# Call: lm(formula=z.diff ~ z.lag.1 - 1)
# 
# Residuals: Min        1Q     Median     3Q      Max 
#          -12.6804  -0.4062   0.0256   0.4484   5.7180 
# 
# Coefficients: Estimate   Std. Error t value Pr(>|t|)    
#       z.lag.1 -0.99597    0.02414  -41.26   <2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1.001 on 1716 degrees of freedom
# Multiple R-squared:  0.498,	Adjusted R-squared:  0.4977 
# F-statistic:  1702 on 1 and 1716 DF,  p-value: < 2.2e-16
# 
# Value of test-statistic is: -41.2597 
# Critical values for test statistics: 1pct  5pct 10pct
#                                tau1 -2.58 -1.95 -1.62
# 
# From the DF test we have a rejection of the null hypothesis of a unit root at the $1\%$ significance level.
# Moreover, considering the residuals of the linear model used for the DF test, we have
y_res <- as.vector(y_ADF_ur.df_none_0_lags@testreg[["residuals"]])
head(y_res, 20)
# 1.7403058  0.1318592 -0.2745083  0.3945865  2.3144850 -2.1844087  0.9967936 -0.6774021  0.8605014  0.1642729 -0.4526543 -0.3251546
# 0.3306633  1.4416539 -0.1194029  0.4327498 -0.5810568 -0.8405774 -0.4208144  0.2877424
n_obs <- nobs(lm(formula=y_ADF_ur.df_none_0_lags@testreg[["terms"]]))
show(n_obs)
# 1717
max_lag <- ceiling(min(10, n_obs/4))    # Hyndman (for data without seasonality)
show(max_lag)
# 10
n_coeffs <- nrow(y_ADF_ur.df_trend_0_lags@testreg[["coefficients"]])
show(n_coeffs)
# 3
n_pars <- n_coeffs
show(n_pars)
# 3
y_res_LB <- Box.test(y_res, lag=max_lag, fitdf=n_pars, type="Ljung-Box")
show(y_res_LB)
# Box-Ljung test
# data:  y_res
# X-squared = 8.4728, df = 7, p-value = 0.2928
#
# The null hypothesis of no autocorrelation in the residuals of the linear model used for the DF test cannot be rejected at the $10\%$ 
# significance level. This validates the rejection of the null hypothesis of a unit root in the residuals of the tseries::garch() fitted 
# GARCH(1,1) model for the SP500 daily logarithm return percentage. The execution of the robust autocorrelation test confirms this 
# finding.
testcorr::ac.test(y_res, max.lag = 10, alpha = 0.10, lambda = 2.576, plot = TRUE, table = TRUE, var.name = NULL, scale.font = 1)
# Tests for zero autocorrelation of x
#   | Lag|     AC|  Stand. CB(90%)|  Robust CB(90%)| Lag|      t| p-value| t-tilde| p-value| Lag|    LB| p-value| Q-tilde| p-value|
#   |---:|------:|---------------:|---------------:|---:|------:|-------:|-------:|-------:|---:|-----:|-------:|-------:|-------:|
#   |   1| -0.001| (-0.040, 0.040)| (-0.037, 0.037)|   1| -0.025|   0.980|  -0.027|   0.979|   1| 0.001|   0.980|   0.001|   0.979|
#   |   2|  0.028| (-0.040, 0.040)| (-0.035, 0.035)|   2|  1.152|   0.249|   1.295|   0.195|   2| 1.330|   0.514|   1.679|   0.432|
#   |   3|  0.022| (-0.040, 0.040)| (-0.033, 0.033)|   3|  0.916|   0.360|   1.115|   0.265|   3| 2.172|   0.537|   2.578|   0.461|
#   |   4|  0.035| (-0.040, 0.040)| (-0.051, 0.051)|   4|  1.437|   0.151|   1.114|   0.265|   4| 4.245|   0.374|   3.819|   0.431|
#   |   5|  0.024| (-0.040, 0.040)| (-0.038, 0.038)|   5|  1.008|   0.314|   1.048|   0.295|   5| 5.265|   0.384|   4.917|   0.426|
#   |   6|  0.009| (-0.040, 0.040)| (-0.035, 0.035)|   6|  0.364|   0.716|   0.407|   0.684|   6| 5.398|   0.494|   5.083|   0.533|
#   |   7| -0.011| (-0.040, 0.040)| (-0.045, 0.045)|   7| -0.459|   0.646|  -0.405|   0.685|   7| 5.610|   0.586|   5.247|   0.630|
#   |   8| -0.024| (-0.040, 0.040)| (-0.037, 0.037)|   8| -1.007|   0.314|  -1.087|   0.277|   8| 6.629|   0.577|   6.429|   0.599|
#   |   9|  0.021| (-0.040, 0.040)| (-0.035, 0.035)|   9|  0.871|   0.384|   0.979|   0.327|   9| 7.392|   0.596|   7.388|   0.597|
#   |  10|  0.025| (-0.040, 0.040)| (-0.036, 0.036)|  10|  1.036|   0.300|   1.143|   0.253|  10| 8.473|   0.583|   8.694|   0.561|
#
# We consider also the KPSS test with null hypothesis of type "mu"
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
l <- 0
y_KPSS_ur.kpss_mu_0_lags <- ur.kpss(y, type="mu", use.lag=0)
summary(y_KPSS_ur.kpss_mu_0_lags)
####################### 
# KPSS Unit Root Test # 
####################### 
# Test is of type: mu with 0 lags. 
# 
# Value of test-statistic is: 0.2375 
# 
# Critical value for a significance level of: 10pct  5pct 2.5pct  1pct
#                             critical values 0.347 0.463  0.574 0.739
#
# In this case we cannot reject the null hypothesis that the standardized residuals are stationary at the $1\%$ significance level.
# Moreover, considering the residuals of the linear model used for the KPSS test, we have 
y_res <- as.vector(y_KPSS_ur.kpss_mu_0_lags@res)
head(y_res, 20)
#  0.4047390  1.7322756  0.1291854 -0.2836504  0.3837788  2.3063703 -2.1847662  0.9783152 -0.6831180  0.8480818  0.1580315 -0.4616800
# -0.3366807  0.3196416  1.4332804 -0.1232832  0.4225891 -0.5890150 -0.8526172 -0.4339178
#
# and
y_res_LB <- Box.test(y_res, lag=max_lag, fitdf=2, type="Ljung-Box")
show(y_res_LB)
# Box-Ljung test
# data:  y_res
# X-squared=8.6429, df=8, p-value=0.3733
#
# Also in this case, we cannot reject the null hypothesis that the residuals of the linear model used for the KPSS test are uncorrelated at 
# the $10\%$ significance level. This validates the non rejection of the null hypothesis of stationarity from the KPSS test.
#
# Now, we consider whether we can assess that the standardized residuals have mean zero and variance one at the $5\%$ significance level. 
# Since we have not checked yet the residuals empirical distribution we apply non parametric tests.
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
# We have
show(c(mean(y), var(y)))
# 0.00970241 1.00110974
#
# We wonder whether the mean is significantly different from zero. To this we determine the bootstrapped confidence intervals.
d <- data.frame(k=1:length(y), y=y)
head(d)
boot_mean <- function(d, k){
  d2 <- d[k,]
  return(mean(d2$y))
}
boot_mean(d)
# 0.00970241
# change or turn off set.seed() if you want the results to vary
set.seed(12345)
booted_mean <- boot(d, boot_mean, R=5000)
show(booted_mean)
# ORDINARY NONPARAMETRIC BOOTSTRAP
# Call: boot(data=d, statistic=boot_mean, R=5000)
# Bootstrap Statistics :
#     original        bias     std. error
# t1* 0.00970241 -1.220604e-05  0.02462959
#
summary(booted_mean)
#    R   original      bootBias     bootSE    bootMed
# 1 5000 0.0097024   -1.2206e-05    0.02463  0.0098051
#
booted_mean.ci <- boot.ci(boot.out=booted_mean, conf=0.80, type=c("norm", "basic", "perc", "bca"))
show(booted_mean.ci)
# 
# BOOTSTRAP CONFIDENCE INTERVAL CALCULATIONS
# Based on 5000 bootstrap replicates
# CALL:  boot.ci(boot.out=booted_mean, conf=0.8, type=c("norm", "basic", "perc", "bca"))
# Intervals: Level      Normal                 Basic         
#             80%   (-0.0218,  0.0413)   (-0.0213,  0.0418)  
#            Level     Percentile               BCa          
#             80%   (-0.0224,  0.0407)   (-0.0229,  0.0403)  
# Calculations and Intervals on Original Scale
#
# Alternatively,
set.seed(12345)
DescTools::BootCI(x=y, y=NULL, FUN=mean, na.rm=TRUE, conf.level=0.80, bci.method="norm", R=5000) 
#     mean      lwr.ci      upr.ci 
# 0.00970241 -0.02184947  0.04127871
set.seed(12345)
DescTools::BootCI(x=y, y=NULL, FUN=mean, na.rm=TRUE, conf.level=0.80, bci.method="basic", R=5000) 
#     mean      lwr.ci      upr.ci 
# 0.00970241 -0.02133602  0.04180539
set.seed(12345)
DescTools::BootCI(x=y, y=NULL, FUN=mean, na.rm=TRUE, conf.level=0.80, bci.method="perc", R=5000) 
#     mean      lwr.ci      upr.ci 
# 0.00970241 -0.02240057  0.04074084 
set.seed(12345)
DescTools::BootCI(x=y, y=NULL, FUN=mean, na.rm=TRUE, conf.level=0.80, bci.method="bca", R=5000) 
#    mean       lwr.ci      upr.ci 
# 0.00970241 -0.02292493  0.04028959
#
# In light of the bootstrapped confidence intervals, we cannot reject the null hypothesis that the true value of the mean of the residuals 
# of the GARCH(1,1) model for the daily logarithm return percentage training set is zero at the $20\%$ significance level. 
#
boot_var <- function(d, k){
  d2 <- d[k,]
  return(var(d2$y))
}
boot_var(d)
# 1.00111
# change or turn off set.seed() if you want the results to vary
set.seed(12345)
booted_var <- boot(d, boot_var, R=5000)
show(booted_var)
# ORDINARY NONPARAMETRIC BOOTSTRAP
# Call: boot(data=d, statistic=boot_var, R=5000)
# Bootstrap Statistics :
#     original      bias      std. error
# t1* 1.00111   0.0007139666   0.1062945
#
summary(booted_var)
#    R   original  bootBias     bootSE    bootMed
# 1 5000 1.0011   0.00071397    0.10629    0.9897
#
booted_var.ci <- boot.ci(boot.out=booted_var, conf=0.80, type=c("norm", "basic", "perc", "bca"))
show(booted_var.ci)
# 
# BOOTSTRAP CONFIDENCE INTERVAL CALCULATIONS
# Based on 5000 bootstrap replicates
# CALL:  boot.ci(boot.out=booted_mean, conf=0.8, type=c("norm", "basic", "perc", "bca"))
# Intervals: Level      Normal            Basic         
#             80%   (0.864,  1.137)   (0.864,  1.128)  
#            Level     Percentile          BCa          
#             80%   (0.874,  1.138)   (0.901,  1.208)  
# Calculations and Intervals on Original Scale
#
# Alternatively,
set.seed(12345)
DescTools::BootCI(x=y, y=NULL, FUN=var, na.rm=TRUE, conf.level=0.80, bci.method="norm", R=5000) 
#    var      lwr.ci      upr.ci 
# 1.0011097  0.8641739   1.1366177 
set.seed(12345)
DescTools::BootCI(x=y, y=NULL, FUN=var, na.rm=TRUE, conf.level=0.80, bci.method="basic", R=5000) 
#    var      lwr.ci      upr.ci 
# 1.0011097  0.8639103   1.1279049
set.seed(12345)
DescTools::BootCI(x=y, y=NULL, FUN=var, na.rm=TRUE, conf.level=0.80, bci.method="perc", R=5000) 
#    var      lwr.ci     upr.ci 
# 1.0011097  0.8743146  1.1383092
set.seed(12345)
DescTools::BootCI(x=y, y=NULL, FUN=var, na.rm=TRUE, conf.level=0.80, bci.method="bca", R=5000) 
#    var      lwr.ci      upr.ci 
# 1.0011097  0.9013402  1.2076123
#
# In light of the bootstrapped confidence intervals, we cannot reject the null hypothesis that the true value of the variance of the 
# residuals of the GARCH(1,1) model for the daily logarithm return percentage training set is zero at the $20\%$ significance level. 
#
# We check the possible autocorrelation.
# Autocorrelogram of the standardized residuals of the GARCH(1,1) model for the SP500 daily logarithm return percentage training set.
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
# Aut_Fun_y <- stats::acf(y, lag.max=max_lag, type="correlation", plot=FALSE)
Aut_Fun_y <- TSA::acf(y, lag.max=max_lag, type="correlation", plot=TRUE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Aut_Fun_y <- data.frame(lag=Aut_Fun_y$lag, acf=Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Autocorrelogram of the Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
ggplot(Plot_Aut_Fun_y, aes(x=lag, y=acf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), lwd=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
#
# The autocorrelogram provides visual evidence for the lack of autocorrelation at the $10\%$ significance level.
#
# Partial autocorrelogram of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model for the SP500 daily percentage 
# logarithm returns training
# set.
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Part_Aut_Fun_y <- stats::pacf(y, lag.max=max_lag, type="correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Part_Aut_Fun_y <- data.frame(lag=Part_Aut_Fun_y$lag, pacf=Part_Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Partial Autocorrelogram of the Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
x_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
ggplot(Plot_Part_Aut_Fun_y, aes(x=lag, y=pacf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=pacf), size=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="pacf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
#
# The partial autocorrelogram also provides visual evidence for the lack of autocorrelation at the $10\%$ significance level.
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
FitAR::LjungBoxTest(y, k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
# Warning message: In (ra^2)/(n - (1:lag.max)): longer object length is not a multiple of shorter object length
# m   Qm    pvalue
# 1 1.34 0.2466391
# 2 2.20 0.3331689
# 3 4.30 0.2304137
# 4 5.38 0.2500391
# 5 5.50 0.3574667
# 6 5.71 0.4564825
# 7 6.74 0.4566020
# 8 7.52 0.4820273
# 9 8.61 0.4739354
# 10 9.96 0.4439883
#
lag_seq <- seq(from=1, to=max_lag, by=1)
y_LB_portes <- portes::LjungBox(y, lags=lag_seq, fitdf=n_pars, sqrd.res=FALSE)
show(y_LB_portes)
# lags statistic df  p-value
# 1 0.02678663  1 0.8699939
# 2 1.36980990  2 0.5041381
# 3 2.22627927  3 0.5267907
# 4 4.33371173  4 0.3627227
# 5 5.41476737  5 0.3673825
# 6 5.53436940  6 0.4773125
# 7 5.73981616  7 0.5704368
# 8 6.76925181  8 0.5617211
# 9 7.54802577  9 0.5802549
# 10 8.64274268 10 0.5663105
#
# The Ljung-Box test confirms the lack of autocorrelation at the $10\%$ significance level.
#
# We also consider the Breusch-Godfrey test for autocorrelation.
# Note that the Breusch-Godfrey test test applies on the residuals from a linear regression.
# Therefore, we can apply it on the trivial linear regression of the standardized residuals of the GARCH(1,1) model for the SP500 daily 
# logarithm return percentage training set.
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
triv_y_lm <- lm(y~0)
# Note that
identical(y,as.vector(triv_y_lm[["residuals"]]))
# TRUE
#
y_BG_Chisq <- lmtest::bgtest(triv_y_lm, order=10, type="Chisq")
show(y_BG_Chisq)
# Breusch-Godfrey test for serial correlation of order up to 10
# data:  triv_y_lm
# LM test=8.6728, df=10, p-value=0.5634
#
y_BG_F <- lmtest::bgtest(triv_y_lm, order=10, type="F")
show(y_BG_F)
# Breusch-Godfrey test for serial correlation of order up to 7
# data:  triv_y_lm
# LM test=0.86661, df1=10, df2=1708, p-value=0.5642
#
# The Breusch-Godfrey test does not allow to reject the null hypothesis that the standardized residuals of the GARCH(1,1) model for the 
# SP500 daily logarithm return percentage training set are uncorrelated at the $10\%$ significance level 

# It is interesting to note that considering the absolute standardized residuals, we obtain
Data_df <- spx_train_df
y <- na.rm(abs(Data_df$GARCH_1_1_stand_res))
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjhyndman.com/hyndsight/ljung-box-test/)
# Aut_Fun_y <- stats::acf(y, lag.max=max_lag, type="correlation", plot=FALSE)
Aut_Fun_y <- TSA::acf(y, lag.max=max_lag, type="correlation", plot=TRUE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Aut_Fun_y <- data.frame(lag=Aut_Fun_y$lag, acf=Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Autocorrelogram of the Absolute Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
Adj_Clox_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
ggplot(Plot_Aut_Fun_y, aes(x=lag, y=acf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=acf), lwd=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="acf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
#
# We have visual evidence for the lack of autocorrelation at the $1\%$ significance level, not at the $5\%$ significance level, though.
Data_df <- spx_train_df
y <- na.rm(abs(Data_df$GARCH_1_1_stand_res))
length <- length(y)
T <- length(y)
# max_lag <- ceiling(10*log10(T))    # Default
# max_lag <- ceiling(sqrt(n)+45)     # Box-Jenkins
max_lag <- ceiling(min(10,T/4))      # Hyndman (for data without seasonality)
# max_lag <- ceiling(min(2*12,T/5))  # Hyndman (for data with seasonality, see https://robjHyndman.com/hy_resndsight/ljung-box-test/)
Part_Aut_Fun_y <- stats::pacf(y, lag.max=max_lag, type="correlation", plot=FALSE)
ci_090 <- qnorm((1+0.90)/2)/sqrt(T)
ci_95 <- qnorm((1+0.95)/2)/sqrt(T)
ci_99 <- qnorm((1+0.99)/2)/sqrt(T)
Plot_Part_Aut_Fun_y <- data.frame(lag=Part_Aut_Fun_y$lag, pacf=Part_Aut_Fun_y$acf)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Partial Autocorrelogram of the Absolute Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
subtitle_content <- bquote(paste("path length ", .(length), " sample points,  ", "lags ", .(max_lag), ".  Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("lags")
x_breaks_num <- max_lag
x_binwidth <- 1
Adj_Clox_breaks <- as.vector(Aut_Fun_y$lag)
x_labs <- format(x_breaks, scientific=FALSE)
ggplot(Plot_Part_Aut_Fun_y, aes(x=lag, y=pacf)) + 
  geom_segment(aes(x=lag, y=rep(0,length(lag)), xend=lag, yend=pacf), size=1, col="black") +
  geom_hline(aes(yintercept=-ci_090, color="CI_090"), lwd=0.9, lty=3, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_090, color="CI_090"), lwd=0.9, lty=3) +
  geom_hline(aes(yintercept=ci_95, color="CI_95"), lwd=0.8, lty=2, show.legend=TRUE) + 
  geom_hline(aes(yintercept=-ci_95, color="CI_95"), lwd=0.8, lty=2) +
  geom_hline(aes(yintercept=-ci_99, color="CI_99"), lwd=0.8, lty=4, show.legend=TRUE) +
  geom_hline(aes(yintercept=ci_99, color="CI_99"), lwd=0.8, lty=4) +
  scale_x_continuous(name= "lag", breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name="pacf value", breaks=waiver(), labels=NULL,
                     sec.axis=sec_axis(~., breaks=waiver(), labels=waiver())) +
  scale_color_manual(name="Conf. Inter.", labels=c("90%","95%","99%"), values=c(CI_090="green", CI_95="blue", CI_99="red"),
                     guide=guide_legend(override.aes=list(linetype=c("dotted", "dashed", "dotdash")))) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=0, vjust=1, hjust=0.5),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
#
# We have visual evidence for autocorrelation at the $1\%$ significance level.
#
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
FitAR::LjungBoxTest(abs(y), k=n_pars, lag.max=max_lag, StartLag=1, SquaredQ=FALSE)
# Warning message: In (ra^2)/(n - (1:lag.max)): longer object length is not a multiple of shorter object length
#  m   Qm     pvalue
#  1  0.22 0.63780801
#  2  1.82 0.40243890
#  3  8.13 0.04342288
#  4  8.19 0.08478211
#  5  8.54 0.12897248
#  6 15.02 0.02011295
#  7 16.63 0.01994940
#  8 16.68 0.03358931
#  9 16.93 0.04986177
# 10 17.15 0.07110163
#
lag_seq <- seq(from=1, to=max_lag, by=1)
y_LB_portes <- portes::LjungBox(abs(y), lags=lag_seq, fitdf=n_pars, sqrd.res=FALSE)
show(y_LB_portes)
# lags  statistic df    p-value
#  1  0.2758388  1 0.59944170
#  2  0.4975883  2 0.77974046
#  3  2.0973241  3 0.55245430
#  4  8.4094103  4 0.07768119
#  5  8.4729327  5 0.13202573
#  6  8.8188192  6 0.18402687
#  7 15.3031548  7 0.03230391
#  8 16.9148511  8 0.03100804
#  9 16.9681682  9 0.04921680
# 10 17.2133319 10 0.06977477
#
# We have computational evidence for the lack of autocorrelation at the $5\5$ significance level.
#
# Although the results of the visual and computational tests are somewhat ambiguous regarding the absolute residuals, the GARCH(1,1) model
# appears to have eliminated most of the autocorrelation in the logarithm percentage returns.
#
# We test the homoscedasticity in the standardized residuals of the GARCH(1,1) model for the SP500 daily logarithm return percentage
# training set.
Data_df <- spx_train_df
head(Data_df)
y <- na.rm(abs(Data_df$GARCH_1_1_stand_res))
head(y,20)
# [1] 0.4144350 1.7419601 0.1388852 0.2739446 0.3934785 2.3160671 2.1750189 0.9879875 0.6733973 0.8577650 0.1677307 0.4519716 0.3269755 0.3293429
# [15] 1.4429839 0.1135800 0.4322909 0.5793139 0.8429184 0.4242169
#
# We start with introducing the linear model used for the Breusch-Pagan test.
x <- 1:length(y)
BP_lm <- lm(y~x)
BP_lm_res <- BP_lm[["residuals"]]
#
# We consider the possible heteroscedasticity of the residuals in the linear model used for the Breusch-Pagan test.
def_mar <- par("mar")
par(mfrow=c(2,1), mar=c(1,1,1,1))
plot(BP_lm,1)
plot(BP_lm,3)
par(mfrow=c(1,1), mar=def_mar)
#
# From the Residual vs Fitted plot, we do not have visual evidence for heteroscedasticity in the residuals. We have strong visual evidence
# for skewness, though. The LOESS curve appears to be flat and the spread of the residuals around the LOESS curve appears to be rather
# homogeneous. The visual evidence from the Scale-Location plot essentially confirms the visual evidence from the Residual vs Fitted plot:
# an almost flat horizontal LOESS curve suggests the absence of non linear forms of heteroscedasticity in the residual time series.
# We check the kurtosis of the residuals in the linear model used for the Breusch-Pagan test.
DescTools::Kurt(BP_lm_res, weights=NULL, method=2, conf.level=0.99, ci.type="classic") 
#   kurtosis    lwr.ci    upr.ci
#  1.0824529 -0.4786685  0.4786685 
#
# The estimated value of the excess kurtosis of the standardized residuals of the estimated GARCH(1,1) model severely conflicts with a 
# possible Gaussian distribution of the residuals at the $1\%$ significance level. We proceed with other non-parametric tests
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.95, ci.type="norm", R=5000) 
#   kurt      lwr.ci     upr.ci 
# 1.08245288 -0.03483036  2.30079681 
#
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL,  na.rm=TRUE, method=2, conf.level=0.99, ci.type="norm", R=5000) 
#
#   kurt     lwr.ci    upr.ci 
# 1.082453 -0.401784  2.667750 
#
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="basic", R=5000) 
#    kurt     lwr.ci     upr.ci 
# 1.0824529 -0.5595086  2.5182957
#
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="perc", R=5000) 
#     kurt     lwr.ci     upr.ci 
# 1.0824529 -0.3533899  2.7244144  
# 
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="bca", R=5000) 
#     kurt     lwr.ci    upr.ci 
# 1.08245288 -0.08915911  3.38782131  
# Warning message: In norm.inter(t, adj.alpha) : extreme order statistics used as endpoints
#
set.seed(12345)
DescTools::Kurt(BP_lm_res, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="bca", R=50000)
#     kurt     lwr.ci    upr.ci 
# 1.0824529 -0.1219101  3.1479135   
# Warning message: In norm.inter(t, adj.alpha) : extreme order statistics used as endpoints
#
# The bootstrapped confidence intervals of type "norm" at the $95\%$ [resp. $99\%$] confidence level does not [resp. does] contain zero.
# Hence, we must [resp. we cannot] reject the null hypothesis of mesokurtic residuals in the linear model for the Breusch-Pagan test at the
# $5\%$ [resp. $1\%$] significance level. On the other hand, the bootstrapped confidence intervals of type "basic", "perc", and "bca" do not
# contain zero. Hence, referring to these confidence intervals, we must reject the null hypothesis of mesokurtic residuals in the linear 
# model for the Breusch-Pagan testat the $1\%$ significance level. In light of this, we execute the Breusch-Pagan and White test in the
# Koenker (studentised) modification.
#
#
lmtest::bptest(BP_lm, varformula=NULL, studentize=TRUE, data=NULL)
# studentized Breusch-Pagan test
# data:  BP_lm
# BP = 1.7896, df = 1, p-value = 0.181
#
#
skedastic::breusch_pagan(BP_lm, koenker=TRUE)
# statistic  p.value  parameter       method          alternative
#      1.79   0.181       1     Koenker (studentised) greater      
#
#
olsrr::ols_test_score(BP_lm, fitted_values=TRUE, rhs=FALSE)
# Score Test for Heteroskedasticity
# ---------------------------------
#   Ho: Variance is homogenous
#   Ha: Variance is not homogenous
# 
# Variables: fitted values of y 
# Test Summary          
# -----------------------------
# DF           =   1 
# Chi2         =   1.789641 
# Prob > Chi2  =   0.18097  
#
# We cannot reject the null of homoscedasticity at the %10\%$ significance level. 
# We consider the White test.
#
Data_df <- spx_train_df
y <- na.rm(abs(Data_df$GARCH_1_1_stand_res))
head(y,20)
# [1] 0.2754854 2.0878992 0.1470659 1.1528523 1.0903893 1.2415021 0.9811109 0.3841106 0.7926566 0.1854945 0.6840742
# [12] 0.2435354 0.3112024 1.7854621 0.7439277 0.3410520 0.7627852 0.3826869 0.3198917 0.1174064
x <- 1:length(y)
BP_lm <- lm(y~x)
BP_lm_res <- BP_lm[["residuals"]]
z <- BP_lm_res^2
Het_Data <- data.frame(x,y,z)
head(Het_Data)
W_lm <- lm(z~x+I(x^2))
#
lmtest::bptest(BP_lm, W_lm, studentize=TRUE, data=NULL)
# studentized Breusch-Pagan (White) test
# data: BP_lm, W_lm
# BP=1.8332, df = 2, p-value = 0.3999
#
#
lmtest::bptest(y~x, z~x+I(x^2), studentize=TRUE, data=Het_Data)
# studentized Breusch-Pagan (White) test
# data:  y ~ x
# BP=1.8332, df = 2, p-value = 0.3999
#
#
skedastic::white(BP_lm, interactions=FALSE, statonly=FALSE)
# statistic  p.value  parameter       method    alternative
#   1.83      0.400      2        White's Test  greater    
#
# library(whitestrap)
white_test(BP_lm)
# White's test results
# Null hypothesis: Homoskedasticity of the residuals
# Alternative hypothesis: Heteroskedasticity of the residuals
# Test Statistic: 1.83
# P-value: 0.399868
#
# Confirming the visual evidence of the scale location plot, the White test does not allow us to reject the null of homoscedasticity at the
# $10\%$ significance level. Due to the sounding results of the studentized Breusch-Pagan and White test, we cannot reject the null of 
# homoscedasticity at the $10\%$ significance level.
# Recall that the Breusch-Pagan test is a test for linear forms of heteroscedasticity, e.g., as y-hat goes up, the error variance goes up. 
# Even in the studentized form, the test does not work well for non-linear forms of heteroscedasticity (where error variance gets larger as
# the explanatory variable gets more extreme in either direction). The White test is more reliable for such cases 
# (see https://www3.nd.edu/~rwilliam/stats2/l25.pdf).
#
# With the goal of testing for Gaussianity of the standardized residual distribution we consider the issue of the possible skewness and
# kurtosis of the standardized residuals. First, the skewness
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
head(y,20)
# [1]  -0.2754854 -2.0878992  0.1470659 -1.1528523  1.0903893 -1.2415021  0.9811109  0.3841106  0.7926566 -0.1854945
# [11] -0.6840742 -0.2435354  0.3112024  1.7854621  0.7439277  0.3410520  0.7627852  0.3826869  0.3198917 -0.1174064
#
DescTools::Skew(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="classic") 
#      skew       lwr.ci       upr.ci 
#  -0.2263499     -0.2396774   0.2396774
#
# The estimated value of the skewness of the standardized residuals of the estimated GARCH(1,1) model conflicts with a possible Gaussian 
# distribution of the standardized residuals at the $1/%$ significance level. However, the bootstrapped confidence intervals do not allow
# us to exclude that an unskewed distribution generates the standardized residuals at the $10\%$ significance level. In fact, we have
set.seed(12345)
DescTools::Skew(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.85, ci.type="norm", R=5000) 
#     skew         lwr.ci       upr.ci 
# -0.22634993   -0.38156941   -0.07736452
#
set.seed(12345)
DescTools::Skew(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.85, ci.type="basic", R=5000) 
#     skew       lwr.ci       upr.ci 
# -0.22634993 -0.38114792 -0.07547849
#
set.seed(12345)
DescTools::Skew(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.85, ci.type="perc", R=5000) 
#     skew       lwr.ci      upr.ci 
# -0.22634993 -0.37722136 -0.07155193
#
set.seed(12345)
DescTools::Skew(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.85, ci.type="bca", R=5000) 
#     skew       lwr.ci      upr.ci 
# -0.22634993 -0.38563399 -0.07856755
#
set.seed(12345)
DescTools::Skew(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.90, ci.type="bca", R=5000) 
#      skew       lwr.ci       upr.ci 
# -0.22634993 -0.40663644 -0.05968246  
#
# The skewness of the standardized residuals is estimated at approximately -0.226,
# suggesting a slight leftward asymmetry. Classic 99% confidence intervals include zero,
# indicating that normality cannot be fully rejected. However, bootstrap confidence intervals 
# (e.g., 85% level) exclude zero, pointing to potential non-normality. These results imply 
# that a GED or STD distribution might better model the residuals, as it allows for slight 
# asymmetry compared to a standard Gaussian distribution.
#
# Second, the kurtosis
DescTools::Kurt(y, weights=NULL, method=2, conf.level=0.99, ci.type="classic") 
#   kurtosis    lwr.ci    upr.ci
#  0.2734216 -0.4786685  0.4786685 
#
# The estimated value of the excess kurtosis of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model severely 
# conflicts with a possible Gaussian distribution of the standardized residuals at the $1\%$ significance level. The bootstrapped confidence
# intervals of type "norm" and "basic" do not allow to exclude that a mesokurtic distribution generates the standardized residuals at the 
# $5\%$ significance level. In contrast, the bootstrapped confidence intervals of type "perc" and "bca" support rejecting the null 
# hypothesis that a mesokurtic distribution might generate the standardized residuals in favor of a leptokurtic distribution at the $1\%$ 
# significance level.
# 
set.seed(12345)
DescTools::Kurt(y, weights=NULL, method=2, conf.level=0.95, ci.type="norm", R=5000) 
#   kurt       lwr.ci     upr.ci 
# 0.2734216 -0.2221711  0.7973110
#
set.seed(12345)
DescTools::Kurt(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.95, ci.type="basic", R=5000) 
#    kurt     lwr.ci     upr.ci 
# 0.2734216 -0.2579279  0.7533121
#
set.seed(12345)
DescTools::Kurt(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="perc", R=5000) 
#     kurt     lwr.ci    upr.ci 
# 0.2734216 -0.3208366  1.0221296
# 
set.seed(12345)
DescTools::Kurt(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="bca", R=5000) 
#     kurt     lwr.ci    upr.ci 
# 0.2734216 -0.2305881  1.3250635
#
set.seed(12345)
DescTools::Kurt(y, weights=NULL, na.rm=TRUE, method=2, conf.level=0.99, ci.type="bca", R=50000)
#     kurt     lwr.ci    upr.ci 
# 0.2734216 -0.2249950  1.2110041  
#
# The bootstrapped confidence intervals of type "norm" and "basic" at the $95\%$ confidence level contain zero. Hence, we cannot reject the
# null hypothesis of mesokurtic standardized residuals at the $5\%$ significance level. On the other hand, The bootstrapped confidence 
# intervals of type "perc" and "bca" at the $99\%$ confidence level do not contain zero. Hence, we must reject the null hypothesis of mesokurtic
# standardized residuals at the $1\%$ significance level.
#
# In light of the results of the non-parametric test for skewness and kurtosis on the standardized residuals of the SP500 daily percentage
# logarithm returns training set, we must reject at the $1\%$ significance level that the standardized residuals might be Gaussian 
# distributed. The following normality tests strengthen this evidence.
#
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
head(y,20)
# -0.2754854 -2.0878992  0.1470659 -1.1528523  1.0903893 -1.2415021  0.9811109  0.3841106  0.7926566 -0.1854945
# -0.6840742 -0.2435354  0.3112024  1.7854621  0.7439277  0.3410520  0.7627852  0.3826869  0.3198917 -0.1174064
#
# Shapiro-Wilks (*SW*) test.
stats::shapiro.test(y)
# Shapiro-Wilk normality test
# data:  y
# W=0.99359, p-value = 0.004901
#
# D'Agostino Pearson (*DP*) test.
# library(fBasics)
fBasics::dagoTest(y)
# D'Agostino Normality Test
# Test Results:
#   STATISTIC:
#     Chi2 | Omnibus: 7.8296
#     Z3  | Skewness: -2.4185
#     Z4  | Kurtosis: 1.4074
#   P VALUE:
#     Omnibus  Test: 0.01994
#     Skewness Test: 0.01559  
#     Kurtosis Test: 0.1593
#
# Anderson-Darling (AD) test.
# library(nortest)
nortest::ad.test(y)
# Anderson-Darling normality test
# data:  y
# A=1.082, p-value = 0.007686
#
# Jarque-Bera (*JB*) test.
tseries::jarque.bera.test(y)
# Jarque Bera Test
# data:  y
# X-squared=7.8513, df = 2, p-value = 0.01973
#
# Normality tests for standardized residuals of the GARCH(1,1) model:
# - The Shapiro-Wilk test (p = 0.0049) rejects the null hypothesis of normality.
# - The D’Agostino-Pearson test (Omnibus p = 0.01994) suggests non-normality with significant skewness (p = 0.01559),
#   though kurtosis is not significantly different from normal (p = 0.1593).
# - The Anderson-Darling test (p = 0.007686) also rejects normality, especially highlighting deviations in the tails.
# - The Jarque-Bera test (p = 0.01973) confirms these findings, indicating non-normal skewness and/or kurtosis.
# Conclusion: All tests reject normality for the standardized residuals, suggesting that a normal distribution 
# does not adequately capture the characteristics of these residuals, which show skewness and/or heavy tails.
################################################################################################################################################
# Despite we must reject the null hypothesis that the standardized residuals of the SP500 daily logarithm return percentage training set 
# are Gaussian distributed at the $1\%$ significance level, the rather good results in terms of stationarity, lack of autocorrelation, and 
# homoscedasticity, advocate the attempt to determine their distribution by means of a parametric approach.
# 
# We start with considering a Cullen-Frey graph.
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
head(y,20)
#  -0.2754854 -2.0878992  0.1470659 -1.1528523  1.0903893 -1.2415021  0.9811109  0.3841106  0.7926566 -0.1854945
# -0.6840742 -0.2435354  0.3112024  1.7854621  0.7439277  0.3410520  0.7627852  0.3826869  0.3198917 -0.1174064
#
# We have already computed the confidence intervals for the mean and the variance of the standardized residuals of the SP500 daily
# logarithm return percentage training set and we have found that they are actually standardized at the $20\%$ significance level.
# Therefore, we apply directly on them the procedures to determine their possible distribution.
#
# We apply a Cullen-Frey graph on the standardized residuals
# library(survival)
# library(MASS)
# library(fitdistrplus)
set.seed(12345)
fitdistrplus::descdist(y, discrete=FALSE, method= "sample", graph=TRUE, boot=5000)
# summary statistics
# ------
# min:  -3.719848   max:  3.501835 
# median:  0.03584449 
# mean:  0.0396896 
# sample sd:  0.9988566 
# sample skewness:  -0.2258576 
# sample kurtosis:  3.262761 
#
# The Cullen-Frey graph appears to be split into three areas. This is likely due to the presence of some outliers in the data set. However, 
# we have a visual insight that the data set is possibly skewed Student distributed. We will explore this possibility in more detail.
# We compute the empirical quantiles, empirical density function, and empirical distribution function of the standardized residuals.
# library(EnvStats)
y_qemp <- EnvStats::qemp(stats::ppoints(y), y) # Empirical quantiles of the data set y.
y_demp <- EnvStats::demp(y_qemp, y)     # Empirical probability density of the data set y.
y_pemp <- EnvStats::pemp(y_qemp, y)     # Empirical distribution function of the data set y.  
x <- y_qemp
y_d <- y_demp
y_p <- y_pemp
#
# With reference to the fGarch library, we plot the histogram of the standardized residuals together with the empirical density function, 
# the Standard Gaussian Distribution Density function, the generalized Error Distribution Density Function (GED) with mean parameter, mean=0, standard deviation 
# parameter, sd=1, and shape parameter, nu=1, and the standardized Student-t distribution (STD) with mean parameter, 
# mean=0, standard deviation parameter, sd=1, and degrees of freedom (shape) parameter, nu=3.
# Note that the standardized GED [resp. STD] is defined so that for a given standard deviation parameter, sd, it has the same variance, sd^2, 
# for all values of the shape parameter [resp. degrees of freedom parameter]. For comparison, the variance of the usual Student-t 
# distribution is nu/(nu-2), where nu is the degrees of freedom. The usual Student-t distribution is obtained by setting 
# sd=sqrt(nu/(nu - 2)). (see Wuertz D., Chalabi Y. and Luksan L. - Parameter estimation of ARMA models with GARCH/APARCH errors: An R and
# SPlus software implementation, Preprint, 41 pages, https://github.com/GeoBosh/fGarchDoc/blob/master/WurtzEtAlGarch.pdf).
#
# library(fGarch)
png(filename = "plots/SP500_GARCH_dens_func_Standardized_Residuals.png", 
    width = 1400, height = 600, units = "px", res = 100)
mean <- 0
sd <- 1
GED_nu <- 1
STD_nu <- 3
GED_leg <- bquote(paste("Generalized Error Distribution Density Function: mean=", .(mean),", standard deviation=", .(sd), ", shape=", .(GED_nu)))
STD_leg <- bquote(paste("Standardized Student-t Distribution: mean=", .(mean),", standard deviation=", .(sd), ", degrees of freedom=", .(STD_nu)))
#plot(x, y_d, xlim=c(x[1]-2.0, x[length(x)]+2.0), ylim=c(0, y_d[length(y_d)]+0.75), type= "n")
hist(y, breaks= "Scott", col= "cyan", border= "black", xlim=c(x[1]-1.0, x[length(x)]+1.0), ylim=c(0, y_d[length(y)]+0.75), 
     freq=FALSE, main= "Density Histogram and Empirical Density Function of the Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage Training Set", 
     xlab= "Standardized Residuals", ylab= "Histogram & Density Functions Values", cex.main=0.7)
# lines(x, y_d, lwd=2, col= "darkblue")
lines(density(y), lwd=2, col= "darkblue")
lines(x, dnorm(x, m=0, sd=1), lwd=2, col= "red")
lines(x, fGarch::dged(x, mean=0, sd=1, nu=1, log=FALSE), lwd=2, col= "magenta")
lines(x, fGarch::dstd(x, mean=0, sd=1, nu=3), lwd=2, col= "darkgreen")
legend("topleft", legend=c("Empirical Density Function", "Standard Gaussian Distribution Density Function", GED_leg, STD_leg), 
       col=c("darkblue", "red","magenta","darkgreen"), 
       lty=1, lwd=0.1, cex=0.8, x.intersp=0.50, y.intersp=0.70, text.width=2, seg.len=1, text.font=4, box.lty=0,
       inset=-0.01, bty= "n")
dev.off()
#
# We also compare the empirical distribution function of the standardized residuals with the distribution functions of the GED and STD.
png(filename = "plots/SP500_GARCH_distr_func_Standardized_Residuals.png", 
    width = 1400, height = 600, units = "px", res = 100)
mean <- 0
sd <- 1
GED_nu <- 1
STD_nu <- 3
GED_leg <- bquote(paste("Generalized Error Distribution Density Function: mean=", .(mean),", standard deviation=", .(sd), ", shape=", .(GED_nu)))
STD_leg <- bquote(paste("Standardized Student-t Distribution: mean=", .(mean),", standard deviation=", .(sd), ", degrees of freedom=", .(STD_nu)))
#dev.new()
EnvStats::ecdfPlot(y, discrete=TRUE, prob.method= "emp.probs", type= "s", plot.it=TRUE, 
                   add=FALSE, ecdf.col= "cyan", ecdf.lwd=2, ecdf.lty=1, curve.fill=TRUE,  
                   main= "Empirical Distribution Function of the Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage  Training Set", 
                   xlab= "Standardized Residuals", ylab= "Probability Distribution", xlim=c(x[1]-1.0, x[length(x)]+1.0), cex.main=0.8)
lines(x, y_p, lwd=2, col= "darkblue")
lines(x, pnorm(x, m=0, sd=1), lwd=2, col= "red")
lines(x, fGarch::pged(x, mean=0, sd=1, nu=1), lwd=2, col= "magenta")
lines(x, fGarch::pstd(x, mean=0, sd=1, nu=3), lwd=2, col= "darkgreen")
legend("topleft", legend=c("Empirical Density Function", "Standard Gaussian Distribution Density Function", GED_leg, STD_leg), 
       col=c("darkblue", "red","magenta","darkgreen"), 
       lty=1, lwd=0.1, cex=0.8, x.intersp=0.50, y.intersp=0.70, text.width=2, seg.len=1, text.font=4, box.lty=0,
       inset=-0.01, bty= "n")
#
dev.off()
#
# In light of the presented plots, we try to estimate the shape parameter of the GED and the degrees of freedom parameter of the STD to
# better adapt them to the empirical distribution of the standardized residuals.
# For this task, the fGarch package provides two functions fGarch::gedFit() and fGarch::stdFit(). However, these functions estimate the 
# whole set of the parameters of the theoretical distribution to adapt it to the empirical distribution and do not allow for the estimation 
# of only a subset of the parameters. Furthermore, in the case of the GED, the estimation procedure is unreliable due to a false convergence 
# issue. In fact,
gedFit_x <- fGarch::gedFit(x)
show(gedFit_x)
# $par
# mean         sd         nu 
# 0.04362647 1.00126051 1.70521545 
# 
# $objective
# [1] 977.9994
# 
# $convergence
# [1] 0
# 
# $iterations
# [1] 23
# 
# $evaluations
# function gradient 
# 30       95 
# 
# $message
# [1] "relative convergence (4)"
#
stdFit_x <- fGarch::stdFit(x)
show(stdFit_x)
# $par
# mean         sd         nu 
# 0.04744185  1.00100848 23.82194897 
# 
# $objective
# [1] 978.77
# 
# $convergence
# [1] 0
# 
# $iterations
# [1] 105
# 
# $evaluations
# function gradient 
# 114      337 
# 
# $message
# [1] "relative convergence (4)"
#
# The fitdistrplus package provides a more general fitdistrplus::fitdist() function that can be fed by the density of the distributions GED
# and SDT provided by the fGarch package and is flexible enough to allow the estimation of only a subset of the parameters.
fitdist_ged <- fitdistrplus::fitdist(y, dged, start=list(nu=1), fix.arg=list(mean=0, sd=1), method= "mle")
summary(fitdist_ged)
# Fitting of the distribution ' ged ' by maximum likelihood 
# Parameters : estimate  Std. Error
#           nu 1.724517  0.1507497
# Fixed parameters: value
#           mean     0
#           sd       1
# Loglikelihood:  -977.3999   AIC:  1956.8   BIC:  1961.337 
#
# Moreover, by means of the object generated by the fitdistrplus::fitdist() function we can also evaluate the uncertainty in estimated 
# parameters of the fitted distribution by means of the fitdistrplus::bootdist() function.
set.seed(12345)
fitdist_ged_bd <- bootdist(fitdist_ged, niter=1000)
summary(fitdist_ged_bd)
# Parametric bootstrap medians and 95% percentile CI 
#     Median      2.5%     97.5% 
#   1.722648  1.484592  2.043908
#
# For cross-checking the result of the fitdistrplus::fitdist() function, we also consider more estimates of the GED shape parameter by 
# tackling the log-likelihood function direct maximization. We start writing the log-likelihood function to be maximized. Note that we again
# use the GED density provided by the fGarch package.
opt_ged_minus_logLik <- function(x) -sum(log(dged(y, mean=0, sd=1, nu=x)))
# Hence, we tackle the optimization of the log-likelihood function by means of the function stats::optimize().
opt_ged_result <- stats::optimize(f=opt_ged_minus_logLik, interval=c(1,2), maximum=FALSE, tol=1e-09)
show(opt_ged_result)
# $minimum 1.723783
# 
# $objective 977.3999
#
# We also show how to apply the rather powerful pracma::fminunc() and pracma::fmincon() functions conceived to optimize multivariate
# functions.
# First, we rewrite the log-likelihood of the GED, fictitiously transformed into a multivariate function by adding a quadratic
# term.
fmin_minus_logLik <- function(x) x[1]^2-sum(log(dged(y, mean=0, sd=1, nu=x[2])))
#
# Second, we fix the initial points of the unconstrained maximization procedure, that we choose as the median provided by the 
# fitdistrplus::bootdist() function.
nu0 <- as.vector(fitdist_ged_bd[["CI"]][["Median"]])
show(nu0)
# 1.722648
# Then, we launch the unconstrained maximization procedure.
# library(NlcOptim)
# library(pracma)
fminunc_result <- pracma::fminunc(fn=fmin_minus_logLik, x0=c(0, nu0), tol=1e-08)
show(fminunc_result)
# $par   x[1]    x[2]=nu
# [1] 0.0000000 1.723783
# 
# $value
# [1] 977.3999
# 
# $counts
# function gradient 
# 21        6 
# 
# $convergence
# [1] 0
# 
# $message
# [1] "Rvmminu converged"
#
# In the end, we consider the constrained optimization procedure where (0,nu0) is the starting point and we use the confidence interval 
# endpoints provided by the fitdistrplus::bootdist() function to build the multivariate constraint.
nu0 <- as.vector(fitdist_ged_bd[["CI"]][["Median"]])
nu_min <- as.vector(fitdist_ged_bd[["CI"]][["2.5%"]])
nu_max <- as.vector(fitdist_ged_bd[["CI"]][["97.5%"]])
show(c(nu0,nu_min,nu_max))
# 1.722648 1.484592 2.043908
#
fmincon_result <- pracma::fmincon(fn=fmin_minus_logLik, x0=c(0, nu0), lb=c(-1, nu_min), ub=c(1, nu_max), tol=1e-06, maxfeval=10000, maxiter=5000) 
# fmincon_result <- pracma::fmincon(fn=minus_logLik, x0=c(0, nu0), lb=c(-1, nu_min), ub=c(1, nu_max), tol=1e-06, maxfeval=1e+09, maxiter=1e+09)   
show(fmincon_result)
# $par   x[1]    x[2]=nu
# [1] 0.0000000 1.723783
# 
# $value
# [1] 977.3999
# 
# $convergence
# [1] 0
# 
# $info$grad
# [,1]
# [1,] 0.0000000000
# [2,] 0.0000221298
# 
# $info$hessian
# [,1]     [,2]
# [1,]    1   0.0000
# [2,]    0 44.05423
#
# Now, we apply the above procedure to the STD distribution. 
fitdist_std <- fitdistrplus::fitdist(y, dstd, start=list(nu=5), fix.arg=list(mean=0, sd=1), method= "mle")
summary(fitdist_std)
# Parameters:  estimate Std. Error
#          nu 30.05425   29.10536
# Fixed parameters: value
#            mean     0
#            sd       1
# Loglikelihood:  -978.2271   AIC:  1958.454   BIC:  1962.991 
#
set.seed(12345)
fitdist_std_bd <- bootdist(fitdist_std, niter=1000)
summary(fitdist_std_bd)
# Parametric bootstrap medians and 95% percentile CI 
#    Median     2.5%    97.5% 
#  30.05755 18.16848 169.16188 
#
# We write the log-likelihood function to be maximized. Note that we again use the GED density provided by the fGarch package.
opt_std_minus_logLik <- function(x) -sum(log(dstd(y, mean=0, sd=1, nu=x)))
opt_std_result <- stats::optimize(f=opt_std_minus_logLik, interval=c(2,100), maximum=FALSE, tol=1e-09)   # the minimization procedure where nu is the starting point.
show(opt_std_result)
# $minimum 30.23046
# 
# $objective 978.2271
#
# We rewrite the log-likelihood of the GED, fictitiously transformed into a multivariate function by adding a quadratic term.
fmin_minus_logLik <- function(x) x[1]^2-sum(log(dstd(y, mean=0, sd=1, nu=x[2])))
#
# We fix the initial points of the unconstrained maximization procedure
nu0 <- as.vector(fitdist_std_bd[["CI"]][["Median"]])
show(nu0)
# 30.05755
#
# We consider the unconstrained minimization procedure where (0,nu0) is the starting point.
fminunc_result <- pracma::fminunc(fn=fmin_minus_logLik, x0=c(0, nu0), tol=1e-08)
show(fminunc_result)
# $par  x[1]    x[2]=nu
# [1] 0.000000 30.23047
# 
# $value
# [1] 978.2271
# 
# $counts
# function gradient 
# 5        5 
# 
# $convergence
# [1] 2
# 
# $message
# [1] "Small gradient norm"
#
# We consider the constrained optimization procedure where (0,nu0) is the starting point and we use the confidence interval endpoints 
# provided by the fitdistrplus::bootdist() function to build the multivariate constraint.
nu0 <- as.vector(fitdist_std_bd[["CI"]][["Median"]])
nu_min <- as.vector(fitdist_std_bd[["CI"]][["2.5%"]])
nu_max <- as.vector(fitdist_std_bd[["CI"]][["97.5%"]])
show(c(nu0,nu_min,nu_max))
# 30.05755  18.16848 169.16188
#
fmincon_result <- pracma::fmincon(fn=fmin_minus_logLik, x0=c(0, nu0), lb=c(-1, nu_min), ub=c(1, nu_max), tol=1e-06, maxfeval=10000, maxiter=5000) 
# fmincon_result <- pracma::fmincon(fn=minus_logLik, x0=c(0, nu0), lb=c(-1, nu_min), ub=c(1, nu_max), tol=1e-06, maxfeval=1e+09, maxiter=1e+09)   
show(fmincon_result)
# $par  x[1]           x[2]=nu
# [1] -0.0000005076525 30.0577484031897
# 
# $value
# [1] 978.2271
# 
# $convergence
# [1] 0
# 
# $info$grad
# [,1]
# [1,] 0.0000005076525
# [2,] -0.0002007765620
# 
# $info$hessian
#      [,1] [,2]
# [1,]    1  0
# [2,]    0  1
#
############################################################################################################################################
# From the above results, we select for the GED the parameter nu=1.722648. It is the optimum point commonly estimated by the optimization 
# procedures stats::optimize(), pracma::fminuncn(), and pracma::fmincon(), and it is very similar to the optimum point nu=1.723783 
# estimated by the fitdistrplus::fitdist() procedure with the same loglikelihood loglik=977.3999, till the third decimal digit. Furthermore,
# the parameter nu=1.722648 falls within the $95\%$ confidence interval [1.484592 2.043908] of the parameter true value estimated by the
# fitdistrplus::bootdist() bootstrap procedure.
# 
# Setting
logLik <- -opt_ged_result[["objective"]] # the minimized negative log-likelihood
n <- length(y)
k <- 1
AIC <- 2*k-2*logLik
BIC <- k*log(n)-2*logLik
AICc <- AIC + 2*k*((k+1)/(n-k-1))
# we have
show(c(logLik, AIC, BIC, AICc))
#   logLik      AIC       BIC      AICc
# -1000.594  2003.187  2007.724  2003.193
#
# Similarly, we select for the STD the parameter nu=30.23047. It is the optimum point commonly estimated by the optimization procedures
# stats::optimize(), pracma::fminuncn(), and pracma::fmincon(), and it is very similar to the optimum points nu=30.23046 estimated by the 
# fitdistrplus::fitdist() procedures, respectively, with the same loglikelihood loglik=-2208.051, till the third decimal digit. Furthermore, 
# the parameter nu=30.23047 falls within the $95\%$ confidence interval [18.16848 169.16188] of the parameter true value estimated by the 
# fitdistrplus::bootdist() bootstrap procedure.
# Setting
logLik <- -opt_std_result[["objective"]] # the minimized negative log-likelihood
n <- length(y)
k <- 1
AIC <- 2*k-2*logLik
BIC <- k*log(n)-2*logLik
AICc <- AIC + 2*k*((k+1)/(n-k-1))
# we have
show(c(logLik, AIC, BIC, AICc))
#   logLik      AIC       BIC      AICc
# -978.2271 1958.4542 1962.9909 1958.4600
#
# We plot the histogram and the empirical density function of the standardized residuals together with the density function of the estimated 
# GED and SDT.
png(filename = "plots/SP500_GARCH_dens_fun_Standardized_Residuals_DLRP_TrnS.png", 
    width = 1400, height = 600, units = "px", res = 100)
mean <- 0
sd <- 1
GED_nu <- opt_ged_result[["minimum"]]
STD_nu <- opt_std_result[["minimum"]]
GED_leg <- bquote(paste("Generalized Error Distribution Density Function: mean=", .(mean),", standard deviation=", .(sd), ", shape=", .(GED_nu)))
STD_leg <- bquote(paste("Standardized Student-t Distribution: mean=", .(mean),", standard deviation=", .(sd), ", degrees of freedom=", .(STD_nu)))
#plot(x, y_d, xlim=c(x[1]-2.0, x[length(x)]+2.0), ylim=c(0, y_d[length(y_d)]+0.75), type= "n")
hist(y, breaks= "Scott", col= "cyan", border= "black", xlim=c(x[1]-1.0, x[length(x)]+1.0), ylim=c(0, y_d[length(y)]+0.75), 
     freq=FALSE, main= "Density Histogram and Empirical Density Function of the Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage Training Set", 
     xlab= "Standardized Residuals", ylab= "Histogram & Density Functions Values", cex.main=0.7)
# lines(x, y_d, lwd=2, col= "darkblue")
lines(density(y), lwd=2, col= "darkblue")
lines(x, dnorm(x, m=0, sd=1), lwd=2, col= "red")
lines(x, fGarch::dged(x, mean=0, sd=1, nu=1, log=FALSE), lwd=2, col= "magenta")
lines(x, fGarch::dstd(x, mean=0, sd=1, nu=3), lwd=2, col= "darkgreen")
legend("topleft", legend=c("Empirical Density Function", "Standard Gaussian Distribution Density Function", GED_leg, STD_leg), 
       col=c("darkblue", "red","magenta","darkgreen"), 
       lty=1, lwd=0.1, cex=0.8, x.intersp=0.50, y.intersp=0.70, text.width=2, seg.len=1, text.font=4, box.lty=0,
       inset=-0.01, bty= "n")
dev.off()
#
# We also compare the empirical distribution function of the standardized residuals with the distribution functions of the estimated GED and
# STD.
png(filename = "plots/SP500_GARCH_distr_fun_Standardized_Residuals_DLRP_TrnS.png", 
    width = 1400, height = 600, units = "px", res = 100)
mean <- 0
sd <- 1
GED_nu <- opt_ged_result[["minimum"]]
STD_nu <- opt_std_result[["minimum"]]
GED_leg <- bquote(paste("Generalized Error Distribution Density Function: mean=", .(mean),", standard deviation=", .(sd), ", shape=", .(GED_nu)))
STD_leg <- bquote(paste("Standardized Student-t Distribution: mean=", .(mean),", standard deviation=", .(sd), ", degrees of freedom=", .(STD_nu)))
#dev.new()
EnvStats::ecdfPlot(y, discrete=TRUE, prob.method= "emp.probs", type= "s", plot.it=TRUE, 
                   add=FALSE, ecdf.col= "cyan", ecdf.lwd=2, ecdf.lty=1, curve.fill=TRUE,  
                   main= "Empirical Distribution Function of the Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage  Training Set", 
                   xlab= "Standardized Residuals", ylab= "Probability Distribution", xlim=c(x[1]-1.0, x[length(x)]+1.0), cex.main=0.8)
lines(x, y_p, lwd=2, col= "darkblue")
lines(x, pnorm(x, m=0, sd=1), lwd=2, col= "red")
lines(x, fGarch::pged(x, mean=0, sd=1, nu=1), lwd=2, col= "magenta")
lines(x, fGarch::pstd(x, mean=0, sd=1, nu=3), lwd=2, col= "darkgreen")
legend("topleft", legend=c("Empirical Density Function", "Standard Gaussian Distribution Density Function", GED_leg, STD_leg), 
       col=c("darkblue", "red","magenta","darkgreen"), 
       lty=1, lwd=0.1, cex=0.8, x.intersp=0.50, y.intersp=0.70, text.width=2, seg.len=1, text.font=4, box.lty=0,
       inset=-0.01, bty= "n")
#
dev.off()
#
# We build the Q-Q plot of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model for the SP500 daily percentage 
# logarithm returns training set against the corresponding quantiles of the estimated generalized GED and STD by using the library 
# *qqplotr*, which extends some functionality of the library *ggplot2*. The library *qqplotr* allows to draw also P-P plots.
# 
# First, we build a suitable data frame.
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
head(y,20)
#  0.4144350  1.7419601  0.1388852 -0.2739446  0.3934785  2.3160671 -2.1750189  0.9879875 -0.6733973  0.8577650  0.1677307 -0.4519716
# -0.3269755  0.3293429  1.4429839 -0.1135800  0.4322909 -0.5793139 -0.8429184 -0.4242169
y_qemp <- EnvStats::qemp(ppoints(length(y)), y)
mean <- 0
sd <- 1
nu  <- GED_nu 
distr <- "ged"
distr_pars <- list(mean=0, sd=1, nu=nu)
quants <- fGarch::qged(ppoints(length(y)), mean=0, sd=1, nu=nu)
QQ_plot_df <- data.frame(T=1:length(y), Q=quants, X=y, Y=y_qemp)
head(QQ_plot_df)
# Second we draw the Q-Q plot of the residuals.
# library(qqplotr)
Data_df <- QQ_plot_df
length <- nrow(Data_df)
quart_probs <- c(0.25,0.75)
quart_X <- as.vector(quantile(QQ_plot_df$X, quart_probs))
quart_Q <- qged(quart_probs, mean=0, sd=1, nu=nu)
slope <- diff(quart_X)/diff(quart_Q)
intercept <- quart_X[1]-slope*quart_Q[1]
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Q-Q plot of the Standardized Residuals of the tseries::garch() fitted GARCH(1,1) Model for the SP500 Daily Logarithm Return Percentage  Training Set Against the Generalized Error Distribution Density Function")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ", .(length), " sample points; Generalized Error Distribution density function: mean ", .(mean), ", standard deviation ", .(sd), ", shape ", .(nu), "."~~"Data by courtesy of Yahoo Finance US - ",.(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("Theoretical Quantiles")
y_name <- bquote("Sample Quantiles")
x_breaks_min <- floor(Data_df$Q[1])
x_breaks_max <- ceiling(Data_df$Q[length])
x_breaks <- seq(from=x_breaks_min, to=x_breaks_max, by=0.5)
x_labs <- format(x_breaks, scientific=FALSE)
y_breaks_num <- length(x_breaks)
y_binwidth <- round((max(Data_df$Y)-min(Data_df$Y))/y_breaks_num, digits=3)
y_breaks_low <- floor((min(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((max(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks <- c(round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3))
y_labs <- format(y_breaks, scientific=FALSE)
y1_shape <- bquote("Q-Q plot")
y1_fill <- bquote("90% confidence intervals")
y2_fill <- bquote("95% confidence intervals")
y1_col <- bquote("interquartile line")
y2_col <- bquote("regression line")
y3_col <- bquote("y=x line")
leg_shape_labs <- y1_shape
leg_fill_labs <- c(y1_fill, y2_fill)
leg_col_labs <- c(y1_col, y2_col, y3_col)
leg_shape_cols <- c("y1_shape"=19)
leg_fill_cols <- c("y1_fill"="chartreuse1", "y2_fill"="deepskyblue1")
leg_col_cols <- c("y1_col"="cyan", "y2_col"="red", "y3_col"="black")
leg_shape_sort <- "y1_shape"
leg_fill_sort <- c("y1_fill", "y2_fill")
leg_col_sort <- c("y1_col", "y2_col", "y3_col")
Stand_Res_ged_QQ_plot <- ggplot(Data_df, aes(sample=X)) +
  qqplotr::stat_qq_band(aes(fill= "y2_fill"), distribution=distr, dparams=distr_pars, conf=0.95) +
  qqplotr::stat_qq_band(aes(fill= "y1_fill"), distribution=distr, dparams=distr_pars, conf=0.90) +
  geom_abline(aes(slope=slope, intercept=intercept, colour= "y1_col"), linewidth=0.8, linetype= "solid")+
  stat_smooth(aes(x=Q, y=Y, colour= "y2_col", group=1), inherit.aes=FALSE, method= "lm" , formula=y~x, alpha=1, linewidth=0.8, linetype= "solid",
              se=FALSE, fullrange=FALSE)+
  geom_abline(aes(slope=1, intercept=0, colour= "y3_col"), linewidth=0.8, linetype= "solid") +
  qqplotr::stat_qq_point(aes(shape= "y1_shape"), distribution=distr, dparams=distr_pars, colour= "black", alpha=1, size=1.0) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_shape_manual(name= "Legend", labels=leg_shape_labs, values=leg_shape_cols, breaks=leg_shape_sort) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_sort) +
  scale_colour_manual(name= "", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_sort) +
  guides(shape=guide_legend(order=1), fill=guide_legend(order=2), colour=guide_legend(order=3)) +
  theme(plot.title=element_text(hjust=0.5, size=8), 
        plot.subtitle=element_text(hjust=0.5, size=6),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_res_ged_QQ.png", plot = Stand_Res_ged_QQ_plot, width = 12, height = 6)
plot(Stand_Res_ged_QQ_plot)
#
# P-P plot of the empirical distribution function of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model for the 
# SP500 daily logarithm return percentage training set against the estimated GED function.
# First, we build a suitable data frame.
y_qemp <- qemp(ppoints(length(y)), y)
y_pemp <- pemp(y_qemp, y)
mean <- 0
sd <- 1
nu  <- GED_nu 
distr <- "ged"
distr_pars <- list(mean=0, sd=1, nu=nu)
quants <- qged(ppoints(length(y)), mean=0, sd=1, nu=nu)
probs <- pged(quants, mean=0, sd=1, nu=nu)
PP_plot_df <- data.frame(T=1:length(y), P=probs, X=y, Y=y_pemp)
head(PP_plot_df)
# Second we draw the P-P plot of the standardized residuals.
Data_df <- PP_plot_df
length <- nrow(PP_plot_df)
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("P-P plot of the Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Returns Training Set Against the Estimated Generalized Logistic Distribution")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ", .(length), " sample points; estimated generalized logistic density function: mean ", .(mean), ", standard deviation ", .(sd), ", shape ", .(nu), "."~~"Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("Theoretical Probabilities")
y_name <- bquote("Sample Probabilities")
x_breaks_min <- floor(Data_df$P[1])
x_breaks_max <- ceiling(Data_df$P[length])
x_breaks <- seq(from=x_breaks_min, to=x_breaks_max, by=0.5)
x_labs <- format(x_breaks, scientific=FALSE)
J <- 0
x_lims <- c(x_breaks_min-J*x_binwidth, x_breaks_max+J*x_binwidth)
y_breaks_num <- length(x_breaks)
y_binwidth <- round((max(Data_df$Y)-min(Data_df$Y))/y_breaks_num, digits=3)
y_breaks_low <- floor((min(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks_up <- floor((max(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks <- c(round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3))
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.3
y_lims <- c(y_breaks_low-K*y_binwidth, y_breaks_up+K*y_binwidth)
y1_shape <- bquote("P-P plot")
y1_fill <- bquote("90% confidence intervals")
y2_fill <- bquote("95% confidence intervals")
y1_col <- bquote("y=x line")
y2_col <- bquote("regression line")
leg_shape_labs <- y1_shape
leg_fill_labs <- c(y1_fill, y2_fill)
leg_col_labs <- c(y1_col, y2_col)
leg_shape_cols <- c("y1_shape"=19)
leg_fill_cols <- c("y1_fill"="chartreuse1", "y2_fill"="deepskyblue1")
leg_col_cols <- c("y1_col"="black", "y2_col"="red")
leg_shape_sort <- "y1_shape"
leg_fill_sort <- c("y1_fill", "y2_fill")
leg_col_sort <- c("y1_col", "y2_col")
Stand_Res_ged_PP_plot <- ggplot(Data_df, aes(sample=X)) +
  qqplotr::stat_pp_band(aes(fill= "y2_fill"), distribution=distr, dparams=distr_pars, conf=0.95) +
  qqplotr::stat_pp_band(aes(fill= "y1_fill"), distribution=distr, dparams=distr_pars, conf=0.90) +
  qqplotr::stat_pp_line(aes(colour= "y1_col"), geom="path", position="identity", colour= "black") +
  stat_smooth(aes(x=P, y=Y, colour= "y2_col"), inherit.aes=FALSE, method= "lm", formula=y~x, alpha=1, linewidth=0.8, linetype= "solid", se=FALSE, fullrange=FALSE) +
  qqplotr::stat_pp_point(aes(shape= "y1_shape"), distribution=distr, dparams=distr_pars, colour= "black", alpha=1, size=1.0) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_shape_manual(name= "Legend", labels=leg_shape_labs, values=leg_shape_cols, breaks=leg_shape_sort) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_sort) +
  scale_colour_manual(name= "", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_sort) +
  guides(shape=guide_legend(order=1), fill=guide_legend(order=2), colour=guide_legend(order=3)) +
  theme(plot.title=element_text(hjust=0.5, size=8), 
        plot.subtitle=element_text(hjust=0.5, size=6),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_stand_res_ged_PP_plot.png", plot = Stand_Res_ged_PP_plot, width = 14, height = 6)
plot(Stand_Res_ged_PP_plot)
#
# We modify the code chunk for the estimated generalized Student-t distribution
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
head(y,20)
#  0.4144414  1.7419780  0.1388878 -0.2739479  0.3934812  2.3160727 -2.1750637  0.9880176 -0.6734156  0.8577843  0.1677339 -0.4519775
# -0.3269782  0.3293440  1.4429828 -0.1135808  0.4322915 -0.5793126 -0.8429148 -0.4242154
y_qemp <- qemp(ppoints(length(y)), y)
mean <- 0
sd <- 1
nu  <- STD_nu 
distr <- "std"
distr_pars <- list(mean=0, sd=1, nu=nu)
quants <- qstd(ppoints(length(y)), mean=0, sd=1, nu=nu)
QQ_plot_df <- data.frame(T=1:length(y), Q=quants, X=y, Y=y_qemp)
head(QQ_plot_df)
# Second we draw the Q-Q plot of the standardized residuals.
Data_df <- QQ_plot_df
length <- nrow(Data_df)
quart_probs <- c(0.25,0.75)
quart_X <- as.vector(quantile(QQ_plot_df$X, quart_probs))
quart_Q <- qstd(quart_probs, mean=0, sd=1, nu=nu)
slope <- diff(quart_X)/diff(quart_Q)
intercept <- quart_X[1]-slope*quart_Q[1]
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Q-Q plot of the Standardized Residuals of the tseries::garch() Fitted GARCH(1,1) Model for the SP500 Daily Logarithm Returns Training Set Against the Generalized Student Distribution")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ", .(length), " sample points; generalized Student density function: mean ", .(mean), ", standard deviation ", .(sd), ", degrees of freedom ", .(nu), "."~~"Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("Theoretical Quantiles")
y_name <- bquote("Sample Quantiles")
x_breaks_min <- floor(Data_df$Q[1])
x_breaks_max <- ceiling(Data_df$Q[length])
x_breaks <- seq(from=x_breaks_min, to=x_breaks_max, by=0.5)
x_labs <- format(x_breaks, scientific=FALSE)
y_breaks_num <- length(x_breaks)
y_binwidth <- round((max(Data_df$Y)-min(Data_df$Y))/y_breaks_num, digits=3)
y_breaks_low <- floor((min(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((max(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks <- c(round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3))
y_labs <- format(y_breaks, scientific=FALSE)
y1_shape <- bquote("Q-Q plot")
y1_fill <- bquote("90% confidence intervals")
y2_fill <- bquote("95% confidence intervals")
y1_col <- bquote("interquartile line")
y2_col <- bquote("regression line")
y3_col <- bquote("y=x line")
leg_shape_labs <- y1_shape
leg_fill_labs <- c(y1_fill, y2_fill)
leg_col_labs <- c(y1_col, y2_col, y3_col)
leg_shape_cols <- c("y1_shape"=19)
leg_fill_cols <- c("y1_fill"="chartreuse1", "y2_fill"="deepskyblue1")
leg_col_cols <- c("y1_col"="cyan", "y2_col"="red", "y3_col"="black")
leg_shape_sort <- "y1_shape"
leg_fill_sort <- c("y1_fill", "y2_fill")
leg_col_sort <- c("y1_col", "y2_col", "y3_col")
Stand_Res_std_QQ_plot <- ggplot(Data_df, aes(sample=X)) +
  qqplotr::stat_qq_band(aes(fill= "y2_fill"), distribution=distr, dparams=distr_pars, conf=0.95) +
  qqplotr::stat_qq_band(aes(fill= "y1_fill"), distribution=distr, dparams=distr_pars, conf=0.90) +
  geom_abline(aes(slope=slope, intercept=intercept, colour= "y1_col"), linewidth=0.8, linetype= "solid")+
  stat_smooth(aes(x=Q, y=Y, colour= "y2_col", group=1), inherit.aes=FALSE, method= "lm" , formula=y~x, alpha=1, linewidth=0.8, linetype= "solid",
              se=FALSE, fullrange=FALSE)+
  geom_abline(aes(slope=1, intercept=0, colour= "y3_col"), linewidth=0.8, linetype= "solid") +
  qqplotr::stat_qq_point(aes(shape= "y1_shape"), distribution=distr, dparams=distr_pars, colour= "black", alpha=1, size=1.0) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_shape_manual(name= "Legend", labels=leg_shape_labs, values=leg_shape_cols, breaks=leg_shape_sort) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_sort) +
  scale_colour_manual(name= "", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_sort) +
  guides(shape=guide_legend(order=1), fill=guide_legend(order=2), colour=guide_legend(order=3)) +
  theme(plot.title=element_text(hjust=0.5, size=10), 
        plot.subtitle=element_text(hjust=0.5, size=8),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_stand_res_std_QQ_plot.png", plot = Stand_Res_std_QQ_plot, width = 12, height = 5)
plot(Stand_Res_std_QQ_plot)
#
# P-P plot of the standardized residuals of the GARCH(1,1) model for the SP500 daily logarithm return percentage training set against the
# estimated standardized Student distribution.
# As before, we start by building a suitable data frame
y_pemp <- pstd(y_qemp, y)
y_pemp <- pemp(y_qemp, y)
mean <- 0
sd <- 1
nu  <- STD_nu 
distr <- "std"
distr_pars <- list(mean=0, sd=1, nu=nu)
quants <- qstd(ppoints(length(y)), mean=0, sd=1, nu=nu)
probs <- pstd(quants, mean=0, sd=1, nu=nu)
PP_plot_df <- data.frame(T=1:length(y), P=probs, X=y, Y=y_pemp)
head(PP_plot_df)
# Second we draw the P-P plot of the standardized residuals.
Data_df <- PP_plot_df
length <- nrow(PP_plot_df)
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("P-P plot of the Standardized Residuals of the GARCH(1,1) Model for the SP500 Daily Logarithm Returns Training Set Against the Estimated Generalized Student Distribution")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ", .(length), " sample points; estimated generalized Student density function: mean ", .(mean), ", standard deviation ", .(sd), ", degrees of freedom ", .(nu), "."~~"Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("Theoretical Probabilities")
y_name <- bquote("Sample Probabilities")
x_breaks_min <- floor(Data_df$P[1])
x_breaks_max <- ceiling(Data_df$P[length])
x_breaks <- seq(from=x_breaks_min, to=x_breaks_max, by=0.5)
x_labs <- format(x_breaks, scientific=FALSE)
J <- 0
x_lims <- c(x_breaks_min-J*x_binwidth, x_breaks_max+J*x_binwidth)
y_breaks_num <- length(x_breaks)
y_binwidth <- round((max(Data_df$Y)-min(Data_df$Y))/y_breaks_num, digits=3)
y_breaks_low <- floor((min(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks_up <- floor((max(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks <- c(round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3))
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.3
y_lims <- c(y_breaks_low-K*y_binwidth, y_breaks_up+K*y_binwidth)
y1_shape <- bquote("P-P plot")
y1_fill <- bquote("90% confidence intervals")
y2_fill <- bquote("95% confidence intervals")
y1_col <- bquote("y=x line")
y2_col <- bquote("regression line")
leg_shape_labs <- y1_shape
leg_fill_labs <- c(y1_fill, y2_fill)
leg_col_labs <- c(y1_col, y2_col)
leg_shape_cols <- c("y1_shape"=19)
leg_fill_cols <- c("y1_fill"="chartreuse1", "y2_fill"="deepskyblue1")
leg_col_cols <- c("y1_col"="black", "y2_col"="red")
leg_shape_sort <- "y1_shape"
leg_fill_sort <- c("y1_fill", "y2_fill")
leg_col_sort <- c("y1_col", "y2_col")
Stand_Res_std_PP_plot <- ggplot(Data_df, aes(sample=X)) +
  qqplotr::stat_pp_band(aes(fill= "y2_fill"), distribution=distr, dparams=distr_pars, conf=0.95) +
  qqplotr::stat_pp_band(aes(fill= "y1_fill"), distribution=distr, dparams=distr_pars, conf=0.90) +
  qqplotr::stat_pp_line(aes(colour= "y1_col"), geom="path", position="identity", colour= "black") +
  stat_smooth(aes(x=P, y=Y, colour= "y2_col"), inherit.aes=FALSE, method= "lm", formula=y~x, alpha=1, linewidth=0.8, linetype= "solid", se=FALSE, fullrange=FALSE) +
  qqplotr::stat_pp_point(aes(shape= "y1_shape"), distribution=distr, dparams=distr_pars, colour= "black", alpha=1, size=1.0) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_shape_manual(name= "Legend", labels=leg_shape_labs, values=leg_shape_cols, breaks=leg_shape_sort) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_sort) +
  scale_colour_manual(name= "", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_sort) +
  guides(shape=guide_legend(order=1), fill=guide_legend(order=2), colour=guide_legend(order=3)) +
  theme(plot.title=element_text(hjust=0.5, size=10), 
        plot.subtitle=element_text(hjust=0.5, size=8),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_stand_res_std_PP_plot.png", plot = Stand_Res_std_PP_plot, width = 12, height = 5)
plot(Stand_Res_std_PP_plot)
#
# From the Q-Q and P-P plots, we have visual evidence of a better fit of the empirical distribution with the GED rather than 
# the STD distribution.
#
# We consider the standard goodness of fit tests.
# The Kolmogorov-Smirnov test in the library *stats*
Data_df <- spx_train_df
y <- na.rm(Data_df$GARCH_1_1_stand_res)
head(y,20)
# [1] -0.2754854 -2.0878992  0.1470659 -1.1528523  1.0903893 -1.2415021  0.9811109  0.3841106  0.7926566 -0.1854945
# [11] -0.6840742 -0.2435354  0.3112024  1.7854621  0.7439277  0.3410520  0.7627852  0.3826869  0.3198917 -0.1174064
mean <- 0
sd <- 1
nu  <- GED_nu 
stats::ks.test(y, y="pged", mean=0, sd=1, nu=nu, alternative= "two.sided")
# Asymptotic one-sample Kolmogorov-Smirnov test
# data:  y
# D = 0.040732, p-value = 0.2024
# alternative hypothesis: two-sided
#
mean <- 0
sd <- 1
nu  <- STD_nu 
stats::ks.test(y, y="pstd", mean=0, sd=1, nu=nu, alternative= "two.sided")
# Asymptotic one-sample Kolmogorov-Smirnov test
# data:  y
# D= 0.047127, p-value = 0.0933
# alternative hypothesis: two-sided
#
# The Kolmgorov-Smirnov test cannot reject the null hypothesis that the standardized residuals of the tseries::garch() fitted GARCH(1,1) 
# model have the estimated generalized Error Distribution Density Function at the $10\%$ significance level, but rejects the null hypothesis
# that the standardized residuals have the estimated standardized Student distribution at the $5\%$ significance level.
# 
# Another application of the Kolmogorov-Smirnov test can be derived using the possibility of comparing two empirical distributions offered 
# by the function stats::ks.test().
mean <- 0
sd <- 1
nu  <- GED_nu 
KS_ged_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  y_rged <- rged(n=length(y), mean=0, sd=1, nu=nu)
  KS_ged <- stats::ks.test(x=y, y=y_rged, alternative="two.sided")
  KS_ged_mat_np[k,1] <- k
  KS_ged_mat_np[k,2] <- KS_ged[["p.value"]]}
summary(KS_ged_mat_np[,2])
#    Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 0.0008849 0.1550758 0.3372064 0.3809752 0.5759151 0.9988767 
quantile(KS_ged_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05,0.1))
#        1%         5%        10%
#   0.01084291 0.03972791 0.06163088
#
# In the $5\%$ of cases on 10000 random vectors sampled by the GED, the null hypothesis that the GED fits the 
# distribution of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model is rejected at the $5\%$ significance level, 
# not at the $1\%$ significance level, though. In the $10\%$ of cases on 10000 random vectors sampled by the GED, the null 
# hypothesis that the GED fits the standardized residuals empirical distribution is not rejected at the $5\%$ significance level,
#
mean <- 0
sd <- 1
nu  <- STD_nu 
KS_std_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  y_rstd <- rstd(n=length(y),  mean=0, sd=1, nu=nu)
  KS_std <- stats::ks.test(x=y, y=y_rstd, alternative="two.sided")
  KS_std_mat_np[k,1] <- k
  KS_std_mat_np[k,2] <- KS_std[["p.value"]]}
summary(KS_std_mat_np[,2])
#    Min.     1st Qu.   Median     Mean    3rd Qu.    Max. 
# 0.0000567 0.1062686 0.2743398 0.3313330 0.4891751 0.9924722  
quantile(KS_std_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05,0.1,0.15,0.20))
#     1%          5%         10%         15%         20% 
# 0.005283932 0.021241859 0.039727913 0.061630880 0.093142888  
#
# In the $15\%$ of cases on 10000 random vectors sampled by the STD distribution, the null hypothesis that the STD distribution fits the 
# distribution of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model is rejected at the $5\%$ significance level, 
# not at the $1\%$ significance level, though. In the $20\%$ of cases on 10000 random vectors sampled by the STD distribution, the null 
# hypothesis that the STD distribution fits the standardized residuals empirical distribution is not rejected at the $5\%$ significance level,
#
# library(goftest)
# The Cramer-Von Mises test in the library *goftest*.
# This function performs the Cramer-Von Mises test of goodness-of-fit to the distribution specified by the argument null. It is assumed that
# the values in x are independent and identically distributed random values, with some cumulative distribution function F. The null 
# hypothesis is that F is the function specified by the argument null, while the alternative hypothesis is that F is some other function.
#
mean <- 0
sd <- 1
nu  <- GED_nu 
goftest::cvm.test(y, null="pged", mean=0, sd=1, nu=nu, estimated=FALSE)
# Cramer-von Mises test of goodness-of-fit
# Null hypothesis: distribution ‘pged’
# with parameters mean=0, sd=1, nu=1.72378290733565
# Parameters assumed to be fixed
# data:  y
# omega2 = 0.2901, p-value = 0.1442
#
mean <- 0
sd <- 1
nu  <- STD_nu 
goftest::cvm.test(y, null="pstd", mean=0, sd=1, nu=nu, estimated=FALSE)
# Cramer-von Mises test of goodness-of-fit
# Null hypothesis: distribution ‘pstd’
# with parameters mean=0, sd=1, nu=30.2304623530709
# Parameters assumed to be fixed
# data:  y
# omega2=0.32328, p-value = 0.1164
#
# By default, the Cramer von Mises test assumes that all the parameters of the null distribution are known in advance (a simple null 
# hypothesis). This test does not account for the effect of estimating the parameters.
# If the parameters of the distribution were estimated (that is, if they were calculated from the same data x), then this should be 
# indicated by setting the argument estimated=TRUE. The test will then use the method of Braun (1980) to adjust for the effect of parameter
# estimation. Note that Braun's method involves randomly dividing the data into two equally-sized subsets, so the p-value is not exactly the
# same if the test is repeated. This technique is expected to work well when the number of observations in x is large. However, we approach 
# this version of the test with a technique similar to that we have used in the Kolmogorov-Smirnov test with random sampling. 
#
mean <- 0
sd <- 1
nu  <- GED_nu 
CVM_ged_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  CVM_ged <- goftest::cvm.test(x=y, null="pged", mean=0, sd=1, nu=nu, estimated=TRUE)
  CVM_ged_mat_np[k,1] <- k
  CVM_ged_mat_np[k,2] <- CVM_ged[["p.value"]]}
summary(CVM_ged_mat_np[,2])
#    Min.    1st Qu.    Median     Mean    3rd Qu.     Max. 
# 0.0000028 0.2241428 0.4602492 0.4708248 0.7084370 0.9996961 
quantile(CVM_ged_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05))
#    1%         5% 
# 0.008043542 0.041394415
#
# In the $1\%$ of cases on 10000 random vectors sampled by the STD distribution, the null hypothesis that the GED fits the
# distribution of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model is rejected at the $5\%$ significance level,
# not at the $1\%$ significance level, though.
#
mean <- 0
sd <- 1
nu  <- STD_nu 
CVM_std_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  CVM_std <- goftest::cvm.test(x=y, null="pstd", mean=0, sd=1, nu=nu, estimated=TRUE)
  CVM_std_mat_np[k,1] <- k
  CVM_std_mat_np[k,2] <- CVM_std[["p.value"]]}
summary(CVM_std_mat_np[,2])
#    Min.    1st Qu.    Median     Mean     3rd Qu.    Max. 
# 0.0000041 0.2364615 0.4756795 0.4813437 0.7210258 0.9994864
quantile(CVM_std_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05))
#     1%         5%      
# 0.008919163 0.045659105
#
# In the $1\%$ of cases on 10000 random vectors sampled by the STD distribution, the null hypothesis that the GED fits the
# distribution of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model is rejected at the $5\%$ significance level, 
# not at the $1\%$ significance level, though.
#
# The Anderson-Darling test in the library *goftest*.
mean <- 0
sd <- 1
nu  <- GED_nu 
goftest::ad.test(y, null="pged", mean=0, sd=1, nu=nu, estimated=FALSE)
#
# Anderson-Darling test of goodness-of-fit
# Null hypothesis: distribution ‘pged’
# with parameters mean=0, sd=1, nu=1.72378290733565
# Parameters assumed to be fixed
# data:  y
# An = 1.7834, p-value = 0.1212
#
mean <- 0
sd <- 1
nu  <- STD_nu 
goftest::ad.test(y, null="pstd", mean=0, sd=1, nu=nu, estimated=FALSE)
# Anderson-Darling test of goodness-of-fit
# Null hypothesis: distribution ‘pstd’
# with parameters mean=0, sd=1, nu=30.2304623530709
# Parameters assumed to be fixed
# data:  y
# An = 1.9096, p-value = 0.1031
#
# By default, also the Anderson Darling test assumes that all the parameters of the null distribution are known in advance (a simple null 
# hypothesis). This test does not account for the effect of estimating the parameters.
# If the parameters of the distribution were estimated (that is, if they were calculated from the same data x), then this should be 
# indicated by setting the argument estimated=TRUE. The test will then use the method of Braun (1980) to adjust for the effect of parameter
# estimation. Note that Braun's method involves randomly dividing the data into two equally-sized subsets, so the p-value is not exactly the
# same if the test is repeated. This technique is expected to work well when the number of observations in x is large. However, we approach 
# this version of the test with the same technique that we have used in the Cramer von Mises test. 
#
mean <- 0
sd <- 1
nu  <- GED_nu 
AD_ged_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  AD_ged <- goftest::ad.test(x=y, null="pged", mean=0, sd=1, nu=nu, estimated=TRUE)
  AD_ged_mat_np[k,1] <- k
  AD_ged_mat_np[k,2] <- AD_ged[["p.value"]]}
summary(AD_ged_mat_np[,2])
#    Min.    1st Qu.    Median     Mean    3rd Qu.     Max. 
# 0.0005998 0.2157345 0.4534562 0.4641253 0.7034995 0.9994645 
quantile(AD_ged_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05))
#      1%         5% 
# 0.007975892 0.040139967
#
# In the $1\%$ of cases on 10000 random vectors sampled by the STD distribution, the null hypothesis that the GED fits the
# distribution of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model is rejected at the $5\%$ significance level,
# not at the $1\%$ significance level, though.
#
mean <- 0
sd <- 1
nu  <- STD_nu 
AD_std_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  AD_std <- goftest::ad.test(x=y, null="pstd", mean=0, sd=1, nu=nu, estimated=TRUE)
  AD_std_mat_np[k,1] <- k
  AD_std_mat_np[k,2] <- AD_std[["p.value"]]}
summary(AD_std_mat_np[,2])
#    Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 0.0005998 0.2257141 0.4663609 0.4732531 0.7111684 0.9994000 
quantile(AD_std_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05,0.1,0.15,0.20))
#     1%          5%         10%       
# 0.008556847 0.043181183 0.089702460

# In the $5\%$ of cases on 10000 random vectors sampled by the STD distribution, the null hypothesis that the GED fits the
# standardized residuals empirical distribution is rejected at the $5\%$ significance level, not at the $1\%$ significance level, though.
#
# The goodness of fit tests yield computational evidence that the estimated GED fits the empirical distribution of the standardized 
# residuals of the tseries::garch() fitted GARCH(1,1) model slightly better than the estimated STD. Overall, the Q-Q plots, P-P plots, 
# and Kolmogorov-Smirnov tests highlight a failure of the estimated STD in the central part of the distribution, where the estimated GED 
# performs better. However, the estimated distribution of the standardized residuals of the tseries::garch() fitted GARCH(1,1) model for 
# the SP500 daily logarithm return percentage training set built using the tseries::garch() function is definitively far from being 
# Gaussian. This is a non-negligible problem for the model validation that we should tackle. Although we could carry out a handmade
# prediction procedure based on the estimated model and standardized residual distribution, the coefficients of the GARCH(1,1) model remain 
# estimated under the assumption of Gaussian-distributed standardized residuals. This renders their estimation less reliable than desirable.
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
############################################################################################################################################
############################################################################################################################################
# The tseries::garch() function, although appreciable for its simplicity, does not allow us to deal with innovation distributions other than 
# the Gaussian distribution (?!). Such a possibility seems to be offered by the function fGarch::garchFit(), which includes options for 
# choosing a GED or an STD or even their skewed modifications as the innovation distribution. Therefore, we start exploring the features
# of the fGarch::garchFit() function by re-estimating the GARCH(1,1).
# First, we consider the options of fGarch::garchFit() which replicates the results of the tseries::garch() function.
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
y <- na.rm(Data_df$log.ret.perc.)
head(y,20)
#  0.1459943 -0.2780218 -2.0574322  0.1567936 -1.1981221  1.1425952 -1.3070934  1.0469459  0.4094494  0.8264048
# -0.1915574 -0.6889464 -0.2419697  0.3017978  1.6919170  0.7432442  0.3369123  0.7366160  0.3657321  0.2991427
# 
# The cond.dist="norm" option calls for using a Gaussian standard distribution as the innovation distribution. The algorithm="lbfgsb" 
# option invokes the limited-memory Broyden–Fletcher–Goldfarb–Shanno algorithm with box constraints for the model estimation.
fGARCH_1_1 <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="norm", include.mean=FALSE, include.skew=FALSE, 
                               include.shape=FALSE, trace=TRUE, algorithm="lbfgsb")
# Extracted from the output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          norm
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              1.12009
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#              U           V      params includes
# mu     -0.26677076   0.2667708    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0    FALSE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1 
#     2      3      5 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: lbfgsb 
# 
# R coded optim[L-BFGS-B] Solver: 
# final  value 910.495126 
# stopped after 8 iterations
# 
# Final Estimate of the Negative LLH: 988.8606    norm LLH:  1.431057 
#   omega     alpha1      beta1 
# 0.004477808 0.050937439 0.944844936 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#           omega     alpha1     beta1
# omega  -201219.0 -119293.1 -142691.6
# alpha1 -119293.1 -105196.5 -112710.7
# beta1  -142691.6 -112710.7 -127969.7
# 
# --- END OF TRACE ---
#
summary(fGARCH_1_1)
# Extracted from the output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula=~garch(1, 1), data=y, init.rec="mci", cond.dist="norm", include.mean=FALSE, include.skew=FALSE,
#                        include.shape=FALSE, trace=TRUE, algorithm="lbfgsb") 
# Conditional Distribution: norm 
# Coefficient(s): omega    alpha1     beta1  
#               0.0044778  0.0509374  0.9448449  
# 
# Std. Errors: based on Hessian 
# Error Analysis: Estimate  Std. Error  t value Pr(>|t|)    
#         omega   0.004478    0.005327    0.841             0.400622    
#         alpha1  0.050937    0.014203    3.586             0.000335 ***
#         beta1   0.944845    0.016113   58.637 < 0.0000000000000002 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -988.8606    normalized:  -1.431057
# 
# Standardised Residuals Tests:    
#                                  Statistic   p-Value
# Jarque-Bera Test   R    Chi^2   7.5871441 0.022515034
# Shapiro-Wilk Test  R    W       0.9936054 0.004926768
# Ljung-Box Test     R    Q(10)   5.6563152 0.843264562
# Ljung-Box Test     R    Q(15)   9.2483087 0.864180256
# Ljung-Box Test     R    Q(20)  18.2165483 0.573145592
# Ljung-Box Test     R^2  Q(10)   4.3041974 0.932582464
# Ljung-Box Test     R^2  Q(15)   8.7916150 0.888158655
# Ljung-Box Test     R^2  Q(20)  10.7616513 0.952170888
# LM Arch Test       R    TR^2    6.6023367 0.882736237
#
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 2.870798 2.890500 2.870760 2.878419
#
# Uncomment and execute the following line
# plot(fGARCH_1_1)
# From the autocorrelograms of the standardized and squared standardized residuals, we have no visual evidence of autocorrelation at the 
# $5\%$ significance level. However, the Q-Q plot highlights the poor fit between the standardized residuals and the quantiles of the
# hypothesized standard Gaussian distribution of the innovation.
#
# Note that the estimated parameters of the GARCH(1,1) model by the function fGarch::garchFit() are very similar to the estimated parameters
# by the function tseries::garch(). Eventually, we have
a0 <- as.numeric(GARCH_1_1$coef[1])
a1 <- as.numeric(GARCH_1_1$coef[2])
b1 <- as.numeric(GARCH_1_1$coef[3])
show(c(a0, a1, b1))
#  0.004202227 0.050657138 0.945421807
#
omega  <- as.numeric(fGARCH_1_1@fit[["par"]][["omega"]])
alpha1 <- as.numeric(fGARCH_1_1@fit[["par"]][["alpha1"]])
beta1  <- as.numeric(fGARCH_1_1@fit[["par"]][["beta1"]])
show(c(omega, alpha1, beta1)) 
variabilita <- sqrt(omega/(1-(alpha1+beta1)))
#TODO: calcolare la variabilita a partire da questi coefficienti: $\frac{\omega}{1-(\alpha_1+\beta_1)}$
# 0.004477808 0.050937439 0.944844936
#
# Therefore,
show(c(abs(a0-omega),abs(a1-alpha1),abs(b1-beta1)))
# 0.0002755810 0.0002803016 0.0005768711
#
# Thus, the coefficient estimates differ by much less than the corresponding standard errors computed by both the tseries::garch() and
# fGarch::garchFit() functions (see summaries) reported below.
#     a0_se  0.17990      a1_se   0.01108     b1_se  0.02166
#  omega_se  0.24757  alpha1_se   0.01763  beta1_se  0.02636 
#
# Note also that the coefficient estimates of the fGARCH_1_1 model can also be obtained by applying the function fGarch::coef(). 
# Similarly, the functions fGarch::residuals() and fGarch::fitted() return the residuals and the fitted values of the model. In fact, 
omega_bis <- as.numeric(fGarch::coef(fGARCH_1_1)[1])
alpha1_bis <- as.numeric(fGarch::coef(fGARCH_1_1)[2])
beta1_bis <- as.numeric(fGarch::coef(fGARCH_1_1)[3])
show(c(omega_bis, alpha1_bis, beta1_bis))
# 0.004477808 0.050937439 0.944844936
#
identical(c(omega, alpha1, beta1),c(omega_bis, alpha1_bis, beta1_bis))
# TRUE
#
fGARCH_1_1_resid <- fGARCH_1_1@residuals
head(fGARCH_1_1_resid,20)
# 0.1459943 -0.2780218 -2.0574322  0.1567936 -1.1981221  1.1425952 -1.3070934  1.0469459  0.4094494  0.8264048
# -0.1915574 -0.6889464 -0.2419697  0.3017978  1.6919170  0.7432442  0.3369123  0.7366160  0.3657321  0.2991427
#
fGARCH_1_1_resid_bis <- fGarch::residuals(fGARCH_1_1, standardize=FALSE)
head(fGARCH_1_1_resid_bis,20)
#  0.1459943 -0.2780218 -2.0574322  0.1567936 -1.1981221  1.1425952 -1.3070934  1.0469459  0.4094494  0.8264048
# -0.1915574 -0.6889464 -0.2419697  0.3017978  1.6919170  0.7432442  0.3369123  0.7366160  0.3657321  0.2991427
#
identical(fGARCH_1_1_resid,fGARCH_1_1_resid_bis)
# TRUE
#
fGARCH_1_1_fit <- fGARCH_1_1@fitted
head(fGARCH_1_1_fit,20)
# 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 
# 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 
# 
fGARCH_1_1_fit_bis <- fGarch::fitted(fGARCH_1_1)
head(fGARCH_1_1_fit_bis,20)
# 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 
# 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 
#
identical(fGARCH_1_1_fit,fGARCH_1_1_fit_bis)
# TRUE
#
# The fitted values being all zero might appear to be a somewhat surprising result. However, recall that for any GARCH(p,q) process with a
# state process $\left(Z_{t}\right)_{t\in\mathbb{N}_{0}$ and available information $\left(\mathcal{F}_{t}\right)_{t\in\mathbb{N}_{0}$ we 
# always have $\mathbf{E}\left[Z_{t}\mid\mathcal{F}_{t-s}\right]=0$, for every $t\in\mathbb{N}$ and every $s=1,\dots,t$,
# Therefore, we should have expected the fitted values of the states y=na.rm(Data_df$log.ret.perc.) are all zero. On the other hand, we have
# $Res\left(Z_{t}\right)=Z_{t}-\mathbf{E}\left[Z_{t}\mid\mathcal{F}_{t-1}\right]=Z_{t}$, for every $t\in\mathbb{N}$.
# Therefore, we should expect that the residuals of the states y=na.rm(Data_df$log.ret.perc.) coincide with the states themselves. 
# Nevertheless, we have
fGARCH_1_1_resid==y
# [1]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE
# [19]  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE
# [37]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [55]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [73]  TRUE  TRUE  TRUE FALSE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [91]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [109]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE FALSE FALSE  TRUE
# [127]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [145]  TRUE FALSE  TRUE  TRUE FALSE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE FALSE  TRUE  TRUE  TRUE
# [163]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [181]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE
# [199]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE
# [217]  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [235]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE
# [253]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [271]  TRUE FALSE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [289] FALSE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [307]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE
# [325]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [343]  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE
# [361]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE FALSE  TRUE
# [379]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE
# [397]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [415]  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE FALSE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE
# [433]  TRUE FALSE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE
# [451]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [469]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE
# [487]  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE FALSE FALSE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE
# [505] FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE FALSE FALSE FALSE  TRUE
# [523]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [541]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE
# [559]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE
# [577]  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [595]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [613]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE
# [631]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# [649]  TRUE  TRUE  TRUE FALSE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE FALSE  TRUE
# [667]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE
# [685]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
# 
# This because
format(round(fGARCH_1_1_resid[11],16), nsmall=16)
"-0.1915574290977773"
format(round(y[11],16), nsmall=16)
"-0.1915574290977773"
#
# However, rounding up to the 13th decimal digit,
identical(round(fGARCH_1_1_resid,13),round(y,13))
# TRUE
#
# Note that the object GARCH_1_1[["fitted.values"]] (presented above) despite the similar denomination of 
# fGARCH_1_1@fitted has the the rather different role of a confidence band.
#
# Another issue is what the standardized residuals of the fGarch::garchFit() fitted GARCH(1,1) (from now on fGARCH_1_1) model are precisely.
# We have
fGARCH_1_1_stand_res <- fGarch::residuals(fGARCH_1_1, standardize=TRUE)
head(fGARCH_1_1_stand_res,20)
#  0.1304317 -0.2549339 -1.9336328  0.1380597 -1.0827814  1.0283810 -1.1750606  0.9324685  0.3660193  0.7558553
# -0.1771919 -0.6537405 -0.2330507  0.2979481  1.7103722  0.7168965  0.3290768  0.7363823  0.3699057  0.3093768
#
# Therefore, the standardized residuals appears to be rather similar to the residuals of the tseries::garch() fitted GARCH(1,1) (from now on
# GARCH_1_1) model.
head(GARCH_1_1_stand_res,20)
#  0.1410255 -0.2754854 -2.0878992  0.1470659 -1.1528523  1.0903893 -1.2415021  0.9811109  0.3841106  0.7926566
# -0.1854945 -0.6840742 -0.2435354  0.3112024  1.7854621  0.7439277  0.3410520  0.7627852  0.3826869  0.3198917
#
# To solve this issue we consider the generation of the path of the positive process $\sigma_{t}$ in the fGARCH_1_1 model.
# First, we recall the basic variables.
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
y <- na.rm(Data_df$log.ret.perc.)
T <- length(y)
show(T)
# 691
omega  <- as.numeric(fGARCH_1_1@fit[["par"]][["omega"]])
alpha1 <- as.numeric(fGARCH_1_1@fit[["par"]][["alpha1"]])
beta1  <- as.numeric(fGARCH_1_1@fit[["par"]][["beta1"]])
show(c(omega, alpha1, beta1))
# 0.004477808 0.050937439 0.944844936
#
# Second, from (22) p. 15 and (23) p. 16 of the paper https://www.math.pku.edu.cn/teachers/heyb/TimeSeries/lectures/garch.pdf, we have found 
# that the conditional variance should be initialized by setting
fGARCH_1_1_sigma0 <- omega + (alpha1+beta1)*(1/T)*sum(y^2)
show(fGARCH_1_1_sigma0)
# 1.252869
#
# Hence, we write the generation procedure.
fGARCH_1_1_cond_var_est <- vector(mode="numeric", length=T)
fGARCH_1_1_cond_var_est[1] <- fGARCH_1_1_sigma0
for(t in 2:T){
  fGARCH_1_1_cond_var_est[t] <- omega + alpha1*y[t-1]^2 + beta1*fGARCH_1_1_cond_var_est[t-1]
}
# The conditional variance, is then given by
head(fGARCH_1_1_cond_var_est,20)
# 1.2528686 1.1893301 1.1321476 1.2898013 1.2243923 1.2344592 1.2373504 1.2606083 1.2513895 1.1953864 1.1687201
# 1.1106062 1.0780057 1.0260084 0.9785361 1.0748554 1.0481879 1.0006348 0.9775613 0.9349351
#
# Consequently, the conditional standard deviation, is
head(sqrt(fGARCH_1_1_cond_var_est),20)
# 1.1193162 1.0905641 1.0640242 1.1356942 1.1065226 1.1110622 1.1123625 1.1227681 1.1186552 1.0933373 1.0810736
# 1.0538530 1.0382705 1.0129207 0.9892099 1.0367523 1.0238105 1.0003173 0.9887170 0.9669204
#
# Note that the objects fGARCH_1_1@h.t and fGARCH_1_1@sigma.t or equivalently the extractor functions fGarch::volatility( , type="h") and
# fGarch::volatility( , type="sigma") are supposed to return the conditional variance and the conditional standard deviation from the
# fGARCH_1_1 model, respectively. However, we have
head(fGARCH_1_1@h.t, 20) 
# or equivalently
head(fGarch::volatility(fGARCH_1_1, type="h"), 20)
# 1.2528686 1.1893301 1.1321476 1.2898013 1.2243923 1.2344592 1.2373504 1.2606083 1.2513895 1.1953864 1.1687201
# 1.1106062 1.0780057 1.0260084 0.9785361 1.0748554 1.0481879 1.0006348 0.9775613 0.9349351
#
# and eventually,
identical(round(fGARCH_1_1_cond_var_est,12),round(fGARCH_1_1@h.t,12))
# TRUE
#
# and
head(fGARCH_1_1@sigma.t, 20)
# or equivalently
head(fGarch::volatility(fGARCH_1_1, type="sigma"), 20)
# 1.1193162 1.0905641 1.0640242 1.1356942 1.1065226 1.1110622 1.1123625 1.1227681 1.1186552 1.0933373 1.0810736
# 1.0538530 1.0382705 1.0129207 0.9892099 1.0367523 1.0238105 1.0003173 0.9887170 0.9669204
# 
# and eventually,
identical(round(sqrt(fGARCH_1_1_cond_var_est),13),round(fGARCH_1_1@sigma.t,13))
# TRUE
#
# Now, referring the defining stochastic equation of the GARCH  models
# $\Z_{t}=\sigma_{t}W_{t}$,
# to the path of the positive process $\sigma_{t}$ that we have determined, we obtain
head(y/fGARCH_1_1@sigma.t, 20)
#  0.1304317 -0.2549339 -1.9336328  0.1380597 -1.0827814  1.0283810 -1.1750606  0.9324685  0.3660193  0.7558553
# -0.1771919 -0.6537405 -0.2330507  0.2979481  1.7103722  0.7168965  0.3290768  0.7363823  0.3699057  0.3093768
#
# This should be compared with
head(fGARCH_1_1_stand_res, 20)
#  0.1304317 -0.2549339 -1.9336328  0.1380597 -1.0827814  1.0283810 -1.1750606  0.9324685  0.3660193  0.7558553
# -0.1771919 -0.6537405 -0.2330507  0.2979481  1.7103722  0.7168965  0.3290768  0.7363823  0.3699057  0.3093768
#
# Eventually,
identical(round(y/fGARCH_1_1@sigma.t, 13), round(fGARCH_1_1_stand_res, 13))
# TRUE
#
# Similarly,
head(GARCH_1_1_stand_res, 20)
#  0.1410255 -0.2754854 -2.0878992  0.1470659 -1.1528523  1.0903893 -1.2415021  0.9811109  0.3841106  0.7926566
# -0.1854945 -0.6840742 -0.2435354  0.3112024  1.7854621  0.7439277  0.3410520  0.7627852  0.3826869  0.3198917
#
# Therefore, also the vector fGARCH_1_1_stand_res is just the path of the noise process $W_{t}$ which contributes jointly to 
# the path of the conditional standard deviation $\hat{sigma}_{t\mid t-1}$ to the realization of the states of the process.
#
# To summarize, the standardized residuals of the fGARCH_1_1 model are analogous to the residuals of the GARCH_1_1 model. In particular,
# from the summary of the fGARCH_1_1 model, we can realize that the standardized residuals of the fGARCH_1_1 model fail to fit the standard
# Gaussian distribution.
# Standardised Residuals Tests:    Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  2.263033e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.983107e-01 0.0000000
# Ljung-Box Test     R    Q(10)  8.792208e+00 0.5519309
# Ljung-Box Test     R    Q(15)  1.071485e+01 0.7725338
# Ljung-Box Test     R    Q(20)  1.290943e+01 0.8812361
# Ljung-Box Test     R^2  Q(10)  3.688948e+00 0.9602901
# Ljung-Box Test     R^2  Q(15)  4.044115e+00 0.9975893
# Ljung-Box Test     R^2  Q(20)  5.057586e+00 0.9996969
# LM Arch Test       R    TR^2   3.680448e+00 0.9885371
#
# Note that the Ljung-Box Test on the standardized residuals and squared standardized residuals are executed setting to zero the number of
# parameters estimated by the model (?!).
y <- fGARCH_1_1_stand_res
head(y,20)
#  0.1304317 -0.2549339 -1.9336328  0.1380597 -1.0827814  1.0283810 -1.1750606  0.9324685  0.3660193  0.7558553
# -0.1771919 -0.6537405 -0.2330507  0.2979481  1.7103722  0.7168965  0.3290768  0.7363823  0.3699057  0.3093768
#
max_lag <- ceiling(min(10, n_obs/4))    # Hyndman (for data without seasonality)
show(max_lag)
# 10
n_coeffs <- nrow(y_ADF_ur.df_trend_0_lags@testreg[["coefficients"]])
show(n_coeffs)
# 3
n_pars <- n_coeffs
show(n_pars)
# 3
Box.test(y, lag=max_lag, fitdf=n_pars, type="Ljung-Box")
# Box-Ljung test, data:  y
# X-squared=5.6563, df = 7, p-value = 0.5804
#
Box.test(y, lag=max_lag, fitdf=0, type="Ljung-Box")
# Box-Ljung test, data:  y
# X-squared=5.6563, df = 10, p-value = 0.8433

#
Box.test(y^2, lag=max_lag, fitdf=n_pars, type="Ljung-Box")
# Box-Ljung test, data:  y^2
# X-squared=4.3042, df = 7, p-value = 0.7441
#
Box.test(y^2, lag=max_lag, fitdf=0, type="Ljung-Box")
# Box-Ljung test, data:  y^2
# X-squared=4.3042, df = 10, p-value = 0.9326
#
# The lack of autocorrelation in the stardardized residuals and squared standardized residuals can also be grasped by the draft plots 
# corresponding to the selection 10 and 11 of
# plot(fGARCH_1_1)
# Uncomment and execute the above line
#
# the lack of Gaussianity in the empirical distribution of the standardized residuals can also be grasped by the draft plot corresponding to
# the selection 13 of
# plot(fGARCH_1_1)
# Uncomment and execute the above line
#
# Again, given the default options, the GARCH(1,1) model is estimated by the fGarch::garchFit() function  under the assumption that the 
# innovation $\left(W_{t}\right)_{t=1}^{T}\equiv W$ is a Standard Gaussian Distributed (SGD) strong white noise. Consequently, to validate
# the model we should check that the standardized residuals are standard Gaussian distributed. We start with plotting them.
head(spx_train_df)
tail(spx_train_df)
spx_train_df <- add_column(spx_train_df, 
                           fGARCH_1_1_stand_res=c(NA,fGARCH_1_1_stand_res), fGARCH_1_1_cond_stand_dev=c(NA,fGARCH_1_1@sigma.t),
                           .after="GARCH_1_1_cond_stand_dev")
head(spx_train_df)
# As we did above, we draw the scatter and line plot of the the standardized residuals of the GARCH(1,1) model for the SP500 daily
# logarithm return percentage estimated by the fGarch::garchFit() function given the default options. The plots will be very similar to the 
# ones presented above, as the values of the standardized residuals estimated by the tseries::garch() function and
# fGarch::garchFit() function given the default options are very similar.
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=fGARCH_1_1_stand_res)
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 691
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Standardized Residuals of the fGarch::garchFit() Fitted GARCH(1,1) Model with SGD Innovation for the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[2]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("standardized residuals (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_fGARCH_1_1_stand_res_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA), linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=10),
        plot.subtitle=element_text(hjust= 0.5, size=8),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_fGARCH_1_1_stand_res_TrnS_sp.png", plot = spx_fGARCH_1_1_stand_res_TrnS_sp, width = 14, height = 6)
plot(spx_fGARCH_1_1_stand_res_TrnS_sp)
#
# The line plot
spx_fGARCH_1_1_stand_res_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="point_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=10),
        plot.subtitle=element_text(hjust= 0.5, size=8),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_fGARCH_1_1_stand_res_TrnS_lp.png", plot = spx_fGARCH_1_1_stand_res_TrnS_lp, width = 14, height = 6)
plot(spx_fGARCH_1_1_stand_res_TrnS_lp)
#
# As we did above, we superimpose the conditional standard deviation of the GARCH(1,1) model estimated by the fGarch::garchFit() function to
# the plots of the SP500 daily logarithm return percentage.
# The scatter plot.
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=fGARCH_1_1_cond_stand_dev)
head(Data_df)
tail(Data_df)
First_Day <- as.character(Data_df$Date[3])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Logarithm Return Percentage and Conditional Standard Deviation of the fGarch::garchFit() Fitted GARCH(1,1) Model with SGD Innovation - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[2]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily logarithm return percentage")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
line_magenta <- bquote("GARCH(1,1) cond. stand. dev.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_magenta, line_green, line_red)
leg_line_cols <- c("line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_magenta", "line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA, NA), linetype=c("blank", "solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=10),
        plot.subtitle=element_text(hjust= 0.5, size=8),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_TrnS_sp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_TrnS_sp, width = 14, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_TrnS_sp)
#
# The line plot.
line_black <- bquote("perc. log. returns")
line_magenta <- bquote("GARCH(1,1) cond. stand. dev.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_black, line_magenta, line_green, line_red)
leg_line_cols <- c("line_black"="black", "line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_black", "line_magenta", "line_green", "line_red")
spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="line_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=10),
        plot.subtitle=element_text(hjust= 0.5, size=8),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_TrnS_lp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_TrnS_lp, width = 14, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_TrnS_lp)
# 
# From the computed values and plots of the standardized residuals and conditional standard deviation of the GARCH(1,1) models for the 
# SP500 daily percentage results estimated by the tseries:garch() function and fGarch:garchFit() function with the default options, it is
# possible to grasp that the two models are very similar. The only difference seems to be in the initialization of the conditional variance.
# In particular, both models are estimated under the assumption of Standard Gaussian Distributed (SGD) innovation. We have shown that the
# analysis of the standardized residuals of the model estimated by the tseries:garch() function contradicts this assumption. We had better 
# think that the standardized residuals are GED or STD distributed. This is clearly true for the standardized residuals of the model 
# estimated by the fGarch:garchFit() function. We do not repeat the long and almost identical analysis, though. On the other hand, suitably
# selecting some options, the fGarch:garchFit() function offers the possibility of estimating the GARCH(1,1) models under the assumption of 
# innovation distribution other than Gaussian. Therefore, we will explore this possibility to check whether it may lead to a more accurate
# estimation.
############################################################################################################################################
# We now estimate the GARCH(1,1) models showing how the options of the fGarch:garchFit() function allow us to consider the possibility that 
# the innovation distribution is not Gaussian.
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
y <- na.rm(Data_df$log.ret.perc.)
head(y,20)
#  0.1459943 -0.2780218 -2.0574322  0.1567936 -1.1981221  1.1425952 -1.3070934  1.0469459  0.4094494  0.8264048
# -0.1915574 -0.6889464 -0.2419697  0.3017978  1.6919170  0.7432442  0.3369123  0.7366160  0.3657321  0.2991427
# 
# We start with considering the nonlinear minimization subject to box constraints "nlminb" algorithm. The options cond.dist="ged" and 
# include.shape=NULL consider a GED innovation and invoke the estimation of the shape parameter.
fGARCH_1_1_ged_shpN_nlminb <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="ged", include.mean=FALSE,  
                                               include.skew=FALSE, include.shape=NULL, trace=TRUE, algorithm="nlminb")
# Extract from the trace output.
# Series Initialization:
#   ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          ged
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
#   Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#   U           V params includes
# mu     -0.11481907   0.1148191    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0     TRUE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1  shape 
#     2      3      5      8 
# Persistence:                  0.9 
# 
# 
# --- START OF TRACE ---
#   Selected Algorithm: nlminb 
# 
# R coded nlminb Solver: 
#   
#   0: 1.1000000e+99: 0.100000 0.100000 0.800000  4.00000
# 1: 1.1000000e+99: 0.100000 0.100000 0.800000  4.00000
# 
# Final Estimate of the Negative LLH:  15158673573804500815488446204484204406004042024404046082422606242064226020486482682066620800844246624486    norm LLH:  8818309234324899608026462422444062044626824822868266440026660468826444642688486204680484246640060004 
#   omega   alpha1    beta1    shape 
# 1.402282 0.100000 0.800000 4.000000 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#   omega
# omega     -4943885520426178748046424880664822866886288682886680428686868202600202684884848682600088666686880442402
# alpha1  -201221340853522147200048248620880204848020446066806062042466020800680868242664424282280862680824820660264
# beta1   -782630796560580336320860422882420448228068602008064284886628208406422008840242422664248620688868648248664
# shape  -3424376615469783005808466864488040082840606040222420664068426080420624642402002606666644866802686622082482
# alpha1
# omega    -201221340853522147200048248620880204848020446066806062042466020800680868242664424282280862680824820660264
# alpha1  -5405147993958730610468460684080608004882244486886428288204228226484644088820828662220004880484840662420462
# beta1  -15688369046096696381840846280864224048604680240266266008448288048440086088088220622206002206888662266280222
# shape  -61018382598994881284024008600626480642664840022440060882646884684820026042062464682804024802626444088042248
# beta1
# omega    -782630796560580336320860422882420448228068602008064284886628208406422008840242422664248620688868648248664
# alpha1 -15688369046096696381840846280864224048604680240266266008448288048440086088088220622206002206888662266280222
# beta1  -30052175913598978352042084684004046860286686846064204226824262086000888040806040086822446844242208886204868
# shape  -87226034679848494872204240282286422426480204246808460064464824408860062824084284220080822604000066442640602
# shape
# omega    -3424376615469783005808466864488040082840606040222420664068426080420624642402002606666644866802686622082482
# alpha1  -61018382598994881284024008600626480642664840022440060882646884684820026042062464682804024802626444088042248
# beta1   -87226034679848494872204240282286422426480204246808460064464824408860062824084284220080822604000066442640602
# shape  -167087613170133353920220424428424262888620424426484028020088048206684800262002400202000420884202282600248600
# 
# --- END OF TRACE ---
#   
#   Error in solve.default(fit$hessian) : 
#   system is computationally singular: reciprocal condition number = 5.99442e-19
#
summary(fGARCH_1_1_ged_shpN_nlminb)
# Error in h(simpleError(msg, call)) : 
#   error in evaluating the argument 'object' in selecting a method for function 'summary': object 'fGARCH_1_1_ged_shpN_nlminb' not found
#
# The estimation algorithm clearly yields error. We add the Nelder-Mead algorithm to the estimation procedure.
fGARCH_1_1_ged_shpN_nlminb_nm <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="ged", include.mean=FALSE,  
                                                  include.skew=FALSE, include.shape=NULL, trace=TRUE, algorithm="nlminb+nm")
# Series Initialization:
#   ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          ged
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
#   Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#   U           V       params   includes
# mu     -0.11481907   0.1148191    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0     TRUE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1  shape 
#     2      3      5      8 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: nlminb+nm 
# 
# R coded nlminb Solver: 
#   
#   0: 1.1000000e+99: 0.100000 0.100000 0.800000  4.00000
# 1: 1.1000000e+99: 0.100000 0.100000 0.800000  4.00000
# 
# R coded Nelder-Mead Hybrid Solver: 
#   
#   Nelder-Mead direct search function minimizer
# function value for initial parameters = 30.912681
# Scaled convergence tolerance is 3.09127e-10
# Stepsize computed as 0.100000
# BUILD              5 45.259256 30.912681
# EXTENSION          7 41.144778 0.000000
# LO-REDUCTION       9 37.404343 0.000000
# LO-REDUCTION      11 34.003949 0.000000
# LO-REDUCTION      13 30.912681 0.000000
# Exiting from Nelder Mead minimizer
# 15 function evaluations used
# 
# Final Estimate of the Negative LLH:  4956.208    norm LLH:  2.883193 
#   omega    alpha1     beta1     shape 
# 4.9846751 0.116691 0.8168750 1.9750000 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#   omega      alpha1       beta1       shape
# omega     6.153787    39.51659   -267.6671   -5.475413
# alpha1   39.516595   609.17058  -3856.7771  -85.535192
# beta1  -267.667128 -3856.77711 -26070.6330 -217.070368
# shape    -5.475413   -85.53519   -217.0704  102.517131
# 
# Warning message: In sqrt(diag(fit$cvar)) : NaNs produced
# 
summary(fGARCH_1_1_ged_shpN_nlminb_nm)
# Extract from the summary output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula = ~garch(1, 1), data = y, init.rec = "mci", cond.dist = "ged", include.mean = FALSE, include.skew = FALSE, 
#                        include.shape = NULL, trace = TRUE, algorithm = "nlminb+nm") 
# 
# Conditional Distribution: ged 
# 
# Coefficient(s): omega   alpha1    beta1    shape  
#                4.98468  0.11617  0.81687  1.97500  
# 
# Std. Errors: based on Hessian 
# 
# Error Analysis: Estimate  Std. Error  t value            Pr(>|t|)    
#         omega   4.984675      NaN      NaN                 NaN    
#        alpha1   0.116172      NaN      NaN                 NaN    
#         beta1   0.816875    0.004191    194.9 <0.0000000000000002 ***
#         shape   1.975000      NaN      NaN                 NaN    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -4956.208    normalized:  -2.883193 
# 
# Standardised Residuals Tests:
#                                   Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  22622.4858041 0.0000000
# Shapiro-Wilk Test  R    W          0.9016892 0.0000000
# Ljung-Box Test     R    Q(10)     10.5784629 0.3912878
# Ljung-Box Test     R    Q(15)     12.3719770 0.6506830
# Ljung-Box Test     R    Q(20)     14.3949542 0.8099197
# Ljung-Box Test     R^2  Q(10)      4.6519698 0.9131825
# Ljung-Box Test     R^2  Q(15)      5.2318064 0.9899751
# Ljung-Box Test     R^2  Q(20)      6.2056106 0.9985898
# LM Arch Test       R    TR^2       4.7582823 0.9655690
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.771039 5.783720 5.771028 5.775731
# 
# The estimation procedure allows to get parameters estimates, but the obtained results appear somewhat lacking. This is confirmed by the
# visual evidence from Plots 13
# plot(fGARCH_1_1_ged_shpN_nlminb_nm)
# Uncomment and execute the above line
#
# Hence, we consider the Limited-memory Broyden–Fletcher–Goldfarb–Shanno algorithm with box constraints "lbfgsb" algorithm.
fGARCH_1_1_ged_shpN_lbfgsb <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="ged", include.mean=FALSE,
                                               include.skew=FALSE, include.shape=NULL, trace=TRUE, algorithm="lbfgsb")
# Extract from the trace output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          ged
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#              U           V      params includes
# mu     -0.11481907   0.1148191    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0    TRUE
# Index List of Parameters to be Optimized:
# omega alpha1  beta1  shape 
#   2      3      5      8 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: lbfgsb 
# 
# R coded optim[L-BFGS-B] Solver: 
# iter   10 value 2183.975912
# iter   20 value 2145.633236
#    final  value 2145.601896 
# stopped after 25 iterations
# 
# Final Estimate of the Negative LLH: 4415.272  norm LLH: 2.568512 
#   omega    alpha1     beta1     shape 
# 0.3792814 0.0750745 0.8942373 1.0000000 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#           omega     alpha1      beta1      shape
# omega   -438.0519  -3066.057  -4206.966  -129.8367
# alpha1 -3066.0574 -33474.628 -37011.953 -1677.3608
# beta1  -4206.9656 -37011.953 -47205.418 -1822.7623
# shape   -129.8367  -1677.361  -1822.762  -675.1041
# 
# --- END OF TRACE ---
#
summary(fGARCH_1_1_ged_shpN_lbfgsb)
# Extract from the summary output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="ged", include.mean=FALSE, include.skew=FALSE, 
#                        include.shape=NULL, trace=TRUE, algorithm="lbfgsb") 
# Conditional Distribution: ged 
# Coefficient(s):  omega    alpha1     beta1     shape  
#                0.379281  0.075074  0.894237  1.000000
#
# Std. Errors: based on Hessian 
# Error Analysis: Estimate  Std. Error  t value Pr(>|t|)    
#        omega    0.37928     0.14094    2.691  0.00712 ** 
#        alpha1   0.07507     0.01673    4.486 7.25e-06 ***
#        beta1    0.89424     0.02223   40.224  < 2e-16 ***
#        shape    1.00000     0.04140   24.152  < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -4415.272    normalized:  -2.568512 
# 
# Standardised Residuals Tests:  Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  2.702746e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.846426e-01 0.0000000
# Ljung-Box Test     R    Q(10)  9.131429e+00 0.5196776
# Ljung-Box Test     R    Q(15)  1.162095e+01 0.7074641
# Ljung-Box Test     R    Q(20)  1.425941e+01 0.8171032
# Ljung-Box Test     R^2  Q(10)  3.425949e+00 0.9695531
# Ljung-Box Test     R^2  Q(15)  4.034650e+00 0.9976217
# Ljung-Box Test     R^2  Q(20)  5.392945e+00 0.9995036
# LM Arch Test       R    TR^2   3.681881e+00 0.9885171
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.141677 5.154358 5.141667 5.146369 
#
# The option include.shape=NULL would allegedly lead to an estimate of the shape parameter. Eventually, the shape parameter seems to move
# from the initial value shape=4.0 to the value shape=1.0, the left endpoint of the interval [1.0  10.0], where the shape seems to be
# constrained to vary. On the other hand, the estimation procedure stops after 25 iterations, signaling no convergence. In light of this, 
# we cannot validate the estimated model. After some failed attempts to modify the include.shape option and introduce the further 
# shape=GED_nu option, which sets the initial value of the shape to the value GED_nu=0.8742729 previously estimated, we have found that the 
# difficulty of successfully estimating the shape parameter can be overcome by changing the estimation algorithm.
#
# plot(fGARCH_1_1_ged_shpN_lbfgsb)
# Uncomment and execute the above line
# From the Q-Q plot, we have visual evidence of some improvement in the fit between the standardized residuals and the quantiles of the
# hypothesized GED of the innovation. However, the likely incorrect shape parameter estimation might prevent a better fit at the tails of 
# the Q-Q plot.
#
# Combining the options shape=GED_nu, include.shape=FALSE, and algorithm="lbfgsb" should fix the shape parameter at the value 
# GED_nu=0.8742729 and estimate the other parameters.
fGARCH_1_1_ged_shpF_lbfgsb <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="ged", shape=GED_nu,
                                               include.mean=FALSE, include.skew=FALSE, include.shape=FALSE, trace=TRUE, algorithm="lbfgsb")
# Extract from the trace output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          ged
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#              U           V       params  includes
# mu     -0.11481907   0.1148191 0.0000000    FALSE
# omega   0.00000100 100.0000000 0.1000000     TRUE
# alpha1  0.00000001   1.0000000 0.1000000     TRUE
# gamma1 -0.99999999   1.0000000 0.1000000    FALSE
# beta1   0.00000001   1.0000000 0.8000000     TRUE
# delta   0.00000000   2.0000000 2.0000000    FALSE
# skew    0.10000000  10.0000000 1.0000000    FALSE
# shape   1.00000000  10.0000000 0.8742729    FALSE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1 
#    2      3      5 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: lbfgsb 
# 
# R coded optim[L-BFGS-B] Solver: 
# iter   10 value 2141.306044
#    final  value 2141.201421 
# converged
# 
# Final Estimate of the Negative LLH: 4410.871  norm LLH: 2.565952 
# omega     alpha1      beta1 
# 0.33912111 0.08157755 0.89939199 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#            omega    alpha1      beta1
# omega   -384.2906  -2605.60  -3879.742
# alpha1 -2605.6000 -27680.23 -33498.961
# beta1  -3879.7419 -33498.96 -46455.613
# 
# --- END OF TRACE ---
#
summary(fGARCH_1_1_ged_shpF_lbfgsb)
# Extract from the summary output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula=~garch(1, 1), data=y, init.rec="mci", shape=GED_nu, cond.dist="ged", include.mean=FALSE,  
#                        include.skew=FALSE, include.shape=FALSE, trace=TRUE, algorithm="lbfgsb") 
# 
# Conditional Distribution: ged 
# Coefficient(s):
#   omega    alpha1     beta1  
# 0.339121  0.081578  0.899392  
# 
# Std. Errors: based on Hessian 
# Error Analysis: Estimate  Std. Error  t value Pr(>|t|)    
#         omega    0.33912     0.14170    2.393   0.0167 *  
#         alpha1   0.08158     0.01853    4.402 1.07e-05 ***
#         beta1    0.89939     0.02172   41.402  < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood:   -4410.871    normalized:  -2.565952 
# 
# Standardised Residuals Tests:
#                                 Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  2.785661e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.816101e-01 0.0000000
# Ljung-Box Test     R    Q(10)  9.308394e+00 0.5031073
# Ljung-Box Test     R    Q(15)  1.189688e+01 0.6868170
# Ljung-Box Test     R    Q(20)  1.465091e+01 0.7960221
# Ljung-Box Test     R^2  Q(10)  3.388936e+00 0.9707356
# Ljung-Box Test     R^2  Q(15)  4.050387e+00 0.9975677
# Ljung-Box Test     R^2  Q(20)  5.476311e+00 0.9994423
# LM Arch Test       R    TR^2   3.686289e+00 0.9884553
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.135394 5.144905 5.135388 5.138913 
#
# In this case, the estimation procedure seems to converge with a slightly improvement in all the values of the information criteria. 
# Note that the estimated values for the parameters omega=0.33912, alpha1=0.08158, and beta1=0.89939, under the assumption of GED
# distributed innovation, are not significantly close to the corresponding estimated values for the parameters omega=1.27007192,  
# alpha1=0.09084851, and beta1=0.82533630, obtained under the assumption of Gaussian innovation. In fact, we have
# omega:  abs(0.33912-1.27007192)=0.9309519  > std_err=0.14170
# alpha1: abs(0.08158-0.09084851)=0.00926851 < std_err=0.01853
# beta1:  abs(0.89939-0.82533630)=0.0740537  > std_err=0.02172
#
# From the Q-Q plot we also have visual evidence that the above combination of options improves significantly the fit between the
# standardized residuals of the estimated model and the quantiles of the hypothesized GED of the innovation.
# plot(fGARCH_1_1_ged_shpF_lbfgsb)
# Uncomment and execute the above line
#
# Combining the options include.shape=NULL and algorithm="lbfgsb+mn", which invokes the Limited-memory Broyden–Fletcher–Goldfarb–Shanno 
# algorithm with box constraints plus the Nelder-Mead algorithm, allows the estimation of the shape parameters.
fGARCH_1_1_ged_shpN_lbfgsb_nm <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="ged", include.mean=FALSE,  
                                                  include.skew=FALSE, include.shape=NULL, trace=TRUE, algorithm="lbfgsb+nm")
# Extract from the trace output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          ged
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#              U           V     params includes
# mu     -0.11481907   0.1148191    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0     TRUE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1  shape 
#     2      3      5      8 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: lbfgsb+nm 
#
# R coded optim[L-BFGS-B] Solver: 
# iter   10 value 2183.975912
# iter   20 value 2145.633236
# final  value 2145.601896 
# stopped after 25 iterations
# 
# R coded Nelder-Mead Hybrid Solver: 
# Nelder-Mead direct search function minimizer
# function value for initial parameters=1.000000
# Scaled convergence tolerance is 1e-11
# Stepsize computed as 0.100000
# BUILD              5 1.290701 1.000000
# LO-REDUCTION       7 1.059806 1.000000
# HI-REDUCTION       9 1.024337 1.000000
# HI-REDUCTION      11 1.009785 1.000000
# HI-REDUCTION      13 1.004947 1.000000
# LO-REDUCTION      15 1.004494 1.000000
# REFLECTION        17 1.003289 0.999535
# REFLECTION        19 1.000406 0.999042
# REFLECTION        21 1.000005 0.998748
# HI-REDUCTION      23 1.000000 0.998748
# LO-REDUCTION      25 0.999535 0.998427
# REFLECTION        27 0.999042 0.998193
# HI-REDUCTION      29 0.998912 0.997975
# HI-REDUCTION      31 0.998748 0.997975
# LO-REDUCTION      33 0.998427 0.997960
# HI-REDUCTION      35 0.998301 0.997960
# HI-REDUCTION      37 0.998193 0.997960
# HI-REDUCTION      39 0.998078 0.997960
# HI-REDUCTION      41 0.998040 0.997960
# LO-REDUCTION      43 0.997977 0.997926
# HI-REDUCTION      45 0.997975 0.997926
# HI-REDUCTION      47 0.997973 0.997923
# HI-REDUCTION      49 0.997960 0.997923
# LO-REDUCTION      51 0.997932 0.997921
# HI-REDUCTION      53 0.997931 0.997920
# HI-REDUCTION      55 0.997926 0.997920
# HI-REDUCTION      57 0.997923 0.997917
# HI-REDUCTION      59 0.997921 0.997917
# HI-REDUCTION      61 0.997920 0.997917
# LO-REDUCTION      63 0.997920 0.997917
# LO-REDUCTION      65 0.997917 0.997917
# REFLECTION        67 0.997917 0.997916
# HI-REDUCTION      69 0.997917 0.997916
# HI-REDUCTION      71 0.997917 0.997916
# HI-REDUCTION      73 0.997917 0.997916
# LO-REDUCTION      75 0.997916 0.997916
# HI-REDUCTION      77 0.997916 0.997916
# LO-REDUCTION      79 0.997916 0.997916
# LO-REDUCTION      81 0.997916 0.997916
# HI-REDUCTION      83 0.997916 0.997916
# REFLECTION        85 0.997916 0.997916
# REFLECTION        87 0.997916 0.997916
# HI-REDUCTION      89 0.997916 0.997916
# REFLECTION        91 0.997916 0.997916
# REFLECTION        93 0.997916 0.997916
# LO-REDUCTION      95 0.997916 0.997916
# EXTENSION         97 0.997916 0.997916
# LO-REDUCTION      99 0.997916 0.997916
# EXTENSION        101 0.997916 0.997916
# LO-REDUCTION     103 0.997916 0.997916
# LO-REDUCTION     105 0.997916 0.997916
# REFLECTION       107 0.997916 0.997916
# EXTENSION        109 0.997916 0.997915
# LO-REDUCTION     111 0.997916 0.997915
# LO-REDUCTION     113 0.997916 0.997915
# LO-REDUCTION     115 0.997916 0.997915
# EXTENSION        117 0.997916 0.997915
# EXTENSION        119 0.997915 0.997915
# LO-REDUCTION     121 0.997915 0.997915
# LO-REDUCTION     123 0.997915 0.997915
# LO-REDUCTION     125 0.997915 0.997915
# LO-REDUCTION     127 0.997915 0.997915
# REFLECTION       129 0.997915 0.997915
# LO-REDUCTION     131 0.997915 0.997915
# HI-REDUCTION     133 0.997915 0.997915
# REFLECTION       135 0.997915 0.997915
# REFLECTION       137 0.997915 0.997915
# LO-REDUCTION     139 0.997915 0.997915
# LO-REDUCTION     141 0.997915 0.997915
# EXTENSION        143 0.997915 0.997915
# LO-REDUCTION     145 0.997915 0.997915
# LO-REDUCTION     147 0.997915 0.997915
# LO-REDUCTION     149 0.997915 0.997915
# REFLECTION       151 0.997915 0.997915
# LO-REDUCTION     153 0.997915 0.997915
# HI-REDUCTION     155 0.997915 0.997915
# LO-REDUCTION     157 0.997915 0.997915
# EXTENSION        159 0.997915 0.997915
# LO-REDUCTION     161 0.997915 0.997915
# LO-REDUCTION     163 0.997915 0.997915
# LO-REDUCTION     165 0.997915 0.997915
# LO-REDUCTION     167 0.997915 0.997915
# LO-REDUCTION     169 0.997915 0.997915
# HI-REDUCTION     171 0.997915 0.997915
# LO-REDUCTION     173 0.997915 0.997915
# REFLECTION       175 0.997915 0.997915
# LO-REDUCTION     177 0.997915 0.997915
# LO-REDUCTION     179 0.997915 0.997915
# LO-REDUCTION     181 0.997915 0.997915
# EXTENSION        183 0.997915 0.997915
# HI-REDUCTION     185 0.997915 0.997915
# LO-REDUCTION     187 0.997915 0.997915
# LO-REDUCTION     189 0.997915 0.997915
# LO-REDUCTION     191 0.997915 0.997915
# LO-REDUCTION     193 0.997915 0.997915
# EXTENSION        195 0.997915 0.997915
# LO-REDUCTION     197 0.997915 0.997915
# LO-REDUCTION     199 0.997915 0.997915
# EXTENSION        201 0.997915 0.997915
# EXTENSION        203 0.997915 0.997915
# LO-REDUCTION     205 0.997915 0.997915
# REFLECTION       207 0.997915 0.997915
# EXTENSION        209 0.997915 0.997915
# LO-REDUCTION     211 0.997915 0.997915
# HI-REDUCTION     213 0.997915 0.997915
# LO-REDUCTION     215 0.997915 0.997915
# EXTENSION        217 0.997915 0.997915
# HI-REDUCTION     219 0.997915 0.997915
# LO-REDUCTION     221 0.997915 0.997915
# LO-REDUCTION     223 0.997915 0.997915
# EXTENSION        225 0.997915 0.997915
# LO-REDUCTION     227 0.997915 0.997915
# EXTENSION        229 0.997915 0.997915
# LO-REDUCTION     231 0.997915 0.997915
# LO-REDUCTION     233 0.997915 0.997915
# REFLECTION       235 0.997915 0.997915
# REFLECTION       237 0.997915 0.997915
# LO-REDUCTION     239 0.997915 0.997915
# EXTENSION        241 0.997915 0.997915
# LO-REDUCTION     243 0.997915 0.997915
# LO-REDUCTION     245 0.997915 0.997915
# LO-REDUCTION     247 0.997915 0.997915
# EXTENSION        249 0.997915 0.997915
# LO-REDUCTION     251 0.997915 0.997915
# EXTENSION        253 0.997915 0.997915
# LO-REDUCTION     255 0.997915 0.997915
# LO-REDUCTION     257 0.997915 0.997915
# LO-REDUCTION     259 0.997915 0.997915
# LO-REDUCTION     261 0.997915 0.997915
# EXTENSION        263 0.997915 0.997915
# EXTENSION        265 0.997915 0.997915
# LO-REDUCTION     267 0.997915 0.997915
# REFLECTION       269 0.997915 0.997915
# LO-REDUCTION     271 0.997915 0.997915
# LO-REDUCTION     273 0.997915 0.997915
# LO-REDUCTION     275 0.997915 0.997915
# LO-REDUCTION     277 0.997915 0.997915
# EXTENSION        279 0.997915 0.997915
# LO-REDUCTION     281 0.997915 0.997915
# LO-REDUCTION     283 0.997915 0.997915
# EXTENSION        285 0.997915 0.997915
# EXTENSION        287 0.997915 0.997915
# LO-REDUCTION     289 0.997915 0.997915
# LO-REDUCTION     291 0.997915 0.997915
# REFLECTION       293 0.997915 0.997915
# Exiting from Nelder Mead minimizer
# 295 function evaluations used
# 
# Final Estimate of the Negative LLH: 4410.799  norm LLH: 2.56591 
#   omega     alpha1      beta1      shape 
# 0.34079449 0.08046777 0.89917369 0.88780427 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#           omega     alpha1      beta1      shape
# omega   -394.7368  -2685.631  -3952.109  -221.8304
# alpha1 -2685.6312 -28609.574 -34203.893 -2469.1411
# beta1  -3952.1091 -34203.893 -46878.309 -2980.3783
# shape   -221.8304  -2469.141  -2980.378 -1000.9125
# 
# --- END OF TRACE ---
#
summary(fGARCH_1_1_ged_shpN_lbfgsb_nm)
# Extract from the summary output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula=~garch(1, 1), data=y, init.rec="mci", cond.dist="ged", include.mean=FALSE, include.skew=FALSE, 
#                        include.shape=NULL, trace=TRUE, algorithm="lbfgsb+nm") 
# 
# Conditional Distribution: ged 
# Coefficient(s):
#   omega    alpha1     beta1     shape  
# 0.340794  0.080468  0.899174  0.887804  
# 
# Std. Errors: based on Hessian 
# Error Analysis:
#           Estimate  Std. Error  t value Pr(>|t|)    
#   omega    0.34079     0.14059    2.424   0.0153 *  
#   alpha1   0.08047     0.01836    4.383 1.17e-05 ***
#   beta1    0.89917     0.02169   41.449  < 2e-16 ***
#   shape    0.88780     0.03571   24.860  < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -4410.799    normalized:  -2.56591 
# 
# Standardised Residuals Tests:
#                                 Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  2.782087e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.818707e-01 0.0000000
# Ljung-Box Test     R    Q(10)  9.292729e+00 0.5045662
# Ljung-Box Test     R    Q(15)  1.187352e+01 0.6885761
# Ljung-Box Test     R    Q(20)  1.461694e+01 0.7978907
# Ljung-Box Test     R^2  Q(10)  3.389556e+00 0.9707160
# Ljung-Box Test     R^2  Q(15)  4.045833e+00 0.9975834
# Ljung-Box Test     R^2  Q(20)  5.464050e+00 0.9994517
# LM Arch Test       R    TR^2   3.683053e+00 0.9885007
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.136473 5.149154 5.136462 5.141165
#
# Note that the estimated value of the state parameter is shape=0.88780 with a standard error std_err=0.03571. Therefore, we have
# abs(0.88780-0.8742729)=0.0135271<0.03571=shp_std_err. Hence, the estimated shape parameter differs from the formerly estimated parameter
# GED_nu=0.8742729 for less than the standard error. Regarding the values of the information criteria, we have a slight worsening compared
# to the former model. However, successfully estimating the shape parameter seems to be a reasonable compensation.
# Note also that the parameters omega, alpha1, and beta1 estimated in this case are very similar to the parameters estimated in the former
# case. In fact, the absolute value of the difference between the estimates of all parameters omega, alpha1, and beta1 is smaller than the
# corresponding minimum standard error.
# omega:  abs(0.34079-0.33912)=0.00167<0.14059=min(0.14059,0.14170);
# alpha1: abs(0.08047-0.08158)=0.00111<0.01836=min(0.01836,0.01853);
# beta1:  abs(0.89917-0.89424)=0.00493<0.02169=min(0.02223,0.02169).
#
# From the Q-Q plot, we also have visual evidence of a slight worsening in the fit between the standardized residuals of the estimated model
# and the quantiles of the hypothesized GED of the innovation.
# plot(fGARCH_1_1_ged_shpN_lbfgsb_nm)
# Uncomment and execute the above line
#
# We consider combining the options shape=GED_nu, include.shape=NULL, algorithm="lbfgsb+nm". These should lead to an estimation of the 
# shape parameter starting from the value GED_nu, by meas of the "lbfgsb+nm" algorithm.
fGARCH_1_1_ged_initshp_shpN_lbfgsb_nm <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="ged", 
                                                          shape=GED_nu, include.mean=FALSE, include.skew=FALSE, include.shape=NULL, 
                                                          trace=TRUE, algorithm="lbfgsb+nm")
# Extrac from the trace output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          ged
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#              U           V       params  includes
# mu     -0.11481907   0.1148191 0.0000000    FALSE
# omega   0.00000100 100.0000000 0.1000000     TRUE
# alpha1  0.00000001   1.0000000 0.1000000     TRUE
# gamma1 -0.99999999   1.0000000 0.1000000    FALSE
# beta1   0.00000001   1.0000000 0.8000000     TRUE
# delta   0.00000000   2.0000000 2.0000000    FALSE
# skew    0.10000000  10.0000000 1.0000000    FALSE
# shape   1.00000000  10.0000000 0.8742729     TRUE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1  shape 
#     2      3      5      8 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: lbfgsb+nm 
# 
# R coded optim[L-BFGS-B] Solver: 
#   iter   10 value 2145.604098
#      final  value 2145.601895 
# converged
# 
# R coded Nelder-Mead Hybrid Solver: 
# Nelder-Mead direct search function minimizer
# function value for initial parameters = 1.000000
# Scaled convergence tolerance is 1e-11
# Stepsize computed as 0.100000
# BUILD              5 1.290719 1.000000
# LO-REDUCTION       7 1.059806 1.000000
# HI-REDUCTION       9 1.024338 1.000000
# HI-REDUCTION      11 1.009785 1.000000
# HI-REDUCTION      13 1.004947 1.000000
# LO-REDUCTION      15 1.004494 1.000000
# REFLECTION        17 1.003289 0.999535
# REFLECTION        19 1.000406 0.999042
# REFLECTION        21 1.000004 0.998748
# HI-REDUCTION      23 1.000000 0.998748
# LO-REDUCTION      25 0.999535 0.998427
# REFLECTION        27 0.999042 0.998193
# HI-REDUCTION      29 0.998912 0.997975
# HI-REDUCTION      31 0.998748 0.997975
# LO-REDUCTION      33 0.998427 0.997960
# HI-REDUCTION      35 0.998301 0.997960
# HI-REDUCTION      37 0.998193 0.997960
# HI-REDUCTION      39 0.998078 0.997960
# HI-REDUCTION      41 0.998040 0.997960
# LO-REDUCTION      43 0.997977 0.997926
# HI-REDUCTION      45 0.997975 0.997926
# HI-REDUCTION      47 0.997973 0.997923
# HI-REDUCTION      49 0.997960 0.997923
# LO-REDUCTION      51 0.997932 0.997921
# HI-REDUCTION      53 0.997931 0.997920
# HI-REDUCTION      55 0.997926 0.997920
# HI-REDUCTION      57 0.997923 0.997917
# HI-REDUCTION      59 0.997921 0.997917
# HI-REDUCTION      61 0.997920 0.997917
# LO-REDUCTION      63 0.997920 0.997917
# LO-REDUCTION      65 0.997917 0.997917
# REFLECTION        67 0.997917 0.997916
# HI-REDUCTION      69 0.997917 0.997916
# HI-REDUCTION      71 0.997917 0.997916
# HI-REDUCTION      73 0.997917 0.997916
# LO-REDUCTION      75 0.997916 0.997916
# HI-REDUCTION      77 0.997916 0.997916
# LO-REDUCTION      79 0.997916 0.997916
# LO-REDUCTION      81 0.997916 0.997916
# HI-REDUCTION      83 0.997916 0.997916
# REFLECTION        85 0.997916 0.997916
# REFLECTION        87 0.997916 0.997916
# HI-REDUCTION      89 0.997916 0.997916
# REFLECTION        91 0.997916 0.997916
# REFLECTION        93 0.997916 0.997916
# LO-REDUCTION      95 0.997916 0.997916
# EXTENSION         97 0.997916 0.997916
# LO-REDUCTION      99 0.997916 0.997916
# EXTENSION        101 0.997916 0.997916
# LO-REDUCTION     103 0.997916 0.997916
# LO-REDUCTION     105 0.997916 0.997916
# REFLECTION       107 0.997916 0.997916
# EXTENSION        109 0.997916 0.997915
# LO-REDUCTION     111 0.997916 0.997915
# LO-REDUCTION     113 0.997916 0.997915
# LO-REDUCTION     115 0.997916 0.997915
# EXTENSION        117 0.997916 0.997915
# EXTENSION        119 0.997915 0.997915
# LO-REDUCTION     121 0.997915 0.997915
# LO-REDUCTION     123 0.997915 0.997915
# LO-REDUCTION     125 0.997915 0.997915
# LO-REDUCTION     127 0.997915 0.997915
# REFLECTION       129 0.997915 0.997915
# LO-REDUCTION     131 0.997915 0.997915
# HI-REDUCTION     133 0.997915 0.997915
# REFLECTION       135 0.997915 0.997915
# REFLECTION       137 0.997915 0.997915
# LO-REDUCTION     139 0.997915 0.997915
# LO-REDUCTION     141 0.997915 0.997915
# EXTENSION        143 0.997915 0.997915
# LO-REDUCTION     145 0.997915 0.997915
# LO-REDUCTION     147 0.997915 0.997915
# LO-REDUCTION     149 0.997915 0.997915
# REFLECTION       151 0.997915 0.997915
# LO-REDUCTION     153 0.997915 0.997915
# LO-REDUCTION     155 0.997915 0.997915
# HI-REDUCTION     157 0.997915 0.997915
# REFLECTION       159 0.997915 0.997915
# REFLECTION       161 0.997915 0.997915
# REFLECTION       163 0.997915 0.997915
# LO-REDUCTION     165 0.997915 0.997915
# LO-REDUCTION     167 0.997915 0.997915
# REFLECTION       169 0.997915 0.997915
# LO-REDUCTION     171 0.997915 0.997915
# HI-REDUCTION     173 0.997915 0.997915
# EXTENSION        175 0.997915 0.997915
# LO-REDUCTION     177 0.997915 0.997915
# LO-REDUCTION     179 0.997915 0.997915
# EXTENSION        181 0.997915 0.997915
# REFLECTION       183 0.997915 0.997915
# EXTENSION        185 0.997915 0.997915
# REFLECTION       187 0.997915 0.997915
# LO-REDUCTION     189 0.997915 0.997915
# LO-REDUCTION     191 0.997915 0.997915
# LO-REDUCTION     193 0.997915 0.997915
# HI-REDUCTION     195 0.997915 0.997915
# LO-REDUCTION     197 0.997915 0.997915
# LO-REDUCTION     199 0.997915 0.997915
# REFLECTION       201 0.997915 0.997915
# REFLECTION       203 0.997915 0.997915
# HI-REDUCTION     205 0.997915 0.997915
# HI-REDUCTION     207 0.997915 0.997915
# REFLECTION       209 0.997915 0.997915
# HI-REDUCTION     211 0.997915 0.997915
# HI-REDUCTION     213 0.997915 0.997915
# REFLECTION       215 0.997915 0.997915
# Exiting from Nelder Mead minimizer
# 217 function evaluations used
# 
# Final Estimate of the Negative LLH: 4410.799  norm LLH: 2.56591 
# omega     alpha1      beta1      shape 
# 0.34079130 0.08046938 0.89917383 0.88779372 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#           omega     alpha1      beta1      shape
# omega   -394.7252  -2685.529  -3952.034  -221.8389
# alpha1 -2685.5292 -28608.302 -34203.110 -2469.2085
# beta1  -3952.0345 -34203.110 -46878.107 -2980.5094
# shape   -221.8389  -2469.209  -2980.509 -1000.9491
# attr(,"time")
# Time difference of 0.04401994 secs
# 
# --- END OF TRACE ---
#
summary(fGARCH_1_1_ged_initshp_shpN_lbfgsb_nm)
# Extract from the summary output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula=~garch(1, 1), data=y, init.rec"mci", shape=GED_nu, cond.dist="ged", include.mean=FALSE, include.skew=FALSE, 
#                        include.shape=NULL, trace=TRUE, algorithm="lbfgsb+nm") 
# 
# Conditional Distribution: ged 
# Coefficient(s):
#   omega    alpha1     beta1     shape  
# 0.340791  0.080469  0.899174  0.887794  
# 
# Std. Errors: based on Hessian 
# Error Analysis: Estimate  Std. Error  t value Pr(>|t|)    
#         omega    0.34079     0.14059    2.424   0.0153 *  
#         alpha1   0.08047     0.01836    4.383 1.17e-05 ***
#         beta1    0.89917     0.02169   41.449  < 2e-16 ***
#         shape    0.88779     0.03571   24.860  < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -4410.799    normalized:  -2.56591 
# 
# Standardised Residuals Tests:
#                                  Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  2.782089e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.818703e-01 0.0000000
# Ljung-Box Test     R    Q(10)  9.292750e+00 0.5045643
# Ljung-Box Test     R    Q(15)  1.187355e+01 0.6885738
# Ljung-Box Test     R    Q(20)  1.461699e+01 0.7978881
# Ljung-Box Test     R^2  Q(10)  3.389558e+00 0.9707160
# Ljung-Box Test     R^2  Q(15)  4.045843e+00 0.9975834
# Ljung-Box Test     R^2  Q(20)  5.464074e+00 0.9994517
# LM Arch Test       R    TR^2   3.683061e+00 0.9885006
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.136473 5.149154 5.136462 5.141165 
#
# Invoking the shape=GED_nu option does not seem to improve the performances of the estimated model.
#
# From the Q-Q plot, we also have visual evidence that invoking the shape=GED_nu option does not seem to improve the performances of the 
# estimated model.
# plot(fGARCH_1_1_ged_initshp_shpN_lbfgsb_nm)
# Uncomment and execute the above line
#
#
# Overall, the best model appears to be estimated invoking the options include.shape=NULL and algorithm="lbfgsb+nm".
#
# We plot the standardized residuals and the conditional standard deviation estimated by the
# fGarch::garchFit(..., include.shape=NULL, algorithm="lbfgsb+nm") function. We have
# 
fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res <- fGarch::residuals(fGARCH_1_1_ged_shpN_lbfgsb_nm, standardize=TRUE)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res, 20)
#  0.1304136 -0.2553669 -1.9402297  0.1377946 -1.0826987  1.0278266 -1.1741721  0.9310255  0.3655234  0.7560434
# -0.1773561 -0.6555149 -0.2338895  0.2995276  1.7221659  0.7185696  0.3300758  0.7397777  0.3718126  0.3114254
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev <- fGARCH_1_1_ged_initshp_shpN_lbfgsb_nm@sigma.t
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev, 20)
# 1.1194712 1.0887139 1.0604043 1.1378811 1.1066073 1.1116619 1.1132049 1.1245095 1.1201738 1.0930652 1.0800717
# 1.0509987 1.0345449 1.0075764 0.9824315 1.0343371 1.0207100 0.9957234 0.9836432 0.9605560
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var <- fGARCH_1_1_ged_initshp_shpN_lbfgsb_nm@h.t
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var, 20)
#
head(spx_train_df)
tail(spx_train_df)
spx_train_df <- add_column(spx_train_df, 
                           fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res=c(NA,fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res), 
                           fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev=c(NA,fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev),
                           fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var=c(NA,fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var),
                           .after="fGARCH_1_1_cond_stand_dev")
head(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res)
head(Data_df)
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 691
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Standardized Residuals of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation for the SP500 Daily Logarithm Return Percentage - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[2]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("standardized residuals (US $)")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
leg_line_labs <- c(line_green, line_red)
leg_line_cols <- c("line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA), linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=8),
        plot.subtitle=element_text(hjust= 0.5, size=7),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_TrnS_sp.png", plot = spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_TrnS_sp, width = 14, height = 6)
plot(spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_TrnS_sp)
#
# The line plot
spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="point_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=8),
        plot.subtitle=element_text(hjust= 0.5, size=7),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_TrnS_lp.png", plot = spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_TrnS_lp, width = 14, height = 6)
plot(spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_TrnS_lp)
#
# We superimpose the conditional standard deviation of the GARCH(1,1) model estimated by the 
# fGarch::garchFit(..., include.shape=NULL, algorithm="lbfgsb+nm") function to the plots of the SP500 daily logarithm return percentage.
# The scatter plot.
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev)
head(Data_df)
tail(Data_df)
First_Day <- as.character(Data_df$Date[3])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Logarithm Return Percentage and Conditional Standard Deviation of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[2]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily logarithm return percentage")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("GARCH(1,1) stand. residuals")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
line_magenta <- bquote("GARCH(1,1) cond. stand. dev.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_magenta, line_green, line_red)
leg_line_cols <- c("line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_magenta", "line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_perc_log_ret_fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA, NA), linetype=c("blank", "solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=10),
        plot.subtitle=element_text(hjust= 0.5, size=8),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev_TrnS_sp.png", plot = spx_perc_log_ret_fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev_TrnS_sp, width = 14, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev_TrnS_sp)
#
# The line plot.
line_black <- bquote("perc. log. returns")
line_magenta <- bquote("GARCH(1,1) cond. stand. dev.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_black, line_magenta, line_green, line_red)
leg_line_cols <- c("line_black"="black", "line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_black", "line_magenta", "line_green", "line_red")
spx_perc_log_ret_fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="line_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=10),
        plot.subtitle=element_text(hjust= 0.5, size=8),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev_TrnS_lp.png", plot = spx_perc_log_ret_fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev_TrnS_lp, width = 14, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev_TrnS_lp)
#
# Note that we have
length(which(abs(spx_train_df$log.ret.perc.[-c(1,2)])<spx_train_df$fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev[-c(1,2)]))/length(spx_train_df$log.ret.perc.[-c(1,2)])
# 0.6811594
#
# We plot the histogram of the standardized residuals together with the empirical density function, the Standard Gaussian Distribution Density function, 
# the generalized Error Distribution Density Function (GED) with mean parameter, mean=0, standard deviation parameter, sd=1, and shape parameter,
# nu=fGARCH_1_1_ged_initshp_shpN_lbfgsb_nm@fit[["par"]][["shape"]]=0.8877937.
png("plots/spx_hist_stand_res_GED_inn.png", width = 1000, height = 600)
y <- fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res
y_qemp <- EnvStats::qemp(stats::ppoints(y), y) # Empirical quantiles of the data set y.
y_demp <- EnvStats::demp(y_qemp, y)            # Empirical probability density of the data set y.
y_pemp <- EnvStats::pemp(y_qemp, y)            # Empirical distribution function of the data set y.  
x <- y_qemp
y_d <- y_demp
y_p <- y_pemp
mean <- 0
sd <- 1
GED_nu <- fGARCH_1_1_ged_initshp_shpN_lbfgsb_nm@fit[["par"]][["shape"]]
GED_leg <- bquote(paste("Generalized Error Distribution Density Function: mean=", .(mean),", standard deviation=", .(sd), ", shape=", .(GED_nu)))
GED_dens_tit <- "Density Histogram and Empirical Density Function of the Standardized Residuals of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED innovation"
#plot(x, y_d, xlim=c(x[1]-2.0, x[length(x)]+2.0), ylim=c(0, y_d[length(y_d)]+0.75), type= "n")
hist(y, breaks= "Scott", col= "cyan", border= "black", xlim=c(x[1]-1.0, x[length(x)]+1.0), ylim=c(0, y_d[length(y)]+0.75), 
     freq=FALSE, main="", xlab= "Standardized Residuals", ylab= "Histogram & Density Functions Values")
# lines(x, y_d, lwd=2, col= "darkblue")
lines(density(y), lwd=2, col= "darkblue")
lines(x, dnorm(x, m=0, sd=1), lwd=2, col= "red")
lines(x, fGarch::dged(x, mean=0, sd=1, nu=1, log=FALSE), lwd=2, col= "magenta")
title(main=list(GED_dens_tit, cex=1.0))
legend("topleft", legend=c("Empirical Density Function", "Standard Gaussian Distribution Density Function", GED_leg), 
       col=c("darkblue", "red","magenta"), 
       lty=1, lwd=0.1, cex=0.8, x.intersp=0.50, y.intersp=0.70, text.width=2, seg.len=1, text.font=4, box.lty=0,
       inset=-0.01, bty= "n")
dev.off()
#
# We also compare the empirical distribution function of the standardized residuals with the distribution functions of the GED and STD.
#dev.new()
png("plots/spx_stand_res_distr_fun_GED_STD.png", width = 1000, height = 600)
GED_distr_tit <- "Empirical Distribution Function of the Standardized Residuals of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED innovation"
EnvStats::ecdfPlot(y, discrete=TRUE, prob.method= "emp.probs", type= "s", plot.it=TRUE, 
                   add=FALSE, ecdf.col= "cyan", ecdf.lwd=2, ecdf.lty=1, curve.fill=TRUE, main="", 
                   xlab= "Standardized Residuals", ylab= "Probability Distribution", xlim=c(x[1]-1.0, x[length(x)]+1.0))
lines(x, y_p, lwd=2, col= "darkblue")
lines(x, pnorm(x, m=0, sd=1), lwd=2, col= "red")
lines(x, fGarch::pged(x, mean=0, sd=1, nu=1), lwd=2, col= "magenta")
title(main=list(GED_distr_tit, cex=1.0))
legend("topleft", legend=c("Empirical Density Function", "Standard Gaussian Distribution Density Function", GED_leg), 
       col=c("darkblue", "red","magenta"), 
       lty=1, lwd=0.1, cex=0.8, x.intersp=0.50, y.intersp=0.70, text.width=2, seg.len=1, text.font=4, box.lty=0,
       inset=-0.01, bty= "n")
#
dev.off()
dev.off()
#
# We build the Q-Q plot of the standardized residuals of the GARCH(1,1) model for the SP500 daily logarithm return percentage training 
# set against the corresponding quantiles of the estimated generalized GED.
# 
# First, we build a suitable data frame.
y <- fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res
head(y,20)
#  0.1304136 -0.2553669 -1.9402297  0.1377946 -1.0826987  1.0278266 -1.1741721  0.9310255  0.3655234  0.7560434
# -0.1773561 -0.6555149 -0.2338895  0.2995276  1.7221659  0.7185696  0.3300758  0.7397777  0.3718126  0.3114254
y_qemp <- qemp(ppoints(length(y)), y)
mean <- 0
sd <- 1
nu  <- GED_nu 
distr <- "ged"
distr_pars <- list(mean=0, sd=1, nu=nu)
quants <- qged(ppoints(length(y)), mean=0, sd=1, nu=nu)
QQ_plot_df <- data.frame(T=1:length(y), Q=quants, X=y, Y=y_qemp)
head(QQ_plot_df)
# Second we draw the Q-Q plot of the residuals.
Data_df <- QQ_plot_df
length <- nrow(Data_df)
quart_probs <- c(0.25,0.75)
quart_X <- as.vector(quantile(QQ_plot_df$X, quart_probs))
quart_Q <- qged(quart_probs, mean=0, sd=1, nu=nu)
slope <- diff(quart_X)/diff(quart_Q)
intercept <- quart_X[1]-slope*quart_Q[1]
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Q-Q plot of the Standardized Residuals of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation for the SP500 Daily Logarithm Return Percentage Training Set Against the Estimated GED")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ", .(length), " sample points; GED density function: mean ", .(mean), ", standard deviation ", .(sd), ", shape ", .(nu), "."~~"Data by courtesy of Yahoo Finance US - ",.(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("Theoretical Quantiles")
y_name <- bquote("Sample Quantiles")
x_breaks_min <- floor(Data_df$Q[1])
x_breaks_max <- ceiling(Data_df$Q[length])
x_breaks <- seq(from=x_breaks_min, to=x_breaks_max, by=0.5)
x_labs <- format(x_breaks, scientific=FALSE)
y_breaks_num <- length(x_breaks)
y_binwidth <- round((max(Data_df$Y)-min(Data_df$Y))/y_breaks_num, digits=3)
y_breaks_low <- floor((min(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((max(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks <- c(round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3))
y_labs <- format(y_breaks, scientific=FALSE)
y1_shape <- bquote("Q-Q plot")
y1_fill <- bquote("90% confidence intervals")
y2_fill <- bquote("95% confidence intervals")
y1_col <- bquote("interquartile line")
y2_col <- bquote("regression line")
y3_col <- bquote("y=x line")
leg_shape_labs <- y1_shape
leg_fill_labs <- c(y1_fill, y2_fill)
leg_col_labs <- c(y1_col, y2_col, y3_col)
leg_shape_cols <- c("y1_shape"=19)
leg_fill_cols <- c("y1_fill"="chartreuse1", "y2_fill"="deepskyblue1")
leg_col_cols <- c("y1_col"="cyan", "y2_col"="red", "y3_col"="black")
leg_shape_sort <- "y1_shape"
leg_fill_sort <- c("y1_fill", "y2_fill")
leg_col_sort <- c("y1_col", "y2_col", "y3_col")
Stand_Res_ged_QQ_plot <- ggplot(Data_df, aes(sample=X)) +
  qqplotr::stat_qq_band(aes(fill= "y2_fill"), distribution=distr, dparams=distr_pars, conf=0.95) +
  qqplotr::stat_qq_band(aes(fill= "y1_fill"), distribution=distr, dparams=distr_pars, conf=0.90) +
  geom_abline(aes(slope=slope, intercept=intercept, colour= "y1_col"), linewidth=0.8, linetype= "solid")+
  stat_smooth(aes(x=Q, y=Y, colour= "y2_col", group=1), inherit.aes=FALSE, method= "lm" , formula=y~x, alpha=1, linewidth=0.8, linetype= "solid",
              se=FALSE, fullrange=FALSE)+
  geom_abline(aes(slope=1, intercept=0, colour= "y3_col"), linewidth=0.8, linetype= "solid") +
  qqplotr::stat_qq_point(aes(shape= "y1_shape"), distribution=distr, dparams=distr_pars, colour= "black", alpha=1, size=1.0) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_shape_manual(name= "Legend", labels=leg_shape_labs, values=leg_shape_cols, breaks=leg_shape_sort) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_sort) +
  scale_colour_manual(name= "", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_sort) +
  guides(shape=guide_legend(order=1), fill=guide_legend(order=2), colour=guide_legend(order=3)) +
  theme(plot.title=element_text(hjust=0.5, size=8), 
        plot.subtitle=element_text(hjust=0.5, size=6),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_stand_res_ged_QQ_plot.png", plot = Stand_Res_ged_QQ_plot, width = 12, height = 5)
plot(Stand_Res_ged_QQ_plot)
#
# P-P plot of the empirical probability distribution of the standardized residuals of the GARCH(1,1) model for the SP500 daily percentage
# logarithm returns training set estimated by the fGarch::garcgFit() function against the estimated GED function.
# First, we build a suitable data frame.
y_qemp <- qemp(ppoints(length(y)), y)
y_pemp <- pemp(y_qemp, y)
mean <- 0
sd <- 1
nu  <- GED_nu 
distr <- "ged"
distr_pars <- list(mean=0, sd=1, nu=nu)
quants <- qged(ppoints(length(y)), mean=0, sd=1, nu=nu)
probs <- pged(quants, mean=0, sd=1, nu=nu)
PP_plot_df <- data.frame(T=1:length(y), P=probs, X=y, Y=y_pemp)
head(PP_plot_df)
# Second we draw the P-P plot of the standardized residuals.
Data_df <- PP_plot_df
length <- nrow(PP_plot_df)
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("P-P plot of the Empirical Probability of the Standardized Residuals of the fGarcg::garchFit() Fitted GARCH(1,1) Model with GED Innovation for the SP500 Daily Logarithm Returns Training Set Against the Estimated GED")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Data set size ", .(length), " sample points; GED density function: mean ", .(mean), ", standard deviation ", .(sd), ", shape ", .(nu), "."~~"Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("Theoretical Probabilities")
y_name <- bquote("Sample Probabilities")
x_breaks_min <- floor(Data_df$P[1])
x_breaks_max <- ceiling(Data_df$P[length])
x_breaks <- seq(from=x_breaks_min, to=x_breaks_max, by=0.5)
x_labs <- format(x_breaks, scientific=FALSE)
J <- 0
x_lims <- c(x_breaks_min-J*x_binwidth, x_breaks_max+J*x_binwidth)
y_breaks_num <- length(x_breaks)
y_binwidth <- round((max(Data_df$Y)-min(Data_df$Y))/y_breaks_num, digits=3)
y_breaks_low <- floor((min(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks_up <- floor((max(Data_df$Y)/y_binwidth))*y_binwidth
y_breaks <- c(round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3))
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.3
y_lims <- c(y_breaks_low-K*y_binwidth, y_breaks_up+K*y_binwidth)
y1_shape <- bquote("P-P plot")
y1_fill <- bquote("90% confidence intervals")
y2_fill <- bquote("95% confidence intervals")
y1_col <- bquote("y=x line")
y2_col <- bquote("regression line")
leg_shape_labs <- y1_shape
leg_fill_labs <- c(y1_fill, y2_fill)
leg_col_labs <- c(y1_col, y2_col)
leg_shape_cols <- c("y1_shape"=19)
leg_fill_cols <- c("y1_fill"="chartreuse1", "y2_fill"="deepskyblue1")
leg_col_cols <- c("y1_col"="black", "y2_col"="red")
leg_shape_sort <- "y1_shape"
leg_fill_sort <- c("y1_fill", "y2_fill")
leg_col_sort <- c("y1_col", "y2_col")
Stand_Res_ged_PP_plot <- ggplot(Data_df, aes(sample=X)) +
  qqplotr::stat_pp_band(aes(fill= "y2_fill"), distribution=distr, dparams=distr_pars, conf=0.95) +
  qqplotr::stat_pp_band(aes(fill= "y1_fill"), distribution=distr, dparams=distr_pars, conf=0.90) +
  qqplotr::stat_pp_line(aes(colour= "y1_col"), geom="path", position="identity", colour= "black") +
  stat_smooth(aes(x=P, y=Y, colour= "y2_col"), inherit.aes=FALSE, method= "lm", formula=y~x, alpha=1, linewidth=0.8, linetype= "solid", se=FALSE, fullrange=FALSE) +
  qqplotr::stat_pp_point(aes(shape= "y1_shape"), distribution=distr, dparams=distr_pars, colour= "black", alpha=1, size=1.0) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_shape_manual(name= "Legend", labels=leg_shape_labs, values=leg_shape_cols, breaks=leg_shape_sort) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_sort) +
  scale_colour_manual(name= "", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_sort) +
  guides(shape=guide_legend(order=1), fill=guide_legend(order=2), colour=guide_legend(order=3)) +
  theme(plot.title=element_text(hjust=0.5, size=11), 
        plot.subtitle=element_text(hjust=0.5, size=10),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_stand_res_ged_PP_plot.png", plot = Stand_Res_ged_PP_plot, width = 14, height = 6)
plot(Stand_Res_ged_PP_plot)
#
# In light of the presented plots, we consider the cross-checking of the estimated value of the GED shape parameter over the standardized 
# residuals. Of course, we use other functions than the fGarch::gedFit() function. We start with applying the fitdistrplus::fitdist() 
# function although fed by the fGarch::dged() function.
fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged <- fitdistrplus::fitdist(y, dged, start=list(nu=1), fix.arg=list(mean=0, sd=1), 
                                                                             method= "mle")
summary(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged)
# Fitting of the distribution ' ged ' by maximum likelihood 
# Parameters : estimate  Std. Error
#           nu 0.887797 0.03160786
# Fixed parameters: value
#           mean     0
#           sd       1
# Loglikelihood:  -2258.638   AIC:  4519.276   BIC:  4524.725  
#
# Note that we have
show(abs(GED_nu-fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged[["estimate"]][["nu"]]))
# 0.0008332549
# much smaller than the estimate standard error. We evaluate the uncertainty in estimated parameter
set.seed(12345)
fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged_bd <- fitdistrplus::bootdist(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged, niter=1000)
summary(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged_bd)
# Parametric bootstrap medians and 95% percentile CI 
#     Median      2.5%     97.5% 
#   1.714471  1.465657  2.014452
#
# For a further cross-checking, we also consider the estimates of the GED shape parameter by tackling the log-likelihood function direct
# maximization. To this we need to write the log-likelihood function to be maximized. Note that we again use the GED density provided by the
# fGarch package.
opt_ged_minus_logLik <- function(x) -sum(log(dged(y, mean=0, sd=1, nu=x)))
# Hence, we tackle the optimization of the log-likelihood function by means of the function stats::optimize().
opt_ged_result <- stats::optimize(f=opt_ged_minus_logLik, interval=c(0,2), maximum=FALSE, tol=1e-09)
show(opt_ged_result)
# $minimum 1.711029
# 
# $objective 976.3213
#
# Note that, setting
logLik <- -opt_ged_minus_logLik(GED_nu) 
n <- length(y)
k <- 1
AIC <- 2*k-2*logLik
BIC <- k*log(n)-2*logLik
AICc <- AIC + 2*k*((k+1)/(n-k-1))
# we obtain
show(c(logLik, AIC, BIC, AICc))
#   logLik      AIC       BIC      AICc
# -2258.638  4519.276  4524.725  4519.278
#
# We show again how to apply pracma::fminunc() and pracma::fmincon() functions conceived to optimize multivariate functions. As above, we
# rewrite the log-likelihood of the GED, fictitiously transformed into a multivariate function by adding a quadratic term.
fmin_minus_logLik <- function(x) x[1]^2-sum(log(dged(y, mean=0, sd=1, nu=x[2])))
#
# Second, we fix the initial points of the unconstrained maximization procedure, that we choose as the median provided by the 
# fitdistrplus::bootdist() function.
nu0 <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged_bd[["CI"]][["Median"]])
show(nu0)
# 1.714471
# Then, we launch the unconstrained maximization procedure.
fminunc_result <- pracma::fminunc(fn=fmin_minus_logLik, x0=c(0, nu0), tol=1e-08)
show(fminunc_result)
# Error in if (f < fmin) { : missing value where TRUE/FALSE needed
# In addition: Warning message: In log(dged(y, mean = 0, sd = 1, nu = x[2])) : NaNs produced
#
# The procedure returns an error, this is likely due to the choice of the starting point of the minimization procedure. Actually, with a 
# different choice we have
fminunc_result <- pracma::fminunc(fn=fmin_minus_logLik, x0=c(0, 0.8), tol=1e-08)
show(fminunc_result)
# $par x[1]    x[2]=nu
# [1] 0.0000000 1.711029
# 
# $value
# [1] 976.3213
# 
# $counts
# function gradient 
# 13        10 
# 
# $convergence
# [1] 2
# 
# $message
# [1] "Small gradient norm"
#
# which still returns some convergence problem. However, with another choice we have
fminunc_result <- pracma::fminunc(fn=fmin_minus_logLik, x0=c(0, 0.9), tol=1e-08)
show(fminunc_result)
# $par x[1]    x[2]=nu
# [1] 0.0000000 1.711029
# 
# $value
# [1] 976.3213
# 
# $counts
# function gradient 
# 19        9 
# 
# $convergence
# [1] 0
# 
# $message
# [1] "Rvmminu converged"
#
# The result of the minimization is the same, but we no longer have the convergence problem. 
# In the end, we consider the constrained optimization procedure where (0,nu0) is the starting point and we use the confidence interval 
# endpoints provided by the fitdistrplus::bootdist() function to build the multivariate constraint.
nu0 <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged_bd[["CI"]][["Median"]])
nu_min <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged_bd[["CI"]][["2.5%"]])
nu_max <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_ged_bd[["CI"]][["97.5%"]])
show(c(nu0,nu_min,nu_max))
# 1.714471 1.465657 2.014452
#
fmincon_result <- pracma::fmincon(fn=fmin_minus_logLik, x0=c(0, nu0), lb=c(-1, nu_min), ub=c(1, nu_max), tol=1e-06, maxfeval=10000, maxiter=5000) 
show(fmincon_result)
# Extract from the output.
# $par   x[1]    x[2]=nu
# [1] 0.0000000 1.711029
# 
# $value
# [1] 976.3213
# 
# $convergence
# [1] 0
# 
# $info$grad
# [,1]
# [1,] 0.0000000000
# [2,] 0.0002095701
# 
# $info$hessian
#      [,1]     [,2]
# [1,]    1    0.000
# [2,]    0  44.5794
#
# The constrained optimization procedure does not return convergence problems.
# To summarize having estimated a GARCH(1,1) model with GED innovation shape parameter GED_nu=1.711029 appears to be coherent with the 
# subsequent checks performed by the optimization procedures.
#
# It is also interesting to observe that removing the constraints fix.arg=list(mean=0, sd=1) the optimization procedure still essentially
# confirms the result of a standardized GED with shape parameter 1.711029. In fact,
fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged <- fitdistrplus::fitdist(y, dged, start=list(mean=0, sd=1,nu=1), method= "mle")
summary(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged)
# Fitting of the distribution ' ged ' by maximum likelihood 
# Parameters: estimate  Std. Error
#        mean 0.04376909 0.03746756
#        sd   0.99583404 0.02917499
#        nu   1.70632381 0.14698730
# Loglikelihood:  -975.6329   AIC:  1957.266   BIC:  1970.88 
# Correlation matrix:   mean          sd          nu
#              mean  1.000000000  0.003463399 -0.03139086
#              sd    0.003463399  1.000000000 -0.10822288
#              nu   -0.031390857 -0.108222882  1.00000000
set.seed(12345)
fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd <- fitdistrplus::bootdist(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged, niter=1000)
summary(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd)
# Parametric bootstrap medians and 95% percentile CI 
#        Median        2.5%      97.5%
# mean 0.04548979 -0.03550343 0.117806
# sd   0.99661063  0.94001261 1.048912
# nu   1.70970762  1.46927137 2.028371
# 
# Note that despite the bootstrapped 95% percentile CI for the mean does not contain the value zero, the bootstrapped 95% percentile CI for
# the standard deviation and shape contain the values one and 0.8877937, respectively.
# The unconstrained minimization of the log-likelihood of the unconstrained ged suffers for the choine of the initial point.
fmin_minus_unc_ged_logLik <- function(x) -sum(log(dged(y, mean=abs(x[1]), sd=abs(x[2]), nu=abs(x[3]))))
fminunc_result <- pracma::fminunc(fn=fmin_minus_unc_ged_logLik, x0=c(0.03, 1.00,0.881), tol=1e-08) #TODO: controllare problema, forse bisogna cambiare parametri
show(fminunc_result)
# $par
# [1] 0.04371879 0.99577092 1.70634910
# 
# $value
# [1] 975.6329
# 
# $counts
# function gradient 
# 36       17 
# 
# $convergence
# [1] 0
# 
# $message
# [1] "Rvmminu converged"
#
mean0 <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[1,1]])
mean_min <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[1,2]])
mean_max <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[1,3]])
show(c(mean0,mean_min,mean_max))
# 0.04548979 -0.03550343  0.11780596
#
sd0 <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[2,1]])
sd_min <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[2,2]])
sd_max <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[2,3]])
show(c(sd0,sd_min,sd_max))
# 0.9966106 0.9400126 1.0489119
#
nu0 <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[3,1]])
nu_min <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[3,2]])
nu_max <- as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res_fitdist_unc_ged_bd[["CI"]][[3,3]])
show(c(nu0,nu_min,nu_max))
# 1.709708 1.469271 2.028371
#
fmincon_result <- pracma::fmincon(fn=fmin_minus_unc_ged_logLik, x0=c(mean0, sd0, nu0), lb=c(mean_min, sd_min, nu_min), ub=c(mean_max, sd_max, nu_max),
                                  tol=1e-06, maxfeval=10000, maxiter=5000) 
show(fmincon_result)
# $par
# [1] 0.04371876 0.99577090 1.70634923
# 
# $value
# [1] 975.6329
# 
# $convergence
# [1] 0
# 
# $info
# $info$lambda
# $info$lambda$lower
# [,1]
# [1,]    0
# [2,]    0
# [3,]    0
# 
# $info$lambda$upper
# [,1]
# [1,]    0
# [2,]    0
# [3,]    0
# 
# $info$grad
# [,1]
# [1,] 0.0003308651
# [2,] 0.0010015377
# [3,] 0.0005454804
# 
# $info$hessian
#             [,1]       [,2]      [,3]
# [1,] 714.3740903    0.5291519  5.242532
# [2,]   0.5291519 1189.0013351 25.177553
# [3,]   5.2425317   25.1775525 46.892366
############################################################################################################################################
# In the end we consider the standard goodness of fit tests.
# The Kolmogorov-Smirnov test in the library *stats*
y <- fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res
head(y,20)
# 0.1304136 -0.2553669 -1.9402297  0.1377946 -1.0826987  1.0278266 -1.1741721  0.9310255  0.3655234  0.7560434
# -0.1773561 -0.6555149 -0.2338895  0.2995276  1.7221659  0.7185696  0.3300758  0.7397777  0.3718126  0.3114254
mean <- 0
sd <- 1
nu  <- GED_nu 
stats::ks.test(y, y="pged", mean=0, sd=1, nu=nu, alternative= "two.sided")
# Asymptotic one-sample Kolmogorov-Smirnov test
# data:  y
# D = 0.040807, p-value = 0.2
# alternative hypothesis: two-sided
#
# The Kolmgorov-Smirnov test cannot reject the null hypothesis that the standardized residuals of the GARCH(1,1) model have the estimated
# GED at the $10\%$ significance level.
# 
# Another application of the Kolmogorov-Smirnov test can be derived using the possibility of comparing two empirical distributions offered 
# by the function stats::ks.test().
mean <- 0
sd <- 1
nu  <- GED_nu 
KS_ged_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  y_rged <- rged(n=length(y), mean=0, sd=1, nu=nu)
  KS_ged <- stats::ks.test(x=y, y=y_rged, alternative="two.sided")
  KS_ged_mat_np[k,1] <- k
  KS_ged_mat_np[k,2] <- KS_ged[["p.value"]]}
summary(KS_ged_mat_np[,2])
#    Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 0.0007234 0.1556498 0.3380609 0.3881495 0.5768512 0.9968208 
quantile(KS_ged_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05,0.1))
#        1%         5%          10%
#   0.01092508 0.03995386 0.07127596 
#
# In the $5\%$ of cases on 10000 random vectors sampled by the GED, the null hypothesis that the GED fits the standardized residuals
# empirical distribution is rejected at the $5\%$ significance level, not at the $1\%$ significance level, though. In the $10\%$ of cases
# on 10000 random vectors sampled by the GED, the null hypothesis that the GED fits the standardized residuals empirical distribution is not
# rejected at the $5\%$ significance level,
#
# The Cramer-Von Mises test in the library *goftest*.
# This function performs the Cramer-Von Mises test of goodness-of-fit to the distribution specified by the argument null. It is assumed that
# the values in x are independent and identically distributed random values, with some cumulative distribution function F. The null 
# hypothesis that F is the function specified by the argument null, while the alternative hypothesis is that F is some other function.
#
mean <- 0
sd <- 1
nu  <- GED_nu 
goftest::cvm.test(y, null="pged", mean=0, sd=1, nu=nu, estimated=FALSE)
# Cramer-von Mises test of goodness-of-fit
# Null hypothesis: distribution ‘pged’
# with parameters mean = 0, sd = 1, nu = 0.887793724741315
# Parameters assumed to be fixed
# data:  y
# omega2 = 0.24542, p-value = 0.1943
#
# By default, the Cramer von Mises test assumes that all the parameters of the null distribution are known in advance (a simple null 
# hypothesis). This test does not account for the effect of estimating the parameters.
# If the parameters of the distribution were estimated (that is, if they were calculated from the same data x), then this should be 
# indicated by setting the argument estimated=TRUE. The test will then use the method of Braun (1980) to adjust for the effect of parameter
# estimation. Note that Braun's method involves randomly dividing the data into two equally-sized subsets, so the p-value is not exactly the
# same if the test is repeated. This technique is expected to work well when the number of observations in x is large. However, we approach 
# this version of the test with a technique similar to that we have used in the Kolmogorov-Smirnov test with random sampling. 
#
mean <- 0
sd <- 1
nu  <- GED_nu 
CVM_ged_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  CVM_ged <- goftest::cvm.test(x=y, null="pged", mean=0, sd=1, nu=nu, estimated=TRUE)
  CVM_ged_mat_np[k,1] <- k
  CVM_ged_mat_np[k,2] <- CVM_ged[["p.value"]]}
summary(CVM_ged_mat_np[,2])
#    Min.    1st Qu.    Median     Mean    3rd Qu.     Max. 
# 0.0000046 0.2182226 0.4565335 0.4672630 0.7093486 0.9995715  
quantile(CVM_ged_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05,0.1))
#    1%           5%          10% 
# 0.008745536 0.044173054 0.089035799  
#
# In the $5\%$ of cases on 10000 random vectors sampled by the GED, the null hypothesis that the GED fits the standardized residuals 
# empirical distribution is rejected at the $5\%$ significance level, not at the $1\%$ significance level, though. In the $10\%$ of cases 
# on 10000 random vectors sampled by the GED, the null hypothesis that the GED fits the standardized residuals empirical distribution cannot
# be rejected at the $5\%$ significance level.
#
# The Anderson-Darling test in the library *goftest*.
mean <- 0
sd <- 1
nu  <- GED_nu 
goftest::ad.test(y, null="pged", mean=0, sd=1, nu=nu, estimated=FALSE)
#
# Anderson-Darling test of goodness-of-fit
# Null hypothesis: distribution ‘pged’
# with parameters mean = 0, sd = 1, nu = 1.71103049588859
# Parameters assumed to be fixed
# data:  y
# An = 1.7741, p-value = 0.1227
#
# By default, also the Anderson Darling test assumes that all the parameters of the null distribution are known in advance (a simple null 
# hypothesis). This test does not account for the effect of estimating the parameters.
# If the parameters of the distribution were estimated (that is, if they were calculated from the same data x), then this should be 
# indicated by setting the argument estimated=TRUE. The test will then use the method of Braun (1980) to adjust for the effect of parameter
# estimation. Note that Braun's method involves randomly dividing the data into two equally-sized subsets, so the p-value is not exactly the
# same if the test is repeated. This technique is expected to work well when the number of observations in x is large. However, we approach 
# this version of the test with the same technique that we have used in the Cramer von Mises test. 
#
mean <- 0
sd <- 1
nu  <- GED_nu 
AD_ged_mat_np <- matrix(NA, nrow=10000, ncol=2)
for(k in 1:10000){
  set.seed(k)
  AD_ged <- goftest::ad.test(x=y, null="pged", mean=0, sd=1, nu=nu, estimated=TRUE)
  AD_ged_mat_np[k,1] <- k
  AD_ged_mat_np[k,2] <- AD_ged[["p.value"]]}
summary(AD_ged_mat_np[,2])
#    Min.    1st Qu.    Median     Mean    3rd Qu.     Max. 
# 0.0005776 0.2175137 0.4531081 0.4633915 0.6970248 0.9991770 
quantile(AD_ged_mat_np[,2], na.rm=TRUE, probs=c(0.01,0.05, 0.1))
#      1%          5%          10%
# 0.008530484 0.045451783 0.085582146 
#
# In the $1\%$ of cases on 10000 random vectors sampled by the GED, the null hypothesis that the GED fits the standardized residuals
# empirical distribution is rejected at the $5\%$ significance level, not at the $1\%$ significance level, though. In the $5\%$ of cases 
# on 10000 random vectors sampled by the GED, the null hypothesis that the GED fits the standardized residuals empirical distribution cannot
# be rejected at the $5\%$ significance level.
#
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
# The goal is now to produce a forecast of the time series.
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
# Let us recall the defining equations of the general GARCH(1,1) model. 
# We say that a stochastic process $\left(Z_{t}\right)_{t\in\mathbb{N}_{0}}\equiv Z$ on a probability space
# $\left(\Omega,\mathcal{E},\mathbf{P}\right)\equiv\Omega$ is a GARCH(1,1) process if there exist a standard second order white noise 
# $\left(W_{t}\right)_{t\in\mathbb{N}}\equiv W$ and a positive process $\left(\sigma_{t}\right)_{t\in\mathbb{N}_{0}}\sigma$ on $\Omega$ 
# such that the following equations are satisfied
# $Z_{t} = \sigma_{t}W_{t}$
# $\sigma_{t}^{2} = \alpha_{0} + alpha_{1}Z_{t-1}^{2} + beta_{1}\sigma_{t-1}^{2}$
# for all $t=1,2,\dots$, where $\alpha_{0},alpha_{1},beta_{1}\in \mathbb{R}_{++}$ and $alpha_{1}+beta_{1}<1$.
# The standard white noise process $W$ is called the innovation of the GARCH(1,1) process $Z$ and the positive process $\sigma$ is called
# the volatility of $Z$.
#
# In the model under consideration, $\alpha_{0}$, $alpha_{1}$, and $beta_{1}$ are the parameters omega, alpha1, and beta1, respectively.
omega <- as.numeric(fGarch::coef(fGARCH_1_1_ged_shpN_lbfgsb_nm)[1])
alpha1 <- as.numeric(fGarch::coef(fGARCH_1_1_ged_shpN_lbfgsb_nm)[2])
beta1 <- as.numeric(fGarch::coef(fGARCH_1_1_ged_shpN_lbfgsb_nm)[3])
shape <- as.numeric(fGarch::coef(fGARCH_1_1_ged_shpN_lbfgsb_nm)[4])
show(c(omega, alpha1, beta1, shape))
# 0.34079449 0.08046777 0.89917369 0.88780427
# To compare with the model's summary coefficients.  
# Coefficient(s):
#   omega    alpha1     beta1     shape  
# 0.340794  0.080468  0.899174  0.887804
#
# Let $\left(\mathcal{F}_{t}^{\left(Z_{0},\sigma_{0},W\right)}\right)_{t\in\mathbb{N}_{0}}\equiv\mathfrak{F}_{Z_{0},\sigma_{0},W}$ be the
# filtration (information) generated by the initial state $Z_{0}$ of the process $Z$ and the strong white noise $W$, formally given by
# $\mathcal{F}_{0}^{\left(Z_{0},W\right)}\overset{\text{def}}{=}\sigma\left(Z_{0},\sigma_{0}\right)$
# and
# $\mathcal{F}_{t}^{\left(Z_{0},\sigma_{0},W\right)}\overset{\text{def}}{=}\sigma\left(Z_{0},\sigma_{0},W_{1},\dots,W_{t}\right)
# \quad\forall t\in\mathbb{N}$,
# in the filtration context, $\sigma\left(X,Y,Z,\dots\right)$ denoting the $\sigma$-algebra generated by the random variables $Z,Y,Z,\dots$.
# We know that we have
# $\mathbf{E}\left[Z_{t}\mid\mathcal{F}_{s}\right]=0$
# for every $t\in\mathbb{N}$ and every $s=0,1,\dots,t-1$.
# In terms of a concrete GARCH(1,1) model this implies that the fitted values are all zero.
# Eventually, in the model under consideration we have
fGARCH_1_1_ged_shpN_lbfgsb_nm_fitted <- as.numeric(fGarch::fitted(fGARCH_1_1_ged_shpN_lbfgsb_nm))
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_fitted,20)
# 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
# While in a concrete GARCH(1,1) model we can observe a realization of the process $Z$, which is the path of the values of the process $Z$
# formally given by the sequence of real numbers $\left(Z_{t}\left(\omega\right)\right)_{t\in\mathbb{N}_{0}}$, for the occurred outcome 
# $\omega\in\Omega$, we cannot observe the corresponding realization of the $Z$ volatility$\sigma$, which is the path of the values of the
# process $\sigma$ formally given by $\left(\sigma_{t}\left(\omega\right)\right)_{t\in\mathbb{N}_{0}}$. This because we have no way to 
# observe the value $\sigma_{0}\left(\omega\right)$. As we discussed above, the value $\sigma_{0}\left(\omega\right)$ is typically chosen
# in different ways. In particular, in the fGARCH_1_1_ged_shpN_lbfgsb_nm model is set to
# $\sigma_{0}\left(\omega\right)\equiv\alpha_{0}+\left(\alpha_{1}+\beta_{1}\right)\frac{1}{T}\sum_{t=0}^{T-1}{Z_{t}^{2}\left(\omega\right)$.
# Concretely,
head(spx_df)
tail(spx_df)
nrow(spx_df)
# 1871
DS_length <- nrow(spx_df)
show(DS_length)
# 1871
TrnS_length <- length(spx_df$log.ret.perc.[which(spx_df$Date<=as.Date(TrnS_Last_Day))])
show(TrnS_length)
# 1720
TstS_length <- DS_length-TrnS_length
show(TstS_length)
# 151
y <- spx_df$log.ret.perc.
head(y)
# NA  3.2535928  1.5906496  6.4376485  0.5608363 -1.0523309
T <- length(y[2:TrnS_length])
show(T)
# 691
fGARCH_1_1_ged_shpN_lbfgsb_nm_sigma0 <- sqrt(omega + (alpha1+beta1)*(1/T)*sum(y[2:TrnS_length]^2))
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_sigma0)
# 3.75126
#
# This corresponds to
fGarch::volatility(fGARCH_1_1_ged_shpN_lbfgsb_nm, type="sigma")[1]
# 3.75126
#
# Once $\sigma_{0}\left(\omega\right)$ is chosen, the full path $\left(\sigma_{t}\left(\omega\right)\right)_{t\in\mathbb{N}_{0}}$ can be
# built. This in the context of the concrete GARCH(1,1) process is called the conditional volatility and it is computed as follows
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var_cmp <- vector(mode="numeric", length=T)
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var_cmp[1] <- fGARCH_1_1_ged_shpN_lbfgsb_nm_sigma0^2
for(t in 2:T){
  fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var_cmp[t] <- omega + alpha1*na.rm(y)[t-1]^2 + beta1*fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var_cmp[t-1]
}
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_std_dev_cmp <- sqrt(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var_cmp)
# 
# We obtain
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var_cmp,20)
# 14.07195 13.84574 12.99412 15.35962 14.17707 13.17755 12.35851 16.91060 22.34711 22.29552 21.22472 20.67650 18.97811 17.70007 16.39730
# 15.21540 16.32847 15.03874 14.07167 13.34326
#
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_std_dev_cmp,20)
# 3.751260 3.720987 3.604736 3.919135 3.765245 3.630090 3.515467 4.112250 4.727272 4.721813 4.607029 4.547142 4.356387 4.207146 4.049358
# 3.900692 4.040850 3.877981 3.751222 3.652842
#
# The conditional standard deviation and variance can also be obtained by applying to the fGARCH_1_1_ged_shpN_lbfgsb_nm model the extractor
# functions fGarch::volatility(..., type="h") and fGarch::volatility(..., type="sigma"), respectively.
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var <- fGarch::volatility(fGARCH_1_1_ged_shpN_lbfgsb_nm, type="h")
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var,20)
# 14.07195 13.84574 12.99412 15.35962 14.17707 13.17755 12.35851 16.91060 22.34711 22.29552 21.22472 20.67650 18.97811 17.70007 16.39730
# 15.21540 16.32847 15.03874 14.07167 13.34326
#
identical(round(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var_cmp,11),round(as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var),11))
# TRUE
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_std_dev <- fGarch::volatility(fGARCH_1_1_ged_shpN_lbfgsb_nm, type="sigma")
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_std_dev,20)
# 3.751260 3.720987 3.604736 3.919135 3.765245 3.630090 3.515467 4.112250 4.727272 4.721813 4.607029 4.547142 4.356387 4.207146 4.049358
# 3.900692 4.040850 3.877981 3.751222 3.652842
#
identical(round(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_std_dev_cmp,11),round(as.vector(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_std_dev),11))
# TRUE
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res <- fGarch::residuals(fGARCH_1_1_ged_shpN_lbfgsb_nm, standardize=TRUE)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_stand_res,20)
#  0.8673333  0.4274806  1.7858863  0.1431021 -0.2794854  0.3989901  2.3425966 -2.2355670  1.0172507 -0.6827799  0.8558484  0.1654581
# -0.4392640 -0.3147066  0.3145931  1.3725041 -0.1097089  0.4150189 -0.5556425 -0.8109007
#
# We plot the SP500 daily logarithm return percentage and the conditional standard deviation of the fGarch::garchFit() fitted GARCH(1,1)
# model with GED innovation training set.
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev)
head(Data_df)
tail(Data_df)
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Logarithm Return Percentage  and Conditional Standard Deviation of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[2]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily logarithm return percentage")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily perc. log. ret.")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
line_magenta <- bquote("cond. stand. dev. - GED inn.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_magenta, line_green, line_red)
leg_line_cols <- c("line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_magenta", "line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA, NA), linetype=c("blank", "solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=8),
        plot.subtitle=element_text(hjust= 0.5, size=7),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_sp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_sp, width = 14, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_sp)
#
# The line plot.
line_black <- bquote("daily perc. log. ret.")
line_magenta <- bquote("cond. stand. dev. - GED inn.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_black, line_magenta, line_green, line_red)
leg_line_cols <- c("line_black"="black", "line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_black", "line_magenta", "line_green", "line_red")
spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="line_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=8),
        plot.subtitle=element_text(hjust= 0.5, size=7),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_lp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_lp, width = 14, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_lp)
#
# We can add the confidence bands to the plot by observing that, having estimated the conditional standard deviation $\sigma_{t}$ and the
# distribution of the innovation $W_{t}$, thanks to the stochastic equation
# $Z_{t} = \sigma_{t}W_{t}$,
# the desired confidence bands are given by the product of the estimated standard deviation times the corresponding quantiles of the 
# innovation estimated distribution.
#
quants_080 <- fGarch::qged(p=c(0.1,0.9), mean=0, sd=1, nu=shape)
show(quants_080)
# -1.097594  1.097594
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_080_low_conf_band <- fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev*quants_080[1]
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_080_low_conf_band)
# -4.117364 -4.084138 -3.956542 -4.301632 -4.132723 -3.984377
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_080_upp_conf_band <- fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev*quants_080[2]
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_080_upp_conf_band)
# 4.117364 4.084138 3.956542 4.301632 4.132723 3.984377
#
quants_085 <- fGarch::qged(p=c(0.075,0.925), mean=0, sd=1, nu=shape)
show(quants_085)
# -1.307547  1.307547
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_085_low_conf_band <- fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev*quants_085[1]
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_085_low_conf_band)
# -4.904954 -4.865373 -4.713369 -5.124470 -4.923251 -4.746528
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_085_upp_conf_band <- fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev*quants_085[2]
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_085_upp_conf_band)
# 4.904954 4.865373 4.713369 5.124470 4.923251 4.746528
#
quants_090 <- fGarch::qged(p=c(0.050,0.950), mean=0, sd=1, nu=shape)
show(quants_090)
# -1.608124  1.608124
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_090_low_conf_band <- fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev*quants_090[1]
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_090_low_conf_band)
# -6.032497 -5.983817 -5.796871 -6.302475 -6.055000 -5.837652
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_090_upp_conf_band <- fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev*quants_090[2]
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_090_upp_conf_band)
# 6.032497 5.983817 5.796871 6.302475 6.055000 5.837652
#
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev)
head(Data_df)
tail(Data_df)
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Logarithm Return Percentage, Conditional Standard Deviation, and Confidence Bands of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[2]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily logarithm return percentage")
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.5
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily perc. log. ret.")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
line_magenta <- bquote("cond. stand. dev. - GED inn.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_magenta, line_green, line_red)
leg_line_cols <- c("line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_magenta", "line_green", "line_red")
fill_col_gray100 <- bquote("80% conf. band")
fill_col_gray55 <- bquote("85% conf. band")
fill_col_gray10 <- bquote("90% conf. band")
leg_fill_labs <- c(fill_col_gray100,fill_col_gray55,fill_col_gray10)
leg_fill_cols <- c("fill_col_gray100"="gray100","fill_col_gray55"="gray55","fill_col_gray10"="gray10")
leg_fill_breaks <- c("fill_col_gray100","fill_col_gray55","fill_col_gray10")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_ribbon(aes(ymin=z*quants_080[1], ymax=z*quants_080[2], fill="fill_col_gray100"), alpha=0.3, colour= "gray100") +
  geom_ribbon(aes(ymin=z*quants_085[1], ymax=z*quants_080[1], fill="fill_col_gray55"), alpha=0.3, colour= "gray55") +
  geom_ribbon(aes(ymin=z*quants_090[1], ymax=z*quants_085[1], fill="fill_col_gray10"), alpha=0.3, colour= "gray10") +
  geom_ribbon(aes(ymin=z*quants_080[2], ymax=z*quants_085[2], fill="fill_col_gray55"), alpha=0.3, colour= "gray55") +
  geom_ribbon(aes(ymin=z*quants_085[2], ymax=z*quants_090[2], fill="fill_col_gray10"), alpha=0.3, colour= "gray10") +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA, NA), linetype=c("blank", "solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=10),
        plot.subtitle=element_text(hjust= 0.5, size=8),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_sp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_sp, width = 12, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_sp)
#
# The line plot.
line_black <- bquote("daily perc. log. ret.")
line_magenta <- bquote("cond. stand. dev. - GED inn.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_black, line_magenta, line_green, line_red)
leg_line_cols <- c("line_black"="black", "line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_black", "line_magenta", "line_green", "line_red")
fill_col_gray100 <- bquote("80% conf. band")
fill_col_gray55 <- bquote("85% conf. band")
fill_col_gray10 <- bquote("90% conf. band")
leg_fill_labs <- c(fill_col_gray100,fill_col_gray55,fill_col_gray10)
leg_fill_cols <- c("fill_col_gray100"="gray100","fill_col_gray55"="gray55","fill_col_gray10"="gray10")
leg_fill_breaks <- c("fill_col_gray100","fill_col_gray55","fill_col_gray10")
spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_ribbon(aes(ymin=z*quants_080[1], ymax=z*quants_080[2], fill="fill_col_gray100"), alpha=0.3, colour= "gray100") +
  geom_ribbon(aes(ymin=z*quants_085[1], ymax=z*quants_080[1], fill="fill_col_gray55"), alpha=0.3, colour= "gray55") +
  geom_ribbon(aes(ymin=z*quants_090[1], ymax=z*quants_085[1], fill="fill_col_gray10"), alpha=0.3, colour= "gray10") +
  geom_ribbon(aes(ymin=z*quants_080[2], ymax=z*quants_085[2], fill="fill_col_gray55"), alpha=0.3, colour= "gray55") +
  geom_ribbon(aes(ymin=z*quants_085[2], ymax=z*quants_090[2], fill="fill_col_gray10"), alpha=0.3, colour= "gray10") +
  geom_smooth(aes(y=y, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y, color="line_black"), alpha=1, lwd=0.5, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=-z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_lp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_lp, width = 12, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_stand_dev_ged_inn_TrnS_lp)
#
# We also draw the plot of the SP500 daily squared logarithm return percentage and the conditional variance of the fGarch::garchFit() 
# fitted GARCH(1,1) model with GED innovation training set.
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var)
head(Data_df)
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Squared Logarithm Return Percentage and Conditional Variance of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - Training Set - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[2]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily squared logarithm return percentage")
y_max <- max(na.rm(Data_df$y^2))
y_min <- min(na.rm(Data_df$y^2))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily squared perc. log. ret.")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
line_magenta <- bquote("GARCH(1,1) cond. var. - GED inn.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_magenta, line_green, line_red)
leg_line_cols <- c("line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_magenta", "line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y^2, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y^2, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y^2, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA, NA), linetype=c("blank", "solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=8),
        plot.subtitle=element_text(hjust= 0.5, size=7),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_sp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_sp, width = 14, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_sp)
#
# The line plot.
line_black <- bquote("daily squared perc. log. ret.")
line_magenta <- bquote("cond. var. - GED inn.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_black, line_magenta, line_green, line_red)
leg_line_cols <- c("line_black"="black", "line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_black", "line_magenta", "line_green", "line_red")
spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y^2, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y^2, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y^2, color="line_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=8),
        plot.subtitle=element_text(hjust= 0.5, size=7),
        plot.caption=element_text(hjust=1.0, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_lp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_lp, width = 14, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_lp)
#
# Plot of the SP500 daily squared logarithm return percentage and the conditional variance of the fGarch::garchFit() fitted GARCH(1,1)
# model with GED innovation training set (with the extreme outlier at date 2020-03-11.
head(spx_train_df)
tail(spx_train_df)
Data_df <- spx_train_df
head(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var)
head(Data_df)
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
Rem_Day <- as.character(Data_df$Date[which.max(Data_df$y^2)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Squared Logarithm Return Percentage and Conditional Variance of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - Training Set - from ", .(First_Day), " to ", .(Last_Day),  ", day ", .(Rem_Day), " removed", sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points. Data by courtesy of Yahoo Finance US - ", .(link)))
caption_content <- "Author: Michele Tosi"
x_name <- bquote("")
# numbers::primeFactors(TrnS_length-2)
x_breaks_num <- last(numbers::primeFactors(TrnS_length-2)) # (deduced from primeFactors(TrnS_length-2))
x_breaks_low <- Data_df$x[2]
x_breaks_up <- Data_df$x[nrow(Data_df)]
x_binwidth <- ceiling((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("daily squared logarithm return percentage")
y_max <- max(na.rm(Data_df$y[-which.max(Data_df$y^2)]^2))
y_min <- min(na.rm(Data_df$y[-which.max(Data_df$y^2)]^2))
as.numeric(floor(y_max-y_min))
y_breaks_num <- 10
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor((y_min/y_binwidth))*y_binwidth
y_breaks_up <- ceiling((y_max/y_binwidth))*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth), digits=3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
point_black <- bquote("daily squared perc. log. ret.")
leg_point_labs <- c(point_black)
leg_point_cols <- c("point_black"="black")
leg_point_breaks <- c("point_black")
line_magenta <- bquote("GARCH(1,1) cond. var. - GED inn.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_magenta, line_green, line_red)
leg_line_cols <- c("line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_magenta", "line_green", "line_red")
leg_col_labs   <- c(leg_point_labs,leg_line_labs)
leg_col_cols   <- c(leg_point_cols,leg_line_cols)
leg_col_breaks <- c(leg_point_breaks,leg_line_breaks)
spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_sp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y^2, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y^2, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_point(aes(y=y^2, color="point_black"), alpha=1, size=0.7, shape=19, na.rm=TRUE) + 
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype="none", shape="none") +
  scale_colour_manual(name="Legend", labels=leg_col_labs, values=leg_col_cols, breaks=leg_col_breaks) +
  guides(colour=guide_legend(override.aes=list(shape=c(19, NA, NA, NA), linetype=c("blank", "solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=10),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_sp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_sp, width = 12, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_sp)
#
# The line plot.
line_black <- bquote("daily squared perc. log. ret.")
line_magenta <- bquote("GARCH(1,1) cond. var. - GED inn.")
line_green <- bquote("regression line")
line_red <- bquote("LOESS curve")
leg_line_labs <- c(line_black, line_magenta, line_green, line_red)
leg_line_cols <- c("line_black"="black", "line_magenta"="magenta", "line_green"="green", "line_red"="red")
leg_line_breaks <- c("line_black", "line_magenta", "line_green", "line_red")
spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_lp <- ggplot(Data_df, aes(x=x)) +
  geom_smooth(aes(y=y^2, color="line_green"), alpha=1, lwd=0.9, linetype="solid", method="lm" , formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_smooth(aes(y=y^2, color="line_red"), alpha=1, lwd=0.9, linetype="dashed", method="loess", formula=y ~ x, na.rm=TRUE, se=FALSE) +
  geom_line(aes(y=y^2, color="line_black"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  geom_line(aes(y=z, color="line_magenta"), alpha=1, lwd=0.7, linetype="solid", na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  theme(plot.title=element_text(hjust=0.5, size=12),
        plot.subtitle=element_text(hjust= 0.5, size=9),
        plot.caption=element_text(hjust=1.0, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_lp.png", plot = spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_lp, width = 12, height = 6)
plot(spx_perc_log_ret_fGARCH_1_1_cond_var_ged_inn_TrnS_lp)
#
############################################################################################################################################
# We now have all the elements to build the predictions of the GARCH(1,1) model.
# As an immediate consequence of the defining equations of the process, the predicted path of the process $Z$ is just a sequence of zeroes.
#
y_pred <- rep(0,TstS_length)
head(y_pred, 20)
# 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# 
# To predict the volatility, we should consider that we predict conditioning to the information till the end of the training set.
# That is we need to compute $\mathbf{E}\left[\sigma_{T+t}\mid\mathcal{F}_{T}\right]=0$, for every $t\in\mathbb{N}$, where $T$ is the 
# train set length and $t$ actually varies till the the test set length. This calls for a modification of the recursive formula as follows.

# We introduce an empty vector to store the steps of the recursive formula
fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_var <- vector("numeric", length=TstS_length)
# We compute the first term of the predicted variance, considering that the last observed percentage logarithm return is stored at the 
# (TrnS_length+1)th row of the spx_df data frame.
# 
fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_var[1] <-  omega + alpha1*spx_df$log.ret.perc.[TrnS_length+1]^2 + beta1*fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var[TrnS_length]
# We launch the recursive procedure to determine all terms of the predicted variance 
for(t in 2:TstS_length){
  fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_var[t] <- omega + (alpha1+beta1)*fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_var[t-1]
}
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_var,20)
# 4.728216 4.972751 5.212307 5.446987 5.676889 5.902110 6.122746 6.338890 6.550634 6.758067 6.961277 7.160350 7.355371 7.546421 7.733581
# 7.916931 8.096548 8.272509 8.444887 8.613756
#
tail(fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_var,20)
# 15.92794 15.94446 15.96065 15.97651 15.99205 16.00727 16.02218 16.03678 16.05109 16.06511 16.07884 16.09229 16.10547 16.11838 16.13103
# 16.14342 16.15556 16.16745 16.17910 16.19051
#
# We compute the predicted volatility (standard deviation) as the square root of the variance
fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_std_dev <- sqrt(fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_var)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_std_dev,20)
# 2.174446 2.229967 2.283048 2.333878 2.382622 2.429426 2.474418 2.517715 2.559421 2.599628 2.638423 2.675883 2.712079 2.747075 2.780932
# 2.813704 2.845443 2.876197 2.906009 2.934920
#
tail(fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_std_dev,20)
# 3.990982 3.993052 3.995078 3.997063 3.999006 4.000908 4.002771 4.004595 4.006381 4.008130 4.009843 4.011520 4.013162 4.014771 4.016345
# 4.017888 4.019398 4.020877 4.022325 4.023743
#
# Note that computing the long-run variance and standard deviation, we obtain
long_run_var <- omega/(1-(alpha1+beta1))
show(long_run_var)
# 16.73963
#
long_run_std_dev <- sqrt(long_run_var)
show(long_run_std_dev)
# 4.091409
#
# Hence, it is possible to grasp the asymptotic tendency of the predicted variance and standard deviation to the long-run variance and standard
# deviation, respectively. We can also obtain the predicted standard deviation as part of the fGarch::predict() function output. In fact, 
# considering prediction bands of the $80\%$, we have
fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred <- fGarch::predict(fGARCH_1_1_ged_shpN_lbfgsb_nm, n.ahead=TstS_length, nx=TrnS_length, 
                                                                 mse="uncond", conf=0.80, trace=FALSE, plot=TRUE)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred, 15)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 1             0  3.743863          2.174446     -4.109242      4.109242
# 2             0  3.743863          2.229967     -4.109242      4.109242
# 3             0  3.743863          2.283048     -4.109242      4.109242
# 4             0  3.743863          2.333878     -4.109242      4.109242
# 5             0  3.743863          2.382622     -4.109242      4.109242
# 6             0  3.743863          2.429426     -4.109242      4.109242
# 7             0  3.743863          2.474418     -4.109242      4.109242
# 8             0  3.743863          2.517715     -4.109242      4.109242
# 9             0  3.743863          2.559421     -4.109242      4.109242
# 10            0  3.743863          2.599628     -4.109242      4.109242
# 11            0  3.743863          2.638423     -4.109242      4.109242
# 12            0  3.743863          2.675883     -4.109242      4.109242
# 13            0  3.743863          2.712079     -4.109242      4.109242
# 14            0  3.743863          2.747075     -4.109242      4.109242
# 15            0  3.743863          2.780932     -4.109242      4.109242
#
tail(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred, 15)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 137            0  3.743863          4.000908     -4.109242      4.109242
# 138            0  3.743863          4.002771     -4.109242      4.109242
# 139            0  3.743863          4.004595     -4.109242      4.109242
# 140            0  3.743863          4.006381     -4.109242      4.109242
# 141            0  3.743863          4.008130     -4.109242      4.109242
# 142            0  3.743863          4.009843     -4.109242      4.109242
# 143            0  3.743863          4.011520     -4.109242      4.109242
# 144            0  3.743863          4.013162     -4.109242      4.109242
# 145            0  3.743863          4.014771     -4.109242      4.109242
# 146            0  3.743863          4.016345     -4.109242      4.109242
# 147            0  3.743863          4.017888     -4.109242      4.109242
# 148            0  3.743863          4.019398     -4.109242      4.109242
# 149            0  3.743863          4.020877     -4.109242      4.109242
# 150            0  3.743863          4.022325     -4.109242      4.109242
# 151            0  3.743863          4.023743     -4.109242      4.109242
#
# Note that the zeros in the "meanForecast" column which represent the predicted percentage log returns. Note also that
identical(round(fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_std_dev,11), round(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred[["standardDeviation"]],11))
# TRUE
#
# Other items in the fGarch::predict() function output are the unconditional "meanError", the "lowerInterval", and the "upperInterval". We
# check them closer.
# The unconditional meanError is given by the square root of the biased mean of the squared errors in fitting the observed values of the 
# logarithm return percentage. Formally
# $\mathbf{MSE}\overset{\text{def}}{=}
# \sqrt\left(frac{1}{T}\sum_{t=1}^{T}\left(Z_{t}\left(omega\right)-\mathbf{E}\left[Z_{t}\mid\mathcal{F}_{t-1}\right]\left(omega\right)\right)^{2}\right)
# where $T$ is the train set length. On the other hand since in a GARCH(1,1) model the fitted values are all zero, the meanError is simply 
# given by the square root of the biased mean of the squared percentage returns. In fact, setting
meanError_cmp <- sqrt((1/(TrnS_length))*sum(na.rm(spx_df$log.ret.perc.[1:(TrnS_length+1)])^2))
show(meanError_cmp)
# 3.743863
#
# We have
round(meanError_cmp,14)==round(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred[["meanError"]][1],14)
# TRUE
#
# Under the options mse="uncond", the prediction bands "lowerInterval" and "upperInterval" are built as products of the meanError with the
# quantiles of the estimated distribution of the innovation specified by the option conf=0.80. In our case, the estimated distribution of 
# the innovation is a GED with shape parameter given by shape=0.887804. That is
quants_080 <- fGarch::qged(p=c(0.1,0.9), mean=0, sd=1, nu=shape)
show(quants_080)
# -1.097594  1.097594
#
lowerInterval_cmp <- rep(quants_080[1]*meanError_cmp,TstS_length)
head(lowerInterval_cmp)
#  -4.109242 -4.109242 -4.109242 -4.109242 -4.109242 -4.109242
#
upperInterval_cmp <- rep(quants_080[2]*meanError_cmp,TstS_length)
head(upperInterval_cmp)
# 4.109242 4.109242 4.109242 4.109242 4.109242 4.109242
#
identical(round(lowerInterval_cmp,13),round(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred[["lowerInterval"]],13))
# TRUE
#
identical(round(upperInterval_cmp,13),round(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred[["upperInterval"]],13))
# TRUE
#
# In the end, under the option rms="cond", the meanError just coincides with the predicted conditional standard deviation
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_080_pred <- fGarch::predict(fGARCH_1_1_ged_shpN_lbfgsb_nm, n.ahead=TstS_length, nx=TrnS_length, 
                                                               mse="cond", conf=0.80, trace=FALSE, plot=TRUE)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_080_pred, 15)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 1             0  2.174446          2.174446     -2.386659      2.386659
# 2             0  2.229967          2.229967     -2.447598      2.447598
# 3             0  2.283048          2.283048     -2.505860      2.505860
# 4             0  2.333878          2.333878     -2.561651      2.561651
# 5             0  2.382622          2.382622     -2.615152      2.615152
# 6             0  2.429426          2.429426     -2.666523      2.666523
# 7             0  2.474418          2.474418     -2.715907      2.715907
# 8             0  2.517715          2.517715     -2.763429      2.763429
# 9             0  2.559421          2.559421     -2.809205      2.809205
# 10            0  2.599628          2.599628     -2.853337      2.853337
# 11            0  2.638423          2.638423     -2.895918      2.895918
# 12            0  2.675883          2.675883     -2.937033      2.937033
# 13            0  2.712079          2.712079     -2.976761      2.976761
# 14            0  2.747075          2.747075     -3.015173      3.015173
# 15            0  2.780932          2.780932     -3.052334      3.052334
#
tail(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_080_pred, 15)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 137            0  4.000908          4.000908     -4.391373      4.391373
# 138            0  4.002771          4.002771     -4.393418      4.393418
# 139            0  4.004595          4.004595     -4.395420      4.395420
# 140            0  4.006381          4.006381     -4.397380      4.397380
# 141            0  4.008130          4.008130     -4.399300      4.399300
# 142            0  4.009843          4.009843     -4.401180      4.401180
# 143            0  4.011520          4.011520     -4.403021      4.403021
# 144            0  4.013162          4.013162     -4.404823      4.404823
# 145            0  4.014771          4.014771     -4.406588      4.406588
# 146            0  4.016345          4.016345     -4.408317      4.408317
# 147            0  4.017888          4.017888     -4.410010      4.410010
# 148            0  4.019398          4.019398     -4.411667      4.411667
# 149            0  4.020877          4.020877     -4.413290      4.413290
# 150            0  4.022325          4.022325     -4.414880      4.414880
# 151            0  4.023743          4.023743     -4.416437      4.416437
#
# Consequently we have
#
lowerInterval_cmp <- quants_080[1]*fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_std_dev
head(lowerInterval_cmp,20)
# -2.386659 -2.447598 -2.505860 -2.561651 -2.615152 -2.666523 -2.715907 -2.763429 -2.809205 -2.853337 -2.895918 -2.937033 -2.976761 
# -3.015173 -3.052334 -3.088305 -3.123142 -3.156897 -3.189618 -3.221351
#
identical(round(lowerInterval_cmp,12),round(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_080_pred[["lowerInterval"]],12))
# TRUE
#
upperInterval_cmp <- quants_080[2]*fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_std_dev
head(upperInterval_cmp,20)
# 2.386659 2.447598 2.505860 2.561651 2.615152 2.666523 2.715907 2.763429 2.809205 2.853337 2.895918 2.937033 2.976761 3.015173 
# 3.052334 3.088305 3.123142 3.156897 3.189618 3.221351
#
identical(round(upperInterval_cmp,12),round(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_080_pred[["upperInterval"]],12))
# TRUE
#
# Similarly we can build the $85\%$ and $90\%$ prediction bands
fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_085_pred <- fGarch::predict(fGARCH_1_1_ged_shpN_lbfgsb_nm, n.ahead=TstS_length, nx=TrnS_length, 
                                                                 mse="uncond", conf=0.85, trace=FALSE, plot=TRUE)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_085_pred)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 1            0  3.743863          2.174446     -4.895279      4.895279
# 2            0  3.743863          2.229967     -4.895279      4.895279
# 3            0  3.743863          2.283048     -4.895279      4.895279
# 4            0  3.743863          2.333878     -4.895279      4.895279
# 5            0  3.743863          2.382622     -4.895279      4.895279
# 6            0  3.743863          2.429426     -4.895279      4.895279
#
tail(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_085_pred)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 146            0  3.743863          4.016345     -4.895279      4.895279
# 147            0  3.743863          4.017888     -4.895279      4.895279
# 148            0  3.743863          4.019398     -4.895279      4.895279
# 149            0  3.743863          4.020877     -4.895279      4.895279
# 150            0  3.743863          4.022325     -4.895279      4.895279
# 151            0  3.743863          4.023743     -4.895279      4.895279
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_085_pred <- fGarch::predict(fGARCH_1_1_ged_shpN_lbfgsb_nm, n.ahead=TstS_length, nx=TrnS_length, 
                                                               mse="cond", conf=0.85, trace=FALSE, plot=TRUE)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_085_pred)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 1            0  2.174446          2.174446     -2.843191      2.843191
# 2            0  2.229967          2.229967     -2.915787      2.915787
# 3            0  2.283048          2.283048     -2.985193      2.985193
# 4            0  2.333878          2.333878     -3.051656      3.051656
# 5            0  2.382622          2.382622     -3.115391      3.115391
# 6            0  2.429426          2.429426     -3.176589      3.176589
#
tail(fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_085_pred)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 146            0  4.016345          4.016345     -5.251562      5.251562
# 147            0  4.017888          4.017888     -5.253578      5.253578
# 148            0  4.019398          4.019398     -5.255553      5.255553
# 149            0  4.020877          4.020877     -5.257487      5.257487
# 150            0  4.022325          4.022325     -5.259380      5.259380
# 151            0  4.023743          4.023743     -5.261235      5.261235
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_090_pred <- fGarch::predict(fGARCH_1_1_ged_shpN_lbfgsb_nm, n.ahead=TstS_length, nx=TrnS_length, 
                                                                 mse="uncond", conf=0.90, trace=FALSE, plot=TRUE)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_090_pred)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 1            0  3.743863          2.174446     -6.020597      6.020597
# 2            0  3.743863          2.229967     -6.020597      6.020597
# 3            0  3.743863          2.283048     -6.020597      6.020597
# 4            0  3.743863          2.333878     -6.020597      6.020597
# 5            0  3.743863          2.382622     -6.020597      6.020597
# 6            0  3.743863          2.429426     -6.020597      6.020597
#
tail(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_090_pred)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 146            0  3.743863          4.016345     -6.020597      6.020597
# 147            0  3.743863          4.017888     -6.020597      6.020597
# 148            0  3.743863          4.019398     -6.020597      6.020597
# 149            0  3.743863          4.020877     -6.020597      6.020597
# 150            0  3.743863          4.022325     -6.020597      6.020597
# 151            0  3.743863          4.023743     -6.020597      6.020597
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_090_pred <- fGarch::predict(fGARCH_1_1_ged_shpN_lbfgsb_nm, n.ahead=TstS_length, nx=TrnS_length, 
                                                               mse="cond", conf=0.90, trace=FALSE, plot=TRUE)
head(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_090_pred)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 1            0  3.743863          2.174446     -6.020597      6.020597
# 2            0  3.743863          2.229967     -6.020597      6.020597
# 3            0  3.743863          2.283048     -6.020597      6.020597
# 4            0  3.743863          2.333878     -6.020597      6.020597
# 5            0  3.743863          2.382622     -6.020597      6.020597
# 6            0  3.743863          2.429426     -6.020597      6.020597
#
tail(fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_090_pred)
# meanForecast meanError standardDeviation lowerInterval upperInterval
# 146            0  3.743863          4.016345     -6.020597      6.020597
# 147            0  3.743863          4.017888     -6.020597      6.020597
# 148            0  3.743863          4.019398     -6.020597      6.020597
# 149            0  3.743863          4.020877     -6.020597      6.020597
# 150            0  3.743863          4.022325     -6.020597      6.020597
# 151            0  3.743863          4.023743     -6.020597      6.020597
#
# To draw some more accurate plot we prepare a suitable data frame.
# We consider
head(spx_df)
nrow(spx_df)
# 1871
head(spx_train_df)
nrow(spx_train_df)
# 1720
DS_length <- nrow(spx_df)
TrnS_length <- nrow(spx_train_df)
TstS_length==DS_length-TrnS_length
# TRUE
# and set
spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df <- spx_df
head(spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df)
# Hence we complete the latter with all elements which are necessary to draw our plots.
spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df <- add_column(spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df,
                                                       log.ret.perc_fit_pred=rep(0,DS_length),
                                                       cond_stand_dev=c(spx_train_df$fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_stand_dev,
                                                                        fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_080_pred$standardDeviation),
                                                       cond_var=c(spx_train_df$fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_var,
                                                                  (fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred$standardDeviation)^2),
                                                       log.ret.perc_uncond_080_upp_pred_int=c(rep(NA,TrnS_length),
                                                                                              fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_080_pred$upperInterval),
                                                       log.ret.perc_uncond_085_upp_pred_int=c(rep(NA,TrnS_length),
                                                                                              fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_085_pred$upperInterval),
                                                       log.ret.perc_uncond_090_upp_pred_int=c(rep(NA,TrnS_length),
                                                                                              fGARCH_1_1_ged_shpN_lbfgsb_nm_uncond_090_pred$upperInterval),
                                                       log.ret.perc_cond_080_upp_pred_int=c(rep(NA,TrnS_length),
                                                                                            fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_080_pred$upperInterval),
                                                       log.ret.perc_cond_085_upp_pred_int=c(rep(NA,TrnS_length),
                                                                                            fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_085_pred$upperInterval),
                                                       log.ret.perc_cond_090_upp_pred_int=c(rep(NA,TrnS_length),
                                                                                            fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_090_pred$upperInterval))
head(spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df)
tail(spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df)
#
# Line plot of the SP500 daily logarithm return percentage.
Data_df <- spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=cond_stand_dev)
head(Data_df)
tail(Data_df)
DS_length <- length(Data_df$y)
show(DS_length)
# 1871
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(Data_df$Date[which(Data_df$Date<=as.Date(TrnS_Last_Day))])
show(TrnS_length)
# 1720
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))])
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("SP500 Daily Logarithm Return Percentage, Conditional Standard Deviation, and Conditional Prediction Bands of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - from ", .(First_Day), " to ", .(Last_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
# x_name <- bquote("dates")
# numbers::primeFactors(DS_length-1)
x_breaks_num <- last(numbers::primeFactors(DS_length-1))
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- floor((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- Data_df$Date[x_breaks]
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("Daily Logarithm Return Percentage ")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y),na.rm(Data_df$log.ret.perc_uncond_090_upp_pred_int))
y_min <- min(na.rm(Data_df$y),na.rm(Data_df$log.ret.perc_uncond_090_low_pred_int))
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_min/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_max/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
line_col_grey <- bquote("daily perc. log. ret. - training set")
line_col_black <- bquote("daily perc. log. ret. - test set")
line_col_magenta <- bquote("cond. stand. dev. - GED inn.")
line_col_green <- bquote("80% pred. band endpoints")
line_col_blue <- bquote("85% pred. band endpoints")
line_col_red <- bquote("90% pred. band endpoints")
leg_line_labs   <- c(line_col_grey, line_col_black, line_col_magenta, line_col_green, line_col_blue, line_col_red)
leg_line_breaks <- c("line_col_grey", "line_col_black", "line_col_magenta", "line_col_green", "line_col_blue", "line_col_red")
leg_line_cols   <- c("line_col_grey"="grey50", "line_col_black"="black", "line_col_magenta"="magenta", 
                     "line_col_green"="green", "line_col_blue"="blue", "line_col_red"="red")
fill_col_lightgreen <- bquote("80% pred. band")
fill_col_cyan <- bquote("85% pred. band")
fill_col_orangered <- bquote("90% pred. band")
leg_fill_labs <- c(fill_col_lightgreen, fill_col_cyan, fill_col_orangered)
leg_fill_breaks <- c("fill_col_lightgreen", "fill_col_cyan", "fill_col_orangered")
leg_fill_cols <- c("fill_col_lightgreen"="lightgreen", "fill_col_cyan"="cyan", "fill_col_orangered"="orangered")
Data_df_lp <- ggplot(Data_df, aes(x=x)) + 
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=-log.ret.perc_cond_080_upp_pred_int, ymax=log.ret.perc_cond_080_upp_pred_int, fill= "fill_col_lightgreen"), 
              alpha=0.3, colour= "lightgreen") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=-log.ret.perc_cond_085_upp_pred_int, ymax=-log.ret.perc_cond_080_upp_pred_int, fill= "fill_col_cyan"),
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=-log.ret.perc_cond_090_upp_pred_int, ymax=-log.ret.perc_cond_085_upp_pred_int, fill= "fill_col_orangered"), 
              alpha=0.3, colour= "orangered") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=log.ret.perc_cond_080_upp_pred_int, ymax=log.ret.perc_cond_085_upp_pred_int, fill= "fill_col_cyan"), 
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=log.ret.perc_cond_085_upp_pred_int, ymax=log.ret.perc_cond_090_upp_pred_int, fill= "fill_col_orangered"), 
              alpha=0.3, colour= "orangered") +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=-log.ret.perc_cond_090_upp_pred_int, colour= "line_col_red"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=log.ret.perc_cond_090_upp_pred_int, colour= "line_col_red"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=-log.ret.perc_cond_085_upp_pred_int, colour= "line_col_blue"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=log.ret.perc_cond_085_upp_pred_int, colour= "line_col_blue"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=-log.ret.perc_cond_080_upp_pred_int, colour= "line_col_green"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=log.ret.perc_cond_080_upp_pred_int, colour= "line_col_green"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x <= x[TrnS_length]), aes(y=y, color= "line_col_grey"),
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=y, colour= "line_col_black"), 
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(aes(y=z, color="line_col_magenta"), linetype="solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, labels=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis= sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype= "none", shape= "none") +
  scale_colour_manual(name= "Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_breaks) +
  guides(colour=guide_legend(order=1), fill=guide_legend(order=2)) +
  theme(plot.title=element_text(hjust=0.5, size=10), 
        plot.subtitle=element_text(hjust=0.5, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_daily_return_percentage_pred_band.png", Data_df_lp, width = 14, height=6)
plot(Data_df_lp)
#
# Detail of the line plot of the SP500 daily logarithm return percentage.
Data_df <- spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=log.ret.perc., z=cond_stand_dev)
head(Data_df)
tail(Data_df)
DS_length <- length(Data_df$y)
show(DS_length)
# 1871
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(Data_df$Date[which(Data_df$Date<=as.Date(TrnS_Last_Day))])
show(TrnS_length)
# 1720
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))])
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
Det_Day <- as.character(Data_df$Date[round(0.70 * nrow(Data_df))]) #TODO: capire cosa rappresenta Det_Day, e come è stata scelta
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Detail of SP500 Daily Logarithm Return Percentage, Conditional Standard Deviation, and Conditional Prediction Bands of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - from ", .(First_Day), " to ", .(Last_Day), ", detail from ", .(Det_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
# x_name <- bquote("dates")
# numbers::primeFactors(which(Data_df$Date==Last_Day)-which(Data_df$Date==Det_Day)-2)
x_breaks_num <- last(numbers::primeFactors(which(Data_df$Date==Last_Day)-which(Data_df$Date==Det_Day)-2))
x_breaks_low <- Data_df$x[which(Data_df$Date==Det_Day)]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- floor((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- Data_df$Date[x_breaks]
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("Daily Logarithm Return Percentage ")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]),
             na.rm(Data_df$log.ret.perc_cond_090_upp_pred_int[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]))
y_min <- min(na.rm(Data_df$y[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]),
             na.rm(-Data_df$log.ret.perc_cond_090_upp_pred_int[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]))
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_min/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_max/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
line_col_grey <- bquote("daily perc. log. ret. - training set")
line_col_black <- bquote("daily perc. log. ret. - test set")
line_col_magenta <- bquote("cond. stand. dev. - GED inn.")
line_col_green <- bquote("80% pred. band endpoints")
line_col_blue <- bquote("85% pred. band endpoints")
line_col_red <- bquote("90% pred. band endpoints")
leg_line_labs   <- c(line_col_grey, line_col_black, line_col_magenta, line_col_green, line_col_blue, line_col_red)
leg_line_breaks <- c("line_col_grey", "line_col_black", "line_col_magenta", "line_col_green", "line_col_blue", "line_col_red")
leg_line_cols   <- c("line_col_grey"="grey50", "line_col_black"="black", "line_col_magenta"="magenta", 
                     "line_col_green"="green", "line_col_blue"="blue", "line_col_red"="red")
fill_col_lightgreen <- bquote("80% pred. band")
fill_col_cyan <- bquote("85% pred. band")
fill_col_orangered <- bquote("90% pred. band")
leg_fill_labs <- c(fill_col_lightgreen, fill_col_cyan, fill_col_orangered)
leg_fill_breaks <- c("fill_col_lightgreen", "fill_col_cyan", "fill_col_orangered")
leg_fill_cols <- c("fill_col_lightgreen"="lightgreen", "fill_col_cyan"="cyan", "fill_col_orangered"="orangered")
Data_df_lp <- ggplot(Data_df, aes(x=x)) + 
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=-log.ret.perc_cond_080_upp_pred_int, ymax=log.ret.perc_cond_080_upp_pred_int, fill= "fill_col_lightgreen"), 
              alpha=0.3, colour= "lightgreen") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=-log.ret.perc_cond_085_upp_pred_int, ymax=-log.ret.perc_cond_080_upp_pred_int, fill= "fill_col_cyan"),
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=-log.ret.perc_cond_090_upp_pred_int, ymax=-log.ret.perc_cond_085_upp_pred_int, fill= "fill_col_orangered"), 
              alpha=0.3, colour= "orangered") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=log.ret.perc_cond_080_upp_pred_int, ymax=log.ret.perc_cond_085_upp_pred_int, fill= "fill_col_cyan"), 
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=log.ret.perc_cond_085_upp_pred_int, ymax=log.ret.perc_cond_090_upp_pred_int, fill= "fill_col_orangered"), 
              alpha=0.3, colour= "orangered") +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=-log.ret.perc_cond_090_upp_pred_int, colour= "line_col_red"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=log.ret.perc_cond_090_upp_pred_int, colour= "line_col_red"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=-log.ret.perc_cond_085_upp_pred_int, colour= "line_col_blue"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=log.ret.perc_cond_085_upp_pred_int, colour= "line_col_blue"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=-log.ret.perc_cond_080_upp_pred_int, colour= "line_col_green"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=log.ret.perc_cond_080_upp_pred_int, colour= "line_col_green"), 
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, (x >= x[which(Data_df$Date==Det_Day)] & x <= x[TrnS_length])), aes(y=y, color= "line_col_grey"),
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=y, colour= "line_col_black"), 
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[which(Data_df$Date==Det_Day)]), aes(y=z, color="line_col_magenta"), 
            linetype="solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, labels=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis= sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype= "none", shape= "none") +
  scale_colour_manual(name= "Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_breaks) +
  guides(colour=guide_legend(order=1), fill=guide_legend(order=2)) +
  theme(plot.title=element_text(hjust=0.5, size=10), 
        plot.subtitle=element_text(hjust=0.5, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_daily_return_percentage_pred_band_GED_inn.png", Data_df_lp, width = 14, height=6)
plot(Data_df_lp)
#
# From the forecasting plot of the logarithm return percentage, it is not difficult to obtain a forecasting plot of the logarithm adjusted 
# close price.
# First, we go back from the logarithm return percentage to the logarithm return and we we build the confidence bands of the latter by the
# multiplication of the confidence bands endpoints of the former times the factor 1/100.
# Second we build the predicted values of the test set by observing that the predicted values of the logarithm returns are all zero.
# Thus, if we denote by $y_{T+t}$ and $\hat{y}_{T+t,T}$ [resp. $z_{T+t}$ and $\hat{z}_{T+t,T}$], $\forall t\geq 0$ the adjusted close price
# logarithm and predicted adjusted close price logarithm [resp. logarithm return and predicted logarithm return] at time $T+t$ given the 
# information up to the end time $T$ of the training set, thanks to the linearity of the conditional expectation operator, from the equation
# $z_{T+t}=y_{T+t}-y_{T+t-1} \forall t=1,\dots,U$ where $U$, is the end time of the test set$,
# we obtain
# $\hat{z}_{T+t,T}=\hat{y}_{T+t,T}-\hat{y}_{T+t-1,T}$.
# On the other hand,
# $\hat{z}_{T+t,T}=0, \forall t=1,\dots,U$ where $U$.
# It follows
# $\hat{y}_{T+1,T}=\hat{y}_{T,T}=y_{T}$,
# $\hat{y}_{T+2,T}=\hat{y}_{T+1,T}=y_{T}$,
# $\dots$,
# $\hat{y}_{T+t,T}=y_{T}, \forall t=1,\dots,U$.
# In addition, from
# $low_{T+t,T} < \hat{z}_{T+t,T} < upp_{T+t,T}, \forall t=1,\dots,U$, where $low_{T+t,T}$ and $upp_{T+t,T}$ are the lower and upper 
# endpoints of any confidence band at time $T+t$ given the information up to the end time $T$ of the training set, we obtain
# $low_{T+1,T} < \hat{y}_{T+1,T}-\hat{y}_{T,T} < upp_{T+1,T}$.
# Hence,
# low_{T+1,T} < \hat{y}_{T+1,T} - y_{T} < upp_{T+1,T}$,
# that is
# y_{T} + low_{T+1,T} < \hat{y}_{T+1,T} <  y_{T} + upp_{T+1,T}$.
# Similarly,
# $low_{T+2,T} < \hat{y}_{T+2,T}-\hat{y}_{T+1,T} < upp_{T+2,T}$,
# from which
# $low_{T+2,T} < \hat{y}_{T+2,T}-{y}_{T} < upp_{T+2,T}$,
# and
# ${y}_{T} + low_{T+2,T} < \hat{y}_{T+2,T} < {y}_{T} + upp_{T+2,T}$.
# In the end, we can write
# ${y}_{T} + low_{T+t,T} < \hat{y}_{T+t,T} < {y}_{T} + upp_{T+t,T}, \forall t=1,\dots,U$.
# This gives the prediction bands for the predicted values of the adjusted price logarithm.
# We plot the detail of the predicted values and prediction bands for the SP500 adjusted close price logarithm
Data_df <- spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df
head(Data_df)
tail(Data_df)
Data_df <- add_column(Data_df, 
                      Pred_Adj_Close_log.=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)),
                      Adj_Close_log_uncond_080_upp_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)+(Data_df$log.ret.perc_uncond_080_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_uncond_085_upp_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)+(Data_df$log.ret.perc_uncond_085_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_uncond_090_upp_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)+(Data_df$log.ret.perc_uncond_090_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_uncond_080_low_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)-(Data_df$log.ret.perc_uncond_080_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_uncond_085_low_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)-(Data_df$log.ret.perc_uncond_085_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_uncond_090_low_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)-(Data_df$log.ret.perc_uncond_090_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_cond_080_upp_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)+(Data_df$log.ret.perc_cond_080_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_cond_085_upp_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)+(Data_df$log.ret.perc_cond_085_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_cond_090_upp_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)+(Data_df$log.ret.perc_cond_090_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_cond_080_low_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)-(Data_df$log.ret.perc_cond_080_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_cond_085_low_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)-(Data_df$log.ret.perc_cond_085_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      Adj_Close_log_cond_090_low_pred_int=c(rep(NA,TrnS_length),rep(Data_df$Adj_Close_log.[TrnS_length],TstS_length)-(Data_df$log.ret.perc_cond_090_upp_pred_int[c((TrnS_length+1):DS_length)]/100)),
                      .after="Adj_Close_log.")
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=Adj_Close_log., z=Pred_Adj_Close_log.)
head(Data_df)
tail(Data_df)
DS_length <- length(Data_df$y)
show(DS_length)
# 1871
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(Data_df$Date[which(Data_df$Date<=as.Date(TrnS_Last_Day))])
show(TrnS_length)
# 1720
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))])
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
Det_Day <- as.character(Data_df$Date[round(0.70 * nrow(Data_df))])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Detail of SP500 Daily Adjusted Close Price Logarithm, Predicted Values, and Prediction Bands of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - from ", .(First_Day), " to ", .(Last_Day), ", detail from ", .(Det_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
# x_name <- bquote("dates")
# numbers::primeFactors(which(Data_df$Date==Last_Day)-which(Data_df$Date==Det_Day)-2)
x_breaks_num <- last(numbers::primeFactors(which(Data_df$Date==Last_Day)-which(Data_df$Date==Det_Day)-2))
x_breaks_low <- Data_df$x[which(Data_df$Date==Det_Day)]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- floor((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- Data_df$Date[x_breaks]
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("Daily Adjusted Close Logarithm")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]),
             na.rm(Data_df$Adj_Close_log_cond_090_upp_pred_int[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]))

y_min <- min(na.rm(Data_df$y[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]),
             na.rm(Data_df$Adj_Close_log_cond_090_low_pred_int[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]))
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_min/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_max/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
line_col_grey <- bquote("adj. close log. - training set")
line_col_black <- bquote("adj. close log. - test set")
line_col_magenta <- bquote("adj. close log. - predicted test set")
line_col_green <- bquote("80% pred. band endpoints")
line_col_blue <- bquote("85% pred. band endpoints")
line_col_red <- bquote("90% pred. band endpoints")
leg_line_labs   <- c(line_col_grey, line_col_black, line_col_magenta, line_col_green, line_col_blue, line_col_red)
leg_line_breaks <- c("line_col_grey", "line_col_black", "line_col_magenta", "line_col_green", "line_col_blue", "line_col_red")
leg_line_cols   <- c("line_col_grey"="grey50", "line_col_black"="black", "line_col_magenta"="magenta", "line_col_green"="green", 
                     "line_col_blue"="blue", "line_col_red"="red")
fill_col_lightgreen <- bquote("80% pred. band")
fill_col_cyan <- bquote("85% pred. band")
fill_col_orangered <- bquote("90% pred. band")
leg_fill_labs <- c(fill_col_lightgreen, fill_col_cyan, fill_col_orangered)
leg_fill_breaks <- c("fill_col_lightgreen", "fill_col_cyan", "fill_col_orangered")
leg_fill_cols <- c("fill_col_lightgreen"="lightgreen", "fill_col_cyan"="cyan", "fill_col_orangered"="orangered")
Data_df_lp <- ggplot(Data_df, aes(x=x)) + 
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_080_low_pred_int, ymax=Adj_Close_log_cond_080_upp_pred_int, fill= "fill_col_lightgreen"),
              alpha=0.3, colour= "lightgreen") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_085_low_pred_int, ymax=Adj_Close_log_cond_080_low_pred_int, fill= "fill_col_cyan"),
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_090_low_pred_int, ymax=Adj_Close_log_cond_085_low_pred_int, fill= "fill_col_orangered"),
              alpha=0.3, colour= "orangered") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_080_upp_pred_int, ymax=Adj_Close_log_cond_085_upp_pred_int, fill= "fill_col_cyan"),
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_085_upp_pred_int, ymax=Adj_Close_log_cond_090_upp_pred_int, fill= "fill_col_orangered"),
              alpha=0.3, colour= "orangered") +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_090_upp_pred_int, colour= "line_col_red"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_090_low_pred_int, colour= "line_col_red"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_085_upp_pred_int, colour= "line_col_blue"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_085_low_pred_int, colour= "line_col_blue"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_080_upp_pred_int, colour= "line_col_green"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_080_low_pred_int, colour= "line_col_green"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, (x >= x[which(Data_df$Date==Det_Day)] & x <= x[TrnS_length])), aes(y=y, color= "line_col_grey"),
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=y, color= "line_col_black"), 
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=z, color="line_col_magenta"),
            linetype="solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, labels=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis= sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype= "none", shape= "none") +
  scale_colour_manual(name= "Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_breaks) +
  guides(colour=guide_legend(order=1), fill=guide_legend(order=2)) +
  theme(plot.title=element_text(hjust=0.5, size=8), 
        plot.subtitle=element_text(hjust=0.5, size=6),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_adj_price_log_pred_band.png", Data_df_lp, width = 14, height=6)
plot(Data_df_lp)
#
# The forecasting performance may appear very poor. However, it must be considered that in this forecast we only use the information
# transmitted by the training set and that the logarithm of the adjusted close price is a non-stationary process. Therefore, in the long 
# run, constant forecasting is bound to fail. In contrast, if we allow a daily update of the forecasting by a daily increasing of the
# training set the forecasting performance improves significantly.
# We denote by $y_{T+t+1}$ and $\hat{y}_{T+t+1,T+t}$ [resp. $z_{T+t+1}$ and $\hat{z}_{T+t+1,T+t}$], $\forall t\geq 0$ the adjusted close 
# price logarithm and predicted adjusted close price logarithm [resp. logarithm return and predicted logarithm return] at time $T+t+1$ given
# the information up to time $T+t$, where $T$ is the end time of the training set, thanks to the linearity of the conditional expectation 
# operator, from the equation
# $z_{T+t+1}=y_{T+t+1}-y_{T+t} \forall t=0,\dots,U-1$ where $U$, is the end time of the test set$,
# we obtain
# $\hat{z}_{T+t+1,T+t}=\hat{y}_{T+t+1,T+t}-\hat{y}_{T+t,T+t}$.
# On the other hand,
# $\hat{z}_{T+t+1,T+t}=0, \forall t=0,\dots,U-1$.
# It follows
# $\hat{y}_{T+1,T}=\hat{y}_{T,T}=y_{T}$,
# $\hat{y}_{T+2,T+1}=\hat{y}_{T+1,T+1}=y_{T+1}$,
# $\dots$,
# $\hat{y}_{T+t+1,T+1}=y_{T+t}, \forall t=0,\dots,U-1$ where $U$.
# In addition, from
# $low_{T+t+1,T+t} < \hat{z}_{T+t+1,T+t} < upp_{T+t+1,T+t}, \forall t=0,\dots,U-1$, where $low_{T+t+1,T+t}$ and $upp_{T+t+1,T+t}$ are the 
# lower and upper endpoints of any confidence band at time $T+t+1$ given the information up to the end time $T+t$ of daily increasing 
# training set, we obtain
# $low_{T+1,T} < \hat{y}_{T+1,T}-\hat{y}_{T,T} < upp_{T+1,T}$.
# Hence,
# low_{T+1,T} < \hat{y}_{T+1,T} - y_{T} < upp_{T+1,T}$,
# that is
# y_{T} + low_{T+1,T} < \hat{y}_{T+1,T} <  y_{T} + upp_{T+1,T}$.
# Similarly,
# $low_{T+2,T+1} < \hat{y}_{T+2,T+1}-\hat{y}_{T+1,T+1} < upp_{T+2,T+1}$,
# from which
# $low_{T+2,T+1} < \hat{y}_{T+2,T+1}-{y}_{T+1} < upp_{T+2,T+1}$,
# and
# ${y}_{T+1} + low_{T+2,T+1} < \hat{y}_{T+2,T+1} < {y}_{T+1} + upp_{T+2,T+1}$.
# In the end, we can write
# ${y}_{T+t} + low_{T+t+1,T+t} < \hat{y}_{T+t+1,T+t} < {y}_{T+t} + upp_{T+t+1,T+t}, \forall t=0,\dots,U-1$.
#
# The result of the daily updating forecasting can be appreciated by the following plot.
Data_df <- spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df
head(Data_df)
tail(Data_df)
Data_df <- add_column(Data_df, 
                      Lagged_Adj_Close_log.=c(NA,Data_df$Adj_Close_log.[-length(Data_df$Adj_Close_log.)]),
                      Adj_Close_log_uncond_080_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_uncond_085_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_uncond_085_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_uncond_090_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_uncond_090_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_uncond_080_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_uncond_085_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_uncond_090_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_cond_080_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_cond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_cond_085_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_cond_085_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_cond_090_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_cond_090_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_cond_080_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_cond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_cond_085_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_cond_085_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      Adj_Close_log_cond_090_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_cond_090_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
                      .after="Adj_Close_log.")
head(Data_df)
tail(Data_df)
Data_df <- dplyr::rename(Data_df, x=index, y=Adj_Close_log., z=Lagged_Adj_Close_log.)
head(Data_df)
tail(Data_df)
DS_length <- length(Data_df$y)
show(DS_length)
# 1871
First_Day <- as.character(Data_df$Date[1])
show(First_Day)
# "2018-04-17"
Last_Day <- as.character(Data_df$Date[DS_length])
show(Last_Day)
# "2023-05-31"
TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
show(TrnS_Last_Day)
# "2022-12-31"
TrnS_length <- length(Data_df$Date[which(Data_df$Date<=as.Date(TrnS_Last_Day))])
show(TrnS_length)
# 1720
TstS_First_Day <- as.character(Data_df$Date[position_92])
show(TstS_First_Day)
# "2023-01-01"
TstS_length <- length(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))])
show(TstS_length)
# 151
TstS_length == DS_length-TrnS_length
# TRUE
First_Day <- as.character(Data_df$Date[2])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
Det_Day <- as.character(Data_df$Date[round(0.70 * nrow(Data_df))])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Detail of SP500 Daily Adjusted Close Price Logarithm, Predicted Values, and Prediction Bands of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - from ", .(First_Day), " to ", .(Last_Day), ", detail from ", .(Det_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
# x_name <- bquote("dates")
# numbers::primeFactors(which(Data_df$Date==Last_Day)-which(Data_df$Date==Det_Day)-2)
x_breaks_num <- last(numbers::primeFactors(which(Data_df$Date==Last_Day)-which(Data_df$Date==Det_Day)-2))
x_breaks_low <- Data_df$x[which(Data_df$Date==Det_Day)]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- floor((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- Data_df$Date[x_breaks]
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("Daily Adjusted Close Logarithm")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]),
             na.rm(Data_df$Adj_Close_log_cond_090_upp_pred_int[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]))

y_min <- min(na.rm(Data_df$y[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]),
             na.rm(Data_df$Adj_Close_log_cond_090_low_pred_int[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]))
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_min/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_max/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
line_col_grey <- bquote("adj. close log. - training set")
line_col_black <- bquote("adj. close log. - test set")
line_col_magenta <- bquote("adj. close log. - predicted test set")
line_col_green <- bquote("80% pred. band endpoints")
line_col_blue <- bquote("85% pred. band endpoints")
line_col_red <- bquote("90% pred. band endpoints")
leg_line_labs   <- c(line_col_grey, line_col_black, line_col_magenta, line_col_green, line_col_blue, line_col_red)
leg_line_breaks <- c("line_col_grey", "line_col_black", "line_col_magenta", "line_col_green", "line_col_blue", "line_col_red")
leg_line_cols   <- c("line_col_grey"="grey50", "line_col_black"="black", "line_col_magenta"="magenta", "line_col_green"="green", 
                     "line_col_blue"="blue", "line_col_red"="red")
fill_col_lightgreen <- bquote("80% pred. band")
fill_col_cyan <- bquote("85% pred. band")
fill_col_orangered <- bquote("90% pred. band")
leg_fill_labs <- c(fill_col_lightgreen, fill_col_cyan, fill_col_orangered)
leg_fill_breaks <- c("fill_col_lightgreen", "fill_col_cyan", "fill_col_orangered")
leg_fill_cols <- c("fill_col_lightgreen"="lightgreen", "fill_col_cyan"="cyan", "fill_col_orangered"="orangered")
Data_df_lp <- ggplot(Data_df, aes(x=x)) + 
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_080_low_pred_int, ymax=Adj_Close_log_cond_080_upp_pred_int, fill= "fill_col_lightgreen"),
              alpha=0.3, colour= "lightgreen") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_085_low_pred_int, ymax=Adj_Close_log_cond_080_low_pred_int, fill= "fill_col_cyan"),
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_090_low_pred_int, ymax=Adj_Close_log_cond_085_low_pred_int, fill= "fill_col_orangered"),
              alpha=0.3, colour= "orangered") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_080_upp_pred_int, ymax=Adj_Close_log_cond_085_upp_pred_int, fill= "fill_col_cyan"),
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_085_upp_pred_int, ymax=Adj_Close_log_cond_090_upp_pred_int, fill= "fill_col_orangered"),
              alpha=0.3, colour= "orangered") +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_090_upp_pred_int, colour= "line_col_red"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_090_low_pred_int, colour= "line_col_red"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_085_upp_pred_int, colour= "line_col_blue"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_085_low_pred_int, colour= "line_col_blue"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_080_upp_pred_int, colour= "line_col_green"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_080_low_pred_int, colour= "line_col_green"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, (x >= x[which(Data_df$Date==Det_Day)] & x <= x[TrnS_length])), aes(y=y, color= "line_col_grey"),
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=y, color= "line_col_black"), 
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=z, color="line_col_magenta"),
            linetype="solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, labels=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis= sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype= "none", shape= "none") +
  scale_colour_manual(name= "Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_breaks) +
  guides(colour=guide_legend(order=1), fill=guide_legend(order=2)) +
  theme(plot.title=element_text(hjust=0.5, size=10), 
        plot.subtitle=element_text(hjust=0.5, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_daily_return_percentage_pred_band_GED_inn.png", Data_df_lp, width = 10, height=6)
plot(Data_df_lp)

# The result of the daily updating forecasting can be appreciated by the following plot (details).
# Data_df <- spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df
# head(Data_df)
# tail(Data_df)
# Data_df <- add_column(Data_df, 
#                       Lagged_Adj_Close_log.=c(NA,Data_df$Adj_Close_log.[-length(Data_df$Adj_Close_log.)]),
#                       Adj_Close_log_uncond_080_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_uncond_085_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_uncond_085_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_uncond_090_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_uncond_090_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_uncond_080_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_uncond_085_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_uncond_090_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_cond_080_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_cond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_cond_085_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_cond_085_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_cond_090_upp_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]+rep(Data_df$log.ret.perc_cond_090_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_cond_080_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_cond_080_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_cond_085_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_cond_085_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       Adj_Close_log_cond_090_low_pred_int=c(rep(NA,TrnS_length),Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))]-rep(Data_df$log.ret.perc_cond_090_upp_pred_int[(TrnS_length+1)]/100,TstS_length)),
#                       .after="Adj_Close_log.")
# head(Data_df)
# tail(Data_df)
# Data_df <- dplyr::rename(Data_df, x=index, y=Adj_Close_log., z=Lagged_Adj_Close_log.)
# head(Data_df)
# tail(Data_df)
# DS_length <- length(Data_df$y)
# show(DS_length)
# # 1871
# First_Day <- as.character(Data_df$Date[1])
# show(First_Day)
# # "2018-04-17"
# Last_Day <- as.character(Data_df$Date[DS_length])
# show(Last_Day)
# # "2023-05-31"
# TrnS_Last_Day <- as.character(Data_df$Date[position_92-1])
# show(TrnS_Last_Day)
# # "2022-12-31"
# TrnS_length <- length(Data_df$Date[which(Data_df$Date<=as.Date(TrnS_Last_Day))])
# show(TrnS_length)
# # 1720
# TstS_First_Day <- as.character(Data_df$Date[position_92])
# show(TstS_First_Day)
# # "2023-01-01"
# TstS_length <- length(Data_df$Date[which(Data_df$Date>=as.Date(TstS_First_Day))])
# show(TstS_length)
# # 151
# TstS_length == DS_length-TrnS_length
# # TRUE
First_Day <- as.character(Data_df$Date[0.60*nrow(Data_df)])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
Det_Day <- as.character(Data_df$Date[round(0.87 * nrow(Data_df))])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                             paste("Detail of SP500 Daily Adjusted Close Price Logarithm, Predicted Values, and Prediction Bands of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - from ", .(First_Day), " to ", .(Last_Day), ", detail from ", .(Det_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))
caption_content <- "Author: Michele Tosi"
# x_name <- bquote("dates")
# numbers::primeFactors(which(Data_df$Date==Last_Day)-which(Data_df$Date==Det_Day)-2)
x_breaks_num <- last(numbers::primeFactors(which(Data_df$Date==Last_Day)-which(Data_df$Date==Det_Day)-2))
x_breaks_low <- Data_df$x[which(Data_df$Date==Det_Day)]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- floor((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- Data_df$Date[x_breaks]
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("Daily Adjusted Close Logarithm")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]),
             na.rm(Data_df$Adj_Close_log_cond_090_upp_pred_int[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]))

y_min <- min(na.rm(Data_df$y[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]),
             na.rm(Data_df$Adj_Close_log_cond_090_low_pred_int[c(which(Data_df$Date==Det_Day):which(Data_df$Date==Last_Day))]))
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_min/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_max/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0.0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
line_col_grey <- bquote("adj. close log. - training set")
line_col_black <- bquote("adj. close log. - test set")
line_col_magenta <- bquote("adj. close log. - predicted test set")
line_col_green <- bquote("80% pred. band endpoints")
line_col_blue <- bquote("85% pred. band endpoints")
line_col_red <- bquote("90% pred. band endpoints")
leg_line_labs   <- c(line_col_grey, line_col_black, line_col_magenta, line_col_green, line_col_blue, line_col_red)
leg_line_breaks <- c("line_col_grey", "line_col_black", "line_col_magenta", "line_col_green", "line_col_blue", "line_col_red")
leg_line_cols   <- c("line_col_grey"="grey50", "line_col_black"="black", "line_col_magenta"="magenta", "line_col_green"="green", 
                     "line_col_blue"="blue", "line_col_red"="red")
fill_col_lightgreen <- bquote("80% pred. band")
fill_col_cyan <- bquote("85% pred. band")
fill_col_orangered <- bquote("90% pred. band")
leg_fill_labs <- c(fill_col_lightgreen, fill_col_cyan, fill_col_orangered)
leg_fill_breaks <- c("fill_col_lightgreen", "fill_col_cyan", "fill_col_orangered")
leg_fill_cols <- c("fill_col_lightgreen"="lightgreen", "fill_col_cyan"="cyan", "fill_col_orangered"="orangered")
Data_df_lp <- ggplot(Data_df, aes(x=x)) + 
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_080_low_pred_int, ymax=Adj_Close_log_cond_080_upp_pred_int, fill= "fill_col_lightgreen"),
              alpha=0.3, colour= "lightgreen") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_085_low_pred_int, ymax=Adj_Close_log_cond_080_low_pred_int, fill= "fill_col_cyan"),
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_090_low_pred_int, ymax=Adj_Close_log_cond_085_low_pred_int, fill= "fill_col_orangered"),
              alpha=0.3, colour= "orangered") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_080_upp_pred_int, ymax=Adj_Close_log_cond_085_upp_pred_int, fill= "fill_col_cyan"),
              alpha=0.3, colour= "cyan") +
  geom_ribbon(data=subset(Data_df, x >= x[TrnS_length+1]), aes(ymin=Adj_Close_log_cond_085_upp_pred_int, ymax=Adj_Close_log_cond_090_upp_pred_int, fill= "fill_col_orangered"),
              alpha=0.3, colour= "orangered") +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_090_upp_pred_int, colour= "line_col_red"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_090_low_pred_int, colour= "line_col_red"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_085_upp_pred_int, colour= "line_col_blue"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_085_low_pred_int, colour= "line_col_blue"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_080_upp_pred_int, colour= "line_col_green"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=Adj_Close_log_cond_080_low_pred_int, colour= "line_col_green"),
            linetype= "solid", alpha=1, linewidth=1) +
  geom_line(data=subset(Data_df, (x >= x[which(Data_df$Date==Det_Day)] & x <= x[TrnS_length])), aes(y=y, color= "line_col_grey"),
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=y, color= "line_col_black"), 
            linetype= "solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  geom_line(data=subset(Data_df, x >= x[TrnS_length+1]), aes(y=z, color="line_col_magenta"),
            linetype="solid", alpha=1, linewidth=0.7, group=1, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, labels=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims, sec.axis= sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  guides(linetype= "none", shape= "none") +
  scale_colour_manual(name= "Legend", labels=leg_line_labs, values=leg_line_cols, breaks=leg_line_breaks) +
  scale_fill_manual(name= "", labels=leg_fill_labs, values=leg_fill_cols, breaks=leg_fill_breaks) +
  guides(colour=guide_legend(order=1), fill=guide_legend(order=2)) +
  theme(plot.title=element_text(hjust=0.5, size=10), 
        plot.subtitle=element_text(hjust=0.5, size=8),
        axis.text.x=element_text(angle=-45, vjust=1, hjust=-0.3),
        legend.key.width=unit(0.8,"cm"), legend.position= "bottom")
ggsave("plots/spx_daily_return_percentage_pred_band_GED_inn_detail.png", Data_df_lp, width = 10, height=6)
plot(Data_df_lp)
#
#
# Inizio con l'aggiornare Data_df per includere i prezzi esponenziali
Data_df <- spx_fGARCH_1_1_ged_shpN_lbfgsb_nm_df

# Aggiungi colonne per i prezzi esponenziali a partire dai logaritmi
Data_df <- add_column(Data_df, 
                      Lagged_Adj_Close_price = exp(c(NA, Data_df$Adj_Close_log.[-length(Data_df$Adj_Close_log.)])),
                      Adj_Close_price_uncond_080_upp_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] + rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_uncond_085_upp_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] + rep(Data_df$log.ret.perc_uncond_085_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_uncond_090_upp_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] + rep(Data_df$log.ret.perc_uncond_090_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_uncond_080_low_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] - rep(Data_df$log.ret.perc_uncond_080_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_uncond_085_low_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] - rep(Data_df$log.ret.perc_uncond_085_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_uncond_090_low_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] - rep(Data_df$log.ret.perc_uncond_090_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_cond_080_upp_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] + rep(Data_df$log.ret.perc_cond_080_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_cond_085_upp_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] + rep(Data_df$log.ret.perc_cond_085_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_cond_090_upp_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] + rep(Data_df$log.ret.perc_cond_090_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_cond_080_low_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] - rep(Data_df$log.ret.perc_cond_080_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_cond_085_low_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] - rep(Data_df$log.ret.perc_cond_085_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      Adj_Close_price_cond_090_low_pred_int = exp(c(rep(NA, TrnS_length), Data_df$Adj_Close_log.[c(TrnS_length:(DS_length-1))] - rep(Data_df$log.ret.perc_cond_090_upp_pred_int[(TrnS_length + 1)] / 100, TstS_length))),
                      .after="Adj_Close_log.")

# Rinomina le colonne per il grafico
Data_df <- dplyr::rename(Data_df, x=index, y=Adj_Close, z=Lagged_Adj_Close_price)
# Calcolare le date per il titolo e il sottotitolo
First_Day <- as.character(Data_df$Date[0.60 * nrow(Data_df)])
Last_Day <- as.character(Data_df$Date[nrow(Data_df)])
Det_Day <- as.character(Data_df$Date[round(0.83 * nrow(Data_df))])
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Modelli Probabilistici e Statistici per i Mercati Finanziati \u0040 Magistrale Ingegneria Informatica 2023-2024",
                            paste("Detail of SP500 Daily Adjusted Close Price, Predicted Values, and Prediction Bands of the fGarch::garchFit() Fitted GARCH(1,1) Model with GED Innovation - from ", .(First_Day), " to ", .(Last_Day), ", detail from ", .(Det_Day), sep="")))
link <- "https://finance.yahoo.com/quote/%5ESPX/history/"
subtitle_content <- bquote(paste("Training set length ", .(TrnS_length), " sample points, from ", .(First_Day), " to ", .(TrnS_Last_Day),". Test set length ", .(TstS_length), " sample points, from ", .(TstS_First_Day), " to ", .(Last_Day),". Data by courtesy of Yahoo Finance - ", .(link)))

# Calcolare i parametri per l'asse x
x_breaks_num <- last(numbers::primeFactors(which(Data_df$Date == Last_Day) - which(Data_df$Date == Det_Day) - 2))
x_breaks_low <- Data_df$x[which(Data_df$Date == Det_Day)]
x_breaks_up <- Data_df$x[DS_length]
x_binwidth <- floor((x_breaks_up - x_breaks_low) / x_breaks_num)
x_breaks <- seq(from = x_breaks_low, to = x_breaks_up, by = x_binwidth)
if ((x_breaks_up - max(x_breaks)) > x_binwidth / 2) { x_breaks <- c(x_breaks, x_breaks_up) }
x_labs <- Data_df$Date[x_breaks]
J <- 0
x_lims <- c(x_breaks_low - J * x_binwidth, x_breaks_up + J * x_binwidth)

# Calcolare i parametri per l'asse y
y_name <- bquote("Daily Adjusted Close Price")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y[c(which(Data_df$Date == Det_Day):which(Data_df$Date == Last_Day))]),
            na.rm(Data_df$Adj_Close_price_cond_090_upp_pred_int[c(which(Data_df$Date == Det_Day):which(Data_df$Date == Last_Day))]))

y_min <- min(na.rm(Data_df$y[c(which(Data_df$Date == Det_Day):which(Data_df$Date == Last_Day))]),
            na.rm(Data_df$Adj_Close_price_cond_090_low_pred_int[c(which(Data_df$Date == Det_Day):which(Data_df$Date == Last_Day))]))
y_binwidth <- round((y_max - y_min) / y_breaks_num, digits = 3)
y_breaks_low <- floor(y_min / y_binwidth) * y_binwidth
y_breaks_up <- ceiling(y_max / y_binwidth) * y_binwidth
y_breaks <- round(seq(from = y_breaks_low, to = y_breaks_up, by = y_binwidth), 3)
y_labs <- format(y_breaks, scientific = FALSE)
K <- 0.0
y_lims <- c((y_breaks_low - K * y_binwidth), (y_breaks_up + K * y_binwidth))

# Definizione dei colori e delle etichette
line_col_grey <- bquote("adj. close - training set")
line_col_black <- bquote("adj. close - test set")
line_col_magenta <- bquote("adj. close - predicted test set")
line_col_green <- bquote("80% pred. band endpoints")
line_col_blue <- bquote("85% pred. band endpoints")
line_col_red <- bquote("90% pred. band endpoints")
leg_line_labs <- c(line_col_grey, line_col_black, line_col_magenta, line_col_green, line_col_blue, line_col_red)
leg_line_breaks <- c("line_col_grey", "line_col_black", "line_col_magenta", "line_col_green", "line_col_blue", "line_col_red")
leg_line_cols <- c("line_col_grey" = "grey50", "line_col_black" = "black", "line_col_magenta" = "magenta", "line_col_green" = "green",
                  "line_col_blue" = "blue", "line_col_red" = "red")
fill_col_lightgreen <- bquote("80% pred. band")
fill_col_cyan <- bquote("85% pred. band")
fill_col_orangered <- bquote("90% pred. band")
leg_fill_labs <- c(fill_col_lightgreen, fill_col_cyan, fill_col_orangered)
leg_fill_breaks <- c("fill_col_lightgreen", "fill_col_cyan", "fill_col_orangered")
leg_fill_cols <- c("fill_col_lightgreen" = "lightgreen", "fill_col_cyan" = "cyan", "fill_col_orangered" = "orangered")

# Creazione del grafico
Data_df_lp <- ggplot(Data_df, aes(x = x)) + 
 geom_ribbon(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(ymin = Adj_Close_price_cond_080_low_pred_int, ymax = Adj_Close_price_cond_080_upp_pred_int, fill = "fill_col_lightgreen"),
             alpha = 0.3, colour = "lightgreen") +
 geom_ribbon(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(ymin = Adj_Close_price_cond_085_low_pred_int, ymax = Adj_Close_price_cond_080_low_pred_int, fill = "fill_col_cyan"),
             alpha = 0.3, colour = "cyan") +
 geom_ribbon(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(ymin = Adj_Close_price_cond_090_low_pred_int, ymax = Adj_Close_price_cond_085_low_pred_int, fill = "fill_col_orangered"),
             alpha = 0.3, colour = "orangered") +
 geom_ribbon(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(ymin = Adj_Close_price_cond_080_upp_pred_int, ymax = Adj_Close_price_cond_085_upp_pred_int, fill = "fill_col_cyan"),
             alpha = 0.3, colour = "cyan") +
 geom_ribbon(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(ymin = Adj_Close_price_cond_085_upp_pred_int, ymax = Adj_Close_price_cond_090_upp_pred_int, fill = "fill_col_orangered"),
             alpha = 0.3, colour = "orangered") +
 geom_line(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(y = Adj_Close_price_cond_090_upp_pred_int, colour = "line_col_red"),
           linetype = "solid", alpha = 1, linewidth = 1) +
 geom_line(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(y = Adj_Close_price_cond_090_low_pred_int, colour = "line_col_red"),
           linetype = "solid", alpha = 1, linewidth = 1) +
 geom_line(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(y = Adj_Close_price_cond_085_upp_pred_int, colour = "line_col_blue"),
           linetype = "solid", alpha = 1, linewidth = 1) +
 geom_line(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(y = Adj_Close_price_cond_085_low_pred_int, colour = "line_col_blue"),
           linetype = "solid", alpha = 1, linewidth = 1) +
 geom_line(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(y = Adj_Close_price_cond_080_upp_pred_int, colour = "line_col_green"),
           linetype = "solid", alpha = 1, linewidth = 1) +
 geom_line(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(y = Adj_Close_price_cond_080_low_pred_int, colour = "line_col_green"),
           linetype = "solid", alpha = 1, linewidth = 1) +
 geom_line(data = subset(Data_df, (x >= x[which(Data_df$Date == Det_Day)] & x <= x[TrnS_length])), aes(y = y, color = "line_col_grey"),
           linetype = "solid", alpha = 1, linewidth = 0.7, group = 1, na.rm = TRUE) +
 geom_line(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(y = y, color = "line_col_black"), 
           linetype = "solid", alpha = 1, linewidth = 0.7, group = 1, na.rm = TRUE) +
 geom_line(data = subset(Data_df, x >= x[TrnS_length + 1]), aes(y = z, color = "line_col_magenta"),
           linetype = "solid", alpha = 1, linewidth = 0.7, group = 1, na.rm = TRUE) +
 scale_x_continuous(name = "Date", breaks = x_breaks, labels = x_labs, limits = x_lims) +
 scale_y_continuous(name = y_name, breaks = y_breaks, labels = NULL, limits = y_lims, sec.axis = sec_axis(~., breaks = y_breaks, labels = y_labs)) +
 ggtitle(title_content) +
 labs(subtitle = subtitle_content, caption = caption_content) +
 guides(linetype = "none", shape = "none") +
 scale_colour_manual(name = "Legend", labels = leg_line_labs, values = leg_line_cols, breaks = leg_line_breaks) +
 scale_fill_manual(name = "", labels = leg_fill_labs, values = leg_fill_cols, breaks = leg_fill_breaks) +
 guides(colour = guide_legend(order = 1), fill = guide_legend(order = 2)) +
 theme(plot.title = element_text(hjust = 0.5, size = 10), 
       plot.subtitle = element_text(hjust = 0.5, size = 8),
       axis.text.x = element_text(angle = -45, vjust = 1, hjust = -0.3),
       legend.key.width = unit(0.8, "cm"), legend.position = "bottom")

ggsave("plots/spx_daily_price_pred_band_GED_inn_detail.png", Data_df_lp, width = 10, height=6)
# Mostra il grafico
plot(Data_df_lp)
#
# It must be considered that in the above plot while the predicted test set values are correct, the endpoints of the confidence bands have
# been computed under the approximations
# $low(T+t+1,T+t)\approx low(T+1,T) \text{and} $upp(T+t+1,T+t)\approx upp(T+1,T), \forall t=0,\dots\U-1$.
# We should build a complete daily updating estimation procedure for an exact computation of the endpoints of the confidence bands.
################################################################################################################################################
################################################################################################################################################
# In the end, we consider the accuracy of the fGARCH_1_1_ged_shpN_lbfgsb_nm model.
#
Data_df <- spx_df
head(Data_df)
tail(Data_df)
#
Data_df <- dplyr::rename(Data_df, y=log.ret.perc.)
DS_length <- length(na.rm(Data_df$y))
show(DS_length)
# 1870
#
TrnS_length <- length(na.rm(Data_df$y[which(Data_df$Date<=as.Date(TrnS_Last_Day))]))
show(TrnS_length)
# 691
#
# Data_df$Date[TrnS_length+2]
# "2023-01-01"
#
TstS_length <- DS_length-TrnS_length
show(TstS_length)
# 151
#
y_train <- Data_df$y[2:(TrnS_length+1)]
head(y_train,20)
# 3.2535928  1.5906496  6.4376485  0.5608363 -1.0523309  1.4483698  8.2353199 -9.1932107  4.8088210 -3.2239593  3.9429183  0.7523614
# -1.9136041 -1.3240167  1.2739001  5.3537158 -0.4433170  1.6094355 -2.0843383 -2.9620923
#
length(y_train)
# 691
#
y_fit  <- fGARCH_1_1_ged_shpN_lbfgsb_nm_fitted
head(y_fit,20)
# [1]  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
length(y_fit)
# 691
#
y_resid  <- y_train
head(y_resid,20)
# 3.2535928  1.5906496  6.4376485  0.5608363 -1.0523309  1.4483698  8.2353199 -9.1932107  4.8088210 -3.2239593  3.9429183  0.7523614
# -1.9136041 -1.3240167  1.2739001  5.3537158 -0.4433170  1.6094355 -2.0843383 -2.9620923
#
y_test <- Data_df$y[(TrnS_length+1):DS_length]
head(y_test,20)
# -0.33236657  0.46776063  0.38057007 -0.05162549  1.09341539 -0.15728177  0.68207922  0.01834058  0.79930823  0.61485892  1.44181339
#  2.76211505  5.08031805  5.36492128  5.21924405 -0.45631528  1.37377200 -0.03833244 -2.25928311  1.90553341class(y_test)
#
length(y_test)
# 151
#
y_pred <- rep(0,TstS_length)
head(y_pred,20)
# 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
length(y_pred)
# 151
#
y_test_resid <- y_test-y_pred
head(y_test_resid,20)
# -0.33236657  0.46776063  0.38057007 -0.05162549  1.09341539 -0.15728177  0.68207922  0.01834058  0.79930823  0.61485892  1.44181339
#  2.76211505  5.08031805  5.36492128  5.21924405 -0.45631528  1.37377200 -0.03833244 -2.25928311  1.90553341class(y_mean_test_resid)
#
# library(fabletools)
fGARCH_1_1_ged_shpN_lbfgsb_nm_acc <- fabletools::accuracy(y_pred, y_test)
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_acc)
#               ME       RMSE      MAE      MPE   MAPE
# Test set  0.3390455  2.548477  1.764749   100   100
#
# library(DescTools)
fGARCH_1_1_ged_shpN_lbfgsb_nm_SMAPE <- DescTools::SMAPE(y_pred, y_test)
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_SMAPE)
# 2
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_SMAPE_perc <- 100*mean(abs(y_test_resid)/(abs(y_pred)+abs(y_test)))
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_SMAPE_perc)
# 100
#
(fGARCH_1_1_ged_shpN_lbfgsb_nm_SMAPE/2)*100==fGARCH_1_1_ged_shpN_lbfgsb_nm_SMAPE_perc
# TRUE
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_MASE <- fabletools::MASE(y_test_resid, y_train, demean=FALSE, na.rm=TRUE, .period=1)
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_MASE)
# 0.4664513
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_RMSSE <- fabletools::RMSSE(y_test_resid, y_train, demean=FALSE, na.rm=TRUE, .period=1)
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_RMSSE)
# 0.4681793
#
# Note that since a GARCH(1,1) model estimates and predicts zero-valued states, most accuracy metrics perform very poorly. On the contrary,
# the MASE and RMSSE perform very well since they compare the empirical mean of the absolute and squared residuals of the predicted values
# in the test set, respectively, with the empirical mean of the absolute residuals of the values of the lagged states of the training set 
# considered as predictors of the states themselves (random walk prediction). The fact that the percentage returns of the logarithm are 
# weakly correlated inflates the latter average and deflates MASE and RMSSE.
# For instance, in terms of the MASE we have
mean(abs(y_train[-length(y_train)]-y_train[-1]))
# 3.783351
mean(abs(y_test_resid))
# 1.764749
mean(abs(y_test_resid))/mean(abs(y_train[-length(y_train)]-y_train[-1]))
# 0.4664513
#
# For this reason, we believe it is incorrect to carry out standard accuracy tests on trivial estimates and predictions of the model states.
#
# However, rather than predicting the states, the main goal of a GARCH(1,1) is predicting the volatility. Therefore, we should apply the
# accuracy metrics to predict the conditional standard deviation. On the other hand, using our GARCH(1,1) model, we have built the daily 
# estimated and predicted conditional volatility, but we have no clue about the true values of the conditional volatility in the training
# and test set. If we had the intra-days data of the Bitcon logarithm return percentage, we could consider their empirical standard 
# deviation as a proxy of the daily conditional volatility in the test and training set and try to confront such a proxy with the daily 
# estimated and predicted conditional volatility, but we have not intra-days data. Thinking about what we can do, we currently see two
# possibilities. The simplest is to consider the absolute values of the daily logarithm return percentage as proxies for the true values
# of the daily conditional volatility. The more complex is to re-estimate the model on a different time scale, for instance a monthly time 
# scale, and consider the empirical mean of the intra-month daily squared percentage return as proxies for the monthly conditional variance.
# We will consider the first possibility, which actually leads to a more reasonable accuracy evaluation than the one obtained above.
# 
Data_df <- spx_df
head(Data_df)
tail(Data_df)
#
Data_df <- dplyr::rename(Data_df, y=log.ret.perc.)
Data_df <- add_column(Data_df, y_sq=Data_df$y^2, y_sqrt=abs(Data_df$y), .after="y")
head(Data_df,20)
tail(Data_df)
#
y_train <- Data_df$y_sqrt[min(which(!is.na(Data_df$y_sqr))):which(Data_df$Date==TrnS_Last_Day)]
head(y_train,20)
# 3.2535928 1.5906496 6.4376485 0.5608363 1.0523309 1.4483698 8.2353199 9.1932107 4.8088210 3.2239593 3.9429183 0.7523614 1.9136041
# 1.3240167 1.2739001 5.3537158 0.4433170 1.6094355 2.0843383 2.9620923#
length(y_train)
# 691
#
y_fit  <- fGARCH_1_1_ged_shpN_lbfgsb_nm_cond_std_dev
head(y_fit,20)
# 3.751260 3.720987 3.604736 3.919135 3.765245 3.630090 3.515467 4.112250 4.727272 4.721813 4.607029 4.547142 4.356387 4.207146 
# 4.049358 3.900692 4.040850 3.877981 3.751222 3.652842
#
length(y_fit)
# 691
#
y_resid  <- y_train-y_fit[-1]
head(y_resid,20)
# -0.46739427 -2.01408619  2.51851374 -3.20440850 -2.57775874 -2.06709677  4.12306982  4.46593818  0.08700767 -1.38306961 -0.60422378
# -3.60402570 -2.29354147 -2.72534091 -2.62679175  1.31286583 -3.43466414 -2.14178646 -1.56850388 -0.64965556
#
y_test <- Data_df$y_sqrt[which(Data_df$Date==TstS_First_Day):nrow(Data_df)]
head(y_test,20)
# 0.46776063 0.38057007 0.05162549 1.09341539 0.15728177 0.68207922 0.01834058 0.79930823 0.61485892 1.44181339 2.76211505 5.08031805
# 5.36492128 5.21924405 0.45631528 1.37377200 0.03833244 2.25928311 1.90553341 7.26845526
#
length(y_test)
# 151
#
y_pred <- fGARCH_1_1_ged_shpN_lbfgsb_nm_pred_std_dev
head(y_pred,20)
# 2.174446 2.229967 2.283048 2.333878 2.382622 2.429426 2.474418 2.517715 2.559421 2.599628 2.638423 2.675883 2.712079 2.747075 2.780932
# 2.813704 2.845443 2.876197 2.906009 2.934920
#
length(y_pred)
# 151
#
y_test_resid <- y_test-y_pred
head(y_test_resid,20)
# -1.7066855 -1.8493965 -2.2314223 -1.2404627 -2.2253404 -1.7473466 -2.4560777 -1.7184071 -1.9445618 -1.1578149  0.1236918  2.4044349
#  2.6528426  2.4721691 -2.3246164 -1.4399321 -2.8071110 -0.6169138 -1.0004754  4.3335352
#
# library(fabletools)
fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_acc <- fabletools::accuracy(y_pred, y_test)
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_acc)
#               ME      RMSE    MAE      MPE     MAPE
# Test set -1.80114 2.607779 2.342589 -1634.44 1642.694
#
# library(DescTools)
fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_SMAPE <- DescTools::SMAPE(y_pred, y_test)
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_SMAPE)
# 1.015688
fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_SMAPE_perc <- 100*mean(abs(y_test_resid)/(abs(y_pred)+abs(y_test)))
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_SMAPE_perc)
# 50.78442
(fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_SMAPE/2)*100==fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_SMAPE_perc
# TRUE
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_MASE <- fabletools::MASE(y_test_resid, y_train, demean=FALSE, na.rm=TRUE, .period=1)
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_MASE)
# 0.9684431
#
fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_RMSSE <- fabletools::RMSSE(y_test_resid, y_train, demean=FALSE, na.rm=TRUE, .period=1)
show(fGARCH_1_1_ged_shpN_lbfgsb_nm_std_dev_RMSSE)
# 0.7008329
#
############################################################################################################################################
y<-na.rm(y)
# We now estimate the GARCH(1,1) models showing how the options of the fGarch:garchFit() function allow us to consider the possibility that 
# the innovation distribution is a Standardized Student Distribution.
# We recall 
# Let $\nu >0$ and let $f_{\nu}:\mathbb{R}\rightarrow \mathbb{R}$ be the function given by
# \begin{equation}
# f_{\nu}\left(x\right)\overset{\text{def}}{=}
# \frac{\Gamma\left(\frac{\nu+1}{2}\right)}{\sqrt{\pi\nu}\Gamma\left(\frac{\nu}{2}\right)}
# \left(1+\frac{x^{2}}{\nu}\right)^{-\frac{\nu +1}{2}},\quad\forall x\in \mathbb{R},
# \label{Student-t-density-exm-eq}
# \end{equation}
# where $\Gamma :\mathbb{R}_{++}\rightarrow \mathbb{R}$ is the Gamma function. Then, $f_{\nu}$ is a probability density.
# (see https://en.wikipedia.org/wiki/Student%27s_t-distribution)
#
# \begin{definition}[Student's t density]
# \label{Student's t-density-def}
# The probability density $f_{\nu}:\mathbb{R}\rightarrow\mathbb{R}$ given by \ref{Student-t-density-exm-eq} is referred to as 
# \emph{Student's t-density} with $\nu $ degrees of freedom\footnote{Despite the Student's t-density is defined for any $\nu >0$, only 
# integer values of $\nu $ are of simple statistical interpretation.}. A probability distribution with Student's t density, for some degree
# of freedom $\nu $, is called a \emph{Student's t-distribution}. An absolutely continuous random variable with Student's t density is 
# called a \emph{Student's t-random variable.}
# \end{definition}
#
# \begin{proposition}
# We have
# \begin{enumerate}
# \item  
# \[
# \int_{\mathbb{R}}x f_{\nu}\left(x\right)d\mu_{L}\left(x\right)
# =\left\{ 
# \begin{array}{ll}
# \text{undefined,} & \text{if } 0< \nu \leq 1, \\ 
# 0, & \text{if }\nu >1.
# \end{array}
# \right. 
# \]
# 
# \item 
# \[
# \int_{\mathbb{R}}x^{2} f_{\nu }\left(x\right)d\mu_{L}\left(x\right)
# =\left\{ 
# \begin{array}{ll}
# +\infty, & \text{if } 0< \nu \leq 2, \\ 
# \frac{\nu }{\nu -2}, & \text{if } \nu >2.
# \end{array}
# \right. 
# \]
# 
# \item 
# \[
# \int_{\mathbb{R}}x^{3} f_{\nu}\left(x\right)d\mu_{L}\left(x\right)
# =\left\{ 
# \begin{array}{ll}
# \text{undefined,} & \text{if } 0< \nu \leq 3, \\ 
# 0, & \text{if } \nu >3.
# \end{array
# \right. 
# \]
# 
# \item 
# \[
# \int_{\mathbb{R}}x^{4} f_{\nu}\left(x\right)d\mu_{L}\left(x\right)
# =\left\{ 
# \begin{array}{ll}
# +\infty , & \text{if } 0< \nu \leq 4, \\ 
# \frac{3\nu -6}{\nu -4}, & \text{if } \nu >4.
# \end{array}
# \right. 
# \]
# \end{enumerate}
# \end{proposition}
#
# \begin{definition}
# Let $\nu >0$, we call Student's random variable with $\nu $ degrees of freedom the absolutely continuos random variable $X$ with density 
# $f_{X}:\mathbb{R}\rightarrow \mathbb{R}$ given by
# \[
# f_{X}\left(x\right)\overset{\text{def}}{=}f_{\nu}\left(x\right),\quad\forall x\in\mathbb{R}.
# \]
# \end{definition}
#   
# \begin{remark}
# Let $\nu >0$ and let $X$ be Student's random variable with $\nu$ degrees of freedom. We have
# 
# \begin{enumerate}
# \item   
# \begin{equation}
# \mathbf{E}\left[X\right]
# =\left\{ 
# \begin{array}{ll}
# \text{undefined,} & \text{if } 0< \nu \leq 1, \\ 
# 0, & \text{if }\nu >1.
# \end{array}
# \right. 
# \label{Student-t-density-rem-01-eq}
# \end{equation}
# 
# \item 
# \begin{equation}
# \mathbf{D}^{2}\left[X\right]
# =\left\{ 
# \begin{array}{ll}
# \text{undefined,} & \text{if } 0< \nu \leq 1, \\ 
# +\infty, & \text{if } 1< \nu \leq 2, \\ 
# \frac{\nu }{\nu -2}, & \text{if } \nu >1.
# \end{array}
# \right.   
# \label{Student-t-density-rem-02-eq}
# \end{equation}
# 
# \item 
# \begin{equation}
# Skew\left(X\right)
# =\left\{ 
# \begin{array}{ll}
# \text{undefined,} & \text{if } 0< \nu \leq 3, \\ 
# 0, & \text{if } \nu >3.
# \end{array}
# \right.   
# \label{Student-t-density-rem-03-eq}
# \end{equation}
# 
# \item 
# \begin{equation}
# Kurt\left(X\right) 
# =\left\{ 
# \begin{array}{ll}
# \text{undefined,} & \text{if } 0< \nu \leq 2, \\ 
# +\infty , & \text{if } 2<\nu \leq 4, \\ 
# \frac{3\nu -6}{\nu -4}, & \text{if } \nu >4.
# \end{array}
# \right.   
# \label{Student-t-density-rem-04-eq}
# \end{equation}
# Consequently, if $\nu >4$, the kurtosis excess is given by
# \[
# Kurt\left(Y\right)-3=\frac{6}{\nu-4}.
# \]
# \end{enumerate}
# \end{remark}
# 
# Assume $\nu >2$. Despite it is centered, $\mathbf{E}\left[X\right]=0$, Student's random variable $X$ with $\nu $ degrees of freedom is not
# standardized, $\mathbf{D}^{2}\left[X\right]=\frac{\nu}{\nu -2}\neq 1$. In many applications, it is desirable to deal with a standardized
# Student's random variable. To this, it is sufficient to observe that setting
# \[
# Y\overset{\text{def}}{=}\sqrt{\frac{\nu-2}{\nu}}X
# \]
# we obtain an absolutely continuous standardized random variable, in fact
# \[
# \mathbf{E}\left[Y\right]=\sqrt{\frac{\nu-2}{\nu}}\mathbf{E}\left[X\right]=0
# \qquad \text{and}\qquad 
# \mathbf{D}^{2}\left[Y\right]=\frac{\nu-2}{\nu}\mathbf{D}^{2}\left[X\right]=1.
# \]
# On account of Equation (\ref{Student-t-density-exm-eq}), we then obtain that the density $f_{Y}:\mathbb{R}\rightarrow \mathbb{R}$ of the 
# random variable $Y$ is given by%
# \begin{eqnarray*}
# f_{Y}\left(y\right)&=&\frac{d}{dy}\mathbf{P}\left(Y\leq y\right)=\frac{d}{dy}\mathbf{P}\left(\sqrt{\frac{\nu-2}{\nu}}X\leq y\right) 
# =\frac{d}{dy}\mathbf{P}\left(X\leq\sqrt{\frac{\nu}{\nu-2}}y\right)\\
# &=&\frac{d}{dx}\mathbf{P}\left(X\leq x\right)_{x=\sqrt{\frac{\nu}{\nu-2}}y}\frac{d}{dy}\sqrt{\frac{\nu}{\nu-2}}y
# =\sqrt{\frac{\nu}{\nu-2}}f_{\nu}\left(\sqrt{\frac{\nu}{\nu-2}}y\right)\\
# &=&\frac{\Gamma\left(\frac{\nu+1}{2}\right)}{\sqrt{\pi\left(\nu-2\right)}\Gamma\left(\frac{\nu}{2}\right)}
# \left(1+\frac{y^{2}}{\nu-2}\right)^{-\frac{\nu+1}{2}},
# \end{eqnarray*}
# for every $y\in\mathbb{R}$.
# 
# \begin{definition}
# Let $\nu >2$. We call \emph{standardized Student's t-density} with $\nu$ degrees of freedom the function 
# $\tilde{f}_{\nu}:\mathbb{R}\rightarrow\mathbb{R}$ given by
# \[
# \tilde{f}_{\nu}\left(x\right)\overset{\text{def}}{=}
# \frac{\Gamma\left(\frac{\nu+1}{2}\right)}{\sqrt{\pi\left(\nu-2\right)}\Gamma\left(\frac{\nu}{2}\right)}
# \left(1+\frac{x^{2}}{\nu-2}\right)^{-\frac{\nu +1}{2}},\quad \forall x\in \mathbb{R},
# \]
# where $\Gamma:\mathbb{R}_{++}\rightarrow \mathbb{R}$ is the Gamma function. A probability distribution with standardized Student's t 
# density, for some degree of freedom $\nu$, is called a \emph{standardized Student's t-distribution}. An absolutely continuous random 
# variable with standardized Student's t density is called a \emph{standardized Student's t-random variable.}
# \end{definition}
# 
# \begin{proposition}
# Let $\nu >2$ and let $Y$ be standardized Student's t-random variable with $\nu$ degrees of freedom. We have
# \[
# Skew\left(Y\right) 
# =\left\{ 
# \begin{array}{ll}
# \text{undefined,} & \text{if } 0< \nu \leq 3, \\ 
# 0, & \text{if } \nu >3.
# \end{array}
# \right. 
# \]
# and
# \[
# Kurt\left( Y\right)
# =\left\{ 
# \begin{array}{ll}
# +\infty , & \text{if } 2<\nu \leq 4, \\ 
# \frac{\left(\nu-2\right)\left(3\nu-6\right)}{\nu\left(\nu-4\right), & \text{if } \nu >4.
# \end{array}
# \right. 
# \]
# Consequently, if $\nu >4$, the kurtosis excess is given by
# \[
# Kurt\left(Y\right)-3=\frac{12}{\nu\left(\nu-4\right)}.
# \]
# \end{proposition}
# 
# \proof
# We have 
# \[
# Y=\sqrt{\frac{\nu-2}{\nu}}X,
# \]
# where $X$ is Student's t-random variable with $\nu $ degrees of freedom, on account of Equations (\ref{Student-t-density-rem-01-eq})-
# (\ref{Student-t-density-rem-04-eq}), we obtain
# \[
# Skew\left(Y\right)=\frac{\mathbf{E}\left[\left(Y-\mathbf{E}\left[Y\right]\right)^{3}\right]}{\mathbf{D}^{2}\left[Y\right]^{3/2}}
# =\mathbf{E}\left[Y^{3}\right]=\left(\frac{\nu -2}{\nu}\right)^{3/2}\mathbf{E}\left[X^{3}\right]=0
# \]
# and
# \begin{eqnarray*}
# Kurt\left(Y\right)&=&\frac{\mathbf{E}\left[\left(Y-\mathbf{E}\left[Y\right]\right)^{2}\right]}{\mathbf{D}^{2}\left[Y\right]^{2}}
# =\mathbf{E}\left[Y^{4}\right]=\left(\frac{\nu-2}{\nu}\right)^{2}\mathbf{E}\left[X^{4}\right]\\
# &=&\left(\frac{\nu-2}{\nu}\right)^{2}\mathbf{E}\left[\left(X-\mathbf{E}\left[X\right]\right)^{4}\right]
# =\left(\frac{\nu-2}{\nu}\right)^{2}Kurt\left(X\right)\mathbf{D}^{2}\left[X\right]^{2}\\
# &=&\left(\frac{\nu-2}{\nu}\right)^{2}\frac{3\nu-6}{\nu-4}\frac{\nu}{\nu-2} \\
# &=&\frac{\left(\nu-2\right)\left(3\nu-6\right)}{\nu\left(\nu-4\right)}.
# \end{eqnarray*}
# 
# What we have showed above is a sketch of standardized Student's t-distribution (STD) and its relationship with Student's t-distribution
# Now, we show how to fit a GARCH(1,1) model endowed with an SDD as the innovation distribution to our data. To this, we call for the 
# options cond.dist="std", include.shape=NULL, algorithm="lbfgsb". Note that the "shape" parameters stands for the degrees of freedom 
# parameters.
fGARCH_1_1_std_lbfgsb <- fGarch::garchFit(formula=~garch(1,1), data=na.rm(y), init.rec="mci", cond.dist="std", include.mean=FALSE,
                                          include.skew=FALSE, include.shape=NULL, trace=TRUE, algorithm="lbfgsb") #NOTA: ho rimosso na dal vettore y
# Extracted from the output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          std
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#              U           V     params includes
# mu     -0.11481907   0.1148191    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0     TRUE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1  shape 
#    2      3      5      8 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: lbfgsb 
# 
# R coded optim[L-BFGS-B] Solver: 
# iter   10 value 2145.982990
# iter   20 value 2134.194155
#    final  value 2133.847758 
# converged
# 
# Final Estimate of the Negative LLH: 4403.518  norm LLH: 2.561674 
#   omega    alpha1     beta1     shape 
# 0.1033955 0.1178320 0.9208707 2.6693898 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#          omega     alpha1      beta1      shape
# omega   -434.978  -2502.788  -5390.238  -299.2810
# alpha1 -2502.788 -23468.964 -42971.108 -2743.8483
# beta1  -5390.238 -42971.108 -88431.138 -5054.5352
# shape   -299.281  -2743.848  -5054.535  -346.1158
# attr(,"time")
# Time difference of 0.02455497 secs
# 
# --- END OF TRACE ---
#   
summary(fGARCH_1_1_std_lbfgsb)
# Extracted from the output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula = ~garch(1, 1), data = y, init.rec = "mci", cond.dist = "std", include.mean = FALSE, include.skew = FALSE, 
#                        include.shape = NULL, trace = TRUE, algorithm = "lbfgsb") 
#
# Conditional Distribution: std 
# Coefficient(s):
#   omega   alpha1    beta1    shape  
# 0.10340  0.11783  0.92087  2.66939  
# 
# Std. Errors: based on Hessian 
# Error Analysis: Estimate  Std. Error  t value Pr(>|t|)    
#        omega    0.10340     0.09975    1.037      0.3    
#        alpha1   0.11783     0.03027    3.893 9.89e-05 ***
#        beta1    0.92087     0.01305   70.557  < 2e-16 ***
#        shape    2.66939     0.19977   13.362  < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -4403.518    normalized:  -2.561674 
# 
# Standardised Residuals Tests:
#                                  Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  3.731606e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.555853e-01 0.0000000
# Ljung-Box Test     R    Q(10)  1.125377e+01 0.3380915
# Ljung-Box Test     R    Q(15)  1.429699e+01 0.5031341
# Ljung-Box Test     R    Q(20)  1.778492e+01 0.6015744
# Ljung-Box Test     R^2  Q(10)  2.970235e+00 0.9821159
# Ljung-Box Test     R^2  Q(15)  3.831154e+00 0.9982397
# Ljung-Box Test     R^2  Q(20)  5.421118e+00 0.9994835
# LM Arch Test       R    TR^2   3.421267e+00 0.9917683
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.128002 5.140682 5.127991 5.132694 
#
# Uncomment and execute the following line
# plot(fGARCH_1_1_std_lbfgsb)
#
# Differently of the GED case, the option include.shape=NULL leads to an estimate of the shape parameter. Eventually, the shape parameter
# moves from the initial value shape=4.0 to the value shape=2.66939, which is inside the interval [1.0  10.0], where the shape seems to be
# constrained to vary. Moreover, the estimation procedure stops signaling convergence. In light of this, we can validate the estimated model
# until the analysis of the standardized residuals is carried out.
# In this case, the addition of the Nelder-Mead algorithm does not seem to improve the estimation of the model significantly, in terms of 
# the information criteria. 
fGARCH_1_1_std_lbfgsb_nm <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="std", include.mean=FALSE,
                                             include.skew=FALSE, include.shape=NULL, trace=TRUE, algorithm="lbfgsb+nm")
# Extracted from the output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          std
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#             U           V      params includes
# mu     -0.11481907   0.1148191    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0     TRUE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1  shape 
#     2      3      5      8 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: lbfgsb+nm 
# 
# R coded optim[L-BFGS-B] Solver: 
# iter   10 value 2145.982990
# iter   20 value 2134.194155
#    final  value 2133.847758 
# converged
# 
# R coded Nelder-Mead Hybrid Solver: 
# Nelder-Mead direct search function minimizer
# function value for initial parameters = 1.000000
# Scaled convergence tolerance is 1e-11
# Stepsize computed as 0.100000
# BUILD              5 5.591365 1.000000
# LO-REDUCTION       7 1.053826 1.000000
# HI-REDUCTION       9 1.022038 1.000000
# HI-REDUCTION      11 1.008815 1.000000
# HI-REDUCTION      13 1.003764 1.000000
# LO-REDUCTION      15 1.003638 1.000000
# HI-REDUCTION      17 1.003006 1.000000
# HI-REDUCTION      19 1.001183 1.000000
# LO-REDUCTION      21 1.001142 1.000000
# HI-REDUCTION      23 1.000693 1.000000
# HI-REDUCTION      25 1.000450 1.000000
# LO-REDUCTION      27 1.000278 1.000000
# HI-REDUCTION      29 1.000237 1.000000
# LO-REDUCTION      31 1.000164 1.000000
# LO-REDUCTION      33 1.000099 1.000000
# HI-REDUCTION      35 1.000043 1.000000
# HI-REDUCTION      37 1.000033 1.000000
# LO-REDUCTION      39 1.000031 1.000000
# LO-REDUCTION      41 1.000020 1.000000
# HI-REDUCTION      43 1.000013 1.000000
# HI-REDUCTION      45 1.000010 1.000000
# LO-REDUCTION      47 1.000008 1.000000
# LO-REDUCTION      49 1.000006 1.000000
# HI-REDUCTION      51 1.000003 1.000000
# HI-REDUCTION      53 1.000003 1.000000
# HI-REDUCTION      55 1.000002 1.000000
# LO-REDUCTION      57 1.000001 1.000000
# LO-REDUCTION      59 1.000001 1.000000
# LO-REDUCTION      61 1.000001 1.000000
# LO-REDUCTION      63 1.000001 1.000000
# LO-REDUCTION      65 1.000000 1.000000
# HI-REDUCTION      67 1.000000 1.000000
# LO-REDUCTION      69 1.000000 1.000000
# HI-REDUCTION      71 1.000000 1.000000
# LO-REDUCTION      73 1.000000 1.000000
# LO-REDUCTION      75 1.000000 1.000000
# LO-REDUCTION      77 1.000000 1.000000
# HI-REDUCTION      79 1.000000 1.000000
# HI-REDUCTION      81 1.000000 1.000000
# LO-REDUCTION      83 1.000000 1.000000
# HI-REDUCTION      85 1.000000 1.000000
# LO-REDUCTION      87 1.000000 1.000000
# HI-REDUCTION      89 1.000000 1.000000
# HI-REDUCTION      91 1.000000 1.000000
# HI-REDUCTION      93 1.000000 1.000000
# HI-REDUCTION      95 1.000000 1.000000
# HI-REDUCTION      97 1.000000 1.000000
# LO-REDUCTION      99 1.000000 1.000000
# HI-REDUCTION     101 1.000000 1.000000
# HI-REDUCTION     103 1.000000 1.000000
# HI-REDUCTION     105 1.000000 1.000000
# LO-REDUCTION     107 1.000000 1.000000
# REFLECTION       109 1.000000 1.000000
# REFLECTION       111 1.000000 1.000000
# REFLECTION       113 1.000000 1.000000
# LO-REDUCTION     115 1.000000 1.000000
# HI-REDUCTION     117 1.000000 1.000000
# LO-REDUCTION     119 1.000000 1.000000
# REFLECTION       121 1.000000 1.000000
# LO-REDUCTION     123 1.000000 1.000000
# HI-REDUCTION     125 1.000000 1.000000
# LO-REDUCTION     127 1.000000 1.000000
# LO-REDUCTION     129 1.000000 1.000000
# REFLECTION       131 1.000000 1.000000
# REFLECTION       133 1.000000 1.000000
# LO-REDUCTION     135 1.000000 1.000000
# REFLECTION       137 1.000000 1.000000
# LO-REDUCTION     139 1.000000 1.000000
# HI-REDUCTION     141 1.000000 1.000000
# Exiting from Nelder Mead minimizer
# 143 function evaluations used
# 
# Final Estimate of the Negative LLH: 4403.517  norm LLH: 2.561674 
#   omega    alpha1     beta1     shape 
# 0.1027144 0.1177161 0.9210094 2.6689599 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#           omega     alpha1      beta1      shape
# omega   -436.2331  -2509.829  -5406.431  -299.9298
# alpha1 -2509.8286 -23533.520 -43109.744 -2750.3519
# beta1  -5406.4307 -43109.744 -88756.947 -5067.8954
# shape   -299.9298  -2750.352  -5067.895  -346.6437
# 
# --- END OF TRACE ---
#   
summary(fGARCH_1_1_std_lbfgsb_nm)
# Extracted from the output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula=~garch(1, 1), data=y, init.rec="mci", cond.dist="std", include.mean=FALSE, include.skew=FALSE, 
#                        include.shape=NULL, trace=TRUE, algorithm="lbfgsb+nm") 
# 
# Conditional Distribution: std 
# Coefficient(s):
#   omega   alpha1    beta1    shape  
# 0.10271  0.11772  0.92101  2.66896  
# 
# Std. Errors: based on Hessian 
# Error Analysis:   Estimate  Std. Error  t value Pr(>|t|)    
#           omega    0.10271     0.09949    1.032 0.301874    
#           alpha1   0.11772     0.03030    3.885 0.000102 ***
#           beta1    0.92101     0.01301   70.777  < 2e-16 ***
#           shape    2.66896     0.20019   13.332  < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -4403.517    normalized:  -2.561674 
# 
# Standardised Residuals Tests:  
#                                 Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  3.738131e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.555013e-01 0.0000000
# Ljung-Box Test     R    Q(10)  1.126136e+01 0.3375214
# Ljung-Box Test     R    Q(15)  1.430669e+01 0.5024074
# Ljung-Box Test     R    Q(20)  1.779663e+01 0.6008034
# Ljung-Box Test     R^2  Q(10)  2.969639e+00 0.9821296
# Ljung-Box Test     R^2  Q(15)  3.829960e+00 0.9982429
# Ljung-Box Test     R^2  Q(20)  5.418338e+00 0.9994855
# LM Arch Test       R    TR^2   3.420234e+00 0.9917797
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.128002 5.140682 5.127991 5.132693 
#
# Uncomment and execute the following line
# plot(fGARCH_1_1_std_lbfgsb_nm)
#
# Using the algorithm="nlminb" option instead of algorithm="lbfgsb" also does not significantly improve the estimated model.
fGARCH_1_1_std_nlminb <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="std", include.mean=FALSE,
                                          include.skew=FALSE, include.shape=NULL, trace=TRUE, algorithm="nlminb")
# Extracted from the output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          std
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#              U           V      params includes
# mu     -0.11481907   0.1148191    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0     TRUE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1  shape 
#     2      3      5      8 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: nlminb 
# 
# R coded nlminb Solver: 
#  0:     2166.8019: 0.100000 0.100000 0.800000  4.00000
#  1:     2163.9611: 0.0925081 0.0982472 0.796361  3.99968
#  2:     2162.6310: 0.0841100 0.0993312 0.795590  3.99918
#  3:     2160.3831: 0.0737033 0.116371 0.811255  3.99771
#  4:     2156.9250: 0.0492961 0.117007 0.817988  3.99552
#  5:     2153.2164: 0.0411887 0.115623 0.841878  3.99272
#  6:     2148.8521: 0.00198487 0.0888775 0.908399  3.98451
#  7:     2146.9054: 0.00585009 0.0894885 0.909758  3.98447
#  8:     2146.3435: 0.00528484 0.0855973 0.910473  3.98338
#  9:     2146.0196: 0.00727409 0.0828414 0.912598  3.98233
# 10:     2145.6525: 0.00616466 0.0793013 0.913834  3.98096
# 11:     2145.4390: 0.00694751 0.0767708 0.916409  3.97909
# 12:     2145.3123: 0.00628419 0.0739889 0.917852  3.97646
# 13:     2145.2011: 0.00687330 0.0731341 0.919087  3.97265
# 14:     2145.1223: 0.00671596 0.0727223 0.918835  3.96854
# 15:     2145.0569: 0.00721605 0.0728025 0.918741  3.96442
# 16:     2138.6380: 0.00558378 0.0839803 0.917021  3.39318
# 17:     2137.8474: 0.00368455 0.0757072 0.929204  3.31762
# 18:     2137.5741: 0.00838200 0.0742097 0.922741  3.24105
# 19:     2137.4517: 0.0137726 0.0882678 0.913868  3.20690
# 20:     2136.6462: 0.0112490 0.0881200 0.913348  3.18790
# 21:     2136.3684: 0.00886256 0.0900787 0.917319  3.16940
# 22:     2136.1436: 0.00722092 0.0894663 0.917423  3.15030
# 23:     2134.5372: 0.00266284 0.0938649 0.929848  2.82789
# 24:     2134.0740: 0.00536045 0.103081 0.924364  2.76431
# 25:     2134.0239: 0.00630563 0.103571 0.925093  2.76433
# 26:     2133.9936: 0.00603790 0.103614 0.924679  2.76314
# 27:     2133.9813: 0.00652593 0.104163 0.923626  2.76301
# 28:     2133.9744: 0.00663740 0.104439 0.923668  2.76175
# 29:     2133.9538: 0.00643931 0.107781 0.922157  2.76131
# 30:     2133.8743: 0.00706778 0.116192 0.921317  2.66789
# 31:     2133.8543: 0.00711097 0.114660 0.921475  2.69093
# 32:     2133.8492: 0.00722944 0.116210 0.921230  2.67882
# 33:     2133.8478: 0.00732191 0.117566 0.921029  2.66935
# 34:     2133.8477: 0.00732747 0.117686 0.921013  2.66902
# 35:     2133.8477: 0.00732756 0.117715 0.921009  2.66893
# 36:     2133.8477: 0.00732729 0.117715 0.921009  2.66892
# 
# Final Estimate of the Negative LLH: 4403.517 norm LLH: 2.561674 
#   omega    alpha1     beta1     shape 
# 0.1027492 0.1177153 0.9210091 2.6689227 
# 
# R-optimhess Difference Approximated Hessian Matrix:
# omega     alpha1      beta1      shape
# omega   -436.1628  -2509.639  -5406.033  -299.9415
# alpha1 -2509.6387 -23532.806 -43108.058 -2750.4995
# beta1  -5406.0333 -43108.058 -88753.670 -5068.2272
# shape   -299.9415  -2750.499  -5068.227  -346.7058
# 
# --- END OF TRACE ---
#
summary(fGARCH_1_1_std_nlminb)
# Extracted from the output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula = ~garch(1, 1), data = y, init.rec = "mci", cond.dist = "std", include.mean = FALSE, include.skew = FALSE, 
#                       include.shape = NULL, trace = TRUE, algorithm = "nlminb") 
# 
# Conditional Distribution: std 
# Coefficient(s):
#   omega   alpha1    beta1    shape  
# 0.10275  0.11772  0.92101  2.66892  
# 
# Std. Errors: based on Hessian 
# Error Analysis:  Estimate  Std. Error  t value Pr(>|t|)    
#         omega    0.10275     0.09950    1.033 0.301789    
#         alpha1   0.11772     0.03029    3.886 0.000102 ***
#         beta1    0.92101     0.01301   70.775  < 2e-16 ***
#         shape    2.66892     0.20013   13.336  < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -4403.517    normalized:  -2.561674 
# 
# Standardised Residuals Tests:
#                                  Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  3.737938e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.555064e-01 0.0000000
# Ljung-Box Test     R    Q(10)  1.126097e+01 0.3375512
# Ljung-Box Test     R    Q(15)  1.430629e+01 0.5024377
# Ljung-Box Test     R    Q(20)  1.779611e+01 0.6008376
# Ljung-Box Test     R^2  Q(10)  2.969690e+00 0.9821284
# Ljung-Box Test     R^2  Q(15)  3.829994e+00 0.9982428
# Ljung-Box Test     R^2  Q(20)  5.418363e+00 0.9994855
# LM Arch Test       R    TR^2   3.420266e+00 0.9917794
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.128002 5.140682 5.127991 5.132693 
#
# Uncomment and execute the following line
# plot(fGARCH_1_1_std_nlminb)
#
# Neither do we have significant improvement invoking the algorithm="nlminb+nm" option.
fGARCH_1_1_std_nlminb_nm <- fGarch::garchFit(formula=~garch(1,1), data=y, init.rec="mci", cond.dist="std", include.mean=FALSE,
                                             include.skew=FALSE, include.shape=NULL, trace=TRUE, algorithm="nlminb+nm")
# Extracted from the output.
# Series Initialization:
# ARMA Model:                arma
# Formula Mean:              ~ arma(0, 0)
# GARCH Model:               garch
# Formula Variance:          ~ garch(1, 1)
# ARMA Order:                0 0
# Max ARMA Order:            0
# GARCH Order:               1 1
# Max GARCH Order:           1
# Maximum Order:             1
# Conditional Dist:          std
# h.start:                   2
# llh.start:                 1
# Length of Series:          691
# Recursion Init:            mci
# Series Scale:              3.744706
# 
# Parameter Initialization:
# Initial Parameters:          $params
# Limits of Transformations:   $U, $V
# Which Parameters are Fixed?  $includes
# Parameter Matrix:
#   U           V params includes
# mu     -0.11481907   0.1148191    0.0    FALSE
# omega   0.00000100 100.0000000    0.1     TRUE
# alpha1  0.00000001   1.0000000    0.1     TRUE
# gamma1 -0.99999999   1.0000000    0.1    FALSE
# beta1   0.00000001   1.0000000    0.8     TRUE
# delta   0.00000000   2.0000000    2.0    FALSE
# skew    0.10000000  10.0000000    1.0    FALSE
# shape   1.00000000  10.0000000    4.0     TRUE
# Index List of Parameters to be Optimized:
#   omega alpha1  beta1  shape 
#     2      3      5      8 
# Persistence:                  0.9 
# 
# --- START OF TRACE ---
#   Selected Algorithm: nlminb+nm 
# 
#  R coded nlminb Solver: 
#  0:     2166.8019: 0.100000 0.100000 0.800000  4.00000
#  1:     2163.9611: 0.0925081 0.0982472 0.796361  3.99968
#  2:     2162.6310: 0.0841100 0.0993312 0.795590  3.99918
#  3:     2160.3831: 0.0737033 0.116371 0.811255  3.99771
#  4:     2156.9250: 0.0492961 0.117007 0.817988  3.99552
#  5:     2153.2164: 0.0411887 0.115623 0.841878  3.99272
#  6:     2148.8521: 0.00198487 0.0888775 0.908399  3.98451
#  7:     2146.9054: 0.00585009 0.0894885 0.909758  3.98447
#  8:     2146.3435: 0.00528484 0.0855973 0.910473  3.98338
#  9:     2146.0196: 0.00727409 0.0828414 0.912598  3.98233
# 10:     2145.6525: 0.00616466 0.0793013 0.913834  3.98096
# 11:     2145.4390: 0.00694751 0.0767708 0.916409  3.97909
# 12:     2145.3123: 0.00628419 0.0739889 0.917852  3.97646
# 13:     2145.2011: 0.00687330 0.0731341 0.919087  3.97265
# 14:     2145.1223: 0.00671596 0.0727223 0.918835  3.96854
# 15:     2145.0569: 0.00721605 0.0728025 0.918741  3.96442
# 16:     2138.6380: 0.00558378 0.0839803 0.917021  3.39318
# 17:     2137.8474: 0.00368455 0.0757072 0.929204  3.31762
# 18:     2137.5741: 0.00838200 0.0742097 0.922741  3.24105
# 19:     2137.4517: 0.0137726 0.0882678 0.913868  3.20690
# 20:     2136.6462: 0.0112490 0.0881200 0.913348  3.18790
# 21:     2136.3684: 0.00886256 0.0900787 0.917319  3.16940
# 22:     2136.1436: 0.00722092 0.0894663 0.917423  3.15030
# 23:     2134.5372: 0.00266284 0.0938649 0.929848  2.82789
# 24:     2134.0740: 0.00536045 0.103081 0.924364  2.76431
# 25:     2134.0239: 0.00630563 0.103571 0.925093  2.76433
# 26:     2133.9936: 0.00603790 0.103614 0.924679  2.76314
# 27:     2133.9813: 0.00652593 0.104163 0.923626  2.76301
# 28:     2133.9744: 0.00663740 0.104439 0.923668  2.76175
# 29:     2133.9538: 0.00643931 0.107781 0.922157  2.76131
# 30:     2133.8743: 0.00706778 0.116192 0.921317  2.66789
# 31:     2133.8543: 0.00711097 0.114660 0.921475  2.69093
# 32:     2133.8492: 0.00722944 0.116210 0.921230  2.67882
# 33:     2133.8478: 0.00732191 0.117566 0.921029  2.66935
# 34:     2133.8477: 0.00732747 0.117686 0.921013  2.66902
# 35:     2133.8477: 0.00732756 0.117715 0.921009  2.66893
# 36:     2133.8477: 0.00732729 0.117715 0.921009  2.66892
# 
# R coded Nelder-Mead Hybrid Solver: 
# Nelder-Mead direct search function minimizer
# function value for initial parameters = 1.000000
# Scaled convergence tolerance is 1e-11
# Stepsize computed as 0.100000
# BUILD              5 5.639129 1.000000
# LO-REDUCTION       7 1.053919 1.000000
# HI-REDUCTION       9 1.022077 1.000000
# HI-REDUCTION      11 1.008829 1.000000
# HI-REDUCTION      13 1.003768 1.000000
# LO-REDUCTION      15 1.003645 1.000000
# HI-REDUCTION      17 1.003003 1.000000
# HI-REDUCTION      19 1.001181 1.000000
# LO-REDUCTION      21 1.001137 1.000000
# HI-REDUCTION      23 1.000695 1.000000
# HI-REDUCTION      25 1.000446 1.000000
# LO-REDUCTION      27 1.000275 1.000000
# HI-REDUCTION      29 1.000233 1.000000
# LO-REDUCTION      31 1.000163 1.000000
# HI-REDUCTION      33 1.000097 1.000000
# HI-REDUCTION      35 1.000050 1.000000
# LO-REDUCTION      37 1.000032 1.000000
# LO-REDUCTION      39 1.000029 1.000000
# HI-REDUCTION      41 1.000021 1.000000
# HI-REDUCTION      43 1.000009 1.000000
# LO-REDUCTION      45 1.000008 1.000000
# LO-REDUCTION      47 1.000007 1.000000
# HI-REDUCTION      49 1.000006 1.000000
# HI-REDUCTION      51 1.000003 1.000000
# LO-REDUCTION      53 1.000003 1.000000
# LO-REDUCTION      55 1.000002 1.000000
# HI-REDUCTION      57 1.000002 1.000000
# LO-REDUCTION      59 1.000001 1.000000
# LO-REDUCTION      61 1.000001 1.000000
# LO-REDUCTION      63 1.000001 1.000000
# LO-REDUCTION      65 1.000000 1.000000
# LO-REDUCTION      67 1.000000 1.000000
# LO-REDUCTION      69 1.000000 1.000000
# LO-REDUCTION      71 1.000000 1.000000
# HI-REDUCTION      73 1.000000 1.000000
# HI-REDUCTION      75 1.000000 1.000000
# LO-REDUCTION      77 1.000000 1.000000
# LO-REDUCTION      79 1.000000 1.000000
# LO-REDUCTION      81 1.000000 1.000000
# LO-REDUCTION      83 1.000000 1.000000
# LO-REDUCTION      85 1.000000 1.000000
# LO-REDUCTION      87 1.000000 1.000000
# LO-REDUCTION      89 1.000000 1.000000
# HI-REDUCTION      91 1.000000 1.000000
# LO-REDUCTION      93 1.000000 1.000000
# LO-REDUCTION      95 1.000000 1.000000
# LO-REDUCTION      97 1.000000 1.000000
# LO-REDUCTION      99 1.000000 1.000000
# LO-REDUCTION     101 1.000000 1.000000
# LO-REDUCTION     103 1.000000 1.000000
# LO-REDUCTION     105 1.000000 1.000000
# LO-REDUCTION     107 1.000000 1.000000
# LO-REDUCTION     109 1.000000 1.000000
# LO-REDUCTION     111 1.000000 1.000000
# HI-REDUCTION     113 1.000000 1.000000
# LO-REDUCTION     115 1.000000 1.000000
# HI-REDUCTION     117 1.000000 1.000000
# LO-REDUCTION     119 1.000000 1.000000
# LO-REDUCTION     121 1.000000 1.000000
# LO-REDUCTION     123 1.000000 1.000000
# LO-REDUCTION     125 1.000000 1.000000
# Exiting from Nelder Mead minimizer
# 127 function evaluations used
# 
# Final Estimate of the Negative LLH: 4403.517  norm LLH: 2.561674 
#   omega    alpha1     beta1     shape 
# 0.1027492 0.1177153 0.9210091 2.6689227 
# 
# R-optimhess Difference Approximated Hessian Matrix:
#            omega     alpha1      beta1      shape
# omega   -436.1628  -2509.639  -5406.033  -299.9415
# alpha1 -2509.6387 -23532.806 -43108.058 -2750.4995
# beta1  -5406.0333 -43108.058 -88753.670 -5068.2272
# shape   -299.9415  -2750.499  -5068.227  -346.7058
# 
# --- END OF TRACE ---
#
summary(fGARCH_1_1_std_nlminb_nm)
# Extracted from the output.
# Title: GARCH Modelling 
# Call: fGarch::garchFit(formula=~garch(1, 1), data=y, init.rec="mci", cond.dist="std", include.mean=FALSE, include.skew=FALSE, 
#                    include.shape=NULL, trace=TRUE, algorithm="nlminb+nm") 
# 
# Conditional Distribution: std 
# Coefficient(s):
#   omega   alpha1    beta1    shape  
# 0.10275  0.11772  0.92101  2.66892  
# 
# Std. Errors: based on Hessian 
# Error Analysis: Estimate  Std. Error  t value Pr(>|t|)    
#         omega    0.10275     0.09950    1.033 0.301789    
#         alpha1   0.11772     0.03029    3.886 0.000102 ***
#         beta1    0.92101     0.01301   70.775  < 2e-16 ***
#         shape    2.66892     0.20013   13.336  < 2e-16 ***
#   ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Log Likelihood: -4403.517    normalized:  -2.561674 
# 
# Standardised Residuals Tests:
#                                  Statistic   p-Value
# Jarque-Bera Test   R    Chi^2  3.737938e+04 0.0000000
# Shapiro-Wilk Test  R    W      8.555064e-01 0.0000000
# Ljung-Box Test     R    Q(10)  1.126097e+01 0.3375512
# Ljung-Box Test     R    Q(15)  1.430629e+01 0.5024377
# Ljung-Box Test     R    Q(20)  1.779611e+01 0.6008376
# Ljung-Box Test     R^2  Q(10)  2.969690e+00 0.9821284
# Ljung-Box Test     R^2  Q(15)  3.829994e+00 0.9982428
# Ljung-Box Test     R^2  Q(20)  5.418363e+00 0.9994855
# LM Arch Test       R    TR^2   3.420266e+00 0.9917794
# 
# Information Criterion Statistics:
#   AIC      BIC      SIC     HQIC 
# 5.128002 5.140682 5.127991 5.132693
#
# Uncomment and execute the following line
#plot(fGARCH_1_1_std_nlminb_nm)


























###############################################################################################################################################
################################################## Caricamento dati opzioni put e call ########################################################
###############################################################################################################################################
#nome cartella relativa alle opzioni
optionsfolder<-"options"
#nome cartella contenente dati puts
putsfolder<-"puts"
#nome cartella contenente dati calls
callsfolder<-"calls"
plotfolder <- "plots"
fedinvestfolder <- "fedinvest"

#percorso dei file opzioni put
puts_path <- file.path(WD,putsfolder)
#percorso file opzioni call
calls_path <- file.path(WD,callsfolder)
plot_path <- file.path(WD, plotfolder)
#prendo file relativi puts
puts_files <- sort(list.files(path = puts_path, pattern = "SPX_Opt_puts_", full.names = TRUE))

#ciclo su file relativi a opzioni puts per costruire la tabella straddle (put e call)
for (file in puts_files){
  nome_file<-basename(file)
  #estraggo la data del file dal nome
  extracted_date<-extract_date_from_filename(nome_file)
  #leggo dati dal file puts
  put_data<-read_excel(file)
  
  #leggo file call con la stessa data del file da cui ho preso i dati delle put
  call_data<-read_excel(paste0(calls_path,"/SPX_Opt_calls_",extracted_date,".xlsx"))

  # Unisci i dati in base allo Strike
  combined_data <- merge(call_data, put_data, by = "Strike", suffixes = c("_Call", "_Put"))
  # Rimuovi le righe con tutti NA
  combined_data <- combined_data[complete.cases(combined_data), ]
  #ordino in base allo Strike (order ritorna gli indici delle righe, l'istruzione dopo le ordina)
  sorted_indices<-order(combined_data$Strike)
  combined_data<-combined_data[sorted_indices,]
  
  #path dove salvare i dati straddle
  opt_path <- file.path(WD, optionsfolder, paste0("SPX_Opt_",extracted_date,".csv"))
  
  #salvo dati straddle su un file csv
  write.csv(combined_data, file = opt_path, row.names = FALSE, quote=FALSE)
}

###### Plot dei vari strike appena scaricati ####


#mi metto nella sottocartella "options" e prelevo tutti i file posseduti contenenti le options di JDX
options_path <- file.path(WD,optionsfolder)
option_files <- sort(list.files(path = options_path, pattern = "SPX_Opt_", full.names = TRUE))

# index day è associato al "giorno" dell'osservazione, strike_values conterrà gli strike che osserverò
index_day<-0
strike_values <- c()



strike_file <- file.path(WD,optionsfolder, "StrikeStory.csv") #qui scriverò la "storia" dei vari strike

# Loop attraverso i file CSV
for (file in option_files) {
  
  # Estrai la parte variabile (data) dal nome del file
  nome_file <- basename(file)
  parte_variabile <- extract_date_from_filename(nome_file)
  
  # Converti la parte variabile in un valore "data" e aggiorna la variabile data_variabile
  data_variabile <- as.Date(parte_variabile)
  
  # Leggi i dati dal file CSV
  dati <- read.csv(file)
  head(dati)
  
  # Converti le colonne in numerico, gestendo i NA
  dati$LastPr_Call <- as.numeric(as.character(dati$LastPr_Call))
  dati$Vol_Call <- as.numeric(as.character(dati$Vol_Call))
  dati$LastPr_Put <- as.numeric(as.character(dati$LastPr_Put))
  dati$Vol_Put <- as.numeric(as.character(dati$Vol_Put))
  dati$Strike <- as.numeric(as.character(dati$Strike))
  dati$LastTrTime_Call <- as.Date(dati$LastTrTime_Call, format= "%m/%d/%Y %I:%M %p")
  dati$LastTrTime_Put <- as.Date(dati$LastTrTime_Put, format= "%m/%d/%Y %I:%M %p")
  
  # Salvataggio del data frame in un file CSV
  write.csv(dati, file = file, quote=FALSE,row.names = FALSE)
  
  head(dati)
  
  # Rimuovi le righe con LastPr_Call uguale a NA
  dati <- dati[!is.na(dati$LastPr_Call), ]

  
  if (index_day == 0) {
    col_name <- "Strike"
    strike_values <<- c(strike_values, dati[col_name]) #prelevo tutti gli strike non nulli
  } #adesso prendo i "last price Call"
  
  print(strike_values)
  
  call_last_pr_values <- c()
  col_name_2 <- "LastPr_Call"
  
  for (val in unlist(strike_values)){  
    # Filtra le righe utilizzando la notazione standard di R
    filtered_rows <- dati[dati[[col_name]] == val, ]
    
    # Controlla il numero di righe in filtered_rows
    if (nrow(filtered_rows) > 0) {
      call_last_pr_values <- c(call_last_pr_values, filtered_rows[[col_name_2]])
    } else {
      # Se non ci sono righe corrispondenti, aggiungi un NA
      call_last_pr_values <- c(call_last_pr_values, NA)
    }
    
  }
  
  nrow(call_last_pr_values)
  
  if (index_day == 0){ # se index_day == 0, vuol dire che sto cercando gli strike, allora sono all'inizio, quindi creo lo strike_frame
    
    strike_frame <- data.frame(call_last_pr_values)
    
  } else{ #lo strike_frame già esiste, devo solo aggiornarlo
    
    strike_frame <- cbind(strike_frame,call_last_pr_values)
  }
  
  index_day <- index_day + 1 #aggiorno l'indice dei giorni passati
  
  write.csv(strike_frame, file = strike_file, row.names = FALSE)
  
}


varianze <- apply(strike_frame, 1, sd)
print(varianze)
clean_strike_frame <- subset(strike_frame, varianze >0.4)
print(clean_strike_frame)


# Grafico di tutti gli strike in funzione di lastCallPrice di un dataset ########

png("plots/evoluzione_last_call_price.png", width=800, height=600)

plot(1, 1, type = "n", xlim = c(0,ncol(strike_frame)), ylim = c(min(strike_frame), max(strike_frame)), 
     xlab = "Giorni dall'osservazione iniziale", ylab = "LastCallPrice", 
     main = "Evoluzione del lastCallPrice")


# Aggiunta delle linee per ogni riga del dataframe
for (i in 1:nrow(strike_frame)) {
  lines(0:(ncol(strike_frame)-1), strike_frame[i,], col = i)
}

num_colonne <- 9 # Scegli il numero di colonne che desideri
num_righe <- ceiling(length(unlist(strike_values)) / num_colonne) # Calcola il numero di righe

# Crea una matrice
strike_matrix <- matrix(c(unlist(strike_values), rep(NA, num_colonne * num_righe - length(unlist(strike_values)))), nrow = num_righe, byrow = TRUE)

# Crea la legenda
strike_legend <- as.vector(strike_matrix)


# Posizione della legenda e creazione
legend("topleft", legend = strike_legend, col = rep(1:length(unlist(strike_values)), each = num_righe), 
       lty = 1, pch = 16, title = "Strikes associated", xpd = TRUE, cex = 0.55, 
       ncol = num_colonne)  # Imposta ncol per gestire le colonne della legenda

dev.off()


# Grafico degli strike in funzione di lastCallPrice di un dataset (only traded)#######

# Questa serie di comandi mi permettono di avere sul grafico gli Strike di riferimento che osservo.

strike_clean_read <- read.csv(file)
print(file)
print(strike_clean_read)
strike_clean_total <- strike_clean_read$Strike
# Trova il numero totale di colonne nel dataframe "clean_strike_frame"
num_colonne <- ncol(clean_strike_frame)
# Estrai la colonna "LastPr" dal dataframe "clean_strike_frame" (considerando l'ultima colonna)
ultima_colonna <- clean_strike_frame[, num_colonne]
# Filtra le colonne "Strike" in base alla presenza dell'elemento "LastPr" nel vettore "clean_strike_frame_strikes"
strike_legend <- strike_clean_total[strike_clean_read$LastPr_Call %in% clean_strike_frame[, num_colonne]]


png("plots/evoluzione_last_call_price_trade_date.png", width=800, height=600)

plot(1, 1, type = "n", xlim = c(0,ncol(clean_strike_frame)), ylim = c(min(clean_strike_frame), max(clean_strike_frame)+400), 
     xlab = "Giorni dall'osservazione iniziale", ylab = "LastCallPrice", 
     main = "Evoluzione del lastCallPrice (Trade date)")


# Aggiunta delle linee per ogni riga del dataframe
for (i in 1:nrow(clean_strike_frame)) {
  lines(0:(ncol(clean_strike_frame)-1), clean_strike_frame[i,], col = i)
}


num_colonne <- 9 # Scegli il numero di colonne che desideri
num_righe <- ceiling(length(unlist(strike_values)) / num_colonne) # Calcola il numero di righe

# Crea una matrice
strike_matrix <- matrix(c(unlist(strike_values), rep(NA, num_colonne * num_righe - length(unlist(strike_values)))), nrow = num_righe, byrow = TRUE)

# Crea la legenda
legend_labels <- as.vector(strike_matrix)


# Posizione della legenda e creazione
legend("topleft", legend = strike_legend, col = rep(1:length(unlist(strike_values)), each = num_righe), 
       lty = 1, pch = 16, title = "Strikes associated", xpd = TRUE, cex = 0.55, 
       ncol = num_colonne)  # Imposta ncol per gestire le colonne della legenda

dev.off()

###### Calcolo di devianza, rendimento medio giornaliero, annuale, prendendolo dai csv del CUSIP########

#NOTA: manualmente recarsi su https://treasurydirect.gov/GA-FI/FedInvest/selectSecurityPriceDate, scaricare il csv,
#      metterlo nella cartella "fedinvest", e aggiungere la data al nome nello stesso formato dei file presenti,
#      ovvero SPX_Opt_[year]-[month]-[currentday]

# Calcolo la deviazione standard dei rendimenti logaritmici dell'ultimo report

data_log <- read.csv(rendimenti_log_path, header = TRUE)
head(data_log$rendimento.giornaliero.log) #se faccio anteprima di data_log, vediamo come rendimento.giornaliero.log è il nome della colonna).

#variabilita <- sd(data_log$rendimento.giornaliero.log)
rendimento_medio <- mean(data_log$rendimento.giornaliero.log)

# Stampa il risultato
print(variabilita)
print(rendimento_medio)

#calcolo del rendimento privo di rischio per CUSIP 912797KT3 con scadenza 10 ottobre 2024
#l'idea è: ho file vari di nome securityprice_[dataDownload] li apro uno ad uno in ordine, prelevo il cusip associato e la data, e li salvo in un nuovo csv dove ho l'andamento di quel CUSIP.

fedinvest_dir <-file.path(WD, fedinvestfolder)

maturity_date<- as.Date("2024-10-10")

# Inizializza un nuovo dataframe vuoto
rendimenti_df <- data.frame()

rendimenti_famiglia_csv <- function(folder, parte_fissa_nome, rendimenti_csv_file_output) {
  
  # Ottieni la lista dei nomi dei file CSV nella folder specificato
  files <- sort(list.files(path = folder, pattern = parte_fissa_nome, full.names = TRUE))
  
  
  # Loop attraverso i file CSV
  for (file in files) {
    
    # Estrai la parte variabile (data) dal nome del file utilizzando substr
    nome_file <- basename(file)
    posizione_trattino <- max(gregexpr("_", nome_file)[[1]])
    parte_variabile <- substr(nome_file, posizione_trattino + 1, nchar(nome_file) - 4)
    
    # Converti la parte variabile in un valore "data" e aggiorna la variabile data_variabile
    data_variabile <- as.Date(parte_variabile)
    
    #print(data_variabile)
    
    # Leggi i dati dal file CSV
    dati <- read.csv(file)
    
    
    # Seleziona la riga con il valore "912797KT3" nel primo campo
    riga_x <- dati %>% filter(dati[, 1] == "912797KT3")
    
    # Se la riga con "x" è stata trovata, aggiungi il valore del primo campo e la data al dataframe
    
    if (nrow(riga_x) > 0) {
      
      r_no_risk_daily <- (100-riga_x[,7])/riga_x[,7] #rendimento giornaliero
      
      time_to_maturity_days <-as.numeric(maturity_date-data_variabile) #tempo alla maturità
      
      r_no_risk_year <- (1+r_no_risk_daily)^(365.2425/time_to_maturity_days)-1 #rendimento annuale
      
      print(r_no_risk_year)
      
      r_composite <- log(1+r_no_risk_year)/time_to_maturity_days
      print(r_composite) #Nota: in rbind uso "<<-" e non "<-" per salvare tali dati nel dataframe globalmente
      
      rendimenti_df <<- rbind(rendimenti_df, c(riga_x[, 7],as.character(data_variabile),time_to_maturity_days, r_no_risk_daily,r_no_risk_year, r_composite)) #prendo la settima colonna, ovvero valore SELL (cusip). as character perchè sennò in csv non viene riconosciuto.
      
      
    }
  }
  
  # Assegna nomi alle colonne
  colnames(rendimenti_df) <<- c("Sell_value", "data_osservazione","days_to_maturity","r_norisk_daily","r_norisk_annual","r_composite")
  rendimenti_csv_file_output <- file.path(fedinvest_dir,rendimenti_csv_file_output)
  print(rendimenti_df)
  
  # Scrivi il nuovo dataframe nel nuovo file CSV
  write.csv(rendimenti_df, rendimenti_csv_file_output, row.names = FALSE)
}

# Richiamo della funzione
rendimenti_famiglia_csv(folder = fedinvest_dir, parte_fissa_nome = "securityprice_", rendimenti_csv_file = "cusipLife.csv")

###### Calibrazione & Lattice Plot  ########


# Model Setting ----------------------------------------------------------------

# converto il rendimento continuamente composto e i giorni alla maturità in valori numerici (nel csv sono salvati come char)
rendimenti_df$r_composite <- as.numeric(rendimenti_df$r_composite)
rendimenti_df$days_to_maturity <- as.numeric(rendimenti_df$days_to_maturity)


#deltaT <- as.numeric(maturity_date-data_variabile) #tempo alla maturità, a partire dall'ultima osservazione disponibile.
deltaT <-1/252 #anche se tratto opzioni europee, le sto plottando su un grafico americano giornaliero, quindi sto vedendo l'andamento giornaliero, ovvero ampiezza 1 giorno.
r <- mean(rendimenti_df$r_composite)
u <- exp(variabilita*sqrt(deltaT))
d <- exp(-variabilita*sqrt(deltaT))
p <- (1 + r - d)/(u-d)
q <- (u - (1+r))/(u-d) 
S_0 <- 5751.13
print(p)
print(q)
print(strike_legend)
chosed_strike <-1 #è l'i-esimo strike osservabile da strike legend. quindi se voglio il primo, metto 1, il secondo 2 etc...
K <- strike_legend[chosed_strike]
N <- 5

#https://www.investing.com/indices/us-spx-500-historical-data reference to spx story


# stock values (K not used, è stata impostata a 0) ------------------------------------------------------------
S <- matrix(NA, nrow=N+1, ncol = N+1)
S[1,1] <- S_0
show(S)

# First Procedure
for(n in 1:N){
  for(k in 0:n){S[k+1,n+1] <- S_0*u^(n-k)*d^k}
}
show(S)

# library(timeDate)
# library(timeSeries)
# library(fBasics)
# library(fOptions)
png("plots/binomial_tree_plot.png", width=800, height=600)
BinomialTreePlot(S)
dev.off()

# Second Procedure
S <- matrix(NA, nrow=N+1, ncol = N+1)
S[1,1] <- S_0
for(n in 1:N){
  for(k in 0:n){S[n+1,k+1] <- round(S_0*u^k*d^(n-k),3)}
}
show(S)
S_df <- as.data.frame(S)

S_tb <- setDT(S_df)   
class(S_tb)
#head(S_tb)

# library(reshape2)
S_rsh_df <- melt(S_tb, na.rm=FALSE)
show(S_rsh_df[1:20,])

# We add an Index identifying variable to the data frame S_rsh_df
# library(tidyverse)
# library(dplyr)
S_mod_rsh_df <- subset(S_rsh_df, select = -variable)
S_mod_rsh_df <- rename(S_mod_rsh_df, S_value = value)
#head(S_mod_rsh_df,15)
S_mod_rsh_df <- add_column(S_mod_rsh_df, Index=rep(0:(nrow(S_df)-1), times=ncol(S_df)), .before="S_value")
#head(S_mod_rsh_df,15)
# We are finally in a position to draw a draft plot of the price lattice
# library(ggplot2)

Data_df <- S_mod_rsh_df
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             "Lattice Plot per spx Index nel CRR Model"))
subtitle_content <- bquote(paste("market periods N = ", .(N), ", risk free rate r = ", .(r), ", up factor u = ",.(u), ", down factor d = ",.(d), ", risk neutral probability distribution (p,q) = (",.(p),",",.(q),")."))
caption_content <- "Author: Michele Tosi, mat. 0327862"
y_breaks_num <- 4
y_margin <- 0 #was 5
y_breaks_low <- floor(min(Data_df$S_value, na.rm =TRUE))-y_margin
y_breaks_up <- ceiling(max(Data_df$S_value, na.rm =TRUE))+y_margin
y_breaks <- seq(from=y_breaks_low, to=y_breaks_up, length.out=y_breaks_num)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_margin), (y_breaks_up+K*y_margin))
y_name <- bquote("stock values")
y1_txt <- bquote("stock values")
y2_txt <- bquote("call current payoffs")
leg_labs <- c(y1_txt)
leg_vals <- c("y1_txt"="black")
leg_sort <- c("y1_txt")
S_lattice_sp <- ggplot(Data_df, aes(Index, S_value)) + 
  geom_point(na.rm = TRUE, colour="black") +
  geom_text(aes(label=round(S_value,3), colour="y1_txt"), hjust=1.0, vjust=-0.7, na.rm = TRUE) + 
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  xlab("time") + 
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_vals, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")

ggsave("plots/lattice_plot_spx_CRR.png", S_lattice_sp, width=8, height=6)
plot(S_lattice_sp)

# Comparazione previsione - indice reale#######

#requires install.packages("latticeExtra", repos="http://R-Forge.R-project.org")

# Ho prelevato da https://www.investing.com/indices/us-spx-500-historical-data i dati reali per confrontarli
x<-0:5
y<-c(5751.13, 5792.04, 5780.05, 5815.03, 5859.85, 5815.26)
index_real_evolution <- data.frame(x =x, y = y)
index_prevision_evolution <- layer_data(S_lattice_sp, 1) #per incompatibilità grafica, scarico i dati del lattice e li metto in un altro grafico su cui ci posso lavorare.
print(index_prevision_evolution)
png("plots/comparison_plot.png", width=800, height=600)  # Specifica il nome del file e la dimensione
comparison_plot <- xyplot(y ~ x, data = index_prevision_evolution, type = "p", col = "black", pch = 16,
                          main = "Evoluzione del spx rispetto le previsioni", xlab = "Giorni dall'osservazione", ylab = "spx value",
                          panel = function(x, y, ...) {
                            panel.xyplot(x, y, ...)
                            panel.text(x = x, y = y, labels = y, pos = 4, offset = 0.5, cex = 0.8, col = "black")
                            panel.points(index_real_evolution$x, index_real_evolution$y, col = "red", pch = 16)
                            panel.lines(index_real_evolution$x, index_real_evolution$y, col = "red")
                            panel.text(x = index_real_evolution$x, y = index_real_evolution$y, labels = index_real_evolution$y, pos = 4, offset = 0.5, cex = 0.8, col = "red")
                            
                          })
dev.off()
print(comparison_plot)

# Stock values, call current payoffs######

# Still assume K=S_0=100 and consider an American call option we have
K <- strike_legend[chosed_strike]
print(strike_legend)
print(K)
ACP <- matrix(NA, nrow=N+1, ncol = N+1)
ACP[1,1] <- 0
for(n in 1:N){
  for(k in 0:N){ACP[n+1,k+1] <- round(max(S[n+1,k+1]-K,0),3)}
}
show(ACP)

ACP_df <- as.data.frame(ACP)
# library("data.table")
ACP_tb <- setDT(ACP_df)   
class(ACP_tb)
head(ACP_tb)
# library(reshape2)
ACP_rsh_df <- melt(ACP_tb, na.rm=FALSE)
show(ACP_rsh_df[1:20,])
ACP_mod_rsh_df <- subset(ACP_rsh_df, select = -variable)
ACP_mod_rsh_df <- rename(ACP_mod_rsh_df, ACP_value=value)
show(ACP_mod_rsh_df[1:20,])
ACP_mod_rsh_df <- add_column(ACP_mod_rsh_df, Index=rep(0:(nrow(S_df)-1), times=ncol(ACP_df)), .before="ACP_value")
show(ACP_mod_rsh_df[1:20,])
ACP_mod_rsh_df <- add_column(ACP_mod_rsh_df, S_value=S_mod_rsh_df$S_value, .before="ACP_value")
show(ACP_mod_rsh_df[1:20,])

Data_df <- ACP_mod_rsh_df
length <- N
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             "Lattice Plot, Call Option - Current Payoffs in CRR Model"))
subtitle_content <- bquote(paste("market periods N = ", .(N), ", risk free rate r = ", .(r), ", up factor u = ",.(u), ", down factor d = ",.(d), ", risk neutral probability distribution (p,q) = (",.(p),",",.(q),"), exercise price K = ",.(K),"."))
caption_content <- "Author: Michele Tosi, mat. 0327862"
y_breaks_num <- 4 #before 4
y_margin <- 0 #before 5
y_breaks_low <- floor(min(Data_df$S_value, na.rm =TRUE))-y_margin
y_breaks_up <- ceiling(max(Data_df$S_value, na.rm =TRUE))+y_margin
y_breaks <- seq(from=y_breaks_low, to=y_breaks_up, length.out=y_breaks_num)
y_labs <- format(y_breaks, scientific=FALSE)
#K <- 0
y_lims <- c((y_breaks_low-K*y_margin), (y_breaks_up+K*y_margin))
y_name <- bquote("stock values")
y1_txt <- bquote("stock values")
y2_txt <- bquote("call current payoffs")
leg_labs <- c(y1_txt, y2_txt)
leg_vals <- c("y1_txt"="black", "y2_txt"="red")
leg_sort <- c("y1_txt", "y2_txt")
S_ACP_lattice_sp <- ggplot(Data_df, aes(Index, S_value, group=factor(Index))) + 
  geom_point(na.rm = TRUE, colour="black") +
  geom_text(aes(label=round(S_value,3), colour="y1_txt"), hjust=1.0, vjust=-0.7, na.rm = TRUE) + 
  geom_text(aes(label=round(ACP_value,3), colour="y2_txt"), hjust=1.0, vjust=1.3, na.rm = TRUE) + 
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  xlab("time") + 
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_vals, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
ggsave("plots/lattice_plot_call_current_payoff.png", S_ACP_lattice_sp, width=8, height=6)
plot(S_ACP_lattice_sp)
#
# Stock values, call current payoffs, call expected payoffs####

AC_EP <- matrix(NA, nrow=N+1, ncol = N+1)
AC_EP[N+1,] <- ACP[N+1,]
for(n in N:1){
  for(k in 0:n){AC_EP[n,k] <- round((1/(1+r))*(q*AC_EP[n+1,k]+p*AC_EP[n+1,k+1]),3)}
}
#show(AC_EP)

AC_EP_df <- as.data.frame(AC_EP)
# library("data.table")
AC_EP_tb <- setDT(AC_EP_df)   
class(AC_EP_tb)
head(AC_EP_tb)
# library(reshape2)
AC_EP_rsh_df <- melt(AC_EP_tb, na.rm=FALSE)
show(AC_EP_rsh_df[1:20,])
AC_EP_mod_rsh_df <- subset(AC_EP_rsh_df, select = -variable)
AC_EP_mod_rsh_df <- rename(AC_EP_mod_rsh_df, AC_EP_value=value)
AC_EP_mod_rsh_df <- add_column(AC_EP_mod_rsh_df, Index=rep(0:(nrow(AC_EP_df)-1), times=ncol(AC_EP_df)), .before="AC_EP_value")
#show(AC_EP_mod_rsh_df[1:20,])

ACP_mod_rsh_df <- add_column(ACP_mod_rsh_df, AC_EP_value=AC_EP_mod_rsh_df$AC_EP_value, .after="ACP_value")
#show(ACP_mod_rsh_df[1:20,])

# library(ggplot2)
Data_df <- ACP_mod_rsh_df
length <- N
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             "Lattice Plot, Call Option - Current Payoffs and Expected Payoffs in CRR Model"))
subtitle_content <- bquote(paste("market periods N = ", .(N), ", risk free rate r = ", .(r), ", up factor u = ",.(u), ", down factor d = ",.(d), ", risk neutral probability distribution (p,q) = (",.(p),",",.(q),"), exercise price K = ",.(K),"."))
caption_content <- "Author: Michele Tosi, mat. 0327862"
y_breaks_num <- 4
y_margin <- 0 #was 4
y_breaks_low <- floor(min(Data_df$S_value, na.rm =TRUE))-y_margin
y_breaks_up <- ceiling(max(Data_df$S_value, na.rm =TRUE))+y_margin
y_breaks <- seq(from=y_breaks_low, to=y_breaks_up, length.out=y_breaks_num)
y_labs <- format(y_breaks, scientific=FALSE)
strike_legend[chosed_strike]
y_lims <- c((y_breaks_low-K*y_margin), (y_breaks_up+K*y_margin))
y_name <- bquote("stock values")
y1_txt <- bquote("stock values")
y2_txt <- bquote("call current payoffs")
y3_txt <- bquote("call expected payoffs")
leg_labs <- c(y1_txt, y2_txt, y3_txt)
leg_vals <- c("y1_txt"="black", "y2_txt"="red", "y3_txt"="blue")
leg_sort <- c("y1_txt", "y2_txt", "y3_txt")
S_ACP_AC_EP_lattice_sp <- ggplot(Data_df, aes(Index, S_value)) + 
  geom_point(na.rm = TRUE, colour="black") +
  geom_text(aes(label=round(S_value,3), colour="y1_txt"), hjust=1.0, vjust=-0.7, na.rm = TRUE) + 
  geom_text(aes(label=round(ACP_value,3), colour="y2_txt"), hjust=1.0, vjust=1.3, na.rm = TRUE) + 
  geom_text(aes(label=round(AC_EP_value,3), colour="y3_txt"), hjust=-0.2, vjust=1.3, na.rm = TRUE) + 
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  xlab("time") + 
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_vals, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
ggsave("plots/lattice_plot_call_opt_expected_payoff.png", S_ACP_AC_EP_lattice_sp, width=8, height=6)
plot(S_ACP_AC_EP_lattice_sp)

ACP_mod_rsh_df <- add_column(ACP_mod_rsh_df, ACMV_value=pmax(ACP_mod_rsh_df$ACP_value, ACP_mod_rsh_df$AC_EP_value, na.rm=TRUE), .after="AC_EP_value")
#show(AP_PO_mod_rsh_df[1:20,])

# Stock values, call current payoffs, call expected payoffs, call market value#####

K <- strike_legend[chosed_strike]  

Data_df <- ACP_mod_rsh_df
length <- N
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             "Lattice Plot,Call Option - Current Payoffs, Expected Payoffs, and Market Values in CRR Model"))
subtitle_content <- bquote(paste("market periods N = ", .(N), ", risk free rate r = ", .(r), ", up factor u = ",.(u), ", down factor d = ",.(d), ", risk neutral probability distribution (p,q) = (",.(p),",",.(q),"), exercise price K = ",.(K),"."))
caption_content <- "Author: Michele Tosi, mat. 0327862"
y_breaks_num <- 4 #original 4
y_margin <- 0 #original 5
y_breaks_low <- floor(min(Data_df$S_value, na.rm =TRUE))-y_margin
y_breaks_up <- ceiling(max(Data_df$S_value, na.rm =TRUE))+y_margin
y_breaks <- seq(from=y_breaks_low, to=y_breaks_up, length.out=y_breaks_num)
y_labs <- format(y_breaks, scientific=FALSE)
#K <- 0 
y_lims <- c((y_breaks_low-K*y_margin), (y_breaks_up+K*y_margin))
y_name <- bquote("stock values")
y1_txt <- bquote("stock values")
y2_txt <- bquote("call current payoffs")
y3_txt <- bquote("call expected payoffs")
y4_txt <- bquote("call market values")
leg_labs <- c(y1_txt, y2_txt, y3_txt, y4_txt)
leg_vals <- c("y1_txt"="black", "y2_txt"="red", "y3_txt"="blue", "y4_txt"="magenta")
leg_sort <- c("y1_txt", "y2_txt", "y3_txt", "y4_txt")
S_ACP_AC_EP_ACMV_lattice_sp <- ggplot(Data_df, aes(Index, S_value)) + 
  geom_point(na.rm = TRUE, colour="black") +
  geom_text(aes(label=round(S_value,3), colour="y1_txt"), hjust=1.0, vjust=-0.7, na.rm=TRUE) + 
  geom_text(aes(label=round(ACP_value,3), colour="y2_txt"), hjust=1.0, vjust=1.3, na.rm=TRUE) + 
  geom_text(aes(label=round(AC_EP_value,3), colour="y3_txt"), hjust=-0.2, vjust=1.3, na.rm=TRUE) + 
  geom_text(aes(label=round(ACMV_value,3), colour="y4_txt"), hjust=-0.2, vjust=-0.7, na.rm = TRUE) + 
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  xlab("time") + 
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_vals, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
ggsave("plots/lattice_plot_call_market_values.png",S_ACP_AC_EP_ACMV_lattice_sp, width=8, height=6)
plot(S_ACP_AC_EP_ACMV_lattice_sp)



##### Osservazioni finali######

# Confronto tra payoff immediato tra spx e strike K#######
K <- strike_legend[chosed_strike]
print(K)
lattice_df <-ACP_mod_rsh_df
lattice_df <- na.omit(lattice_df)

# Creazione del grafico con etichette dei valori delle colonne "ACP_value", "AC_EP_value" e "ACMV_value"
grafico_lattice <- ggplot(lattice_df, aes(x = Index, y = S_value)) +
  geom_point() +
  geom_text(aes(label = S_value), nudge_x = -0.2, nudge_y = +55, color = "black", size=3) +
  
  geom_text(aes(label = ACP_value), nudge_x = -0.2, nudge_y = -55, color = "red", size=3) +
  labs(title = paste("Confronto predizione - real data", "in funzione di K =", K),subtitle = "Author: Michele Tosi, mat. 0327862",
       x = "Giorni dall'osservazione", y = "Valore spx") +
  theme_classic() +   guides(color = none)+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(plot.subtitle = element_text(hjust = 0.5))
index_real_evolution <- index_real_evolution %>%
  mutate(Payoff_immediato = y - K)
ggsave("plots/confronto_predizione_real.png", grafico_lattice, width=8, height=6)
print(index_real_evolution)

call_evolution_about_chosed_strike <- clean_strike_frame[chosed_strike,]
print(call_evolution_about_chosed_strike)
for (i in 1:6){ 
  if (index_real_evolution$Payoff_immediato[i] <=0 ){
    index_real_evolution$Payoff_immediato[i] <- 0
  }
  
  print(y[i])
  index_real_evolution$payoff_c0[i] <- y[i] - K- call_evolution_about_chosed_strike[i]
  if (index_real_evolution$payoff_c0[i] <=0 ){
    index_real_evolution$payoff_c0[i] <- 0
    
  }
}

print(index_real_evolution)



grafico_confronto <- grafico_lattice +
  geom_line(data = index_real_evolution, aes(x = x, y = y), color = "#230fd6", linewidth = 1) +
  geom_point(data = index_real_evolution, aes(x = x, y = y), color = "#230fd6", size = 1.5) +
  geom_label(data = index_real_evolution, aes(x = x, y = y, label = round(Payoff_immediato, 3)), fill="white", color = "#fc4103", nudge_x=0.2, nudge_y = -200, vjust= -1, size=3, label.size = 0)+
  geom_label(data = index_real_evolution, aes(x = x, y = y, label = round(y, 3)), fill="white", color = "#190d82",nudge_x=0.2, nudge_y = -100, vjust = -1, size=3, label.size = 0) +
  geom_label(data = index_real_evolution, aes(x = x, y = y, label = round(as.numeric(payoff_c0),3)), fill="white", color = "violet", nudge_x=0.2, nudge_y = -300, vjust = -1, size=3, label.size = 0)

ggsave("plots/confronto_pred_real_data.png", grafico_confronto, width=10, height=6)

# Stampa il grafico con i nuovi punti e le etichette "Payoff"
plot(grafico_confronto)



# Put - Call Parity#####

#Copio in nuovo df le triple <callLP,putLP,strike> solo se nessuno dei tre è NA.
# Converti le colonne "Call_LastTrTime" e "Put_LastTrTime" in formato data senza l'ora
spx_PCP_df <- read.csv(file.path(WD, optionsfolder, "SPX_Opt_2024-10-04.csv")) %>%
  mutate(LastTrDate_Call = as.Date(LastTrTime_Call),
         LastTrDate_Put = as.Date(LastTrTime_Put))


spx_PCP_df <- spx_PCP_df %>%
  select(Strike, LastPr_Call, LastPr_Put,LastTrDate_Call,LastTrDate_Put) #lascio le colonne di interesse
print(spx_PCP_df)


spx_PCP_df <- spx_PCP_df %>% #max due giorni di differenza tra trade call e put
  filter(abs(difftime(LastTrDate_Call, LastTrDate_Put, units = "days")) <= 2)

spx_PCP_df <- spx_PCP_df[complete.cases(spx_PCP_df$LastPr_Call, spx_PCP_df$LastPr_Put), ] #tolgo valori NA in quei campi
print(spx_PCP_df)




S <- 5751.07 #è S0, lo devo prendere dal sito investing.com il giorno che esamino la put call parity, poichè ovviamente cambia.
spx_PCP_df$r_stimato <- spx_PCP_df$Strike / (spx_PCP_df$LastPr_Put - spx_PCP_df$LastPr_Call + S) - 1



r_mean <-mean(spx_PCP_df$r_stimato)
print(r_mean)

spx_PCP_df$deltaParity<- (spx_PCP_df$LastPr_Call - spx_PCP_df$LastPr_Put) - S + spx_PCP_df$Strike/(1+r)
print(spx_PCP_df)
print (mean(spx_PCP_df$deltaParity))


#####Call-Put difference against the strike price######

na.rm <- function(x){x <- as.vector(x[!is.na(as.vector(x))])}
x <- spx_PCP_df$Strike
show(x)
length(x)
y <- spx_PCP_df$LastPr_Call - spx_PCP_df$LastPr_Put
show(y)
length(y)
#
Data_df <- data.frame(x,y)
nrow(Data_df)
Data_df <- na.omit(Data_df)
nrow(Data_df)
head(Data_df,10)
tail(Data_df,10)
rownames(Data_df) <- 1:nrow(Data_df)
nrow(Data_df)
head(Data_df,10)
tail(Data_df,10)
n <- nrow(Data_df)
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 MPSMF 2023-2024", 
                             paste("Scatter Plot of the Call-Put Difference Against the Strike Price")))
subtitle_content <- bquote(paste("Evaluation Date 2024-10-04;   Maturity Date 2024-10-10"))
caption_content <- "Author: Michele Tosi, mat. 0327862" 
x_breaks_num <- 8
x_breaks_low <- min(Data_df$x)
x_breaks_up <- max(Data_df$x)
x_binwidth <- floor((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- format(x_breaks, scientific=FALSE)
J <- 0.2
x_lims <- c(x_breaks_low-J*x_binwidth,x_breaks_up+J*x_binwidth)
x_name <- bquote("strike")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- y_min
y_breaks_up <- y_max
y_breaks <- seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth)
if((y_breaks_up-max(y_breaks))>y_binwidth/2){y_breaks <- c(y_breaks,y_breaks_up)}
y_labs <- format(y_breaks, scientific=FALSE)
y_name <- bquote("call-put difference")
K <- 0.2
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("data set sample points")
col_2 <- bquote("regression line")
col_3 <- bquote("LOESS curve")
leg_labs <- c(col_1, col_2, col_3)
leg_cols <- c("col_1"="blue", "col_2"="green", "col_3"="red")
leg_ord <- c("col_1", "col_2", "col_3")
Call_Put_Strike_Pr_2023_04_11_06_16_sp <- ggplot(Data_df, aes(x=x, y=y)) +
  geom_smooth(alpha=1, linewidth=0.8, linetype="dashed", aes(color="col_3"),
              method="loess", formula=y ~ x, se=FALSE, fullrange = FALSE) +
  geom_smooth(alpha=1, linewidth=0.8, linetype="solid", aes(color="col_2"),
              method="lm" , formula=y ~ x, se=FALSE, fullrange=FALSE) +
  geom_point(alpha=1, size=1.0, shape=19, aes(color="col_1")) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_ord,
                      guide=guide_legend(override.aes=list(shape=c(19,NA,NA), 
                                                           linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(1.0,"cm"), legend.position="bottom")
ggsave("plots/call_put_diff_against_sp.png", Call_Put_Strike_Pr_2023_04_11_06_16_sp, width=8, height=6)
plot(Call_Put_Strike_Pr_2023_04_11_06_16_sp)
#
PutCall_par_lm <- lm(y~x)
summary(PutCall_par_lm)
#
S_0 <- PutCall_par_lm$coefficients[1]
show(S_0)

