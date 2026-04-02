if (exists("startrun")) {
  print(fortunes::fortune())
} else {
  source(here::here("scripts","startHere.R"))
}
if (exists("fxsVars")) {
  print(fortunes::fortune())
} else {
  source(here::here("scripts","fxsAndVars.R"))
}



# || Script

## ||| For figuring
if(TRUE){}else{
  varCheck <- load_variables(2020, dataset="pl", cache=TRUE)
  varCheck |> select(concept) |> distinct()
  
  sumFileCheck <- summary_files(2020)
  
  acs2020 <- load_variables(acsYear, "acs5", cache = TRUE)
  v2020 <- load_variables(2020, dataset="cd118", cache=TRUE)
  censusVars <- ("P3")
  APIDemVars <- 
    c(
      v2020 %>% 
        filter(str_detect(name, paste(censusVars, collapse = "|"))) %>% 
        select(name) %>% 
        pull()
    )
}
# || Getting ACS data
for (geographyLevel in c("county", "place")){
  for (acsYear in c(2010,2020)){
fileName <- here::here("data","interim",str_c("acsData",as.character(acsYear),geographyLevel,".csv"))
surveyName <- "acs5"

if(file.exists(fileName) & !reset){
  fortunes::fortune()
} else {
  vars <- c(
    "S0101","S1901", "B19301", "S1901", "B17010", "C24050", 
    "B08130", "B15002", "S1501", "B25034", "B25003"
  )
  getACSData(acsYear, state, vars, fileName, surveyName, geographyLevel)
}}}

# || Getting census data
for (geographyLevel in c("county", "place")){
  censusYear <- 2020
  fileName <- here::here("data","interim",str_c("censusData",as.character(censusYear),geographyLevel,".csv"))
  
  if (file.exists(fileName) & !reset){
    print(fortunes::fortune())
  } else{
    surveyName <- "pl"
    vars <- c("P1","H1","P12","P13")
    getCensusData(censusYear, state, vars, fileName, surveyName,geographyLevel)
    }
  
  censusYear <- 2010
  fileName <- here::here("data","interim",str_c("censusData",as.character(censusYear),geographyLevel,".csv"))
  
  if (file.exists(fileName) & !reset){
    print(fortunes::fortune())
  } else{
    surveyName <- "sf1"
    vars <- c("P1","H1","P12","P13")
    getCensusData(censusYear, state, vars, fileName, surveyName,geographyLevel)
  }

  }


if (file.exists(here::here("data","interim","lehdr_tn_od_main_JT00_2020.csv")) & !reset) {
  print(fortunes::fortune())
} else {
  for (year in (c(2010,2020))) {
      tempDF <- lehdr::grab_lodes(state="TN",
                                  year=year,
                                  lodes_type="od",
                                  job_type="JT00",
                                  segment="S000",
                                  state_part="main",
                                  download_dir=here::here("data","raw","lehdr"),
                                  use_cache=TRUE
      ) |> 
       select(w_geocode,h_geocode,S000)
      filename <-  str_c("lehdr_tn_od_main_JT00_",as.character(year),".csv")
      write_csv(tempDF, here::here('data', "interim",filename))
    }
}

# || get LODES

if (file.exists(here::here("data","interim","lehdr_tn_wac_main_JT00_2020.csv"))) {
  print(fortunes::fortune())
} else {
  for (year in (c(2010,2020))) {
    for (type in (c("wac","rac"))){
      tempDF <- lehdr::grab_lodes(state="TN",
                                  year=year,
                                  lodes_type=type,
                                  job_type="JT00",
                                  segment="S000",
                                  state_part="main",
                                  download_dir=here::here("data","raw","lehdr"),
                                  use_cache=TRUE
      ) |> 
        mutate(w_geocode=as.character(w_geocode))
      filename <-  str_c("lehdr_tn_",type,"_main_JT00_",as.character(year),".csv")
      write_csv(tempDF, here::here('data', "interim",filename))
    }
  }}

if (file.exists(here::here("data","interim","lehdrBlockConverison.csv"))) {
  print(fortunes::fortune())
} else {
  tempcrossWalkDF <- lehdr::grab_crosswalk(
    state="TN",
    download_dir=here::here("data","raw","lehdr")
  ) |> 
        select(stplcname,ctyname,tabblk2020)|> 
    mutate(tabblk2020=as.character(tabblk2020))
      filename <-  str_c("lehdrBlockConverison.csv")
      write_csv(tempcrossWalkDF, here::here('data', "interim",filename))
    }
