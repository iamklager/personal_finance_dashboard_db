#### Server
# The server...


server <- function(input, output, session) {
  
  ### Reactive values
  ## Misc
  rv_Today <- reactive({
    invalidateLater(24 * 60 * 60 * 1000)
    format(Sys.Date(), "%Y-%m-%d")
  })
  
  ## Income
  rv_Income      <- reactiveVal(QueryTableSimple(dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_IncomeGroup <- reactiveVal(QueryIncExpGrouped(dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_IncomeMonth <- reactiveVal(QueryIncExpMonth(dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  
  ## Expenses
  rv_Expenses      <- reactiveVal(QueryTableSimple(dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_ExpensesGroup <- reactiveVal(QueryIncExpGrouped(dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_ExpensesMonth <- reactiveVal(QueryIncExpMonth(dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  
  ## Assets
  rv_Assets <- reactiveVal(QueryTableSimple(dbConn, "assets", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  
  
  ### Event handling
  ## Periodically
  observeEvent(rv_Today(), {
    # Writing price data
  })
  
  ## Settings
  # Coloring
  observeEvent(input$in_DarkModeOn, {
    toggle_dark_mode(ifelse(input$in_DarkModeOn, "dark", "light"))
    dbSendQuery(dbConn, paste0("update settings set DarkModeOn = ", input$in_DarkModeOn, ";"))
  })
  observeEvent(input$in_ColorProfit, {
    dbSendQuery(dbConn, paste0("update settings set ColorProfit = '", input$in_ColorProfit, "';"))
  })
  observeEvent(input$in_ColorLoss, {
    dbSendQuery(dbConn, paste0("update settings set ColorLoss = '", input$in_ColorLoss, "';"))
  })
  # Text rendering
  observeEvent(input$in_DateFormat, { # To-Do: Add info box stating that this does only apply after restarting the tool
    dbSendQuery(dbConn, paste0("update settings set DateFormat = '", input$in_DateFormat, "';"))
  })
  
  ## Tracking
  # Income
  observeEvent(input$in_TrackIncome, {
    TrackIncExp(dbConn, "income", input$in_DateIncome, input$in_AmountIncome, input$in_ProductIncome, input$in_SourceIncome, input$in_CategoryIncome)
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
  })
  observeEvent(input$in_AppendFileIncome, {
    file <- input$in_FileIncome
    if (length(file) != 0) {
      ext <- tools::file_ext(file$name)
      df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
      df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
      Append2Table(dbConn, "income", df)
      rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
      rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
      rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    }
  })
  observeEvent(input$in_OverwriteFileIncome, {
    file <- input$in_FileIncome
    if (length(file) != 0) {
      ext <- tools::file_ext(file$name)
      df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
      df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
      OverWriteTable(dbConn, "income", df)
      rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
      rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
      rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    }
  })
  # Expenses
  observeEvent(input$in_TrackExpenses, {
    TrackIncExp(dbConn, "expenses", input$in_DateExpenses, input$in_AmountExpenses, input$in_ProductExpenses, input$in_SourceExpenses, input$in_CategoryExpenses)
    rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
  })
  observeEvent(input$in_AppendFileExpenses, {
    file <- input$in_FileExpenses
    if (length(file) != 0) {
      ext <- tools::file_ext(file$name)
      df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
      df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
      Append2Table(dbConn, "expenses", df)
      rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
      rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
      rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    }
  })
  observeEvent(input$in_OverwriteFileExpenses, {
    file <- input$in_FileExpenses
    if (length(file) != 0) {
      ext <- tools::file_ext(file$name)
      df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
      df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
      OverWriteTable(dbConn, "expenses", df)
      rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
      rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
      rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    }
  })
  # Assets
  observeEvent(input$in_TrackAsset, {
    TrackAsset(
      dbConn, input$in_TypeAsset, input$in_GroupAsset, input$in_TickerSymbolAsset, input$in_DisplayNameAsset, 
      input$in_DateAsset, input$in_QuantityAsset, input$in_PriceTotalAsset, input$in_TransTypeAsset, 
      input$in_TransCurrencyAsset, input$in_SourceCurrencyAsset
    )
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
  })
  observeEvent(input$in_AppendFileExpenses, {
    file <- input$in_FileAssets
    if (length(file) != 0) {
      ext <- tools::file_ext(file$name)
      df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
      df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
      Append2Table(dbConn, "assets", df)
      rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
    }
  })
  observeEvent(input$in_OverwriteFileExpenses, {
    file <- input$in_FileAssets
    if (length(file) != 0) {
      ext <- tools::file_ext(file$name)
      df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
      df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
      OverWriteTable(dbConn, "assets", df)
      rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
    }
  })
  
  ## Date selection
  observeEvent(input$in_DateFrom, {
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
  })
  observeEvent(input$in_DateTo, {
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
  })
  
  
  ### Outputs
  ## Download thingy
  output$out_Download <- downloadHandler(
    filename = function() {
      paste0(format(input$in_DateFrom, "%Y%m%d"), "_", format(input$in_DateTo, "%Y%m%d"), "_my_finances.csv")
    },
    content  = function(file) {
      write.csv(NA, file)
    },
    contentType = "text/csv"
  )
  
  ## Tracking
  # Income
  output$out_DTIncome   <- DT::renderDT({ rv_Income() })
  # Expenses
  output$out_DTExpenses <- DT::renderDT({ rv_Expenses() })
  # Assets
  output$out_DTAssets   <- DT::renderDT({ rv_Assets() })
  
  ## Income
  output$out_hcIncomeCategory <- renderHighchart({ hcIncExpByCategory(rv_IncomeGroup()) })
  output$out_hcIncomeMonth <- renderHighchart({ hcIncExpByMonth(rv_IncomeMonth(), input$in_ColorProfit) })
  output$out_hcIncomeSource <- renderHighchart({ hcIncExpBySource(rv_IncomeGroup())})
  
  ## Expenses
  output$out_hcExpensesCategory <- renderHighchart({ hcIncExpByCategory(rv_ExpensesGroup()) })
  output$out_hcExpensesMonth <- renderHighchart({ hcIncExpByMonth(rv_ExpensesMonth(), input$in_ColorLoss) })
  output$out_hcExpensesSource <- renderHighchart({ hcIncExpBySource(rv_ExpensesGroup())})
  
  ## Assets
  
  
}

