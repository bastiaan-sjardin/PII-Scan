# Activate the `foreign` library
library(foreign)

# Activate the `readstata13` library to read Stata dta-file that only works in version 13 and 14
library(readstata13)

# Create prinf function
printf <- function(...) cat(sprintf(...))

# Strings to look for in variable names
pii_strings_names <- c("name", "fname", "lname", "first_name", "last_name")
pii_strings_dates <- c("birth", "birthday", "bday")
pii_strings_locations <- c("district", "country", "subcountry", "parish", "lc", "village", "community", "address", "gps", "lat", "log", "coord", "location", "house", "compound")
pii_strings_other <- c("school", "social", "network", "census", "gender", "sex", "fax", "email", "ip", "url")

# Create single list of all strings, removing duplicates
pii_strings <- unique(c(pii_strings_names, pii_strings_dates, pii_strings_locations, pii_strings_other))

# Set path to search for PII
path <- "C:\\Users\\zacha\\Dropbox (MIT)\\_data_verification_pd\\472\\472_data"

# Change to path
setwd(path)

# Get list of Stata files (.dta) to scan for PII
files = list.files(path = ".", pattern = "\\.dta$", recursive = TRUE)

# Loop over files
for ( file in files ) {
  
  # Clear PII status
  PII_Found <- FALSE
  
  # Open file, ignore missing value labels.
  tryCatch(
    {
      data <- read.dta(file, warn.missing.labels = FALSE)
    },
    error=function(cond) {
      data <- read.dta13(file, missing.type = FALSE)
      return(NA)
    }
    )
  
  # Loop over variable names in file
  for ( var in names( data )) {
    FOUND <- FALSE
    for ( string in pii_strings) {
      if (grepl(string, var)) {
        FOUND <- TRUE
      }
    }
    # Check to see if variable name mataches our susspect list
    if ( FOUND) {
      
      # Set PII status
      if ( !PII_Found) {
        PII_Found <- TRUE
        printf("Possible PII found in %s:\n", file)
      }
      
      # Print warning, and first five data values
      printf("\tPossible PII in variable \"%s\":\n", var)
      
      # Print first five values
      for ( i in 1:5 ) {
        printf("\t\tRow %d value: %s\n", i, data[i,var])
      } # for ( i in 1:5 )
      
      # Print newline for readability
      printf("\n")
      
    } # if ( var %in% pii_strings )
  } # for ( var in names( data ))
} # for ( file in files )
