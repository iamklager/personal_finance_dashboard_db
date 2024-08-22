nav_TrackAssets <- nav_panel(
  title = "Assets",
  div(
    style = "display: block;",
    DT::DTOutput("out_DTAssets")
  ),
  div(
    style = "display: inline-flex; border-width: thick; gap: 1.50%; justify-content: center; align-items: center;",
    dateInput(
      inputId = "in_DateAsset",
      label   = "Date",
      value   = Sys.Date(),
      max     = Sys.Date(),
      format  = dbGetQuery(dbConn, "select DateFormat from settings limit 1;")[[1]],
      width   = "8.70%"
    ),
    textInput(
      inputId     = "in_DisplayNameAsset",
      label       = "Name",
      value       = "",
      placeholder = "none",
      width       = "34.78%"
    ),
    numericInput(
      inputId = "in_QuantityAsset",
      label   = "Quantity",
      value   = 0.00,
      min     = 0.00,
      step    = 1.00,
      width   = "11.30%"
    ),
    numericInput(
      inputId = "in_PriceTotalAsset",
      label   = "Price (Total)",
      value   = 0.00,
      min     = 0.00,
      step    = 0.50,
      width   = "11.30%"
    ),
    textInput(
      inputId     = "in_TickerSymbolAsset",
      label       = "Ticker Symbol",
      value       = "",
      placeholder = "none",
      width       = "11.30%"
    ),
    selectizeInput(
      inputId     = "in_TypeAsset",
      label       = "Type",
      choices     = c("Stock", "Alternative"),
      selected    = "Stock",
      multiple    = "FALSE",
      width       = "11.30%"
    ),
    textInput(
      inputId     = "in_GroupAsset",
      label       = "Group",
      value       = "",
      placeholder = "none",
      width       = "11.30%"
    )
  ),
  div(
    style = "display: inline-flex; border-width: thick; gap: 1.50%; justify-content: center; align-items: center;",
    selectizeInput(
      inputId     = "in_TransTypeAsset",
      label       = "Transaction Type",
      choices     = c("Buy", "Sell"),
      selected    = "Buy",
      multiple    = "FALSE",
      width       = "16.02%"
    ),
    textInput(
      inputId     = "in_TransCurrencyAsset",
      label       = "Transaction Currency",
      value       = "",
      placeholder = "none",
      width       = "16.02%"
    ),
    textInput(
      inputId     = "in_SourceCurrencyAsset",
      label       = "Source Currency",
      value       = "",
      placeholder = "none",
      width       = "16.02%"
    ),
    input_task_button(
      id         = "in_TrackAsset",
      label      = "Track",
      label_busy = "Tracking asset",
      auto_reset = TRUE, state = "ready",
      style      = "width: 47.34%; height: 40px;"
    )
  ),
  div(
    style = "display: inline-flex; border-width: thick; gap: 1.50%; justify-content: center; align-items: center;",
    fileInput(
      inputId = "in_FileAssets",
      label   = "Assets file",
      accept  = c(".csv", ".xlsx"),
      placeholder = ".csv or .xlsx",
      width = "51.16%"
    ),
    input_task_button(
      id         = "in_AppendFileAssets",
      label      = "Append",
      label_busy = "Appending to assets...",
      auto_reset = TRUE, state = "ready",
      style      = "width: 22.92%; height: 40px;"
    ),
    input_task_button(
      id         = "in_OverwriteFileAssets",
      label      = "Overwrite",
      label_busy = "Overwriting asset...",
      auto_reset = TRUE, state = "ready",
      style      = "width: 22.92%; height: 40px;"
    )
  )
)

