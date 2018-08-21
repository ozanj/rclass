#CREATE DATASET WITH ONE OBSERVATION PER EVENT FOR USE IN R-CLASS
#rm(list = ls()) # remove all objects

######## LOAD LIBRARIES ##########
#options(max.print=999999)
library(tidyverse)
#################################

rm(list = ls()) # remove all objects

#wwlist<-read_csv("data/prospect_list/western_washington_college_board_list.csv", col_names=FALSE, skip=1)
#names(wwlist)


wwlist<-read_csv("data/prospect_list/western_washington_college_board_list.csv", 
  col_names=c("receive_date", "psat_range", "sat_range", "ap_range", "gpa_b_aplus", "gpa_b_aplus_null","gpa_bplus_aplus","state","zip","for_country","sex","hs_ceeb_code","hs_name","hs_city","hs_state","hs_grad_date","ethn_code","homeschool","firstgen"), 
  skip=1)

str(wwlist)

#https://bookdown.org/rdpeng/rprogdatascience/using-the-readr-package.html

wwlist<-read_csv("data/prospect_list/western_washington_college_board_list.csv", 
  col_names=c("receive_date", "psat_range", "sat_range", "ap_range", "gpa_b_aplus", "gpa_b_aplus_null","gpa_bplus_aplus","state","zip","for_country","sex","hs_ceeb_code","hs_name","hs_city","hs_state","hs_grad_date","ethn_code","homeschool","firstgen"), 
  skip=1,
  col_types = cols(
    receive_date = col_character(),
    psat_range = col_character(),
    sat_range = col_character(),
    ap_range = col_character(),
    gpa_b_aplus = col_character(),
    gpa_b_aplus_null = col_character(),
    gpa_bplus_aplus = col_character(),
    state = col_character(),
    zip = col_character(),
    for_country = col_character(),
    sex = col_character(),
    hs_ceeb_code = col_integer(),
    hs_name = col_character(),
    hs_city = col_character(),
    hs_state = col_character(),
    hs_grad_date = col_character(),
    ethn_code = col_character(),
    homeschool = col_character(),
    firstgen = col_character()    
  ),
)


wwlist<-read_csv("data/prospect_list/western_washington_college_board_list.csv", 
                 col_names=c("receive_date", "psat_range", "sat_range", "ap_range", "gpa_b_aplus", "gpa_b_aplus_null","gpa_bplus_aplus","state","zip","for_country","sex","hs_ceeb_code","hs_name","hs_city","hs_state","hs_grad_date","ethn_code","homeschool","firstgen"), 
                 skip=1,
                 col_types = cols(
                   receive_date = col_integer(),
                   psat_range = col_character(),
                   sat_range = col_character(),
                   ap_range = col_character(),
                   gpa_b_aplus = col_character(),
                   gpa_b_aplus_null = col_character(),
                   gpa_bplus_aplus = col_character(),
                   state = col_character(),
                   zip = col_character(),
                   for_country = col_character(),
                   sex = col_character(),
                   hs_ceeb_code = col_integer(),
                   hs_name = col_character(),
                   hs_city = col_character(),
                   hs_state = col_character(),
                   hs_grad_date = col_character(),
                   ethn_code = col_character(),
                   homeschool = col_character(),
                   firstgen = col_character()    
                 ),
)


names(wwlist)
str(wwlist)

head(wwlist)

wwlist<-read_csv("data/prospect_list/western_washington_college_board_list.csv", 
  col_names=c("receive_date", "psat_range", "sat_range", "ap_range", "gpa_b_aplus", "gpa_b_aplus_null","gpa_bplus_aplus","state","zip","for_country","sex","hs_ceeb_code","hs_name","hs_city","hs_state","hs_grad_date","ethn_code","homeschool","firstgen"), 
  col_types = cols(
    receive_date=col_double(),
    psat_range=col_character()
    ),
  skip=1)

str(wwlist)
names(wwlist)
head(wwlist)

names(wwlist)

wwlist<-read.csv("data/prospect_list/western_washington_college_board_list.csv", na.strings = "")
names(wwlist)
str(wwlist)

names(wwlist)

head(wwlist, n=5)
str(wwlist)

#Rename variables
names(wwlist) <- tolower(names(wwlist))
names(wwlist)
wwlist <- dplyr::rename(wwlist, psat_range = psat.score.range, sat_range = sat.score.range, ap_range = ap.score.range, gpa_b_to_a = gpa.btoa., gpa_b_to_a_null = gpa..btoa..or.null, gpa_bplus_to_aplus = gpa..b.toa., state = stat_code, foreign_country = natn_desc..not.us., hs_name = high_school, homeschool = homeschooled_ind, firstgen = fgen_ind)


#convert to tibble
str(wwlist)
names(wwlist)
wwlist <- as.tibble(wwlist)

wwlist$receive_date[1:10]
wwlist$grad_date[1:10]

wwlist

##################################

challenge <- 1

challenge <-read.csv(
  "data/prospect_list/challenge.csv", 
  na.strings = "",
)

challenge <- read_csv(
  "data/prospect_list/challenge.csv", 
  col_types = cols(
    x = col_double(),
    y = col_date()
  ), 
  na = c(".","") ,
)


challenge <- read_csv(
  "data/prospect_list/challenge.csv", 
  col_types = cols(
    x = col_double(),
    y = col_date()
  ), 
)



challenge <- read_csv(
  readr_example("challenge.csv"), 
  col_types = cols(
    x = col_double(),
    y = col_date()
  ), 
)

getwd()

challenge <-read.csv("data/prospect_list/challenge.csv", na.strings = "")
