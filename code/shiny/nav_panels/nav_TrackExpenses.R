nav_TrackExpenses <- nav_panel(
  title = "Expenses",
  div(
    style = "display: block;",
    DT::DTOutput("out_DTExpenses")
  ),
  div(
    style = "display: inline-flex; border-width: thick; gap: 1.50%; justify-content: center; align-items: center;",
    dateInput(
      inputId = "in_DateExpenses",
      label   = "Date",
      value   = Sys.Date(),
      max     = Sys.Date(),
      format  = "yy/mm/dd",
      width   = "8.70%"
    ),
    numericInput(
      inputId = "in_AmountExpenses",
      label   = "Amount",
      value   = 0.00,
      min     = 0.00,
      step    = 0.50,
      width   = "8.70%"
    ),
    textInput(
      inputId     = "in_ProductExpenses",
      label       = "Product",
      value       = "",
      placeholder = "insert expenses name",
      width       = "34.78%"
    ),
    textInput(
      inputId     = "in_SourceExpenses",
      label       = "Source",
      value       = "",
      placeholder = "insert expenses source",
      width       = "13.04%"
    ),
    textInput(
      inputId     = "in_CategoryExpenses",
      label       = "Category",
      value       = "",
      placeholder = "insert expenses category",
      width       = "13.04%"
    ),
    input_task_button(
      id         = "in_TrackExpenses",
      label      = "Track",
      label_busy = "Tracking expenses...",
      auto_reset = TRUE, state = "ready",
      style      = "width: 21.74%; height: 40px;"
    )
  ),
  div(
    style = "display: inline-flex; border-width: thick; gap: 1.50%; justify-content: center; align-items: center;",
    fileInput(
      inputId = "in_FileExpenses",
      label   = "Expenses file",
      accept  = c(".csv", ".xlsx"),
      placeholder = ".csv or .xlsx",
      width = "51.16%"
    ),
    input_task_button(
      id         = "in_AppendFileExpenses",
      label      = "Append",
      label_busy = "Appending to expenses...",
      auto_reset = TRUE, state = "ready",
      style      = "width: 22.92%; height: 40px;"
    ),
    input_task_button(
      id         = "in_OverwriteFileExpenses",
      label      = "Overwrite",
      label_busy = "Overwriting expenses...",
      auto_reset = TRUE, state = "ready",
      style      = "width: 22.92%; height: 40px;"
    )
  )
)

