if (exists("startrun")) {
  print(fortunes::fortune())
} else {
  source(here::here("scripts","startHere.R"))
}



# || Variables
options(tigris_use_cache = TRUE)
reset <- FALSE
numberOfTopCounties <- 5
numberOfTopIndustries <- 5
state <- "tn"

cityTownRegex <- "(CDP)?(city)?(town)?"
cityTownTNRegex <- str_c("\\s?",cityTownRegex,"\\s?, TN")

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


censusYears <- c(2010, 2020)
acsYears <- c(2010, 2020)

# || Functions

# ||| Dev
fuzzyMatchNames <- function(currNamesDf,canonDf,nameVar, numResponse=1){
  currNamesMissing <- anti_join(currNamesDf,canonDf) 
  canonNamesNotAssigned <- anti_join(canonDf,currNamesDf)
  nameMatches <-  fuzzyjoin::stringdist_join(currNamesMissing, canonNamesNotAssigned, 
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

getPlaceNamesInCounties <- function(placeFileName,countyFileName){
  countiesShapeFile <- sf::read_sf(countyFileName)
  
  # Convert the area geometry to WKT
  wkt <- countiesShapeFile |> 
    filter(NAME %in% countiesInETDDNameOnly) |>
    sf::st_combine() |> 
    sf::st_geometry() |>
    sf::st_as_text()
  
  # Read the filtered dataset using the bounding box
  placeNames <- sf::read_sf(placeFileName, wkt_filter = wkt) |> 
    as_tibble() |> 
    select(NAME) |> 
    arrange(NAME) |> 
    pull()
return(placeNames)
}

if(FALSE){
  currETDDNames <- data.frame(NAME=municipalitiesInETDD)
  
  cityTownRegex <- "(CDP)?(city)?(town)?"
  placeNames <- getPlaceNamesInCounties(here::here("data","clean","tigerFiles2020place.gpkg"),
                 here::here("data","clean","tigerFiles2020county.gpkg"))
  notInList <- 
      currETDDNames |> 
        mutate(NAME=str_remove(NAME,"\\s(city)?(town)?$")) |> 
        anti_join(data.frame(NAME=placeNames))
  
  fuzzyMatchNames(acsNames,notInList,"NAME") |> 
    mutate(ending=str_extract(NAME.y,"(city)|(town)|(CDP)")) |> 
    arrange(desc(ending)) |> 
    print(n=50)
    
    
}

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

loadSfIfExists <- function(fileName){
  
  if(!file.exists(fileName)){
    source(here::here("scripts","get.R"))
  }
  return(sf::read_sf(fileName))
  
}

loadIPUMSIfExists <- function(zipFileName, selectedFileName){
  if(!file.exists(zipFileName)){
    source(here::here("scripts","get.R"))
  }
  return( ipumsr::read_ipums_agg(filepath,file_select = selectedFileName))
}


# || Final
fxsVarsrun <- TRUE