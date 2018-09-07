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


Libraries we will use

```r
library(tidyverse)
#> -- Attaching packages ---------------------------------------------------------------- tidyverse 1.2.1 --
#> v ggplot2 3.0.0     v purrr   0.2.5
#> v tibble  1.4.2     v dplyr   0.7.6
#> v tidyr   0.8.1     v stringr 1.3.1
#> v readr   1.1.1     v forcats 0.3.0
#> -- Conflicts ------------------------------------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
```


## NLS data

# Keys

# Mutating joins

# Filtering joins

# Appending/stacking data
