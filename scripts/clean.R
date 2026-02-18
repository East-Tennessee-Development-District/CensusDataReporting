if (exists("startrun")) {
  print(fortunes::fortune())
} else {
  source(here::here("scripts","startHere.R"))
}

# fileName <-  (here::here("data","interim","lehdr_tn_wac_main_JT00_2010.csv"))
# || Variables
reset <- FALSE
countiesInETDD <- c(
  "Anderson County",
  "Blount County",
  "Campbell County",
  "Claiborne County",
  "Cocke County",
  "Grainger County",
  "Hamblen County",
  "Jefferson County",
  "Knox County",
  "Loudon County",
  "Monroe County",
  "Morgan County",
  "Roane County",
  "Scott County",
  "Sevier County",
  "Union County"
)
# || Functions
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


# || Script
acsYear <- 2020
geographyLevel <- "county"
fileName <- here::here("data","clean",str_c("acsData",as.character(acsYear),geographyLevel,".csv"))
interimDataFileName <- here::here("data","interim",str_c("acsData",as.character(acsYear),geographyLevel,".csv"))

if(file.exists(fileName) & !reset){
  print(fortunes::fortune())
} else{
  
  acsDF <- loadIfExists(interimDataFileName)
  acsDF |> 
    mutate(
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
          
        .default= "Other"
      )
    ) |> 
    filter(NAME %in% countiesInETDD) |> 
    group_by(NAME,concept,cleanedLabel) |> 
    summarize(estimate=sum(estimate)) |> filter(NAME=="Anderson County", cleanedLabel!="Other") |> 
    print(n=100)
  
  # convert industry by occupation to old style- see if we could just do that for historical comparison
  
  # fix year structure built year cats
  # add totals for poverty by female headed + kids
  
  acsDF |> select(concept) |> distinct() |> pull() # print(n=100)
  acsDF |> filter(str_detect(concept,"SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER")) |> 
    select(label) |> distinct() |> pull() #print(n=100)
  acsDF |> filter(NAME=="Anderson County, Tennessee")
}



censusYear <- 2020
geographyLevel <- "county"
fileName <- here::here("data","clean",str_c("censusData",as.character(censusYear),geographyLevel,".csv"))
interimDataFileName <- here::here("data","interim",str_c("censusData",as.character(censusYear),geographyLevel,".csv"))


if(file.exists(fileName) & !reset){
  print(fortunes::fortune())
} else{
  
  censusDF <- loadIfExists(interimDataFileName)
  censusDF |> 
    mutate(
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
    filter(NAME %in% countiesInETDD) |> 
    group_by(NAME,concept,cleanedLabel) |> 
    summarize(value=sum(value)) |> filter(NAME=="Anderson County")
  
  censusDF |> select(concept, label) |> distinct() |> print(n=100)
  censusDF |> filter(NAME=="Anderson County, Tennessee")
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
    


