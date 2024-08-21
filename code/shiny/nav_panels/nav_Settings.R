nav_Settings <- nav_panel(
  title = "",
  div(
    style = "display: inline-flex; border-width: thick; gap: 1.50%;",
    input_switch(
      id = "in_DarkModeOn",
      label = "Dark Mode",
      value = dbGetQuery(dbConn, "select DarkModeOn from settings limit 1;")[[1]],
      width = "8.70%"
    ),
    colourInput(
      inputId    = "in_ColorProfit",
      label      = "Color: Profit",
      value      = dbGetQuery(dbConn, "select ColorProfit from settings limit 1;")[[1]],
      showColour = "both",
      palette    = "square",
      width      = "8.70%"
    ),
    colourInput(
      inputId    = "in_ColorLoss",
      label      = "Color: Loss",
      value      = dbGetQuery(dbConn, "select ColorLoss from settings limit 1;")[[1]],
      showColour = "both",
      palette    = "square",
      width      = "8.70%"
    )
  ),
  div(
    style = "display: inline-flex; border-width: thick; gap: 1.50%;",
    selectizeInput(
      inputId  = "in_DateFormat",
      label    = "Date format",
      choices  = c("yyyy-mm-dd", "mm/dd/yyyy", "dd.mm.yyyy"),
      selected = dbGetQuery(dbConn, "select DateFormat from settings limit 1;")[[1]]
      
    )
  )
)