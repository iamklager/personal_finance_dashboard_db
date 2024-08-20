#### Main
# Run this file to start the app.


### Libraries ----
library(DBI)
library(RSQLite)
library(shiny)
library(bslib)
library(bsicons)
library(DT)


### Sourcing files ----
source("code/database/db_setup.R")


### Server and UI ----
source("code/shiny/ui.R")
source("code/shiny/server.R")


### Run the app ----
shinyApp(ui = ui, server = server)

