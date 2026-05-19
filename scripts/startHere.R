RequiredPackages <- c(#"Rtools",
  "renv", "remotes","tidyverse","lehdr","beepr","fortunes",
  "tidycensus","terra","gt", "here")
for (pkg in RequiredPackages) {
  if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
}

library(tidyverse)
library(lehdr)
library(beepr)
library(patchwork)
library(scales)
# This is for good luck
library(fortunes)
# Api calls
# library(httr)
# library(jsonlite)

# This is for census data
library(tidycensus)

# This is for spatial data
library(terra)

# This is for saving keys
# install.packages("pak")
# pak::pak("keyring")

# for fancy tables
library(gt)

# This sets a seed so any randomized stuff is consistent. I don't know if I need this, but it's a good habit to just do it at the beginning of projects to be safe (for when you add stuff without thinking)
set.seed(1552)

# this creates any missing folders
if (!dir.exists(here::here("data"))){
  dir.create(here::here("data"))
}
if (!dir.exists(here::here("data","raw"))){
  dir.create(here::here("data","raw"))
}
if (!dir.exists(here::here("data","interim"))){
  dir.create(here::here("data","interim"))
}
if (!dir.exists(here::here("data","clean"))){
  dir.create(here::here("data","clean"))
}

# This gets the date for saving things later
CurrentDate <- as.character(Sys.Date())
startrun <- TRUE