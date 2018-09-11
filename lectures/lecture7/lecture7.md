---
title: Joining multiple datasets
subtitle:  Lecture 7
author: Ozan Jaquette
date: 
output: 
  html_document:
    toc: true
    toc_depth: 2
    toc_float: # toc_float option to float the table of contents to the left of the main document content. floating table of contents will always be visible even when the document is scrolled
      collapsed: false # collapsed (defaults to TRUE) controls whether the TOC appears with only the top-level (e.g., H2) headers. If collapsed initially, the TOC is automatically expanded inline when necessary
      smooth_scroll: true # smooth_scroll (defaults to TRUE) controls whether page scrolls are animated when TOC items are navigated to via mouse clicks
    number_sections: true
    fig_caption: true # ? this option doesn't seem to be working for figure inserted below outside of r code chunk    
    highlight: default # Supported styles include "default", "tango", "pygments", "kate", "monochrome", "espresso", "zenburn", and "haddock" (specify null to prevent syntax    
    theme: default # theme specifies the Bootstrap theme to use for the page. Valid themes include default, cerulean, journal, flatly, readable, spacelab, united, cosmo, lumen, paper, sandstone, simplex, and yeti.
    df_print: tibble #options: default, tibble, paged
    keep_md: true # may be helpful for storing on github
    
---



# Introduction

Rare for an analysis dataset to consist of data from only one input dataset. For most projects, each analysis dataset contains data from multiple data sources. Therefore, you must become proficient in combining data from multiple data sources.

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

Our main focus today is on _mutating joins_. _Filtering joins_ are useful fir data quality checks of _mutating joins_.

Libraries we will use

```r
library(tidyverse)
#> -- Attaching packages ------------------------------------------------------------------------------------ tidyverse 1.2.1 --
#> v ggplot2 3.0.0     v purrr   0.2.5
#> v tibble  1.4.2     v dplyr   0.7.6
#> v tidyr   0.8.1     v stringr 1.3.1
#> v readr   1.1.1     v forcats 0.3.0
#> -- Conflicts --------------------------------------------------------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(haven)
library(labelled)
```

## NLS72 data

Today's lecture will utilize several datasets from the National Longitudinal Survey of 1972 (NLS72)
- Student level dataset
- Student-transcript level dataset
- Student-transcript-term level dataset
- Student-transcript-term-course level dataset

These datasets good for teaching "joining" because you get practice joining data sources with different "observational levels" (e.g., join student level and student-transcript level data)

Below, we'll read-in Stata data files and keep a small number of variables

Student level data

```r
rm(list = ls()) # remove all objects

getwd()
#> [1] "C:/Users/ozanj/Documents/rclass/lectures/lecture7"
nls_stu <- read_dta(file="../../data/nls72/nls72stu_percontor_vars.dta") %>%
  select(id,schcode,bysex,csex,crace,cbirthm,cbirthd,cbirthyr)

#get a feel for the data
names(nls_stu)
#> [1] "id"       "schcode"  "bysex"    "csex"     "crace"    "cbirthm" 
#> [7] "cbirthd"  "cbirthyr"
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
nls_stu %>% select(bysex) %>% count(bysex)
#> # A tibble: 4 x 2
#>   bysex         n
#>   <dbl+lbl> <int>
#> 1 " 1"       8208
#> 2 " 2"       8340
#> 3 98          135
#> 4 99         5969
nls_stu %>% select(bysex) %>% count(bysex) %>% as_factor()
#> # A tibble: 4 x 2
#>   bysex                       n
#>   <fct>                   <int>
#> 1 1. male                  8208
#> 2 2. female                8340
#> 3 98. {ILLEGITIMATE SKIP}   135
#> 4 99. {LEGITIMATE SKIP}    5969
```
Student level dataset containing variables about completeness of postsecondary education transcripts (PETS)

```r
nls_stu_pets <- read_dta(file="../../data/nls72/nls72petsstu_v2.dta") %>%
  select(id,reqtrans,numtrans)

names(nls_stu_pets)
#> [1] "id"       "reqtrans" "numtrans"
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

Student-transcript level data

```r
nls_tran <- read_dta(file="../../data/nls72/nls72petstrn_v2.dta") %>%
  select(id,transnum,findisp,trnsflag,terms,fice,state,cofcon,instype,itype)

names(nls_tran)
#>  [1] "id"       "transnum" "findisp"  "trnsflag" "terms"    "fice"    
#>  [7] "state"    "cofcon"   "instype"  "itype"
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
```

Student-transcript-term level data

```r
nls_term <- read_dta(file="../../data/nls72/nls72petstrm_v2.dta") %>%
  select(id,transnum,termnum,courses,termtype,season,sortdate,gradcode,transfer)

names(nls_term)
#> [1] "id"       "transnum" "termnum"  "courses"  "termtype" "season"  
#> [7] "sortdate" "gradcode" "transfer"
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
```

Student-transcript-term-course level data

```r
nls_course <- read_dta(file="../../data/nls72/nls72petscrs_v2.dta") %>%
  select(id,transnum,termnum,crsecip,crsecred,gradtype,crsgrada,crsgradb)

names(nls_course)
#> [1] "id"       "transnum" "termnum"  "crsecip"  "crsecred" "gradtype"
#> [7] "crsgrada" "crsgradb"
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
```

## Relational databases and tables

__Traditionally, social scientists store data in "flat files"__

- flat files are "rectangular" datasets consisting of columns (usually called variables) and rows (usually called observations)
- When we want to incorporate variables from two flat files, we "merge" them together.

__The rest of the world stores data in "relational databases"__

- A relational database consists of multiple __tables__
- Each table is a flat file
- A goal of relational databases is to store data using the minimum possible space; Therefore, a rule is to never duplicate information across tables
- When you need information from multiple tables, you merge ("join") tables "on the fly" rather than creating some permanent flat file that contains data from multiple tables
- Each table in a relational database has a different "observational level"
    - For example, the NLS data have a student level table, a student-transcript level table, etc.
    - It wouldn't make sense to store student level variables (e.g., birth-date) on the student-transcript level table because student birth-date does not vary by transcript, so this would result in needless duplication of data
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
    - a set of tables that comprise a relational database
- Although we are combining flat-files, tidyverse uses the terminology (e.g, "keys," "join") of relational databases for doing so


# Keys

__Keys__ are "the variables used to connect each pair of tables" in a relational database

An important thing to keep in mind before we delve into an in-depth discussion of keys

- Even though relational databases often consit of many tables, __relations__ are always defined between a __pair__ of tables
- When joining tables, focus on joining __one__ table to __another__; you make this "join" using the __key variable(s)__ that define the relationship between these two tables
- Even when your analysis requires varaibles from more than two tables, you proceed by joining one pair of tables at a time

__Definition of keys__

- Wickham: "A key is a variable (or set of variables) that uniquely identifies an observation"
- In other words, no two observations in the dataset have the same value of the key


In the simplest case, a single variable uniquely identifies observations and, thus, the key is simply that variable

- e.g., the variable `id` -- "unique student identification variable" -- uniquely identifies observations in the dataset `nls_stu` 
- No two observations in `nls_stu` have the same value of `id`

Let's confirm that each value of `id` is associated with only one observation

```r
#approach 1: count how many values of id have than one observation per id
nls_stu %>% 
  count(id) %>% # create object that counts the number of obs for each value of id
  filter(n>1) # keep only rows where count of obs per id is greater than 1
#> # A tibble: 0 x 2
#> # ... with 2 variables: id <dbl>, n <int>

#approach 2: 
nls_stu %>% group_by(id) %>% # group by your candidate key
  summarise(n_per_id=n()) %>% # create a measure of number of observations per group
  ungroup %>% # ungroup, otherwise frequency table [next step] created separately for each group
  count(n_per_id) # frequency of number of observations per group
#> # A tibble: 1 x 2
#>   n_per_id     n
#>      <int> <int>
#> 1        1 22652
```

Often, multiple variables are required to create the key for a table.

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
__The first step before merging some some set of tables is always to identify the key for each table__.  We have already identified the key for `nls_stu` and `nls_tran`.

Student task: try to identify the key for `nls_stu_pets`, `nls_term` and for `nls_course`


```r
#DELETE THIS CODE?

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

- A __primary key__ is a variable (or combination of variables) in a table that uniquely identifies observations in its own table
    - this definition is the same as our previous definition for __key__
    - e.g., `id` is the _primary key_ for the dataset `nls_stu`
    - e.g., `id` and `transnum` form the _primary key_ for the dataset `nls_trans`
    
- A __foreign key__ is a variable (or combination of variables) in a table that uniquely identify observations in another table
    - said differently, a foreign key variable (or combination of variables) in a table that is the primary key in another table
    - e.g., in the dataset `nls_tran`, the variable `id` is the _foreign key_ for the dataset `nls_stu`
    - e.g., in the dataset `nls_term`, the variables `id` and `transnum` form the _foreign key_ for the dataset `nls_trans`


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

There are four types of joins between tables `x` and `y`:

- __inner join__: keep all observations that appear in both table `x` and table `y`
- __left join__: keep all observations in `x` (regardless of whether these obs appear in `y`)
- __right join__: keep all observations in `y` (regardless of whether these obs appear in `x`)
- __full join__: keep all observations that appear in `x` or in `y`

The last three joins -- left, right, full -- keep observations that appear in at least one table and are collectively referred to as __outer joins__

The following Venn diagram is useful for developing an initial understanding of the four join types

![INSERT FIGURE TITLE](http://r4ds.had.co.nz/diagrams/join-venn.png)

We will join tables `x` and `y` using the  `join` command from `dplyr`, which has more specific commands for each type of join:

- `inner_join()`
- `left_join()`
- `right_join()`
- `full_join()`

Note that all of these join commands result in an object that contains all the variables from `x` and all the variables from `y`

## Inner joins

__inner joins__ keep all observations that appear in both table `x` and table `y`

- More correctly, an inner join mathes observations from two tables "whenever their keys are equal"
- If there are multiple matches between `x` and `y`, all combination of the matches are returned.

Visual representation of `x` and `y`:

![](join-setup.png)

- the colored column in each dataset is the "key" variable. The key variable(s) match rows between the tables.

Below is a visual representation of an inner join. 

- Matches in a join (rows common to both `x` and `y`) are indicated with dots. "The number of dots=the number of matches=the number of rows in the output"

![](join-inner.png)


The basic synatx is `inner_join(x, y, by ="keyvar")`

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
x %>% 
  inner_join(y, by = "key")
#> # A tibble: 2 x 3
#>     key val_x val_y
#>   <dbl> <chr> <chr>
#> 1     1 x1    y1   
#> 2     2 x2    y2
```

Practical example: let's try an inner join of the two datasets `nls_stu` and `nls_stu_pets`

I recommend these general steps when merging two datasets

1. For each dataset, invesigate data structure (which variables uniquely identify obs)
    - Identify key variables you will use to join the two tables
3. Join variables
4. Assess/investigate quality of join


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
- __one-to-many__ join: key variable uniquely identifies observatiosn in table `x` and does not uniquely identify observations in table `y`
    - each observation from table `x` may match to multiple observations from table `y'
    - e.g., `inner_join(nls_stu, nls_trans, by = "id")`
- __many-to-one__ join: key variable does not uniquely identify observations in table `x' and does uniquely identify observations in table `y`
    - each observation from table `y` may match to multiple observations from table `x'
    - e.g., `inner_join(nls_trans, nls_trans, by = "id")`
- __many-to-many__ join: key variable does not uniquely identify observations in table `x' and does not uniquely identify observations in table `y`
    - This is usually an error


Many-to-one merge using fictitious tables `x` and `y`

```r
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

Note that `key` does not uniquely identify observations in `x` but does uniquely identify observations in `y`

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

Merge

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
Student-task: conduct a one-to-many inner join of the two datasets `nls_stu` and `nls_trans`

1. Invesigate data structure
2. Join variables
3. Assess/investigate quality of join

```r
#DELETE CODE?

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
```
### Defining the key columns

Thus far, tables have been joined by a single "key" variable using this syntax:

- `inner_join(x,y, by = "keyvar")`

Often, multiple variables form the "key". Specify this using this syntax:

- `inner_join(x,y, by = c("keyvar1","keyvar2","..."))`

Practical example: perform an inner join of `nls_tran` and `nls_term`

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
Sometimes a key variable in one table has a different variabel name in the other table. You can specify that the variables to be matched from one table to another as follows:

- `inner_join(x,y, by = c("keyvarx" = "keyvary"))`

Practical example: merging `nls_stu` and `nls_tran`:

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


inner_join()
return all rows from x where there are matching values in y, and all columns from x and y. If there are multiple matches between x and y, all combination of the matches are returned.

left_join()
return all rows from x, and all columns from x and y. Rows in x with no match in y will have NA values in the new columns. If there are multiple matches between x and y, all combinations of the matches are returned.

right_join()
return all rows from y, and all columns from x and y. Rows in y with no match in x will have NA values in the new columns. If there are multiple matches between x and y, all combinations of the matches are returned.

full_join()
return all rows and all columns from both x and y. Where there are not matching values, returns NA for the one missing.



Two tables `x` and `y` can be "joined" when the primary key for table `x` can be found in table `y`; in other words, when table `y` contains the _foreign key_, which uniquely identifies observations in table `x`
 
- e.g., use `id` to join `nls_stu` and `nls_tran` because `id` is the primary key for `nls_stu` (i.e., uniquely identifies obs in `nls_stu`) and `id` can be found on `nls_tran`

## Outer joins

Thus far we have focused on "inner joins"

- keep all observations that appear in both table `x` and table `y`

"outer joins" keep observations that appear in at least one table. There are three types of outer joins:

- __left join__: keep all observations in `x` (regardless of whether these obs appear in `y`)
- __right join__: keep all observations in `y` (regardless of whether these obs appear in `x`)
- __full join__: keep all observations that appear in `x` or in `y`

The syntax for the outer join commands is identical to inner joins, so once you understand inner joins, outer joins are not difficult.

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

Student task: 

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
    - A semi join differs from an inner join because an inner join will return one row of x for each matching row of y, where a semi join will never duplicate rows of x.

Note: syntax for `semi_join()` and `anti_join()` follows the exact same patterns as syntax for mutating joins (e.g., `inner_join()` `left_join`)

## Using `anti_join()` to diagnose mismatches in mutating joins

A primary use of filtering joins is as an investigative tool to diagnose problems with mutating joins

Practical example: Investigate observations that don't match from `inner_join()` of `nls_tran` and `nls_course`

- transcript data has info on postsecondary transcripts; course data has info on each course in postsecondary transcript


```r
#inner join of nls_tran and nls_course results in object with this count:
nls_tran %>% group_by(id,transnum) %>% summarise(n_per_key=n()) %>% ungroup %>% count(n_per_key)
#> # A tibble: 1 x 2
#>   n_per_key     n
#>       <int> <int>
#> 1         1 24253
nls_tran %>% inner_join(nls_course, by = c("id","transnum")) %>% count()
#> # A tibble: 1 x 1
#>        n
#>    <int>
#> 1 484294

nls_course %>% count()
#> # A tibble: 1 x 1
#>        n
#>    <int>
#> 1 484522

#difficult to tell which obs from nls_tran didn't merge
#these are obs from nls_tran that didn't have match in nls_course
nls_tran %>% anti_join(nls_course, by = c("id","transnum")) %>% count()
#> # A tibble: 1 x 1
#>       n
#>   <int>
#> 1  5398

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

Practical example: perform an inner-join of `nls_tran` and `nls_course` and a semi-join of `nls_tran` and `nls_course`.

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

# Join problems

How to avoid join problems before they arise. How to overcome join problems when they do arise

Overcoming join problems before they arise

1. Start by investigating the data structure of tables you are going to merge
    - identify the primary key in each table.
        - This investigation should be based on your understanding of the data and reading data documentation rather than checking if each combination of variables is a primary key
    - does either table have missing or strang values (e.g., `-8`) for the primary key; if so, these observations won't match
1. Before joining, make sure that key you will use for joining uniquely identies observations in at least one of the datasets and that the key variable(s) is present in both datasets
    - investigate whether key variables have different names across the two tables. if different, then you will have to adjust syntax of your join statement accordingly
1. Think about which observations you want retained after joining
    - think about which dataset should be the `x` table and which should be the `y` table
    - think about whether you want an inner, left, right, or full join
1. Since mutating joins keep all variables in `x` and `y`, you may want to keep only specific variables in `x` and/or `y` as a prior step to joining
    - Make sure that non-key variables from tables have different names; if duplicate names exist, the default is to CHECK ON DEFAULT

Overcoming join problems when they do arise

- Identify which observations don't match
    - `anti_join()` is your friend here
- Investigate the reasons taht observations don't match
    - Investigating joins is a craft that takes some practice getting good at.
    - First, you have to _care_ about data quality
    - Identifying causes for non-matches usually involves consulting data documentation for both tables and performing basic descriptive statistics (e.g., frequency tables) on specific variables that documentation suggests may be relevant for whether obs match or not

SOMETHING TO CHECK?
- WHAT IF KEY VARIABLE IS STRING IN ONE TABLE AND NUMERIC IN ANOTHER TABLE?

[OWN: WHAT THIS LECTURE IS MISSING IS WALKING STUDENTS THROUGH INVESTIGATION OF WHY OBS DON'T MATCH; EITHER ADD THIS TO THE LECTURE OR MAKE THIS A BIG PART OF THE PROBLEM SET AND QUESTIONS YOU ASK WILL WALK THEM THROUGH STEPS OF A MERGING INVESTIGATION]

# Appending/stacking data

Often we want to "stack" multiple datasets on top of one another

- typically datasets have the same variables, so stacking means that number of variables remains the same but number of observations increases

Most common practical use of stacking is creating "longitudinal dataset" when input data are released separately for each time period

- longitudinal data has one row per time period for a person/place/observation

Example: 

- IPEDS collects annual survey data from colleges/universities
- I create longitudinal data about university characteristics by appending/staking annual data

Load annual IPEDS data on admissions characteristics

```r

admit16_17 <- read_dta(file="../../data/ipeds/ic/ic16-17_admit.dta") %>%
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
admit16_17 %>% val_labels()
#> $unitid
#> NULL
#> 
#> $endyear
#> NULL
#> 
#> $sector
#>                      Administrative Unit 
#>                                        0 
#>                  Public, 4-year or above 
#>                                        1 
#>  Private not-for-profit, 4-year or above 
#>                                        2 
#>      Private for-profit, 4-year or above 
#>                                        3 
#>                           Public, 2-year 
#>                                        4 
#>           Private not-for-profit, 2-year 
#>                                        5 
#>               Private for-profit, 2-year 
#>                                        6 
#>                 Public, less-than 2-year 
#>                                        7 
#> Private not-for-profit, less-than 2-year 
#>                                        8 
#>     Private for-profit, less-than 2-year 
#>                                        9 
#>              Sector unknown (not active) 
#>                                       99 
#> 
#> $admcon1
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#> 
#> $admcon2
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#> 
#> $admcon3
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#> 
#> $admcon4
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#> 
#> $admcon5
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#> 
#> $admcon6
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#> 
#> $admcon7
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#> 
#> $admcon8
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#> 
#> $admcon9
#>                         Required                      Recommended 
#>                                1                                2 
#> Neither required nor recommended      Considered but not required 
#>                                3                                5 
#>                                  
#>                                9 
#> 
#> $numapplymen
#> NULL
#> 
#> $numapplywom
#> NULL
#> 
#> $numapplytot
#> NULL
#> 
#> $numadmitmen
#> NULL
#> 
#> $numadmitwom
#> NULL
#> 
#> $numadmittot
#> NULL

#read in previous two years of data
admit15_16 <- read_dta(file="../../data/ipeds/ic/ic15-16_admit.dta") %>%
  select(unitid,endyear,sector,contains("admcon"),contains("numapply"),contains("numadmit"))

admit14_15 <- read_dta(file="../../data/ipeds/ic/ic14-15_admit.dta") %>%
  select(unitid,endyear,sector,contains("admcon"),contains("numapply"),contains("numadmit"))
```

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

Example using IPEDS data


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

QUESTION FOR PATRICIA/CRYSTAL: EASY WAY TO RETAIN ATTRIBUTES/CLASS FROM LABELLED DATA?
