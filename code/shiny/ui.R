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
  selected = "Tracking",
  lang = "en",
  
  sidebar = sidebar(
    # switchInput(
    #   inputId  = "input_DarkMode",
    #   label    = "",
    #   value    = c_DarkOnStart,
    #   onLabel  = "light",
    #   offLabel = "dark"
    # )
    div(
      style = "display: flex; gap: 20px;",
      dateInput(
        inputId   = "in_DateFrom",
        label     = "From",
        value     = paste0(substr(Sys.Date(), 1, 4), "-01-01"),
        min       = as.Date("1900-01-01", format = "%Y-%m-%d"),
        format    = "yy/mm/dd"
      ),
      dateInput(
        inputId   = "in_DateTo",
        label     = "To",
        value     = Sys.Date(),
        min       = as.Date("1900-01-01", format = "%Y-%m-%d"),
        max       = Sys.Date(),
        format    = "yy/mm/dd"
      )
    )
  ),
  
  
  nav_panel(
    title = "Summary"
  ),
  
  
  nav_panel(
    title = "Income"
  ),
  
  
  nav_panel(
    title = "Expenses"
  ),
  
  
  nav_panel(
    title = "Assets"
  ),
  
  
  nav_panel(
    title = "Tracking",
    
    navset_card_underline(
      full_screen = TRUE,
      
      nav_panel(
        title = "Income",
        DT::DTOutput("out_DTIncExp"),
        div(
          style = "display: flex; gap: 20px;",
          dateInput(
            inputId = "in_DateIncome",
            label   = "Date",
            value   = Sys.Date(),
            format  = "yy/mm/dd"
          ),
          numericInput(
            inputId = "in_AmountIncome",
            label   = "Amount",
            value   = 0,
            min     = 0,
            step    = 1
          ),
          textInput(
            inputId     = "in_ProductIncome",
            label       = "Product",
            value       = "",
            placeholder = "insert income name"
          ),
          textInput(
            inputId     = "in_SourceIncome",
            label       = "Source",
            value       = "",
            placeholder = "insert income source"
          ),
          textInput(
            inputId     = "in_CategoryIncome",
            label       = "Category",
            value       = "",
            placeholder = "insert income category"
          )
        ),
        bslib::input_task_button(
          id         = "in_TrackIncome",
          label      = "Track",
          label_busy = "Tracking income...",
          auto_reset = FALSE, state = "ready"
        ),
        div(
          style = "display: flex; gap: 20px;",
          fileInput(
            inputId = "in_FileIncome",
            label   = "Income file",
            accept  = c(".csv", ".xlsx"),
            placeholder = "Add .csv or .xlsx"
          ),
          bslib::input_task_button(
            id         = "in_AppendFileIncome",
            label      = "Append",
            label_busy = "Appending to income...",
            auto_reset = FALSE, state = "ready"
          ),
          bslib::input_task_button(
            id         = "in_OverwriteFileIncome",
            label      = "Overwrite",
            label_busy = "Overwriting income...",
            auto_reset = FALSE, state = "ready"
          )
        )
      )
      
      
    )
  )
)