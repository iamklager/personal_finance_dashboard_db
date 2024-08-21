#### UI
# The ui...


ui <- navbarPage(
  ## Design stuff
  theme = bs_theme(
    # Base theme
    preset     = "cosmo",
    primary    = "gray"
  ),
  title = "My Finances",
  windowTitle = "My Finances",
  selected = "Income",
  lang = "en",
  
  sidebar = sidebar(
    div(
      style = "display: flex; gap: 20px;",
      dateInput(
        inputId   = "in_DateFrom",
        label     = "From",
        value     = dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]],
        min       = as.Date("1900-01-01", format = "%Y-%m-%d"),
        format    = dbGetQuery(dbConn, "select DateFormat from settings limit 1;")[[1]],
        startview = "year"
      ),
      dateInput(
        inputId   = "in_DateTo",
        label     = "To",
        value     = Sys.Date(),
        min       = as.Date("1900-01-01", format = "%Y-%m-%d"),
        max       = Sys.Date(),
        format    = dbGetQuery(dbConn, "select DateFormat from settings limit 1;")[[1]]
      )
    ),
    downloadButton(
      outputId = "out_Download",
      label = "Download .csv"
    )
  ),
  
  
  nav_panel(
    title = "Summary",
    layout_columns(
      navset_card_underline(
        full_screen = FALSE,
        title       = "Profit/Loss (Total)",
        height      = "435px",
        nav_panel(title = "")
      ),
      navset_card_underline(
        full_screen = FALSE,
        title       = "Profit/Loss (As % of Income)",
        height      = "435px",
        nav_panel(title = "")
      )
    ),
    layout_columns(
      navset_card_underline(
        full_screen = TRUE,
        title       = "Income, Expenses, and Investments",
        height      = "435px",
        nav_panel(title = "")
      ),
      navset_card_underline(
        full_screen = TRUE,
        title       = "Profit/Loss Over Time",
        height      = "435px",
        nav_panel(title = "")
      )
    )
  ),
  
  
  nav_panel(
    title = "Income",
    layout_columns(
      navset_card_underline(
        full_screen = TRUE,
        title       = "Income by Category",
        height      = "435px",
        nav_panel(title = "", highchartOutput("out_hcIncomeCategory", height = "100%"))
      ),
      navset_card_underline(
        full_screen = TRUE,
        title       = "Income by Month",
        height      = "435px",
        nav_panel(title = "", highchartOutput("out_hcIncomeMonth", height = "100%"))
      )
    ),
    navset_card_underline(
      full_screen = TRUE,
      title       = "Income by Source",
      height      = "435px",
      nav_panel(title = "", highchartOutput("out_hcIncomeSource", height = "100%"))
    )
  ),
  
  
  nav_panel(
    title = "Expenses",
    layout_columns(
      navset_card_underline(
        full_screen = TRUE,
        title       = "Expenses by Category",
        height      = "435px",
        nav_panel(title = "", highchartOutput("out_hcExpensesCategory", height = "100%"))
      ),
      navset_card_underline(
        full_screen = TRUE,
        title       = "Expenses by Month",
        height      = "435px",
        nav_panel(title = "", highchartOutput("out_hcExpensesMonth", height = "100%"))
      )
    ),
    navset_card_underline(
      full_screen = TRUE,
      title       = "Expenses by Source",
      height      = "435px",
      nav_panel(title = "", highchartOutput("out_hcExpensesSource", height = "100%"))
    )
  ),
  
  
  nav_panel(
    title = "Assets",
    layout_columns(
      navset_card_underline(
        full_screen = TRUE,
        title       = "Asset allocation",
        height      = "435px",
        nav_panel(title = "Current Value"),
        nav_panel(title = "Acquisition Value")
      ),
      navset_card_underline(
        full_screen = TRUE,
        title       = "Asset Gains",
        height      = "435px",
        nav_panel(title = "Stocks"),
        nav_panel(title = "Alternatives")
      )
    ),
    navset_card_underline(
      full_screen = TRUE,
      title       = "Asset Price Development",
      height      = "435px",
      nav_panel(title = "Stocks"),
      nav_panel(title = "Alternatives")
    )
  ),
  
  
  nav_panel(
    title = "Tracking",
    navset_card_underline(
      full_screen = FALSE,
      height      = "885px",
      nav_TrackIncome,
      nav_TrackExpenses,
      nav_TrackAssets
    )
  ),
  
  nav_panel(
    title = "Settings",
    
    navset_card_underline(
      full_screen = FALSE,
      height = "885px",
      nav_Settings
    )
  )
)