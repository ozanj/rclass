

######## LOAD LIBRARIES ##########
#options(max.print=999999)
library(tidyverse)
library(haven)
library(labelled)
#################################

getwd()
list.files("../../Dropbox/teaching-data/nls/data/analysis/pets")

#Read Stata data
nls_crs <- read_dta(file="../../Dropbox/teaching-data/nls/data/analysis/pets/nls72petscrs_v2.dta", encoding=NULL)



#sort and order

nls_crs <- nls_crs %>% select(-cname) # drop variable cname, which we don't use
nls_crs <- nls_crs %>% arrange(id, transnum, termnum, crsename) # sort observations
nls_crs <- nls_crs %>% select(id, transnum, termnum, crsecred, gradtype, crsgradb, crsgrada, crsecip, crsename) # order variables

#Investigate data patterns
glimpse(nls_crs)
names(nls_crs)
head(nls_crs)
nls_crs %>% var_label() # view variable labels
#nls_crs %>% val_labels()

#Investigate variable transnum

nls_crs %>% select(transnum) %>% var_label() # view variable labels
nls_crs %>% count(transnum)
310800+131412+34926+6396+851+137==484522 ## asser sum of frequencies == number of rows

#Investigate variable termnum
nls_crs %>% select(termnum) %>% var_label() # view variable labels

nls_crs %>% count(termnum)
options(tibble.print_min=40)
nls_crs %>% count(termnum)
options(tibble.print_min=20)
nls_crs %>% count(termnum)

#Investigate course credits
glimpse(nls_crs)
nls_crs %>% select(crsecred) %>% var_label() # view variable labels


summary(nls_crs$crsecred)

nls_crs %>% count(crsecred)
options(tibble.print_min=Inf)
nls_crs %>% count(crsecred)
options(tibble.print_min=20)

#investigate high values of crsecred
nls_crs %>% filter(crsecred>=100) %>% count(crsecred) # frequency table of crsecred

nls_crs %>% filter(crsecred==999) # printing some observations for specific values of crsecred
nls_crs %>% filter(crsecred==1000) # printing some observations for specific values of crsecred
nls_crs %>% filter(crsecred>999) # printing some observations for specific values of crsecred

#Investigate gradtype
glimpse(nls_crs)
nls_crs %>% select(gradtype) %>% var_label() # view variable labels
nls_crs %>% select(gradtype) %>% val_labels() # view value labels on variable

nls_crs %>% count(gradtype)

#crsgrada, crsgradb
glimpse(nls_crs)
nls_crs %>% select(crsgrada,crsgradb) %>% var_label() # view variable labels
nls_crs %>% count(crsgrada)
nls_crs %>% count(crsgradb)

#Investigate gradtype, crsgrada, crsgradb
  nls_crs %>% filter(gradtype==1) # letter grade
  nls_crs %>% filter(gradtype==2) # numeric grade
  nls_crs %>% filter(gradtype==9) # missing
  
  #some tabulations for different values of gradtype
  nls_crs %>% filter(gradtype==1) %>% count(crsgrada) # letter grade
  nls_crs %>% filter(gradtype==1) %>% count(crsgradb) # letter grade
  
  nls_crs %>% filter(gradtype==2) %>% count(crsgrada) # numeric grade
  nls_crs %>% filter(gradtype==2) %>% count(crsgradb) # numeric grade
  
  nls_crs %>% filter(gradtype==9) %>% count(crsgrada) # missing
  nls_crs %>% filter(gradtype==9) %>% count(crsgradb) # missing
  



nls_crs %>% select(id, transnum, termnum, crsename)






#STEPS IN CREATING INSTITUTION-LEVEL GPA VARIABLE

#Write a plan for how you will create an institution-level GPA variable  
  #The general definition of GPA is quality points (course credit multiplied by numerical grade value) 
    #divided by total credits. 
  
  #The first part of creating an institution-level GPA variable is to explore the input variables: 
    #id transnum gradtype crsecred crsgradb crsgrada. 
  
  #Next, we will generate missing values to deal with idiosyncracies in the value of "input" variables
    #so that calculations accross observations will be correct despite any one variable being missing.
  
  #Then, we will begin creating an institutional-level GPA by first generating a brand new numerical grade
    #value variable using crsegrada crsgradb and gradtype. This new variable will equal the numerical value
    #associated with crsgrada when gradtype==1 and it will equal crsegradb when gradtype==2 and crsegradb>4,
    #multipliying each observation's numerical grade value variable by crsecred will generate a course level
    #quality points variable.  
  
  #We will calculate institutional level quality points and total credits variables by summing across observations
    #within id and transnum. Finally, we will divide the institutional level quality points by insitutional total
    #credits to generate the institutional level GPA. 


#Create measure of course credits attempted that replaces 999 and 999.999 with missing

nls_crs %>% count(crsecred)


