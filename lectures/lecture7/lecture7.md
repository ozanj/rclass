---
title: "Lecture 7: Joining multiple datasets"
subtitle: "EDUC 263: Managing and Manipulating Data Using R" 
author: Ozan Jaquette
date: 
urlcolor: blue
output: 
  html_document:
    toc: true
    toc_depth: 2
    toc_float: # toc_float option to float the table of contents to the left of the main document content. floating table of contents will always be visible even when the document is scrolled
      collapsed: false # collapsed (defaults to TRUE) controls whether the TOC appears with only the top-level (e.g., H2) headers. If collapsed initially, the TOC is automatically expanded inline when necessary
      smooth_scroll: true # smooth_scroll (defaults to TRUE) controls whether page scrolls are animated when TOC items are navigated to via mouse clicks
    number_sections: true
    fig_caption: true # ? this option doesn't seem to be working for figure inserted below outside of r code chunk    
    highlight: tango # Supported styles include "default", "tango", "pygments", "kate", "monochrome", "espresso", "zenburn", and "haddock" (specify null to prevent syntax    
    theme: default # theme specifies the Bootstrap theme to use for the page. Valid themes include default, cerulean, journal, flatly, readable, spacelab, united, cosmo, lumen, paper, sandstone, simplex, and yeti.
    df_print: tibble #options: default, tibble, paged
    keep_md: true # may be helpful for storing on github
    
---







# Introduction

## Logistics

READING

OTHER

## Lecture overview

It is rare for an analysis dataset to consist of data from only one input dataset. For most projects, each analysis dataset contains data from multiple data sources. Therefore, you must become proficient in combining data from multiple data sources.

Two broad topics today:

1. __Joining__ datasets [big topic]
    - Combine two datasets so that the resulting dataset has additional variables
    - The term "join" comes from the relational databases world; Social science research often uses the term "merge" rather than "join"
2. __Appending__ datasets  [small topic]
    - Stack datasets on top of one another so that resulting dataset has more observations, but (typically) the same number of variables
    - Often, longitudinal datasets are created by appending datasets


Wickham differentiates __mutating joins__ from __filtering joins__

- Mutating joins "add new variables to one data frame from matching observations in another"
- Filtering joins "filter observations from one data frame based on whether or not they match an observation in the other table"
    - doesn't add new variables

Our main focus today is on _mutating joins_. But _Filtering joins_ are useful for data quality checks of _mutating joins_.

Libraries we will use

```r
library(tidyverse)
#> ── Attaching packages ──────────────────────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ ggplot2 3.0.0     ✔ purrr   0.2.5
#> ✔ tibble  1.4.2     ✔ dplyr   0.7.6
#> ✔ tidyr   0.8.1     ✔ stringr 1.3.1
#> ✔ readr   1.1.1     ✔ forcats 0.3.0
#> ── Conflicts ─────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
library(haven)
library(labelled)
```

## NLS72 data

Today's lecture will utilize several datasets from the National Longitudinal Survey of 1972 (NLS72):

- Student level dataset
- Student-transcript level dataset
- Student-transcript-term level dataset
- Student-transcript-term-course level dataset

These datasets good for teaching "joining" because you get practice joining data sources with different "observational levels" (e.g., join student level and student-transcript level data)

### Read in NLS72 data frames

Below, we'll read-in Stata data files and keep a small number of variables from each. Don't worry about investigating individual variables, just get an overall sense of each data frame.

- __Student level data__

```r
rm(list = ls()) # remove all objects

#getwd()
nls_stu <- read_dta(file="https://github.com/ozanj/rclass/raw/master/data/nls72/nls72stu_percontor_vars.dta") %>%
  select(id,schcode,bysex,csex,crace,cbirthm,cbirthd,cbirthyr)

#get a feel for the data
names(nls_stu)
#> [1] "id"       "schcode"  "bysex"    "csex"     "crace"    "cbirthm" 
#> [7] "cbirthd"  "cbirthyr"
glimpse(nls_stu)
#> Observations: 22,652
#> Variables: 8
#> $ id       <dbl> 18, 67, 83, 174, 190, 232, 315, 380, 414, 430, 497, 5...
#> $ schcode  <dbl> 3000, 3000, 2518, 2911, 800, 7507, 3000, 9516, 2518, ...
#> $ bysex    <dbl+lbl> 2, 1, 2, 1, 2, 2, 1, 1, 1, 1, 99, 1, 1, 2, 1, 1, ...
#> $ csex     <dbl+lbl> 1, 1, 2, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2...
#> $ crace    <dbl+lbl> 4, 2, 7, 7, 7, 7, 7, 7, 7, 4, 7, 7, 7, 7, 7, 7, 7...
#> $ cbirthm  <dbl> 12, 10, 3, 5, 1, 7, 3, 10, 9, 4, 6, 2, 5, 1, 10, 5, 9...
#> $ cbirthd  <dbl> 9, 14, 10, 11, 5, 8, 1, 24, 3, 17, 11, 13, 28, 24, 9,...
#> $ cbirthyr <dbl> 53, 53, 54, 54, 55, 54, 54, 53, 53, 54, 54, 54, 54, 5...

nls_stu %>% var_label()
#> $id
#> [1] "unique school code of high school student attended"
#> 
#> $schcode
#> [1] "SCHOOL CODE"
#> 
#> $bysex
#> [1] "SEX OF STUDENT FROM BASE YEAR INSTRUMENT"
#> 
#> $csex
#> [1] "CSEX - SEX OF RESPONDENT"
#> 
#> $crace
#> [1] "RACE COMPOSITE"
#> 
#> $cbirthm
#> [1] "COMPOSITE BIRTH MONTH"
#> 
#> $cbirthd
#> [1] "COMPOSITE BIRTH DAY"
#> 
#> $cbirthyr
#> [1] "COMPOSITE BIRTH YEAR"

#we can investigate individual variables (e.g., bysex variable)
class(nls_stu$bysex)
#> [1] "labelled"
str(nls_stu$bysex)
#>  'labelled' num [1:22652] 2 1 2 1 2 2 1 1 1 1 ...
#>  - attr(*, "label")= chr "SEX OF STUDENT FROM BASE YEAR INSTRUMENT"
#>  - attr(*, "format.stata")= chr "%23.0g"
#>  - attr(*, "labels")= Named num [1:4] 1 2 98 99
#>   ..- attr(*, "names")= chr [1:4] "1. male" "2. female" "98. {ILLEGITIMATE SKIP}" "99. {LEGITIMATE SKIP}"

nls_stu %>% select(bysex) %>% var_label()
#> $bysex
#> [1] "SEX OF STUDENT FROM BASE YEAR INSTRUMENT"
nls_stu %>% select(bysex) %>% val_labels()
#> $bysex
#>                 1. male               2. female 98. {ILLEGITIMATE SKIP} 
#>                       1                       2                      98 
#>   99. {LEGITIMATE SKIP} 
#>                      99

nls_stu %>% count(bysex)
#> # A tibble: 4 x 2
#>   bysex         n
#>   <dbl+lbl> <int>
#> 1 " 1"       8208
#> 2 " 2"       8340
#> 3 98          135
#> 4 99         5969
nls_stu %>% count(bysex) %>% as_factor()
#> # A tibble: 4 x 2
#>   bysex                       n
#>   <fct>                   <int>
#> 1 1. male                  8208
#> 2 2. female                8340
#> 3 98. {ILLEGITIMATE SKIP}   135
#> 4 99. {LEGITIMATE SKIP}    5969
```
- __Student level data, containing variables about completeness of postsecondary education transcripts (PETS)__


```r
nls_stu_pets <- read_dta(file="https://github.com/ozanj/rclass/raw/master/data/nls72/nls72petsstu_v2.dta") %>%
  select(id,reqtrans,numtrans)

names(nls_stu_pets)
#> [1] "id"       "reqtrans" "numtrans"
glimpse(nls_stu_pets)
#> Observations: 14,759
#> Variables: 3
#> $ id       <dbl> 18, 67, 83, 315, 414, 430, 802, 836, 935, 1040, 1057,...
#> $ reqtrans <dbl> 1, 1, 1, 2, 1, 1, 2, 2, 3, 2, 1, 3, 1, 2, 1, 3, 2, 3,...
#> $ numtrans <dbl> 0, 1, 0, 2, 0, 0, 1, 1, 2, 2, 1, 1, 1, 2, 1, 0, 2, 3,...
nls_stu_pets %>% var_label()
#> $id
#> [1] "unique student identification variable"
#> 
#> $reqtrans
#> [1] "NUMBER OF TRANSCRIPTS REQUESTED"
#> 
#> $numtrans
#> [1] "NUMBER OF TRANSCRIPTS RECEIVED"
```

- __Student-transcript level data__


```r
nls_tran <- read_dta(file="https://github.com/ozanj/rclass/raw/master/data/nls72/nls72petstrn_v2.dta") %>%
  select(id,transnum,findisp,trnsflag,terms,fice,state,cofcon,instype,itype)

names(nls_tran)
#>  [1] "id"       "transnum" "findisp"  "trnsflag" "terms"    "fice"    
#>  [7] "state"    "cofcon"   "instype"  "itype"
glimpse(nls_tran)
#> Observations: 24,253
#> Variables: 10
#> $ id       <dbl> 18, 67, 83, 315, 315, 414, 430, 802, 802, 836, 836, 9...
#> $ transnum <dbl> 1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 2, 1, 2, 3, 1, 2, 1, 1,...
#> $ findisp  <dbl+lbl> 6, 1, 3, 1, 1, 3, 4, 1, 2, 4, 1, 1, 1, 3, 1, 1, 1...
#> $ trnsflag <dbl+lbl> 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1...
#> $ terms    <dbl> 99, 8, 99, 20, 1, 99, 99, 2, 99, 99, 6, 11, 6, 99, 1,...
#> $ fice     <dbl> 1009, 5694, 1166, 1009, 1057, 1166, 2089, 2865, 3687,...
#> $ state    <dbl> 1, 1, 5, 1, 1, 5, 21, 33, 46, 14, 23, 15, 23, 15, 5, ...
#> $ cofcon   <dbl+lbl> 6, 2, 4, 6, 6, 4, 4, 4, 3, 5, 3, 5, 6, 1, 6, 5, 6...
#> $ instype  <dbl+lbl> 3, 1, 4, 3, 3, 4, 4, 4, 2, 2, 2, 2, 3, 1, 3, 2, 3...
#> $ itype    <dbl+lbl> 1, 5, 4, 1, 2, 4, 4, 4, 3, 6, 4, 2, 2, 5, 1, 1, 2...

nls_tran %>% var_label()
#> $id
#> [1] "unique student identification variable"
#> 
#> $transnum
#> [1] "TRANSCRIPT NUMBER"
#> 
#> $findisp
#> [1] "FINAL DISPOSITION"
#> 
#> $trnsflag
#> [1] "TRANSCRIPT FLAG"
#> 
#> $terms
#> [1] "NUMBER OF TERMS ON THIS TRANSCRIPT"
#> 
#> $fice
#> [1] "POSTSECONDARY INSTITUTION ID CODE"
#> 
#> $state
#> [1] "state"
#> 
#> $cofcon
#> [1] "OFFERING & CONTROL"
#> 
#> $instype
#> [1] "INSTITUTION TYPE"
#> 
#> $itype
#> [1] "INSTITUTION TYPE"

nls_tran %>% val_labels()
#> $id
#> NULL
#> 
#> $transnum
#> NULL
#> 
#> $findisp
#>      1. TRANSCRIPT RECEIVED           2. SCHOOL REFUSED 
#>                           1                           2 
#>   3. STUDENT NEVER ATTENDED 4. SCHOOL LOST OR DESTROYED 
#>                           3                           4 
#>            5. SCHOOL CLOSED  6. NO RESPONSE FROM SCHOOL 
#>                           5                           6 
#> 
#> $trnsflag
#>     0. DUMMY TRANSCRIPT 1. REQUESTED & RECEIVED 
#>                       0                       1 
#> 
#> $terms
#> NULL
#> 
#> $fice
#> NULL
#> 
#> $state
#> NULL
#> 
#> $cofcon
#>          1. proprietary      2. PUBLIC < 2-YEAR 3. PRIVATE NFP < 4-YEAR 
#>                       1                       2                       3 
#>        4. PUBLIC 2-YEAR   5. PRIVATE NFP 4-YEAR        6. PUBLIC 4-YEAR 
#>                       4                       5                       6 
#> 
#> $instype
#>   1. proprietary   2. PRIVATE NFP 3. PUBLIC 4-YEAR 4. PUBLIC 2-YEAR 
#>                1                2                3                4 
#>       5. foreign 
#>                5 
#> 
#> $itype
#>   1. Research & Doctoral         2. Comprehensive          3. Liberal Arts 
#>                        1                        2                        3 
#>                4. 2-year      5. Less than 2-year           6. Specialized 
#>                        4                        5                        6 
#> 8. Special comprehensive 
#>                        8
```

- __Student-transcript-term level data__


```r
nls_term <- read_dta(file="https://github.com/ozanj/rclass/raw/master/data/nls72/nls72petstrm_v2.dta") %>%
  select(id,transnum,termnum,courses,termtype,season,sortdate,gradcode,transfer)

names(nls_term)
#> [1] "id"       "transnum" "termnum"  "courses"  "termtype" "season"  
#> [7] "sortdate" "gradcode" "transfer"
glimpse(nls_term)
#> Observations: 120,885
#> Variables: 9
#> $ id       <dbl> 67, 67, 67, 67, 67, 67, 67, 67, 315, 315, 315, 315, 3...
#> $ transnum <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
#> $ termnum  <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10...
#> $ courses  <dbl> 3, 2, 2, 2, 2, 2, 2, 2, 4, 3, 5, 4, 4, 4, 4, 5, 1, 4,...
#> $ termtype <dbl+lbl> 4, 4, 4, 4, 4, 4, 4, 4, 2, 4, 4, 4, 4, 4, 4, 4, 4...
#> $ season   <dbl+lbl> 2, 3, 1, 2, 3, 4, 1, 2, 1, 2, 3, 2, 3, 1, 2, 3, 1...
#> $ sortdate <dbl> 8101, 8104, 8109, 8201, 8204, 8207, 8209, 8301, 7209,...
#> $ gradcode <dbl+lbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
#> $ transfer <dbl+lbl> 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0...

nls_term %>% var_label()
#> $id
#> [1] "unique student identification variable"
#> 
#> $transnum
#> [1] "TRANSCRIPT NUMBER"
#> 
#> $termnum
#> [1] "TERM NUMBER"
#> 
#> $courses
#> [1] "NUMBER OF COURSES TERM"
#> 
#> $termtype
#> [1] "TYPE OF TERM"
#> 
#> $season
#> [1] "SEASON OF TERM"
#> 
#> $sortdate
#> [1] "DATE OF TERM"
#> 
#> $gradcode
#> [1] "GRADE SCALE TYPE"
#> 
#> $transfer
#> [1] "TRANSFER COURSES FLAG"

nls_term %>% val_labels()
#> $id
#> NULL
#> 
#> $transnum
#> NULL
#> 
#> $termnum
#> NULL
#> 
#> $courses
#> NULL
#> 
#> $termtype
#> 1. VARIABLE LENGTH OR NONCOURSE TERM                          2. semester 
#>                                    1                                    2 
#>                         3. trimester                           4. quarter 
#>                                    3                                    4 
#>             5. CREDIT BY EXAMINATION                         7. {UNKNOWN} 
#>                                    5                                    7 
#> 
#> $season
#>      1. fall    2. winter    3. spring    4. summer 9. {MISSING} 
#>            1            2            3            4            9 
#> 
#> $sortdate
#> NULL
#> 
#> $gradcode
#>  1. LETTER GRADES 2. NUMERIC GRADES 
#>                 1                 2 
#> 
#> $transfer
#>  0. NOT TRANSFER 1. TRANSFER TERM 
#>                0                1
```

- __Student-transcript-term-course level data__ 
    - This is the file we worked with for the "create GPA" problem set


```r
nls_course <- read_dta(file="https://github.com/ozanj/rclass/raw/master/data/nls72/nls72petscrs_v2.dta") %>%
  select(id,transnum,termnum,crsecip,crsecred,gradtype,crsgrada,crsgradb)

names(nls_course)
#> [1] "id"       "transnum" "termnum"  "crsecip"  "crsecred" "gradtype"
#> [7] "crsgrada" "crsgradb"
glimpse(nls_course)
#> Observations: 484,522
#> Variables: 8
#> $ id       <dbl> 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 6...
#> $ transnum <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
#> $ termnum  <dbl> 1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 1,...
#> $ crsecip  <dbl+lbl> 150803, 150803, 270101, 470604, 470604, 470604, 4...
#> $ crsecred <dbl> 0.5, 1.0, 0.5, 0.7, 1.0, 0.7, 1.0, 1.0, 0.7, 0.7, 1.0...
#> $ gradtype <dbl+lbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
#> $ crsgrada <chr> "B", "C", "A", "A", "B", "C", "B", "B", "A", "C", "B"...
#> $ crsgradb <dbl> 3.000, 2.000, 4.000, 4.000, 3.000, 2.000, 3.000, 3.00...

nls_course %>% var_label()
#> $id
#> [1] "unique student identification variable"
#> 
#> $transnum
#> [1] "TRANSCRIPT NUMBER"
#> 
#> $termnum
#> [1] "TERM NUMBER"
#> 
#> $crsecip
#> [1] "COURSE CODE"
#> 
#> $crsecred
#> [1] "COURSE CREDITS POSSIBLE"
#> 
#> $gradtype
#> [1] "TYPE OF GRADE"
#> 
#> $crsgrada
#> [1] "COURSE GRADE ALPHA"
#> 
#> $crsgradb
#> [1] "COURSE GRADE NUMERIC"

#nls_course %>% val_labels() # output too long!
```

## Relational databases and tables

__Traditionally, social scientists store data in "flat files"__

- flat files are "rectangular" datasets consisting of columns (usually called variables) and rows (usually called observations)
- When we want to incorporate variables from two flat files, we "merge" them together.

__The rest of the world stores data in "relational databases"__

- A relational database consists of multiple __tables__
- Each table is a flat file
- A goal of relational databases is to store data using the minimum possible space; therefore, a rule is to never duplicate information across tables
- When you need information from multiple tables, you "join"(the database term for "merge") tables "on the fly" rather than creating some permanent flat file that contains data from multiple tables
- Each table in a relational database has a different "observational level"
    - For example, NLS72 has a student level table, a student-transcript level table, etc.
    - From the perspective of a database person, it wouldn't make sense to store student level variables (e.g., birth-date) on the student-transcript level table because student birth-date does not vary by transcript, so this would result in needless duplication of data
- Structured Query Language (SQL) is the universally-used programming language for relational databases

__Real-world examples of relational databases__

- iTunes
    - Behind the scenes, there are separate tables for artist, album, song, genre, etc.
    - The "library" you see as a user is the result of "on the fly" joins of these tables
- Every social media app (e.g., twitter, fb, gram) you use is a relational database; 
    - What you see as a user is the result of "on the fly" joins of individual tables running in the background
- Interactive maps typically have relational databases running in the background
    - Clicking on some part of the map triggers a join of tables and you see the result of some analysis based on that join
    - e.g., our [off-campus recruiting map](https://map.emraresearch.org/)

Should you think of combining data-frames in R as "merging" flat-files or "joining" tables of a relational database?

- Can think of it either way; but I think better to think of it _both_ ways
- For example, you can think of the NLS72 datasets as:
    - a bunch of flat-files that we merge
    - OR a set of tables that comprise a relational database
- Although we are combining flat-files, tidyverse uses the terminology (e.g, "keys," "join") of relational databases for doing so


# Keys

__Keys__ are "the variables used to connect each pair of tables" in a relational database

<br>
__An important thing to keep in mind before we delve into an in-depth discussion of keys__

- Even though relational databases often consist of many tables, __relations__ are always defined between a __pair__ of tables
- When joining tables, focus on joining __one__ table to __another__; you make this "join" using the __key variable(s)__ that define the relationship between these two tables
- Even when your analysis requires variables from more than two tables, you proceed by joining one pair of tables at a time

<br>
__Definition of keys__

- Wickham: "A key is a variable (or set of variables) that uniquely identifies an observation"
- In other words, no two observations in the dataset have the same value of the key


In the simplest case, a single variable uniquely identifies observations and, thus, the key is simply that variable

- e.g., the variable `id` -- "unique student identification variable" -- uniquely identifies observations in the dataset `nls_stu` 
- No two observations in `nls_stu` have the same value of `id`

Let's confirm that each value of `id` is associated with only one observation

```r
#approach A: create a variable that counts how many rows there are for each unique value of your candidate key
nls_stu %>% group_by(id) %>% # group by your candidate key
  summarise(n_per_id=n()) %>% # create a measure of number of observations per group
  ungroup %>% # ungroup, otherwise frequency table [next step] created separately for each group
  count(n_per_id) # frequency of number of observations per group
#> # A tibble: 1 x 2
#>   n_per_id     n
#>      <int> <int>
#> 1        1 22652

#approach B: count how many values of id have more than one observation per id
nls_stu %>% 
  count(id) %>% # create object that counts the number of obs for each value of id
  filter(n>1) # keep only rows where count of obs per id is greater than 1
#> # A tibble: 0 x 2
#> # ... with 2 variables: id <dbl>, n <int>
```

- Approach B is simpler from a coding perspective, but I prefer Approach A

<br>
__Often, multiple variables are required to create the key for a table__

Student task: confirm that the variables `id` and `transnum` form the key for the table `nls_tran`

```r
#ERASE THIS CODE?
nls_tran %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 24253

nls_tran %>% count(id,transnum) %>% filter(n>1)
#> # A tibble: 0 x 3
#> # ... with 3 variables: id <dbl>, transnum <dbl>, n <int>
```
__The first step before merging a pair of tables is always to identify the key for each table__.  We have already identified the key for `nls_stu` and `nls_tran`.

__Student task__: 

- try to identify the key for `nls_stu_pets`, `nls_term` and for `nls_course`


```r
#DELETE THIS CODE?
#nls_stu_pets
nls_stu_pets %>% group_by(id) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 14759

#nls_term
nls_term %>% group_by(id,transnum,termnum) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key      n
#>       <int>  <int>
#> 1         1 120885

#nls_course; key doesn't exist
nls_course %>% group_by(id,transnum,termnum,crsecip) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 24 x 2
#>    n_per_key      n
#>        <int>  <int>
#>  1         1 403677
#>  2         2  25658
#>  3         3   4439
#>  4         4   1784
#>  5         5    715
#>  6         6    375
#>  7         7    136
#>  8         8     61
#>  9         9     37
#> 10        10     25
#> # ... with 14 more rows
```
The dataset `nls_course` doesn't have a key! That is, there is no combination of variables that uniquely identifies each observation in `nls_course`.

When a table doesn't have a key, you can create one. This is called a __surrogate__ key


```r
nls_course_temp <- nls_course %>% group_by(id,transnum,termnum) %>% 
  mutate(coursenum=row_number()) %>% ungroup

nls_course_temp %>%  group_by(id,transnum,termnum,coursenum) %>%
  summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key      n
#>       <int>  <int>
#> 1         1 484522

rm(nls_course_temp)  
```


## Primary keys and foreign keys

So far, our discussion of keys has focused on a single table. 

As we consider the relationship between tables, there are two types of keys, __primary key__ and __foreign key__:

### Primary key

__Definition of primary key__: 

- a variable (or combination of variables) in a table that uniquely identifies observations in its own table
- this definition is the same as our previous definition for __key__

__Examples of primary keys:__

- e.g., `id` is the _primary key_ for the dataset `nls_stu`
    

```r
nls_stu %>% group_by(id) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 22652
```
    
- e.g., `id` and `transnum` form the _primary key_ for the dataset `nls_trans`

```r
nls_tran %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 24253
```

- But note that the dataset `nls_course` did not have a _primary key_

```r
nls_course %>% group_by(id,transnum,termnum,crsecip) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 24 x 2
#>    n_per_key      n
#>        <int>  <int>
#>  1         1 403677
#>  2         2  25658
#>  3         3   4439
#>  4         4   1784
#>  5         5    715
#>  6         6    375
#>  7         7    136
#>  8         8     61
#>  9         9     37
#> 10        10     25
#> # ... with 14 more rows
```


### Foreign key

__Definition of foreign key__: 

- A variable (or combination of variables) in a table that uniquely identify observations in another table
- Said differently, a foreign key is a variable (or combination of variables) in a table that is the primary key in another table

Personally, I find the concept __foreign key__ a little bit slippery. Here is how I wrap my head around it: 

- First, always remember that "joins" happen between two specific tables, so have two specific tables in mind
- Second, to understand _foreign key_ concept, I think of a "focal table" [my term] (e.g., `nls_tran`) and some "other table" (e.g., `nls_stu`). 
- Third, then, the foreign key is a variable (or combination of variables) that satisfies two conditions (A) and (B):
    - (A) exists in the "focal table" (but may or may not be the primary key for the focal table)
    - (B) exists in the "other table" __AND__ is the primary key for that "other table"

__Example of foreign key__

- With respect to the "focal table" `nls_tran` and the "other table" `nls_stu`, the variable `id` is the _foregn key_ because:
    - `id` exists in the "focal table" `nls_trans` (though it does not uniquely identifies observations in `nls_trans`)
    - `id` exists in the "other table" `nls_stu` and `id` uniquely identifies observations in `nls_stu`

```r
nls_tran %>% group_by(id) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 7 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1  8022
#> 2         2  4558
#> 3         3  1681
#> 4         4   415
#> 5         5    71
#> 6         6     6
#> 7         7     3

nls_stu %>% group_by(id) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 22652
```

__Example of foreign key__

- With respect to the "focal table" `nls_term` and the "other table" `nls_trans`, the variables `id` and `transnum` form the _foreign key_ because:
    - These variables exists in the "focal table" `nls_term,` (though they do not uniquely identifies observations in `nls_term`)
    - These variables exist in the "other table" `nls_tran` and they uniquely identifies observations in `nls_tran`


```r
nls_term %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 34 x 2
#>    n_per_key     n
#>        <int> <int>
#>  1         1  2644
#>  2         2  2199
#>  3         3  1728
#>  4         4  1761
#>  5         5  1288
#>  6         6  1333
#>  7         7  1024
#>  8         8  1234
#>  9         9  1146
#> 10        10   911
#> # ... with 24 more rows

nls_tran %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 24253
```


In practice, you join two tables without explicit thinking about "primary key" vs. "foreign key" and "focal table" vs. "other table"

- Doesn't matter wich data frame you "start with" (e.g., as the "focal table")
- The only requirements for joining are:
    1. One of the two data frames have a __primary key__ (variable or combination of variables that uniquely identify observations) __AND__
    1. That variable or combination of variables is available in the other of the two data frames
  

# Mutating joins

## Overview of mutating joins

Following Wickham, we'll explain joins by creating hypothetical tables `x` and `y`

```r
x <- tribble(
  ~key, ~val_x,
     1, "x1",
     2, "x2",
     3, "x3"
)
y <- tribble(
  ~key, ~val_y,
     1, "y1",
     2, "y2",
     4, "y3"
)
x
#> # A tibble: 3 x 2
#>     key val_x
#>   <dbl> <chr>
#> 1     1 x1   
#> 2     2 x2   
#> 3     3 x3
y
#> # A tibble: 3 x 2
#>     key val_y
#>   <dbl> <chr>
#> 1     1 y1   
#> 2     2 y2   
#> 3     4 y3
```

A __join__ "is a way of connecting each row in `x` to zero, one, or more rows in `y`"

Observations in table `x` matched to observations in table `y` using a "key" variable

- A key is a variable (or combination of variables) that exist in both tables and uniquely identifies observations in at least one of the two tables

Two tables `x` and `y` can be "joined" when the primary key for table `x` can be found in table `y`; in other words, when table `y` contains the _foreign key_, which uniquely identifies observations in table `x`
 
- e.g., use `id` to join `nls_stu` and `nls_tran` because `id` is the primary key for `nls_stu` (i.e., uniquely identifies obs in `nls_stu`) and `id` can be found in `nls_tran`

There are four types of joins between tables `x` and `y`:

- __inner join__: keep all observations that appear in both table `x` and table `y`
- __left join__: keep all observations in `x` (regardless of whether these obs appear in `y`)
- __right join__: keep all observations in `y` (regardless of whether these obs appear in `x`)
- __full join__: keep all observations that appear in `x` or in `y`

The last three joins -- left, right, full -- keep observations that appear in at least one table and are collectively referred to as __outer joins__

The following Venn diagram -- copied from Grolemund and Wickham Chapter 13 -- is useful for developing an initial understanding of the four join types

![](http://r4ds.had.co.nz/diagrams/join-venn.png)


<br>
We will join tables `x` and `y` using the  `join()` command from `dplyr` package.  `join()` is a general command, which has more specific commands for each type of join:

- `inner_join()`
- `left_join()`
- `right_join()`
- `full_join()`

<br>
Note that all of these join commands result in an object that contains __all__ the variables from `x` and all the variables from `y`

- So if you want resulting object to contain a subset of variables from `x` and `y`, then prior to the join, you should eliminate unwanted variables from `x` and/or `y`

### How we'll teach joins

- I'll spend the most amount of time on __inner joins__, e.g., moving from simpler to more complicated joins. 
- I'll spend less time on __outer joins__ because most of the stuff from inner joins will apply to outer joins too
- Note: all of the cool, multi-colored visual representations of joins are copied __directly__ from Grolemund and Wickham, Chapter 12) 


## Inner joins

__inner joins__ keep all observations that appear in both table `x` and table `y`

- More correctly, an inner join mathes observations from two tables "whenever their keys are equal"
- If there are multiple matches between `x` and `y`, all combination of the matches are returned.
    - e.g., if object `x` has one row where the variable `key==1` and object `y` has two rows where the variable `key==1`, the resulting object will contain two rows where the variable `key==1`

Visual representation of `x` and `y`:

![](join-setup.png)

- the colored column in each dataset is the "key" variable. The key variable(s) match rows between the tables.

<br>
Below is a visual representation of an inner join. 

- Matches in a join (rows common to both `x` and `y`) are indicated with dots. "The number of dots=the number of matches=the number of rows in the output"

![](join-inner.png)


<br>
The basic synatx in R: `inner_join(x, y, by ="keyvar")`

- where `x` and `y` are names of tables to join
- `by` specifies the name of the key variable or the combination of variables that form the key


```r
x
#> # A tibble: 3 x 2
#>     key val_x
#>   <dbl> <chr>
#> 1     1 x1   
#> 2     2 x2   
#> 3     3 x3
y
#> # A tibble: 3 x 2
#>     key val_y
#>   <dbl> <chr>
#> 1     1 y1   
#> 2     2 y2   
#> 3     4 y3

#inner_join (without pipes)
inner_join(x,y, by = "key")
#> # A tibble: 2 x 3
#>     key val_x val_y
#>   <dbl> <chr> <chr>
#> 1     1 x1    y1   
#> 2     2 x2    y2

#inner_join (with pipes)
x %>% 
  inner_join(y, by = "key")
#> # A tibble: 2 x 3
#>     key val_x val_y
#>   <dbl> <chr> <chr>
#> 1     1 x1    y1   
#> 2     2 x2    y2
```

<br>
__Practical example__: 

- let's try an inner join of the two datasets `nls_stu` and `nls_stu_pets`

I recommend these general steps when merging two datasets

1. Identify `key` variable for `join()` command by investigating the data structure of each dataset. Do stuff like this:
    - which variables uniquely identify obs (i.e., what is the "key" in each table)
        - note: not all tables have keys
    - Once you identify the primary key for one of the tables, make sure that variable (or combination of variables) exists in the other table
    - Identify key variables you will use to join the two tables
2. Join variables
3. Assess/investigate quality of join
    - This is basically exploratory data analysis for the purpose of data quality
        - e.g., for obs that don't "match", investigate why (what are the patterns)
    - We talk about these investigations in more detail below in section on __filtering joins__ and section on __join problems__
    

__Task__: inner join of the two datasets `nls_stu` and `nls_stu_pets`

```r
#investigate data structure
nls_stu %>% group_by(id) %>% summarise(n_per_id=n()) %>% ungroup %>% count(n_per_id) 
#> # A tibble: 1 x 2
#>   n_per_id     n
#>      <int> <int>
#> 1        1 22652
nls_stu_pets %>% group_by(id) %>% summarise(n_per_id=n()) %>% ungroup %>% count(n_per_id) 
#> # A tibble: 1 x 2
#>   n_per_id     n
#>      <int> <int>
#> 1        1 14759

#id is primary key for both datasets, so use id as key variable

nls_stu_stu <- nls_stu %>% 
  inner_join(nls_stu_pets, by = "id")
#> Warning: Column `id` has different attributes on LHS and RHS of join

names(nls_stu_stu)
#>  [1] "id"       "schcode"  "bysex"    "csex"     "crace"    "cbirthm" 
#>  [7] "cbirthd"  "cbirthyr" "reqtrans" "numtrans"

nrow(nls_stu)
#> [1] 22652
nrow(nls_stu_pets)
#> [1] 14759
nrow(nls_stu_stu)
#> [1] 14759
```
### one-to-one join vs. one-to-many join

Note: Wickham refers to the concepts in this section as "duplicate keys"

General rule rule of thumb for joining two tables

- __key variable must uniquely identify observations in at least one of the tables you are joining__

Depending on whether the key variable uniquely identifies observations in table `x` and/or table `y` you will have:

- __one-to-one__ join: key variable uniquely identifies observations in table `x` and uniquely identifies observations in table `y`
    - The join between `nls_stu` and `nls_stu_pets` was a one-to-one join; the variable `id` uniquely identifies observations in both tables
    - In the relational database world one-to-one joins are rare and are considered special cases of one-to-many or many-to-one joins
        - Why? if tables can be joined via one-to-one join, then they should already be part of the same table.
- __one-to-many__ join: key variable uniquely identifies observatiosn in table `x` and does not uniquely identify observations in table `y`
    - each observation from table `x` may match to multiple observations from table `y'
    - e.g., `inner_join(nls_stu, nls_trans, by = "id")`
- __many-to-one__ join: key variable does not uniquely identify observations in table `x` and does uniquely identify observations in table `y`
    - each observation from table `y` may match to multiple observations from table `x'
    - e.g., `inner_join(nls_trans, nls_trans, by = "id")`
- __many-to-many__ join: key variable does not uniquely identify observations in table `x' and does not uniquely identify observations in table `y`
    - This is usually an error


Many-to-one merge using fictitious tables `x` and `y`

```r
#create new versions of table x and table y
x <- tribble(
  ~key, ~val_x,
     1, "x1",
     2, "x2",
     2, "x3",
     1, "x4"
)
y <- tribble(
  ~key, ~val_y,
     1, "y1",
     2, "y2"
)
x
#> # A tibble: 4 x 2
#>     key val_x
#>   <dbl> <chr>
#> 1     1 x1   
#> 2     2 x2   
#> 3     2 x3   
#> 4     1 x4
y
#> # A tibble: 2 x 2
#>     key val_y
#>   <dbl> <chr>
#> 1     1 y1   
#> 2     2 y2
```

Step 1: Investigate the two tables

- Note that `key` does not uniquely identify observations in `x` but does uniquely identify observations in `y`

```r
x %>% group_by(key) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         2     2
y %>% group_by(key) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1     2
```

Visual representation of merge

![](join-many-to-one.png)

Step 2: "join" the two tables

```r
left_join(x, y, by = "key")
#> # A tibble: 4 x 3
#>     key val_x val_y
#>   <dbl> <chr> <chr>
#> 1     1 x1    y1   
#> 2     2 x2    y2   
#> 3     2 x3    y2   
#> 4     1 x4    y1
```
<br>
__Student-task__: 

- conduct a one-to-many inner join of the two datasets `nls_stu` and `nls_trans`

Fine to try doing it without looking at solutions, or just work through solutions below

<br>
<br>
__Solution to student task__: steps

1. Invesigate data structure
2. Join variables
3. Assess/investigate quality of join

```r
#Investigate data
#we know id is primary key for nls_stu, investigate primary key for nls_tran

#id does not uniquely identify obs in nls_tran
nls_tran %>% group_by(id) %>% summarise(n_per_key=n()) %>% ungroup %>% 
  filter(n_per_key>1) %>% count(n_per_key) 
#> # A tibble: 6 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         2  4558
#> 2         3  1681
#> 3         4   415
#> 4         5    71
#> 5         6     6
#> 6         7     3

#id and transnum uniquely identify obs
nls_tran %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% 
  filter(n_per_key>1) %>% count(n_per_key) 
#> # A tibble: 0 x 2
#> # ... with 2 variables: n_per_key <int>, n <int>

#id uniquely identifies obs in nls_stu and id is available in nls_tran, so use id as key

#merge
nls_stu_tran <- nls_stu %>% inner_join(nls_tran, by = "id")
#> Warning: Column `id` has different attributes on LHS and RHS of join

#investigate results of merge
names(nls_stu_tran)
#>  [1] "id"       "schcode"  "bysex"    "csex"     "crace"    "cbirthm" 
#>  [7] "cbirthd"  "cbirthyr" "transnum" "findisp"  "trnsflag" "terms"   
#> [13] "fice"     "state"    "cofcon"   "instype"  "itype"
nrow(nls_stu)
#> [1] 22652
nrow(nls_tran)
#> [1] 24253
nrow(nls_stu_tran)
#> [1] 24253

#Below sections show how to investigate quality of merge in more detail
```
### Defining the key columns

Thus far, tables have been joined by a single "key" variable using this syntax:

- `inner_join(x,y, by = "keyvar")`

Often, multiple variables form the "key". Specify this using this syntax:

- `inner_join(x,y, by = c("keyvar1","keyvar2","..."))`

__Practical example__: 

- perform an inner join of `nls_tran` and `nls_term`

```r
#Investigate
nls_tran %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% 
  filter(n_per_key>1) %>% count(n_per_key) 
#> # A tibble: 0 x 2
#> # ... with 2 variables: n_per_key <int>, n <int>

nls_term %>% group_by(id,transnum,termnum) %>% summarise(n_per_key=n()) %>% ungroup %>% 
  filter(n_per_key>1) %>% count(n_per_key)
#> # A tibble: 0 x 2
#> # ... with 2 variables: n_per_key <int>, n <int>


#merge
nls_tran_term <- nls_tran %>% inner_join(nls_term, by = c("id","transnum"))

#investigate
nrow(nls_tran)
#> [1] 24253
nrow(nls_term)
#> [1] 120885
nrow(nls_tran_term)
#> [1] 120807

#appears that some observations from nls_term did not merge with nls_trans
  #we shoudl investigate this further [below]
```
<br>
Sometimes a key variable in one table has a different variabel name in the other table. You can specify that the variables to be matched from one table to another as follows:

- `inner_join(x,y, by = c("keyvarx" = "keyvary"))`

__Practical example__: 

- perform inner join between `nls_stu` and `nls_tran`:

```r
#we've seen this code before
nls_stu_tran <- nls_stu %>% inner_join(nls_tran, by = "id")
#> Warning: Column `id` has different attributes on LHS and RHS of join
#but this code works too
nls_stu_tran <- nls_stu %>% inner_join(nls_tran, by = c("id" = "id"))
#> Warning: Column `id` has different attributes on LHS and RHS of join

#and this code would work too
nls_stu_tran <- nls_stu %>% rename(idv2=id) %>% # rename id var in nls_stu
  inner_join(nls_tran, by = c("idv2" = "id"))
#> Warning: Column `idv2`/`id` has different attributes on LHS and RHS of join
```
Same syntax can be used when key is formed from multiple variables

- show using merge of `nls_tran` and `nls_term`

```r
#we've seen this code before
nls_tran_term <- nls_tran %>% inner_join(nls_term, by = c("id","transnum"))

#this code works too
nls_tran_term <- nls_tran %>% inner_join(nls_term, by = c("id" = "id","transnum" = "transnum"))

#and so does this
nls_tran_term <- nls_tran %>% rename(transnumv2=transnum) %>%
  inner_join(nls_term, by = c("id" = "id","transnumv2" = "transnum"))
```

## Outer joins


Thus far we have focused on "inner joins"

- keep all observations that appear in both table `x` and table `y`

"outer joins" keep observations that appear in at least one table. There are three types of outer joins:

- __left join__: keep all observations in `x` (regardless of whether these obs appear in `y`)
- __right join__: keep all observations in `y` (regardless of whether these obs appear in `x`)
- __full join__: keep all observations that appear in `x` or in `y`

### Description of the four join types from R help file

The syntax for the outer join commands is identical to inner joins, so once you understand inner joins, outer joins are not difficult.

- `inner_join()`
    - return all rows from x where there are matching values in y, and all columns from x and y. If there are multiple matches between x and y, all combination of the matches are returned.

- `left_join()`
    - return all rows from x, and all columns from x and y. Rows in x with no match in y will have NA values in the new columns. If there are multiple matches between x and y, all combinations of the matches are returned.

- `right_join()`
    - return all rows from y, and all columns from x and y. Rows in y with no match in x will have NA values in the new columns. If there are multiple matches between x and y, all combinations of the matches are returned.

- `full_join()`
    - return all rows and all columns from both x and y. Where there are not matching values, returns NA for the one missing.




### Visual representation of outer joins

This figures are copied straight from Wickham chapter 12

__Venn diagram of joins__

![](http://r4ds.had.co.nz/diagrams/join-venn.png)


__We want to perform outer joins on these two tables__

![](join-setup.png)

__Visual representation of outer joins__

"These joins work by adding an additional “virtual” observation to each table. This observation has a key that always matches (if no other key matches), and a value filled with NA."

![Outer joins](join-outer.png)

### Practicing outer joins

The left-join is the most commonly used outer join in social science research (more common than inner join too). 

Why is this? Often, we start with some dataset `x` (e.g., `nls_stu`) and we want to add variables from dataset `y`

- Usually, we want to keep observations from `x` regardless of whether they match with `y`
- Usually uninterested in observations from `y` that did not match with `x`

__Student task__ (try doing yourself or just follow along): 

- start with `nls_stu_pets`
- perform a left join with `nls_stu` and save the object
- Then perform a left join with `nls_tran`


```r

#investigate data structure of nls_stu_pets and nls_tran
nls_stu_pets %>% group_by(id) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 14759
nls_stu %>% group_by(id) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 22652

#left merge w/ nls_stu_pets as x table and nls_tran as y table
nls_stu_pets_stu <- nls_stu_pets %>% 
  left_join(nls_stu, by = "id")
#> Warning: Column `id` has different attributes on LHS and RHS of join

#investigate data structure of merged object
nrow(nls_stu_pets)
#> [1] 14759
nrow(nls_stu)
#> [1] 22652
nrow(nls_stu_pets_stu)
#> [1] 14759

#investigate data structure of nls_stu_pets and nls_tran
nls_tran %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 24253

#merge nls_stu_pets_stu with nls_tran
nls_stu_pets_stu_tran <- nls_stu_pets_stu %>% 
  left_join(nls_tran, by = "id")

#investigate data structure of merged object
nrow(nls_stu_pets_stu)
#> [1] 14759
nrow(nls_tran)
#> [1] 24253
nrow(nls_stu_pets_stu_tran) # 3 more obs in resulting dataset than in nls_tran
#> [1] 24256
```


# Filtering joins

__Filtering joins__ are very similar to _mutating joins_. 

Filtering joins affect which observations are retained in the resulting object, but not which variables are retained

There are two types of filtering joins, `semi_join()` and `anti_join()`. Here are their descriptions from `?join`:

- `anti_join(x, y)`
    - return all rows from x where there are not matching values in y, keeping just columns from x
- `semi_join(x, y)`
    - return all rows from x where there are matching values in y, keeping just columns from x.
    
Difference between a `semi_join()` and an `inner_join()` in terms of which observations are present in the resulting object:

- Imagine that if object `x` has one row with `key==4` and object `y` has two rows with `key==4`' 
- __inner_join__: resulting object will have two rows with `key==4`
- __semi_join__: resulting object will have one row with `key==4`
    - Why? __because the rule for `semi_join` is to never duplicate rows of x__

Note: syntax for `semi_join()` and `anti_join()` follows the exact same patterns as syntax for mutating joins (e.g., `inner_join()` `left_join`)

## Using `anti_join()` to diagnose mismatches in mutating joins

A primary use of filtering joins is as an investigative tool to diagnose problems with mutating joins

__Practical example__: Investigate observations that don't match from `inner_join()` of `nls_tran` and `nls_course`

- transcript data has info on postsecondary transcripts; course data has info on each course in postsecondary transcript


```r
#assert that id and transnum uniquely identify obs in nls_trans
nls_tran %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 24253

#join data frames
nls_tran %>% inner_join(nls_course, by = c("id","transnum")) %>% count()
#> # A tibble: 1 x 1
#>        n
#>    <int>
#> 1 484294

#compare to coint of number of obs in nls_course
nls_course %>% count()
#> # A tibble: 1 x 1
#>        n
#>    <int>
#> 1 484522

#difficult to tell which obs from nls_tran didn't merge

#use ant_join to isolate obs from nls_tran that didn't have match in nls_course
nls_tran %>% anti_join(nls_course, by = c("id","transnum")) %>% count()
#> # A tibble: 1 x 1
#>       n
#>   <int>
#> 1  5398

#create object of obs that didn't merge
tran_course_anti <- nls_tran %>% anti_join(nls_course, by = c("id","transnum"))
names(tran_course_anti)
#>  [1] "id"       "transnum" "findisp"  "trnsflag" "terms"    "fice"    
#>  [7] "state"    "cofcon"   "instype"  "itype"
tran_course_anti %>% select(findisp) %>% var_label()
#> $findisp
#> [1] "FINAL DISPOSITION"

tran_course_anti %>% select(findisp) %>% count(findisp)
#> # A tibble: 5 x 2
#>   findisp       n
#>   <dbl+lbl> <int>
#> 1 2           272
#> 2 3          2565
#> 3 4          1113
#> 4 5           210
#> 5 6          1238
tran_course_anti %>% select(findisp) %>% val_labels()
#> $findisp
#>      1. TRANSCRIPT RECEIVED           2. SCHOOL REFUSED 
#>                           1                           2 
#>   3. STUDENT NEVER ATTENDED 4. SCHOOL LOST OR DESTROYED 
#>                           3                           4 
#>            5. SCHOOL CLOSED  6. NO RESPONSE FROM SCHOOL 
#>                           5                           6
tran_course_anti %>% select(findisp) %>% count(findisp) %>% as_factor()
#> # A tibble: 5 x 2
#>   findisp                         n
#>   <fct>                       <int>
#> 1 2. SCHOOL REFUSED             272
#> 2 3. STUDENT NEVER ATTENDED    2565
#> 3 4. SCHOOL LOST OR DESTROYED  1113
#> 4 5. SCHOOL CLOSED              210
#> 5 6. NO RESPONSE FROM SCHOOL   1238
```

__Practical example__: perform an inner-join of `nls_tran` and `nls_course` and a semi-join of `nls_tran` and `nls_course`.

- How do the results of these two joins differ?
- How can this semi-join be practically useful?


```r
#inner join
inner_tran_course <- nls_tran %>% inner_join(nls_course, by = c("id","transnum"))

#semi-join
semi_tran_course <- nls_tran %>% semi_join(nls_course, by = c("id","transnum"))
```

- How do the results of these two joins differ?
    - semi-join contains obs from `x` that matched with `y` [nls_course] but does not repeat rows of x
    - semi-join only retains columns from `x`
- How can this semi-join be practically useful?
    - NOT 100% SURE YET...
    - PATRICIA HELP IDENTIFYING PRACTICAL USE OF FILTERING JOINS

# Join problems

How to avoid join problems before they arise. How to overcome join problems when they do arise

## Overcoming join problems before they arise

1. Start by investigating the data structure of tables you are going to merge
    - identify the primary key in each table.
        - This investigation should be based on your understanding of the data and reading data documentation rather than checking if each combination of variables is a primary key
    - does either table have missing or strange values (e.g., `-8`) for the primary key; if so, these observations won't match
1. Before joining, make sure that key you will use for joining uniquely identifies observations in at least one of the datasets and that the key variable(s) is present in both datasets
    - investigate whether key variables have different names across the two tables. If different, then you will have to adjust syntax of your join statement accordingly
1. Think about which observations you want retained after joining
    - think about which dataset should be the `x` table and which should be the `y` table
    - think about whether you want an inner, left, right, or full join
1. Since mutating joins keep all variables in `x` and `y`, you may want to keep only specific variables in `x` and/or `y` as a prior step to joining
    - Make sure that non-key variables from tables have different names; if duplicate names exist, the default is to CHECK ON DEFAULT

## Overcoming join problems when they do arise

- Identify which observations don't match
    - `anti_join()` is your friend here
- Investigate the reasons that observations don't match
    - Investigating joins is a craft that takes some practice getting good at; this is essentially an exercise in exploratory data analysis for the purpose of data quality
    - First, you have to _care_ about data quality
    - Identifying causes for non-matches usually involves consulting data documentation for both tables and performing basic descriptive statistics (e.g., frequency tables) on specific variables that documentation suggests may be relevant for whether obs match or not

STUFF FOR PATRICIA TO CHECK
- WHAT IF KEY VARIABLE IS STRING IN ONE TABLE AND NUMERIC IN ANOTHER TABLE? THIS IS A PROBLEM IN STATA. IS IT A PROBLEM IN R?

POTENTIAL THING FOR PATRICIA TO ADD:

- [OWN: WHAT THIS LECTURE IS MISSING IS WALKING STUDENTS THROUGH INVESTIGATION OF WHY OBS DON'T MATCH; EITHER ADD THIS TO THE LECTURE OR MAKE THIS A BIG PART OF THE PROBLEM SET AND QUESTIONS YOU ASK WILL WALK THEM THROUGH STEPS OF A MERGING INVESTIGATION]
- PATRICIA, DO YOU THINK THIS WOULD BE USEFUL AND WOULD YOU LIKE TO ADD THIS?

# Appending/stacking data

Often we want to "stack" multiple datasets on top of one another

- typically datasets have the same variables, so stacking means that number of variables remains the same but number of observations increases

We append data using the `bind_rows()` function, which is from the _dplyr_ package

```r
#?bind_rows

time1 <- tribble(
  ~id, ~year, ~income,
     1, 2017, 50,
     2, 2017, 100,
     3, 2017, 200
)
time2 <- tribble(
  ~id, ~year, ~income,
     1, 2018, 70,
     2, 2018, 120,
     3, 2018, 220
)

time1
#> # A tibble: 3 x 3
#>      id  year income
#>   <dbl> <dbl>  <dbl>
#> 1     1  2017     50
#> 2     2  2017    100
#> 3     3  2017    200
time2
#> # A tibble: 3 x 3
#>      id  year income
#>   <dbl> <dbl>  <dbl>
#> 1     1  2018     70
#> 2     2  2018    120
#> 3     3  2018    220

append_time <- bind_rows(time1,time2)
append_time
#> # A tibble: 6 x 3
#>      id  year income
#>   <dbl> <dbl>  <dbl>
#> 1     1  2017     50
#> 2     2  2017    100
#> 3     3  2017    200
#> 4     1  2018     70
#> 5     2  2018    120
#> 6     3  2018    220

append_time %>% arrange(id,year)
#> # A tibble: 6 x 3
#>      id  year income
#>   <dbl> <dbl>  <dbl>
#> 1     1  2017     50
#> 2     1  2018     70
#> 3     2  2017    100
#> 4     2  2018    120
#> 5     3  2017    200
#> 6     3  2018    220
```

<br>
<br>
Most common practical use of stacking is creating "longitudinal dataset" when input data are released separately for each time period

- longitudinal data has one row per time period for a person/place/observation

__Practical Example__:

- IPEDS collects annual survey data from colleges/universities
- Create longitudinal data about university characteristics by appending/staking annual data

Load annual IPEDS data on admissions characteristics

```r

admit16_17 <- read_dta(file="https://github.com/ozanj/rclass/raw/master/data/ipeds/ic/ic16_17_admit.dta") %>%
  select(unitid,endyear,sector,contains("admcon"),contains("numapply"),contains("numadmit"))

glimpse(admit16_17)
#> Observations: 2,068
#> Variables: 18
#> $ unitid      <dbl> 100654, 100663, 100706, 100724, 100751, 100830, 10...
#> $ endyear     <dbl> 2017, 2017, 2017, 2017, 2017, 2017, 2017, 2017, 20...
#> $ sector      <dbl+lbl> 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 2, 2, 1, 2, 1...
#> $ admcon1     <dbl+lbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 3, 1, 1, 2...
#> $ admcon2     <dbl+lbl> 2, 3, 2, 3, 2, 2, 2, 1, 2, 2, 3, 2, 3, 3, 2, 3...
#> $ admcon3     <dbl+lbl> 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
#> $ admcon4     <dbl+lbl> 2, 1, 1, 3, 1, 3, 1, 3, 3, 3, 3, 2, 3, 3, 2, 2...
#> $ admcon5     <dbl+lbl> 3, 3, 3, 3, 3, 3, 2, 1, 2, 2, 3, 2, 1, 3, 2, 3...
#> $ admcon6     <dbl+lbl> 2, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 3, 3...
#> $ admcon7     <dbl+lbl> 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1...
#> $ admcon8     <dbl+lbl> 1, 3, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1...
#> $ admcon9     <dbl+lbl> 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 3, 3, 3, 3, 3...
#> $ numapplymen <dbl> 2725, 3510, 2385, 2967, 14846, 1021, 7886, 1525, 2...
#> $ numapplywom <dbl> 4318, 5949, 2160, 6086, 23391, 1884, 10370, 2197, ...
#> $ numapplytot <dbl> 7043, 9459, 4545, 9053, 38237, 2905, 18256, 3722, ...
#> $ numadmitmen <dbl> 2276, 2062, 1930, 1293, 7819, 786, 6314, 818, 87, ...
#> $ numadmitwom <dbl> 3878, 3437, 1537, 2862, 12288, 1439, 8390, 983, 64...
#> $ numadmittot <dbl> 6154, 5499, 3467, 4155, 20107, 2225, 14704, 1801, ...
admit16_17 %>% var_label()
#> $unitid
#> [1] "Unique identification number of the institution"
#> 
#> $endyear
#> NULL
#> 
#> $sector
#> [1] "Sector of institution"
#> 
#> $admcon1
#> [1] "Secondary school GPA"
#> 
#> $admcon2
#> [1] "Secondary school rank"
#> 
#> $admcon3
#> [1] "Secondary school record"
#> 
#> $admcon4
#> [1] "Completion of college-preparatory program"
#> 
#> $admcon5
#> [1] "Recommendations"
#> 
#> $admcon6
#> [1] "Formal demonstration of competencies"
#> 
#> $admcon7
#> [1] "Admission test scores"
#> 
#> $admcon8
#> [1] "TOEFL (Test of English as a Foreign Language"
#> 
#> $admcon9
#> [1] "Other Test (Wonderlic, WISC-III, etc.)"
#> 
#> $numapplymen
#> [1] "Applicants men"
#> 
#> $numapplywom
#> [1] "Applicants women"
#> 
#> $numapplytot
#> [1] "numapplymen + numapplywom"
#> 
#> $numadmitmen
#> [1] "Admissions men"
#> 
#> $numadmitwom
#> [1] "Admissions women"
#> 
#> $numadmittot
#> [1] "numadmitmen + numadmitwom"
#admit16_17 %>% val_labels()

#read in previous two years of data
admit15_16 <- read_dta(file="https://github.com/ozanj/rclass/raw/master/data/ipeds/ic/ic15_16_admit.dta") %>%
  select(unitid,endyear,sector,contains("admcon"),contains("numapply"),contains("numadmit"))

admit14_15 <- read_dta(file="https://github.com/ozanj/rclass/raw/master/data/ipeds/ic/ic14_15_admit.dta") %>%
  select(unitid,endyear,sector,contains("admcon"),contains("numapply"),contains("numadmit"))
```


Appending/Stack IPEDS datasets

```r
admit_append <- bind_rows(admit16_17,admit15_16,admit14_15)
#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'labelled' elements may not
#> preserve their attributes
#note that R complains about preserving "labelled" data; does not retain labels
str(admit_append)
#> Classes 'tbl_df', 'tbl' and 'data.frame':	6514 obs. of  18 variables:
#>  $ unitid     : num  100654 100663 100706 100724 100751 ...
#>  $ endyear    : num  2017 2017 2017 2017 2017 ...
#>  $ sector     : num  1 1 1 1 1 1 1 2 2 2 ...
#>  $ admcon1    : num  1 1 1 1 1 1 1 1 1 1 ...
#>  $ admcon2    : num  2 3 2 3 2 2 2 1 2 2 ...
#>  $ admcon3    : num  1 1 1 2 1 1 1 1 1 1 ...
#>  $ admcon4    : num  2 1 1 3 1 3 1 3 3 3 ...
#>  $ admcon5    : num  3 3 3 3 3 3 2 1 2 2 ...
#>  $ admcon6    : num  2 3 2 3 3 3 3 3 3 3 ...
#>  $ admcon7    : num  1 1 1 1 1 1 1 1 2 1 ...
#>  $ admcon8    : num  1 3 1 1 1 1 1 1 1 2 ...
#>  $ admcon9    : num  3 3 3 3 3 3 3 3 3 3 ...
#>  $ numapplymen: num  2725 3510 2385 2967 14846 ...
#>  $ numapplywom: num  4318 5949 2160 6086 23391 ...
#>  $ numapplytot: num  7043 9459 4545 9053 38237 ...
#>  $ numadmitmen: num  2276 2062 1930 1293 7819 ...
#>  $ numadmitwom: num  3878 3437 1537 2862 12288 ...
#>  $ numadmittot: num  6154 5499 3467 4155 20107 ...
```

Investigate structure

```r
admit_append %>% select(unitid,endyear,admcon1,admcon2,numapplytot,numadmittot) %>%
  arrange(unitid,endyear) %>% head(n=10)
#> # A tibble: 10 x 6
#>    unitid endyear admcon1 admcon2 numapplytot numadmittot
#>     <dbl>   <dbl>   <dbl>   <dbl>       <dbl>       <dbl>
#>  1 100654    2015       1       2        9901        5204
#>  2 100654    2016       1       2        7901        5166
#>  3 100654    2017       1       2        7043        6154
#>  4 100663    2015       1       3        5710        4893
#>  5 100663    2016       1       3        7672        4636
#>  6 100663    2017       1       3        9459        5499
#>  7 100706    2015       1       2        2104        1726
#>  8 100706    2016       1       2        3308        2686
#>  9 100706    2017       1       2        4545        3467
#> 10 100724    2015       1       3        7673        4087

#investigate data structure: one obs per unitid-endyear
admit_append %>% group_by(unitid,endyear) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1  6514
```
