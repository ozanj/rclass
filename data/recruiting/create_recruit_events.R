#CREATE DATASET WITH ONE OBSERVATION PER EVENT FOR USE IN R-CLASS
rm(list = ls()) # remove all objects

######## LOAD LIBRARIES ##########
#options(max.print=999999)
library(tidyverse)
#library(DataExplorer)
library(reshape2)
#library(stringr)
library(plyr)
library(scales)
#options(scipen=999)



#########################################
"ACROSS UNIVERSITY EDA"
#########################################

######## LOAD DATA ##########

#change directory to open parsed csv

getwd()  
#setwd("/Users/Karina/Dropbox/recruiting-m1/analysis/data")

#load in csv
all<-read.csv("data/recruiting/events_data.csv", na.strings = "")

#add univ names
all$instnm[all$univ_id==196097]<-"Stony Brook" #checking
all$instnm[all$univ_id==186380]<-"Rutgers"
all$instnm[all$univ_id==215293]<-"Pitt"
all$instnm[all$univ_id==201885]<-"Cinci"
all$instnm[all$univ_id==181464 ]<-"UNL"
all$instnm[all$univ_id==139959]<-"UGA" #checked 
all$instnm[all$univ_id==218663]<-"USCC"
all$instnm[all$univ_id==100751]<-"Bama"
all$instnm[all$univ_id==199193]<-"NC State"
all$instnm[all$univ_id==110635]<-"UC Berkeley"
all$instnm[all$univ_id==110653]<-"UC Irvine"
all$instnm[all$univ_id==126614]<-"CU Boulder" 
all$instnm[all$univ_id==155317]<-"Kansas"
all$instnm[all$univ_id==106397]<-"Arkansas"
all$instnm[all$univ_id==149222]<-"S Illinois"
all$instnm[all$univ_id==166629]<-"UM Amherst"

table(all$instnm) #no missing


#add univ states
all$instst[all$univ_id==196097]<-"NY"
all$instst[all$univ_id==186380]<-"NJ"
all$instst[all$univ_id==215293]<-"PA"
all$instst[all$univ_id==201885]<-"OH"
all$instst[all$univ_id==181464 ]<-"NE"
all$instst[all$univ_id==139959]<-"GA"
all$instst[all$univ_id==218663]<-"SC"
all$instst[all$univ_id==100751]<-"AL"
all$instst[all$univ_id==199193]<-"NC"
all$instst[all$univ_id==110635]<-"CA"
all$instst[all$univ_id==110653]<-"CA"
all$instst[all$univ_id==126614]<-"CO"
all$instst[all$univ_id==155317]<-"KS"
all$instst[all$univ_id==106397]<-"AR"
all$instst[all$univ_id==149222]<-"IL"
all$instst[all$univ_id==166629]<-"MA"

table(all$instst) #no missing


#19 events have missing locations==wrong IDS attached [drop, we'll fix during manual checks address for all pubs]
count(all$event_state) #19 are missing 
all[is.na(all$event_state), "instnm"] #diff univs

all<-all[!is.na(all$event_state),]
count(all$event_state) #none are missing 


#drop if ipeds_id of recruting event =ipeds_id of institution (on campus event)
count(is.na(all$ipeds_id))
count(all$univ_id==all$ipeds_id) #none currently on-campus

#OZAN [8/3/2018]: I DON'T HAVE ACCESS TO THIS FOLDER
#merge in level of urbanicity

#setwd("/Users/Karina/Dropbox/acs/data")
#zip<-read.csv("urbantozip.csv", colClasses=c('numeric', 'factor', 'factor'))


#some zips belong to more than one area, keep area with largest % of zip population
#zip <- zip[order(zip$ZCTA5, -abs(zip$UAPOPPCT) ), ] #sort by id and reverse of abs(value) of pop
#zip<- zip[ !duplicated(zip$ZCTA5), ]              # take the first row within each id

#names(all)[names(all) == 'determined_zip'] <- 'zip'
#names(zip)[names(zip) == 'ZCTA5'] <- 'zip'

#df <- merge(x = all, y = zip[ , c("UANAME", "zip")], by="zip", all.x=TRUE)
df <- all

######## DIMENSIONS BY VISITS ##########

#count of df visits 
table(df$univ_id)
counts<-table(df$instnm)
counts

obs<-melt(counts)
obs
ggplot(obs,aes(x=as.factor(Var1),y=value))+
  geom_bar(stat='identity') +
  xlab("Univ") + ylab("Total Visits") 

#count of visits by type
table(df$sector)
df$eventtype[is.na(df$school_id) & is.na(df$ipeds_id)]<-"other"
df$eventtype[nchar(as.character(df$school_id))>8]<-"public hs"
df$eventtype[nchar(as.character(df$school_id))<= 8]<-"private hs"
df$eventtype[df$sector=="Public, 2-year"]<-"pub 2yr cc"
df$eventtype[df$sector=="Public, 4-year or above"]<-"pub 4yr univ"
df$eventtype[df$sector=="Private not-for-profit, 4-year or above"]<-"PNP 4yr univ"
df$eventtype[is.na(df$eventtype) & !is.na(df$sector)]<-"other college/univ"

count(df$eventtype)
counts<-table(df$eventtype, df$instnm)
counts

obs  
obs<-melt(counts, id.vars="instnm")
obs

ggplot(obs, aes(Var2, value)) +   
  geom_bar(aes(fill = Var1), position = "dodge", stat="identity") +
  scale_x_discrete(labels = wrap_format(8))


#lots of "other"/college fairs: Bama
#lots of events at both CCs and 4-year pub univs: Bama

#proportion of visits by type
props<- prop.table(table(df$instnm,df$eventtype),1) #% rows
obs<-melt(props, id.vars="instnm")

ggplot(obs, aes(Var1, value)) +   
  geom_bar(aes(fill = Var2), position = "dodge", stat="identity") +
  scale_x_discrete(labels = wrap_format(8))

## low private HS, high public= UNL, Stony Brook
## high private, low public= Georgia, Boulder
## high cc|univ= UC Irvine 


#geographic markets, in-state vs out-state-ALL EVENT TYPES
df$event_inst[df$instst==df$event_state]<-"In-State"
df$event_inst[df$instst!=df$event_state]<-"Out-State"

typeof(df$event_inst)
count(df$event_inst)
table(df$event_inst, df$instnm)

props<- prop.table(table(df$instnm,df$event_inst),1) #% rows
obs<-melt(props, id.vars="instnm")

ggplot(obs, aes(Var1, value)) +   
  geom_bar(aes(fill = Var2), position = "dodge", stat="identity") +
  scale_x_discrete(labels = wrap_format(8))


#geographic markets, in-state vs out-state-By EVENT TYPES
typebystate<- table(df$event_inst, df$eventtype, df$instnm)
ftable(typebystate)
obs<-melt(typebystate, id.vars="instnm")


for (i in unique(obs$Var3)) {
  print(ggplot(subset(obs, Var3==i), aes(x = Var2, y = value)) +
          geom_bar(stat = "identity", position = "dodge") +
          geom_text(aes(label = value), position = position_dodge(width = 1),
                    vjust = 1.5, size = 3, colour="white") +
          facet_grid( ~ Var1) +
          scale_colour_identity() +
          scale_x_discrete(labels = wrap_format(8)) +
          labs(title= i))  
}

#SAVE DATASET FOR USE IN R CLASS [ALL VARIABLES]
df <- as.tibble(df)
attributes(df)
save(df, file = "data/recruiting/recruit_event_allvars.RData")
#rm(list = ls()) # remove all objects

load("data/recruiting/recruit_event_allvars.Rdata")
df <- as.tibble(df)

#Create version of dataset that has selected variables
names(df)
str(df)

nrow(df)
table(df$g12offered)


table(df$g12offered, useNA="ifany")

table(df$school_type_pri, useNA="ifany")


select(df, instnm, univ_id, instst, pid, event_date, eventtype, determined_zip, school_id, ipeds_id, event_state, event_inst, avgmedian_inc_2564,pop_total,pct_white_zip,pct_black_zip,pct_asian_zip,pct_hispanic_zip,pct_amerindian_zip,pct_nativehawaii_zip,pct_tworaces_zip,pct_otherrace_zip,free_reduced_lunch,titlei_status_pub,total_12)

df_event <- select(df, instnm, univ_id, instst, pid, event_date, eventtype, determined_zip, school_id, ipeds_id, event_state, event_inst, avgmedian_inc_2564,pop_total,pct_white_zip,pct_black_zip,pct_asian_zip,pct_hispanic_zip,pct_amerindian_zip,pct_nativehawaii_zip,pct_tworaces_zip,pct_otherrace_zip,free_reduced_lunch,titlei_status_pub,total_12,school_type_pri,school_type_pub,g12offered,g12)
attributes(df_event)

#shorten variable names
df_event <- dplyr::rename(df_event, med_inc = avgmedian_inc_2564, fr_lunch = free_reduced_lunch)
names(df_event)

save(df_event, file = "data/recruiting/recruit_event_somevars.RData")
rm(list = ls()) # remove all objects
load("data/recruiting/recruit_event_somevars.Rdata")
names(df_event)
########
######## CREATE CLASS DATASET FOR DATA WITH ONE OBSERVATION PER HIGH SCHOOL
########

rm(list = ls()) # remove all objects

#use all school data
#setwd("/Users/Karina/Dropbox/recruiting-m1/analysis/data")
all<-read.csv("data/recruiting/data_hs.csv", na.strings = "")
names(all)
all <- as.tibble(all)


#set INST state
all$inst_196097<-"NY"
all$inst_186380<-"NJ"
all$inst_215293<-"PA"
all$inst_201885<-"OH"
all$inst_181464<-"NE"
all$inst_139959<-"GA"
all$inst_218663<-"SC"
all$inst_100751<-"AL"
all$inst_199193<-"NC"
all$inst_110635<-"CA"
all$inst_110653<-"CA"
all$inst_126614<-"CO"
all$inst_155317<-"KS"
all$inst_106397<-"AR"
all$inst_149222<-"IL"
all$inst_166629<-"MA"

names(all)
table(all$school_type)

#"110635"="UC Berkeley",
#"126614"="CU Boulder" ,
#"100751"="Bama",

table(all$visits_by_110635) # berkeley
table(all$visits_by_126614) # Boulder
table(all$visits_by_100751) # Bama

#these vars are just always equal to the state of the university
table(all$inst_110635) # berkeley
table(all$inst_126614) # Boulder
table(all$inst_100751) # Bama

names(all)

select(all,state_code,school_type,ncessch,name,address,city,zip_code,pct_white,pct_black,pct_hispanic,pct_asian,pct_amerindian,pct_other,num_fr_lunch,total_students,num_took_math,num_prof_math,num_took_rla,num_prof_rla,avgmedian_inc_2564,visits_by_110635,visits_by_126614,visits_by_100751,inst_110635,inst_126614,inst_100751)

df_school <- select(all,state_code,school_type,ncessch,name,address,city,zip_code,pct_white,pct_black,pct_hispanic,pct_asian,pct_amerindian,pct_other,num_fr_lunch,total_students,num_took_math,num_prof_math,num_took_rla,num_prof_rla,avgmedian_inc_2564,visits_by_110635,visits_by_126614,visits_by_100751,inst_110635,inst_126614,inst_100751)

names(df_school)

attributes(df_school)

save(df_school, file = "data/recruiting/recruit_school_somevars.RData")
rm(list = ls()) # remove all objects
load("data/recruiting/recruit_school_somevars.Rdata")

