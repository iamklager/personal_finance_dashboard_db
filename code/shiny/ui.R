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
    ),
    
    
    downloadButton(
      outputId = "out_Download",
      label = "Download .csv"
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
        div(
          style = "display: block;",
          DT::DTOutput("out_DTIncExp")
        ),
        div(
          style = "display: inline-flex; border-width: thick; gap: 1.50%; justify-content: center; align-items: center;",
          dateInput(
            inputId = "in_DateIncome",
            label   = "Date",
            value   = Sys.Date(),
            format  = "yy/mm/dd",
            width   = "8.70%"
          ),
          numericInput(
            inputId = "in_AmountIncome",
            label   = "Amount",
            value   = 0.00,
            min     = 0.00,
            step    = 0.50,
            width   = "8.70%"
          ),
          textInput(
            inputId     = "in_ProductIncome",
            label       = "Product",
            value       = "",
            placeholder = "insert income name",
            width       = "34.78%"
          ),
          textInput(
            inputId     = "in_SourceIncome",
            label       = "Source",
            value       = "",
            placeholder = "insert income source",
            width       = "13.04%"
          ),
          textInput(
            inputId     = "in_CategoryIncome",
            label       = "Category",
            value       = "",
            placeholder = "insert income category",
            width       = "13.04%"
          ),
          input_task_button(
            id         = "in_TrackIncome",
            label      = "Track",
            label_busy = "Tracking income...",
            auto_reset = TRUE, state = "ready",
            style      = "width: 21.74%; height: 40px;"
          )
        ),
        div(
          style = "display: inline-flex; border-width: thick; gap: 1.50%; justify-content: center; align-items: center;",
          fileInput(
            inputId = "in_FileIncome",
            label   = "Income file",
            accept  = c(".csv", ".xlsx"),
            placeholder = "Add .csv or .xlsx",
            width = "51.16%"
          ),
          input_task_button(
            id         = "in_AppendFileIncome",
            label      = "Append",
            label_busy = "Appending to income...",
            auto_reset = TRUE, state = "ready",
            style      = "width: 100%; height: 40px;"
          ),
          input_task_button(
            id         = "in_OverwriteFileIncome",
            label      = "Overwrite",
            label_busy = "Overwriting income...",
            auto_reset = TRUE, state = "ready",
            style      = "width: 100%; height: 40px;"
          )
        )
      )
      
      
    )
  )
)