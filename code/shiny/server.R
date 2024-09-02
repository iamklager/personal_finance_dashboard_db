#### Server
# The server...


server <- function(input, output, session) {
  
  ### Reactive values
  ## Today
  rv_Today <- reactive({
    invalidateLater(24 * 60 * 60 * 1000)
    format(Sys.Date(), "%Y-%m-%d")
  })
  
  ## Income
  rv_Income      <- reactiveVal(QueryTableMainCur(
    dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], format(Sys.Date(), "%Y-%m-%d"),
    dbGetQuery(dbConn, "select MainCurrency FROM settings limit 1;"[[1]])
  ))
  # rv_IncomeGroup <- reactiveVal(QueryIncExpGrouped(dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], format(Sys.Date(), "%Y-%m-%d")))
  # rv_IncomeMonth <- reactiveVal(QueryIncExpMonth(dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], format(Sys.Date(), "%Y-%m-%d")))
  
  ## Expenses
  rv_Expenses      <- reactiveVal(QueryTableMainCur(
    dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], format(Sys.Date(), "%Y-%m-%d"),
    dbGetQuery(dbConn, "select MainCurrency FROM settings limit 1;"[[1]])
  ))
  # rv_ExpensesGroup <- reactiveVal(QueryIncExpGrouped(dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], format(Sys.Date(), "%Y-%m-%d")))
  # rv_ExpensesMonth <- reactiveVal(QueryIncExpMonth(dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], format(Sys.Date(), "%Y-%m-%d")))
  
  ## Assets
  rv_Assets        <- reactiveVal(QueryTableSimple(dbConn, "assets", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], format(Sys.Date(), "%Y-%m-%d")))
  rv_CurrentAssets <- reactiveVal(CurrentAssets(dbConn, format(Sys.Date(), "%Y-%m-%d")))
  rv_InvCurv       <- reactiveVal(InvestedCurves(dbConn, dbGetQuery(dbConn, "SELECT MainCurrency FROM settings LIMIT 1;")[[1]]))
  # rv_AssetAllocAcq   <- reactiveVal(AssetAllocAcq(dbConn, Sys.Date(), dbGetQuery(dbConn, "SELECT Currency FROM currencies LIMIT 1;")[[1]]))
  # rv_AssetAllocCur   <- reactiveVal(AssetAllocCur(dbConn, Sys.Date(), dbGetQuery(dbConn, "SELECT Currency FROM currencies LIMIT 1;")[[1]]))
  # rv_AssetGainCurves <- reactiveVal(GetAssetGainCurves(dbConn, dbGetQuery(dbConn, "SELECT DateFrom FROM settings LIMIT 1;")[[1]], Sys.Date()))
  
  
  ### Event handling
  ## Periodically
  observeEvent(rv_Today(), {
    # Writing price data
    QueryPrices(dbConn)
    QueryXRates(dbConn)
    
    # rv_AssetGainCurves(GetAssetGainCurves(dbConn, input$in_DateFrom, input$in_DateTo))
    rv_CurrentAssets(CurrentAssets(dbConn, input$in_DateTo))
    rv_InvCurv(InvestedCurves(dbConn, input$in_MainCurrency))
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
  # Currency 
  observeEvent(input$in_MainCurrency, {
    dbSendQuery(dbConn, paste0("update settings set MainCurrency = '", input$in_MainCurrency, "';"))
    
    rv_Income(QueryTableMainCur(dbConn, "income", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    
    rv_Expenses(QueryTableMainCur(dbConn, "expenses", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    
    # rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetAllocCur(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    rv_InvCurv(InvestedCurves(dbConn, input$in_MainCurrency))
  })
  
  
  ## Tracking
  # Income
  observeEvent(input$in_TrackIncome, {
    if (input$in_AmountIncome == 0) {
      showNotification(ui = "Cannot track items of value 0.", type = "error")
      return(NULL)
    }
    TrackIncExp(
      dbConn, "income", input$in_DateIncome, input$in_AmountIncome, input$in_ProductIncome, 
      input$in_SourceIncome, input$in_CategoryIncome, input$in_CurrencyIncome
    )
    rv_Income(QueryTableMainCur(dbConn, "income", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    # rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    
    updateNumericInput(inputId = "in_AmountIncome", value = 0)
    updateTextInput(inputId = "in_ProductIncome", value = "")
    updateTextInput(inputId = "in_SourceIncome", value = "")
    updateTextInput(inputId = "in_CategoryIncome", value = "")
    
    showNotification(ui = "Successfully tracked income.", type = "default")
  })
  observeEvent(input$in_AppendFileIncome, {
    file <- input$in_FileIncome
    if (length(file) == 0) {
      showNotification(ui = "No file selected.", type = "error")
      return(NULL)
    }
    ext <- tools::file_ext(file$name)
    if (!(ext %in% c("csv", "xlsx"))) {
      showNotification(ui = "Invalid file extension.", type = "error")
      return(NULL)
    }
    df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
    if (!all(colnames(df) == c("Date", "Amount", "Product", "Source","Category", "Currency"))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    Append2Table(dbConn, "income", df)
    rv_Income(QueryTableMainCur(dbConn, "income", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    # rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    
    showNotification(ui = "Appended income.", type = "default")
  })
  observeEvent(input$in_OverwriteFileIncome, {
    file <- input$in_FileIncome
    if (length(file) == 0) {
      showNotification(ui = "No file selected.", type = "error")
      return(NULL)
    }
    ext <- tools::file_ext(file$name)
    if (!(ext %in% c("csv", "xlsx"))) {
      showNotification(ui = "Invalid file extension.", type = "error")
      return(NULL)
    }
    df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
    if (!all(colnames(df) == c("Date", "Amount", "Product", "Source","Category", "Currency"))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    OverWriteTable(dbConn, "income", df)
    rv_Income(QueryTableMainCur(dbConn, "income", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    # rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    
    showNotification(ui = "Overwrote income.", type = "default")
  })
  # Expenses
  observeEvent(input$in_TrackExpenses, {
    if (input$in_AmountExpenses == 0) {
      showNotification(ui = "Cannot track items of value 0.", type = "error")
      return(NULL)
    }
    TrackIncExp(
      dbConn, "expenses", input$in_DateExpenses, input$in_AmountExpenses, input$in_ProductExpenses, 
      input$in_SourceExpenses, input$in_CategoryExpenses, input$in_CurrencyExpenses
    )
    rv_Expenses(QueryTableMainCur(dbConn, "expenses", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    # rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    
    updateNumericInput(inputId = "in_AmountExpenses", value = 0)
    updateTextInput(inputId = "in_ProductExpenses", value = "")
    updateTextInput(inputId = "in_SourceExpenses", value = "")
    updateTextInput(inputId = "in_CategoryExpenses", value = "")
    
    showNotification(ui = "Successfully tracked expenses.", type = "default")
  })
  observeEvent(input$in_AppendFileExpenses, {
    file <- input$in_FileExpenses
    if (length(file) == 0) {
      showNotification(ui = "No file selected.", type = "error")
      return(NULL)
    }
    ext <- tools::file_ext(file$name)
    if (!(ext %in% c("csv", "xlsx"))) {
      showNotification(ui = "Invalid file extension.", type = "error")
      return(NULL)
    }
    df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
    if (!all(colnames(df) == c("Date", "Amount", "Product", "Source","Category", "Currency"))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    Append2Table(dbConn, "expenses", df)
    rv_Expenses(QueryTableMainCur(dbConn, "expenses", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    # rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    
    showNotification(ui = "Appended expenses.", type = "default")
  })
  observeEvent(input$in_OverwriteFileExpenses, {
    file <- input$in_FileExpenses
    if (length(file) == 0) {
      showNotification(ui = "No file selected.", type = "error")
      return(NULL)
    }
    ext <- tools::file_ext(file$name)
    if (!(ext %in% c("csv", "xlsx"))) {
      showNotification(ui = "Invalid file extension.", type = "error")
      return(NULL)
    }
    df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
    if (!all(colnames(df) == c("Date", "Amount", "Product", "Source","Category", "Currency"))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    OverWriteTable(dbConn, "expenses", df)
    rv_Expenses(QueryTableMainCur(dbConn, "expenses", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    # rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    
    showNotification(ui = "Overwrote expenses.", type = "default")
  })
  # Assets
  observeEvent(input$in_TrackAsset, {
    if (input$in_QuantityAsset == 0) {
      showNotification(ui = "Cannot track a quantity of 0.", type = "error")
      return(NULL)
    }
    if (input$in_TickerSymbolAsset == "") {
      showNotification(ui = "Cannot track an asset without a ticker symbol.", type = "error")
      return(NULL)
    }
    TrackAsset(
      dbConn, input$in_TypeAsset, input$in_GroupAsset, input$in_TickerSymbolAsset, input$in_DisplayNameAsset, 
      input$in_DateAsset, input$in_QuantityAsset, input$in_PriceTotalAsset, input$in_TransTypeAsset, 
      input$in_TransCurrencyAsset, input$in_SourceCurrencyAsset
    )
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
    
    QueryPrices(dbConn)
    AddCurrencies(dbConn, c(input$in_TransCurrencyAsset, input$in_SourceCurrencyAsset))
    QueryXRates(dbConn)

    # rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetGainCurves(GetAssetGainCurves(dbConn, input$in_DateFrom, input$in_DateTo))
    rv_CurrentAssets(CurrentAssets(dbConn, input$in_DateTo))
    rv_InvCurv(InvestedCurves(dbConn, input$in_MainCurrency))
    
    updateTextInput(inputId = "in_DisplayNameAsset", value = "")
    updateNumericInput(inputId = "in_QuantityAsset", value = 0)
    updateNumericInput(inputId = "in_PriceTotalAsset", value = 0)
    updateTextInput(inputId = "in_TickerSymbolAsset", value = "")
    updateTextInput(inputId = "in_GroupAsset", value = "")
    updateTextInput(inputId = "in_TransCurrencyAsset", value = "")
    updateTextInput(inputId = "in_SourceCurrencyAsset", value = "")
    
    showNotification(ui = "Successfully tracked assets.", type = "default")
  })
  observeEvent(input$in_AppendFileAssets, {
    file <- input$in_FileAssets
    if (length(file) == 0) {
      showNotification(ui = "No file selected.", type = "error")
      return(NULL)
    }
    ext <- tools::file_ext(file$name)
    if (!(ext %in% c("csv", "xlsx"))) {
      showNotification(ui = "Invalid file extension.", type = "error")
      return(NULL)
    }
    df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
    if (!all(colnames(df) == c(
      "Date", "DisplayName", "Quantity",	"PriceTotal",	"TickerSymbol",	"Type",	"Group",	"TransactionType",	
      "TransactionCurrency",	"SourceCurrency"
      ))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    Append2Table(dbConn, "assets", df)
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
    
    QueryPrices(dbConn)
    AddCurrencies(dbConn, unique(c(df$TransactionCurrency, df$SourceCurrency)))
    QueryXRates(dbConn)
    
    # rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetGainCurves(GetAssetGainCurves(dbConn, input$in_DateFrom, input$in_DateTo))
    rv_CurrentAssets(CurrentAssets(dbConn, input$in_DateTo))
    rv_InvCurv(InvestedCurves(dbConn, input$in_MainCurrency))
    
    showNotification(ui = "Appended assets.", type = "default")
  })
  observeEvent(input$in_OverwriteFileAssets, {
    file <- input$in_FileAssets
    if (length(file) == 0) {
      showNotification(ui = "No file selected.", type = "error")
      return(NULL)
    }
    ext <- tools::file_ext(file$name)
    if (!(ext %in% c("csv", "xlsx"))) {
      showNotification(ui = "Invalid file extension.", type = "error")
      return(NULL)
    }
    df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
    if (!all(colnames(df) == c(
      "Date", "DisplayName", "Quantity",	"PriceTotal",	"TickerSymbol",	"Type",	"Group",	"TransactionType",	
      "TransactionCurrency",	"SourceCurrency"
    ))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    OverWriteTable(dbConn, "assets", df)
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
    
    QueryPrices(dbConn)
    AddCurrencies(dbConn, unique(c(df$TransactionCurrency, df$SourceCurrency)))
    QueryXRates(dbConn)
    
    # rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetGainCurves(GetAssetGainCurves(dbConn, input$in_DateFrom, input$in_DateTo))
    rv_CurrentAssets(CurrentAssets(dbConn, input$in_DateTo))
    rv_InvCurv(InvestedCurves(dbConn, input$in_MainCurrency))
    
    showNotification(ui = "Overwrote assets.", type = "default")
  })
  
  
  ## Date selection
  observeEvent(input$in_DateFrom, {
    # Income
    rv_Income(QueryTableMainCur(dbConn, "income", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    # rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    # Expenses
    rv_Expenses(QueryTableMainCur(dbConn, "expenses", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    # rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    # Assets
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
    
    # rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetGainCurves(GetAssetGainCurves(dbConn, input$in_DateFrom, input$in_DateTo))
  })
  observeEvent(input$in_DateTo, {
    # Income
    rv_Income(QueryTableMainCur(dbConn, "income", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    # rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    # Expenses
    rv_Expenses(QueryTableMainCur(dbConn, "expenses", input$in_DateFrom, input$in_DateTo, input$in_MainCurrency))
    # rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    # rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    # Assets
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
    
    # rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
    # rv_AssetGainCurves(GetAssetGainCurves(dbConn, input$in_DateFrom, input$in_DateTo))
    rv_CurrentAssets(CurrentAssets(dbConn, input$in_DateTo))
  })
  observeEvent(input$in_EntireDateRange, {
    updateDateInput(inputId = "in_DateFrom", value = FirstDate(dbConn))
    updateDateInput(inputId = "in_DateTo", value = rv_Today())
  })
  observeEvent(input$in_YTD, {
    updateDateInput(inputId = "in_DateFrom", value = dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]])
    updateDateInput(inputId = "in_DateTo", value = rv_Today())
  })
  observeEvent(input$in_OneYearDateRange, {
    from <- as.POSIXlt(Sys.Date())
    from$year <- from$year - 2
    from <- format(as.Date(from), "%Y-%m-%d")
    updateDateInput(inputId = "in_DateFrom", value = from)
    updateDateInput(inputId = "in_DateTo", value = rv_Today())
  })
  observeEvent(input$in_ThisMonthDateRange, {
    updateDateInput(inputId = "in_DateFrom", value = format(as.Date(rv_Today()), "%Y-%m-01"))
    updateDateInput(inputId = "in_DateTo", value = rv_Today())
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
  output$out_DTIncome   <- DT::renderDT({ DT::datatable(rv_Income(), options = list(paging = TRUE, pageLength = 7)) })
  # Expenses
  output$out_DTExpenses <- DT::renderDT({ DT::datatable(rv_Expenses(), options = list(paging = TRUE, pageLength = 7)) })
  # Assets
  output$out_DTAssets   <- DT::renderDT({ DT::datatable(rv_Assets(), options = list(paging = TRUE, pageLength = 5)) })
  
  ## Income
  output$out_hcIncomeCategory <- renderHighchart({ hcIncExpByCategory(rv_Income(), input$in_MainCurrency, input$in_DarkModeOn) })
  output$out_hcIncomeMonth    <- renderHighchart({ hcIncExpByMonth(rv_Income(), input$in_ColorProfit, input$in_MainCurrency, input$in_DarkModeOn) })
  output$out_hcIncomeSource   <- renderHighchart({ hcIncExpBySource(rv_Income(), input$in_MainCurrency, input$in_DarkModeOn)})
  
  ## Expenses
  output$out_hcExpensesCategory <- renderHighchart({ hcIncExpByCategory(rv_Expenses(), input$in_MainCurrency, input$in_DarkModeOn) })
  output$out_hcExpensesMonth    <- renderHighchart({ hcIncExpByMonth(rv_Expenses(), input$in_ColorLoss, input$in_MainCurrency, input$in_DarkModeOn) })
  output$out_hcExpensesSource   <- renderHighchart({ hcIncExpBySource(rv_Expenses(), input$in_MainCurrency, input$in_DarkModeOn)})
  
  ## Assets
  output$out_hcPlaceHolder <- renderHighchart({})
  output$out_hcAssetAllocAcq <- renderHighchart({ hcAssetAllocAcq(rv_InvCurv(), rv_CurrentAssets(), input$in_DateTo, input$in_MainCurrency, input$in_DarkModeOn) })
  output$out_hcAssetAllocCur <- renderHighchart({ hcAssetAllocCur(rv_InvCurv(), rv_CurrentAssets(), input$in_DateTo, input$in_MainCurrency, input$in_DarkModeOn) })
  output$out_hcAssetGainsStock <- renderHighchart({ hcAssetGains(rv_InvCurv(), rv_CurrentAssets(), "Stock", input$in_DateFrom, input$in_DateTo, input$in_DarkModeOn) })
  output$out_hcAssetGainsAlternative <- renderHighchart({ hcAssetGains(rv_InvCurv(), rv_CurrentAssets(), "Alternative", input$in_DateFrom, input$in_DateTo, input$in_DarkModeOn) })
  output$out_hcAssetGainCurvesStock <- renderHighchart({ hcAssetGainCurves(rv_InvCurv(), "Stock", input$in_DateFrom, input$in_DateTo, input$in_DarkModeOn) })
  output$out_hcAssetGainCurvesAlternative <- renderHighchart({ hcAssetGainCurves(rv_InvCurv(), "Alternative", input$in_DateFrom, input$in_DateTo, input$in_DarkModeOn) })
  
  ## Summary
  output$out_txtPLTotal <- renderUI({ 
    txtPLTotal(
      rv_Income(), rv_Expenses(), rv_InvCurv(), input$in_DateFrom, input$in_DateTo, input$in_MainCurrency, 
      input$in_ColorProfit, input$in_ColorLoss
    )
  })
  output$out_txtPLRatio <- renderUI({
    txtPLRatio(
      rv_Income(), rv_Expenses(), rv_InvCurv(), input$in_DateFrom, input$in_DateTo, 
      input$in_ColorProfit, input$in_ColorLoss
    )
  })
  output$out_hcPLSource <- renderHighchart({})
  output$out_hcPLMonth  <- renderHighchart({})
  
}

