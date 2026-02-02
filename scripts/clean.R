if (exists("startrun")) {
  print(fortunes::fortune())
} else {
  source(here::here("scripts","startHere.R"))
}

# fileName <-  (here::here("data","interim","lehdr_tn_wac_main_JT00_2010.csv"))

loadIfExists <- function(fileName){
  
  if (file.exists(fileName)) {
    tmpData <- read_csv(fileName)
    return(tmpData)
    
  } else {
    source(here::here("scripts", "get.R"))
    tmpData <- read_csv(fileName)
    return(tmpData)
    
  }
  
  
}

lehdCrossWalk <- loadIfExists((here::here("data","interim","lehdrBlockConverison.csv"))) |> 
  mutate(w_geocode=as.character(tabblk2020)) |> 
  select(-tabblk2020)

# wacData2010 <- loadIfExists(here::here("data","interim","lehdr_tn_wac_main_JT00_2010.csv"))  

# racData2010 <- loadIfExists(here::here("data","interim","lehdr_tn_rac_main_JT00_2010.csv"))  

odData2010 <- loadIfExists(here::here("data","interim","lehdr_tn_od_main_JT00_2010.csv")) |> 
  # select(w_geocode, C000) |> 
  mutate(w_geocode=as.character(w_geocode),
         h_geocode=as.character(h_geocode)) |> 
  right_join(
    lehdCrossWalk,
    by = join_by(w_geocode==w_geocode)
  ) |> 
    mutate(workCountyName=str_remove(ctyname," County, TN")) |> 
    select(workCountyName, h_geocode, S000) |> 
    right_join(
      lehdCrossWalk,
      by = join_by(h_geocode==w_geocode)
    ) |> 
    mutate(homeCountyName=str_remove(ctyname," County, TN")) |> 
    group_by(workCountyName, homeCountyName) |> 
    summarize(numberOfJobs=sum(S000)) |> 
    write_csv(here::here("data","clean","ods2010.csv"))
    


