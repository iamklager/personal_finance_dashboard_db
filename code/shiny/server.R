#### Server
# The server...


server <- function(input, output, session) {
  
  ### Reactive values
  rv_Income <- reactiveVal(QueryTableSimple(dbConn, "income", paste0(format(Sys.Date(), "%Y"), "-01-01"), format(Sys.Date(), "%Y-%m-%d")))
  
  ### Event handling
  ## Date selection
  observeEvent(input$in_DateFrom, {
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
  })
  observeEvent(input$in_DateTo, {
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
  })
  
  ## Adding income
  observeEvent(input$in_TrackIncome, {
    TrackIncExp(dbConn, "income", input$in_DateIncome, input$in_AmountIncome, input$in_ProductIncome, input$in_SourceIncome, input$in_CategoryIncome)
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
  })
  observeEvent(input$in_AppendFileIncome, {
    file <- input$in_FileIncome
    ext <- tools::file_ext(file$name)
    df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    Append2Table(dbConn, "income", df)
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
  })
  observeEvent(input$in_OverwriteFileIncome, {
    file <- input$in_FileIncome
    ext <- tools::file_ext(file$name)
    df <- switch(EXPR = ext, csv = read.csv(file$datapath), xlsx = readxl::read_xlsx(file$datapath))
    df$Date <- format(as.Date(df$Date), "%Y-%m-%d")
    OverWriteTable(dbConn, "income", df)
    rv_Income(QueryTableSimple(dbConn, "income", input$in_DateFrom, input$in_DateTo))
  })
  
  ## Adding expenses
  
  
  
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
  output$out_DTIncExp <- DT::renderDT({ rv_Income() })
  # Expenses
}