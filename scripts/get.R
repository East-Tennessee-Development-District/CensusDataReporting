if (exists("startrun")) {
  print(fortunes::fortune())
} else {
  source(here::here("scripts","startHere.R"))
}

reset <- FALSE

# if(file.exists(here::here("data","interim","census_2020.csv")) & !reset){
#     print(fortunes::fortune())
#   } else {
#     
#     vars <- c()
#     
#     tempDF <- get_decennial(geography = "place", 
#                             variables = vars,
#                             year = 2020,
#                             # sumfile = "dhc",
#                             state="TN")
#     
#   }
# if(file.exists(here::here("data","interim","censusblocks.csv")) & !reset){
#   print(fortunes::fortune())
# } else {
#   
#   vars <- c()
#   
#   tempDF <- get_decennial(geography = "block", 
#                           variables = vars,
#                           year = 2020,
#                           # sumfile = "dhc",
#                           state="TN")
#   
# } 





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
