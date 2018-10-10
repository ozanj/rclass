#CREATE DATASET WITH ONE OBSERVATION PER EVENT FOR USE IN R-CLASS
rm(list = ls()) # remove all objects

######## LOAD LIBRARIES ##########
#options(max.print=999999)
library(tidyverse)
#################################

setAs("character","myDate", function(from) as.Date(from, format="%d-%b-%y") )


# Merged data
wwlist_merged <- read.csv("data/prospect_list/wwlist_merged_.csv",
                          na.strings=c("","NA"),
                          col.names=c("receive_date", "psat_range", "sat_range", "ap_range", "gpa_b_aplus", "gpa_b_aplus_null","gpa_bplus_aplus","state","zip","for_country","sex","hs_ceeb_code","hs_name","hs_city","hs_state","hs_grad_date","ethn_code","homeschool","firstgen", "zip_code", "pop_total", "pop_white", "pop_black", "pop_asian", "pop_hispanic", "pop_amerindian", "pop_nativehawaii", "pop_tworaces", "pop_otherrace", "avgmedian_inc_2564", "school_type", "merged_hs", "school_category", "total_12", "total_students", "total_free_reduced_lunch"),
                          colClasses=c(receive_date="myDate",
                                       state="character",
                                       zip="character",
                                       for_country="character",
                                       hs_name="character",
                                       hs_city="character",
                                       hs_state="character",
                                       hs_grad_date="myDate",
                                       zip_code="character",
                                       merged_hs="character",
                                       gpa_b_aplus="character",
                                       gpa_b_aplus_null="character",
                                       gpa_bplus_aplus="character",
                                       sex="character",
                                       homeschool="character",
                                       firstgen="character",
                                       school_type="character",
                                       psat_range="character",
                                       school_category="character"
                          )
)

# Convert to tibble
wwlist_merged <- as.tibble(wwlist_merged)


names(wwlist_merged)
str(wwlist_merged)
# Shows fctr, dbl, int as col types
wwlist_merged %>% select(ethn_code, avgmedian_inc_2564, pop_total)

# Of the 268396 obs...
count(filter(wwlist_merged, is.na(merged_hs)))  # 134731 not merged to HS data
count(filter(wwlist_merged, !is.na(merged_hs)))  # 133665 merged to HS data

# Of 133665 merged to HS data...
count(filter(wwlist_merged, school_type=='private'))  # 94 private
count(filter(wwlist_merged, school_type=='public'))  # 133571 public

#investigate received date, score vars
options(tibble.print_min=50) # set default printing back to 10 lines
names(wwlist_merged)
wwlist_merged %>% count(receive_date)
wwlist_merged %>% count(psat_range) # mostly present!
  wwlist_merged %>% filter(is.na(psat_range)) %>% count(receive_date) # psat score missing for lots of different receive dates

wwlist_merged %>% count(sat_range) # mostly missing
  wwlist_merged %>% group_by(receive_date) %>% count(sat_range) # not a systematic relationship
  
wwlist_merged %>% count(ap_range) # mostly missing

#investigate received date, gpa vars
wwlist_merged %>% count(gpa_b_aplus) # X for 164,242; missing for 104,154
  wwlist_merged %>% group_by(receive_date) %>% count(gpa_b_aplus) %>% 
    spread(gpa_b_aplus, n) # no systematic relationship between receive data and NA

  wwlist_merged %>% filter(gpa_b_aplus_null=="x") %>% count(gpa_b_aplus)
  
wwlist_merged %>% count(gpa_b_aplus_null) # X for 88,943;
  wwlist_merged %>% group_by(receive_date) %>% count(gpa_b_aplus_null) %>% 
    spread(gpa_b_aplus_null, n) # no systematic relationship between receive data and NA

  wwlist_merged %>% filter(gpa_b_aplus=="x") %>% count(gpa_b_aplus_null)
wwlist_merged %>% count(gpa_bplus_aplus) # X for 15211;
  wwlist_merged %>% group_by(receive_date) %>% count(gpa_bplus_aplus) %>% 
    spread(gpa_bplus_aplus, n) # no systematic relationship between receive data and NA
  
164242+88943+15211
nrow(wwlist_merged)

wwlist_merged %>% count(school_type)

#remove certain variables
names(wwlist_merged)
wwlist <- wwlist_merged %>% select(-sat_range,-contains("gpa"),-ap_range)
wwlist <- wwlist %>% rename(fr_lunch = total_free_reduced_lunch, 
                            med_inc = avgmedian_inc_2564,
                            zip9 = zip,
                            zip5 = zip_code)
names(wwlist)

# Convert/save data
save(wwlist, file = "data/prospect_list/wwlist_merged.RData")






####################### OLD CODE; NON MERGED DATA

setAs("character","myDate", function(from) as.Date(from, format="%d-%b-%y") )

wwlist <- read.csv("data/prospect_list/western_washington_college_board_list.csv",
                   na.strings="",
                   col.names=c("receive_date", "psat_range", "sat_range", "ap_range", "gpa_b_aplus", "gpa_b_aplus_null","gpa_bplus_aplus","state","zip","for_country","sex","hs_ceeb_code","hs_name","hs_city","hs_state","hs_grad_date","ethn_code","homeschool","firstgen"),
                   colClasses=c(receive_date="myDate",
                                state="character",
                                zip="character",
                                for_country="character",
                                hs_name="character", 
                                hs_city="character",
                                hs_state="character",
                                hs_grad_date="myDate")
)

names(wwlist)
str(wwlist)


wwlist2 <- read_csv("data/prospect_list/western_washington_college_board_list.csv",
                    col_names=c("receive_date", "psat_range", "sat_range", "ap_range", "gpa_b_aplus", "gpa_b_aplus_null","gpa_bplus_aplus","state","zip","for_country","sex","hs_ceeb_code","hs_name","hs_city","hs_state","hs_grad_date","ethn_code","homeschool","firstgen"),
                    skip=1,
                    na="",
                    col_types = cols(
                      receive_date = col_date("%d-%b-%y"),
                      psat_range = col_factor(NULL),
                      sat_range = col_factor(NULL),
                      ap_range = col_factor(NULL),
                      gpa_b_aplus = col_factor(NULL),
                      gpa_b_aplus_null = col_factor(NULL),
                      gpa_bplus_aplus = col_factor(NULL),
                      state = col_character(),
                      zip = col_character(),
                      for_country = col_character(),
                      sex = col_factor(NULL),
                      hs_ceeb_code = col_integer(),
                      hs_name = col_character(),
                      hs_city = col_character(),
                      hs_state = col_character(),
                      hs_grad_date = col_date("%d-%b-%y"),
                      ethn_code = col_factor(NULL),
                      homeschool = col_factor(NULL),
                      firstgen = col_factor(NULL)
                    )
)

attr(wwlist2, 'spec') <- NULL

#Comparing the two data frames
names(wwlist2)
str(wwlist2)

str(wwlist)
str(wwlist2)

attributes(wwlist)
attributes(wwlist2)

str(wwlist$ethn_code)
str(wwlist2$ethn_code)

attributes(wwlist$ethn_code)
attributes(wwlist2$ethn_code)

typeof(wwlist$ethn_code)
typeof(wwlist2$ethn_code)

class(wwlist$ethn_code)
class(wwlist2$ethn_code)

#I'll choose the object wwlist created by read.csv

#convert to tibble
str(wwlist)
names(wwlist)
wwlist <- as.tibble(wwlist)

save(wwlist, file = "data/prospect_list/western_washington_college_board_list.RData")
