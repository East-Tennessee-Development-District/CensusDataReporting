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

# || Variables
# reset <- FALSE
# || Functions

# || Script

# ACS
for (geoLevel in c("county", "place")){
  for (acsYear in acsYears){
  geographyLevel <- geoLevel
  # acsYear <- 2020
  
fileName <- here::here("data","clean",str_c("acsData",as.character(acsYear),geographyLevel,".csv"))
interimDataFileName <- here::here("data","interim",str_c("acsData",as.character(acsYear),geographyLevel,".csv"))

if(file.exists(fileName) & !reset){
  print(fortunes::fortune())
} else{
  
  acsDF <- loadIfExists(interimDataFileName)
  if("value" %in% colnames(acsDF)){
    acsDF <- acsDF |> mutate(estimate=value)
  }
  acsDF |> 
    mutate(
      year=acsYear,
      NAME = str_remove(NAME, ", Tennessee"),
      cleanedLabel = case_when(
        concept == "MEANS OF TRANSPORTATION TO WORK BY PLACE OF WORK--STATE AND COUNTY LEVEL" & 
          str_detect(label, "EstimateTotal:Worked in state of residence:Worked in county of residence") 
        ~ "Work in County of Residence",
        concept == "MEANS OF TRANSPORTATION TO WORK BY PLACE OF WORK--STATE AND COUNTY LEVEL" & 
          str_detect(label, "EstimateTotal:Worked in state of residence:Worked outside county of residence") 
        ~ "Work Out of County of Residence",
        concept == "MEANS OF TRANSPORTATION TO WORK BY PLACE OF WORK--STATE AND COUNTY LEVEL" & 
          str_detect(label, "EstimateTotal:Worked outside state of residence") 
        ~ "Work Out Of State",
        concept == "POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES BY FAMILY TYPE BY PRESENCE OF RELATED CHILDREN UNDER 18 YEARS BY AGE OF RELATED CHILDREN" &
          label == "EstimateTotal:"
        ~ "Total",
        concept == "POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES BY FAMILY TYPE BY PRESENCE OF RELATED CHILDREN UNDER 18 YEARS BY AGE OF RELATED CHILDREN" &
          label == "EstimateTotal:Income in the past 12 months below poverty level:"
        ~ "Below Poverty",
        concept == "POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES BY FAMILY TYPE BY PRESENCE OF RELATED CHILDREN UNDER 18 YEARS BY AGE OF RELATED CHILDREN" &
          label == "EstimateTotal:Income in the past 12 months at or above poverty level:"
        ~ "Above Poverty",
        concept == "POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES BY FAMILY TYPE BY PRESENCE OF RELATED CHILDREN UNDER 18 YEARS BY AGE OF RELATED CHILDREN" &
          label == "EstimateTotal:Income in the past 12 months below poverty level:Other family:Female householder, no spouse present:"
        ~ "Below Poverty",
        concept == "POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES BY FAMILY TYPE BY PRESENCE OF RELATED CHILDREN UNDER 18 YEARS BY AGE OF RELATED CHILDREN" &
          label == "EstimateTotal:Income in the past 12 months at or above poverty level:Other family:Female householder, no spouse present:"
        ~ "Above Poverty",
        concept == "POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES BY FAMILY TYPE BY PRESENCE OF RELATED CHILDREN UNDER 18 YEARS BY AGE OF RELATED CHILDREN" &
          label == "EstimateTotal:Income in the past 12 months below poverty level:Other family:Female householder, no spouse present:With related children of the householder under 18 years:"
        ~ "Below Poverty",
        concept == "POVERTY STATUS IN THE PAST 12 MONTHS OF FAMILIES BY FAMILY TYPE BY PRESENCE OF RELATED CHILDREN UNDER 18 YEARS BY AGE OF RELATED CHILDREN" &
          label == "EstimateTotal:Income in the past 12 months at or above poverty level:Other family:Female householder, no spouse present:With related children of the householder under 18 years:"
        ~ "Above Poverty",
        str_detect(concept,"PER CAPITA INCOME IN THE PAST 12 MONTHS") &
          ! str_detect(concept, "ALONE") & !str_detect(concept,"HISPANIC") & 
          !str_detect(concept,"TWO")
          ~ "per capita income",
        concept == "TENURE" &
          label == "EstimateTotal:"
        ~ "Total",
        concept == "TENURE" &
          label == "EstimateTotal:Owner occupied"
        ~ "Own",
        concept == "TENURE" &
          label == "EstimateTotal:Renter occupied"
        ~"Rent",
        concept == "YEAR STRUCTURE BUILT" &
          label == "EstimateTotal:"
        ~ "Total",
        concept == "YEAR STRUCTURE BUILT" &
          label == "EstimateTotal:Built 1940 to 1949"
        ~ "1940-1959",
        concept == "YEAR STRUCTURE BUILT" &
          label == "EstimateTotal:Built 1950 to 1959"
        ~ "1940-1959",
        concept == "YEAR STRUCTURE BUILT" &
          label == "EstimateTotal:Built 1960 to 1969"
        ~ "1960-1979",
        concept == "YEAR STRUCTURE BUILT" &
          label == "EstimateTotal:Built 1970 to 1979"
        ~ "1960-1979",
        concept == "YEAR STRUCTURE BUILT" &
          label == "EstimateTotal:Built 2010 to 2013"
        ~ "2010 or later",
        concept == "YEAR STRUCTURE BUILT" &
          label == "EstimateTotal:Built 2014 or later"
        ~ "2010 or later",
        
        concept == "YEAR STRUCTURE BUILT"
        ~ str_remove(label, "EstimateTotal:Built "),
        concept == "INDUSTRY BY OCCUPATION FOR THE CIVILIAN  EMPLOYED POPULATION 16 YEARS AND OVER" &
          label == "EstimateTotal:"
        ~ "Total",
        concept == "INDUSTRY BY OCCUPATION FOR THE CIVILIAN  EMPLOYED POPULATION 16 YEARS AND OVER" &
          !str_detect(label, "([\\w\\s\\,]*:){2,}")
        ~ str_remove(label,"EstimateTotal:"),
        concept == "SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER" &
          label == "EstimateTotal:"
        ~ "Total",
        concept == "SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER" &
          str_detect(label,"No schooling") |
          str_detect(label,"Nursery") |
          str_detect(label,"5th") |
          str_detect(label,"7th") 
        ~ "Less Than 9th Grade",
        concept == "SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER" &
          str_detect(label,"9th") |
          str_detect(label,"10th") |
          str_detect(label,"11th") |
          str_detect(label,"12th, no diploma") 
        ~ "9th to 12th Grade, No Diploma",
        concept == "SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER" &
          str_detect(label,"High school graduate (includes equivalency)") 
        ~ "High School Graduate, or GED",
        concept == "SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER" &
          str_detect(label,"Some college") 
        ~ "Some College, No Degree",
        concept == "SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER" &
          str_detect(label,"Associate's degree") 
        ~ "Associate's degree",
        concept == "SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER" &
          str_detect(label,"Bachelor's degree") 
        ~ "Bachelor's degree",
        concept == "SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER" &
          str_detect(label,"Master's degree") |
          str_detect(label,"Professional school degree") |
          str_detect(label,"Doctorate degree")
        ~ "Graduate or Professional Degree",
        concept == "INDUSTRY BY OCCUPATION FOR THE CIVILIAN  EMPLOYED POPULATION 16 YEARS AND OVER" &
          !str_detect(label, "([\\w\\s\\,]*:){2,}") &
          (str_detect(label, "Wholesale") |
             str_detect(label, "Retail") |
             str_detect(label, "Transportation") |
             str_detect(label, "Finance") 
             )
        ~ "Trade, Finance, Insurance & Real Estate",
        concept == "INDUSTRY BY OCCUPATION FOR THE CIVILIAN  EMPLOYED POPULATION 16 YEARS AND OVER" &
          !str_detect(label, "([\\w\\s\\,]*:){2,}") &
          (str_detect(label, "Information") |
             str_detect(label, "waste") |
             str_detect(label, "Educational") |
             str_detect(label, "Arts") 
          )
        ~ "Professional Services",
        concept == "INDUSTRY BY OCCUPATION FOR THE CIVILIAN  EMPLOYED POPULATION 16 YEARS AND OVER" &
          !str_detect(label, "([\\w\\s\\,]*:){2,}") &
          (str_detect(label, "Other services")
          )
        ~ "OtherInt",
          
        .default= "Other"
      )
    ) |> 
    # filter(NAME=="Anderson County", str_detect(concept, "YEAR STRUCTURE"))|>
    # select(estimate, label, cleanedLabel) |>
    # print(n=100)
    filter(NAME %in% countiesInETDD | NAME %in% municipalitiesInETDD) |> 
    group_by(NAME,concept,cleanedLabel,year) |> 
    summarize(estimate=sum(estimate)) |> 
    # filter(NAME=="Anderson County", str_detect(concept, "INDUSTRY"))|> 
    # print(n=100)
    write_csv(fileName)
  
  # add totals for poverty by female headed + kids
  
  acsDF |> select(concept) |> distinct() |> pull() # print(n=100)
  acsDF |> filter(str_detect(concept,"SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER")) |> 
    select(label) |> distinct() |> pull() #print(n=100)
  acsDF |> filter(NAME=="Anderson County, Tennessee") |> filter(concept == "INDUSTRY BY OCCUPATION FOR THE CIVILIAN  EMPLOYED POPULATION 16 YEARS AND OVER")
}}

}

fileName <- here::here("data","clean","acsDataCombined.csv")

if(file.exists(fileName) & !reset){print(fortunes::fortune())} else {
  
  for (geographyLevel in c("county", "place")){
    for (censusYear in censusYears){
      readingFileName <- here::here("data","clean",str_c("acsData",as.character(acsYear),geographyLevel,".csv"))
      if(exists("combinedAcsDf")){
        combinedAcsDf <- combinedAcsDf |> 
          rbind(read_csv(readingFileName))
      } else {
        combinedAcsDf <- read_csv(readingFileName)
      }
      
    }}
  combinedAcsDf |> 
    write_csv(fileName)
}

# Census
for (geographyLevel in c("county", "place")){
  for (censusYear in censusYears){
  fileName <- here::here("data","clean",str_c("censusData",as.character(censusYear),geographyLevel,".csv"))
  interimDataFileName <- here::here("data","interim",str_c("censusData",as.character(censusYear),geographyLevel,".csv"))
  
  if(file.exists(fileName) & !reset){
    print(fortunes::fortune())
  } else{
    
    censusDF <- loadIfExists(interimDataFileName)
    censusDF |> 
      mutate(
        year = censusYear,
        NAME = str_remove(NAME, ", Tennessee"),
        cleanedLabel = case_when(
          concept == "RACE" & str_detect(label, "White alone") ~ "White",
          concept == "RACE" & str_detect(label,"Black or African American alone") ~ "Black",
          label == "Total:" ~ "Total",
          concept == "RACE" & label !="Total: White alone" & label != "Total:"
            & label!= "Total: Black or African American alone"
          & label !="Total:Population of one race:"
          & !str_detect(label,"Total:Population of two or more races:Population")
            # label =="Total:Population of two or more races:"
          ~ "Other",
          
             )
              
      ) |> 
      filter(NAME %in% countiesInETDD | NAME %in% municipalitiesInETDD) |>
      group_by(NAME,concept,cleanedLabel,year) |> 
      summarize(value=sum(value)) |> 
      # filter(NAME=="Anderson County")
      write_csv(fileName)
    
    # censusDF |> select(concept, label) |> distinct() |> print(n=100)
    # censusDF |> filter(NAME=="Anderson County, Tennessee")
  }}}

fileName <- here::here("data","clean","censusDataCombined.csv")

if(file.exists(fileName) & !reset){print(fortunes::fortune())} else {

  for (geographyLevel in c("county", "place")){
    for (censusYear in censusYears){
      readingFileName <- here::here("data","clean",str_c("censusData",as.character(censusYear),geographyLevel,".csv"))
      if(exists("combinedCensusDf")){
        combinedCensusDf <- combinedCensusDf |> 
          rbind(read_csv(readingFileName))
      } else {
        combinedCensusDf <- read_csv(readingFileName)
      }
      
    }}
  combinedCensusDf |> 
    write_csv(fileName)
}


  



# Work vs home counties
lehdCrossWalk <- loadIfExists((here::here("data","interim","lehdrBlockConverison.csv"))) |> 
  mutate(w_geocode=as.character(tabblk2020)) |> 
  select(-tabblk2020)
for (year in (c(2010,2020))) {
  loadIfExists(here::here("data","interim",str_c("lehdr_tn_od_main_JT00_",year,".csv"))) |> 
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
    write_csv(here::here("data","clean",str_c("ods",year,".csv")))
  
  
  }


