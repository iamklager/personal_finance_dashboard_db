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
  rv_Income      <- reactiveVal(QueryTableSimple(dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_IncomeGroup <- reactiveVal(QueryIncExpGrouped(dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_IncomeMonth <- reactiveVal(QueryIncExpMonth(dbConn, "income", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  
  ## Expenses
  rv_Expenses      <- reactiveVal(QueryTableSimple(dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_ExpensesGroup <- reactiveVal(QueryIncExpGrouped(dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_ExpensesMonth <- reactiveVal(QueryIncExpMonth(dbConn, "expenses", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  
  ## Assets
  rv_Assets <- reactiveVal(QueryTableSimple(dbConn, "assets", dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]], Sys.Date()))
  rv_AssetAllocAcq <- reactiveVal(AssetAllocAcq(dbConn, Sys.Date(), dbGetQuery(dbConn, "SELECT Currency FROM currencies LIMIT 1;")[[1]]))
  rv_AssetAllocCur <- reactiveVal(AssetAllocCur(dbConn, Sys.Date(), dbGetQuery(dbConn, "SELECT Currency FROM currencies LIMIT 1;")[[1]]))
  
  ### Event handling
  ## Periodically
  observeEvent(rv_Today(), {
    # Writing price data
    QueryPrices(dbConn)
    QueryXRates(dbConn)
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
    dbSendQuery(dbConn, paste0("update settings set DarkModeOn = ", input$in_DarkModeOn, ";"))
    rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    rv_AssetAllocCur(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
  })
  
  
  ## Tracking
  # Income
  observeEvent(input$in_TrackIncome, {
    if (input$in_AmountIncome == 0) {
      showNotification(ui = "Cannot track items of value 0.", type = "error")
      return(NULL)
    }
    TrackIncExp(dbConn, "income", input$in_DateIncome, input$in_AmountIncome, input$in_ProductIncome, input$in_SourceIncome, input$in_CategoryIncome)
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
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
    if (!all(colnames(df) == c("Date", "Amount", "Product", "Source","Category"))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    Append2Table(dbConn, "income", df)
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    
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
    if (!all(colnames(df) == c("Date", "Amount", "Product", "Source","Category"))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    OverWriteTable(dbConn, "income", df)
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    
    showNotification(ui = "Overwrote income.", type = "default")
  })
  # Expenses
  observeEvent(input$in_TrackExpenses, {
    if (input$in_AmountExpenses == 0) {
      showNotification(ui = "Cannot track items of value 0.", type = "error")
      return(NULL)
    }
    TrackIncExp(dbConn, "expenses", input$in_DateExpenses, input$in_AmountExpenses, input$in_ProductExpenses, input$in_SourceExpenses, input$in_CategoryExpenses)
    rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
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
    if (!all(colnames(df) == c("Date", "Amount", "Product", "Source","Category"))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    Append2Table(dbConn, "expenses", df)
    rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    
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
    if (!all(colnames(df) == c("Date", "Amount", "Product", "Source","Category"))) {
      showNotification(ui = "File columns do not match.", type = "error")
      return(NULL)
    }
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    OverWriteTable(dbConn, "expenses", df)
    rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    
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
    rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
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
    rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
    
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
    rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
    
    showNotification(ui = "Overwrote assets.", type = "default")
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
    rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
  })
  observeEvent(input$in_DateTo, {
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeGroup(QueryIncExpGrouped(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_IncomeMonth(QueryIncExpMonth(dbConn, "income", input$in_DateFrom, input$in_DateTo))
    rv_Expenses(QueryTableSimple(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesGroup(QueryIncExpGrouped(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_ExpensesMonth(QueryIncExpMonth(dbConn, "expenses", input$in_DateFrom, input$in_DateTo))
    rv_Assets(QueryTableSimple(dbConn, "assets", input$in_DateFrom, input$in_DateTo))
    rv_AssetAllocAcq(AssetAllocAcq(dbConn, input$in_DateTo, input$in_MainCurrency))
    rv_AssetAllocCur(AssetAllocCur(dbConn, input$in_DateTo, input$in_MainCurrency))
  })
  observeEvent(input$in_EntireDateRange, {
    updateDateInput(inputId = "in_DateFrom", value = FirstDate(dbConn))
    updateDateInput(inputId = "in_DateTo", value = rv_Today())
  })
  observeEvent(input$in_YTD, {
    updateDateInput(inputId = "in_DateFrom", value = dbGetQuery(dbConn, "select DateFrom from settings limit 1;")[[1]])
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
  output$out_DTIncome   <- DT::renderDT({ rv_Income() })
  # Expenses
  output$out_DTExpenses <- DT::renderDT({ rv_Expenses() })
  # Assets
  output$out_DTAssets   <- DT::renderDT({ rv_Assets() })
  
  ## Income
  output$out_hcIncomeCategory <- renderHighchart({ hcIncExpByCategory(rv_IncomeGroup(), input$in_DarkModeOn) })
  output$out_hcIncomeMonth    <- renderHighchart({ hcIncExpByMonth(rv_IncomeMonth(), input$in_ColorProfit, input$in_DarkModeOn) })
  output$out_hcIncomeSource   <- renderHighchart({ hcIncExpBySource(rv_IncomeGroup(), input$in_DarkModeOn)})
  
  ## Expenses
  output$out_hcExpensesCategory <- renderHighchart({ hcIncExpByCategory(rv_ExpensesGroup(), input$in_DarkModeOn) })
  output$out_hcExpensesMonth    <- renderHighchart({ hcIncExpByMonth(rv_ExpensesMonth(), input$in_ColorLoss, input$in_DarkModeOn) })
  output$out_hcExpensesSource   <- renderHighchart({ hcIncExpBySource(rv_ExpensesGroup(), input$in_DarkModeOn)})
  
  ## Assets
  output$out_hcPlaceHolder <- renderHighchart({})
  output$out_hcAssetAllocAcq <- renderHighchart({ hcAssetAllocAcq(rv_AssetAllocAcq(), input$in_MainCurrency, input$in_DarkModeOn) })
  output$out_hcAssetAllocCur <- renderHighchart({ hcAssetAllocCur(rv_AssetAllocCur(), input$in_MainCurrency, input$in_DarkModeOn) })
  output$out_hcAssetGainsStock <- renderHighchart({ hcAssetGains(rv_AssetAllocAcq(), rv_AssetAllocCur(), "Stock", input$in_DarkModeOn) })
  output$out_hcAssetGainsAlternative <- renderHighchart({ hcAssetGains(rv_AssetAllocAcq(), rv_AssetAllocCur(), "Alternative", input$in_DarkModeOn) })
  
}

