if (exists("startrun")) {
  print(fortunes::fortune())
} else {
  source(here::here("scripts","startHere.R"))
}



# || Variables
options(tigris_use_cache = TRUE)
reset <- FALSE

numberOfTopCounties <- 5
state <- "tn"

currReportYear <- 2020
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

countiesInETDDNameOnly <- c(
  "Anderson",
  "Blount",
  "Campbell",
  "Claiborne",
  "Cocke",
  "Grainger",
  "Hamblen",
  "Jefferson",
  "Knox",
  "Loudon",
  "Monroe",
  "Morgan",
  "Roane",
  "Scott",
  "Sevier",
  "Union"
)


municipalitiesInAnderson <- c(
  "Clinton city",
  "Norris city",
  "Oak Ridge city",
  "Oliver Springs town",
  "Rocky Top city"
)
municipalitiesInBlount <- c(
  "Alcoa city",
  "Friendsville city",
  "Louisville city",
  "Maryville city",
  "Rockford city",
  "Townsend city"
  
)
municipalitiesInCampbell <- c(
  "Caryville town",
  "Jacksboro town",
  "Jellico city",
  "La Follette city"
  
)
municipalitiesInClaiborne <- c(
  "Cumberland Gap town", 
  "Harrogate city",
  "New Tazewell town", 
  "Tazewell town"
  
)
municipalitiesInCocke <- c(
  "Newport city",
  "Parrottsville town"
  
)
municipalitiesInGrainger <- c(
  "Bean Station city",
  "Blaine city",
  "Rutledge town"
  
)
municipalitiesInHamblen <- c(
  "Morristown city"
)
municipalitiesInJefferson <- c(
  "Baneberry city",
  "Dandridge town",
  "Jefferson City city",
  "New Market town",
  "White Pine town"
  
)
municipalitiesInKnox <- c(
  "Farragut town",
  "Knoxville city"
)
municipalitiesInLoudon <- c( 
  "Greenback city",
  "Loudon city",
  "Philadelphia city",
  "Lenoir City city"
  
  )
municipalitiesInMonroe <- c( 
  "Madisonville city",
  "Sweetwater city",
  "Vonore town",
  "Tellico Plains town"

  )
municipalitiesInMorgan <- c(
  "Oakdale town",
  "Sunbright city",
  "Wartburg city"
  
  )
municipalitiesInRoane <- c( 
  "Harriman city",
  "Kingston city",
  "Rockwood city"
  
  )
municipalitiesInScott <- c( 
  "Huntsville town",
  "Oneida town",
  "Winfield town"
  
  )
municipalitiesInSevier <- c(
  "Pigeon Forge city",
  "Pittman Center town",
  "Gatlinburg city",
  "Sevierville city"
  
)
municipalitiesInUnion <- c(
  "Luttrell town",
  "Maynardville city",
  "Plainview city"
)



municipalitiesInETDD <- c(
  municipalitiesInAnderson,
  municipalitiesInBlount,
  municipalitiesInCampbell,
  municipalitiesInClaiborne,
  municipalitiesInCocke,
  municipalitiesInGrainger,
  municipalitiesInHamblen,
  municipalitiesInJefferson,
  municipalitiesInKnox,
  municipalitiesInLoudon,
  municipalitiesInMonroe,
  municipalitiesInMorgan,
  municipalitiesInRoane,
  municipalitiesInScott,
  municipalitiesInSevier,
  municipalitiesInUnion
)


fuzzyMatchNames <- function(currNamesDf,canonDf,nameVar, numResponse=1){
  currNamesMissing <- anti_join(currETDDNames,acsNames) 
  canonNamesNotAssigned <- anti_join(acsNames,currETDDNames)
  nameMatches <-  stringdist_join(currNamesMissing, canonNamesNotAssigned, 
                  by = nameVar,
                  mode = "left",
                  ignore_case = TRUE, 
                  method = "jw", 
                  max_dist = 99, 
                  distance_col = "dist") %>%
    group_by(.data[[paste0(nameVar,".x")]]) %>%
    slice_min(order_by = dist, n =  numResponse)
  return(nameMatches)
}

if(FALSE){
  # This is an example of how to use this function to fix the names, included for future years
  acsNames <- read_csv(here::here("data","interim","acsData2020place.csv")) |> 
    select(NAME) |> 
    mutate(NAME=str_remove(NAME,", Tennessee")) |>
    distinct()
  
  currETDDNames <- data.frame(NAME=municipalitiesInETDD)
  
  fuzzyMatchNames(acsNames,currETDDNames,"NAME") |> 
    mutate(ending=str_extract(NAME.y,"(city)|(town)")) |> 
    arrange(desc(ending)) |> 
    print(n=50)
}





# tmpdf <- data.frame(NAME=municipalitiesInETDD)
# tmpdff <- read_csv(here::here("data","interim",str_c("censusData",as.character(2020),"place",".csv")))
# tmpdffcounty <- read_csv(here::here("data","interim",str_c("censusData",as.character(2020),"county",".csv")))
# tmpdffcounty |> select(NAME,GEOID) |> distinct() |> 
#   filter(NAME=="Anderson County, Tennessee")
# 
# testingGeoID <- tmpdffcounty |> select(NAME,GEOID) |> distinct() |> 
#   filter(NAME=="Anderson County, Tennessee") |> pull()
# 
# tmpdff |> 
#   filter(str_detect(GEOID, as.character(testingGeoID))) |> select(GEOID,NAME) |> distinct()
# 
# fuzzyjoin::stringdist_join(tmpdf, tmpdff, 
#                            by = "NAME",
#                            mode = "left",
#                            ignore_case = TRUE, 
#                            method = "jw", 
#                            max_dist = 99, 
#                            distance_col = "dist") %>%
#   group_by(NAME.x) %>%
#   slice_min(order_by = dist, n = 1) |> 
#   select(NAME.y, NAME.x, GEOID) |> 
#   distinct() |> 
#   print(n=50)


censusYears <- c(2010, 2020)
acsYears <- c(2010, 2020)


# || Functions

# ||| Getting
getCensusData <- function(censusYear, state, vars, fileName, surveyName, geographyLevel, getShapeFile = FALSE){
  varFromAPI <- load_variables(censusYear, dataset=surveyName, cache=TRUE)
  APIVars <- 
    c(
      varFromAPI %>% 
        filter(str_detect(name, paste(vars, collapse = "|"))) %>% 
        select(name) %>% 
        pull()
    )
  get_decennial(
    geography=geographyLevel,
    variables = APIVars,
    year = censusYear,
    output = "tidy",
    state = state,
    cache_table = TRUE,
    geometry=getShapeFile,
    # county = countyName,
    # key = keyring::key_get("CensusApi"),
    survey = surveyName,
    show_call = TRUE
  ) |> 
    left_join(varFromAPI, by=c("variable"="name")) |> 
    mutate(
      label=str_remove_all(label, "!")
    ) |> 
    write_csv(file = fileName)
}

getACSData <- function(acsYear, state, vars, fileName, surveyName, geographyLevel, surveyVarName = surveyName){
  varFromAPI <- load_variables(acsYear, dataset=surveyVarName, cache=TRUE)
  APIVars <- 
    c(
      varFromAPI %>% 
        filter(str_detect(name, paste(vars, collapse = "|"))) %>% 
        select(name) %>% 
        pull()
    )
  
  get_acs(
    geography=geographyLevel,
    variables = APIVars,
    year = acsYear,
    output = "tidy",
    state = state,
    cache_table = TRUE,
    # county = countyName,
    # key = keyring::key_get("CensusApi"),
    survey = surveyName,
    show_call = TRUE
  ) |> 
    left_join(varFromAPI, by=c("variable"="name")) |> 
    mutate(
      label=str_remove_all(label, "!")
    ) |> 
    write_csv(file = fileName)
  
}

# ||| Cleaning
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



# || Final
fxsVarsrun <- TRUE