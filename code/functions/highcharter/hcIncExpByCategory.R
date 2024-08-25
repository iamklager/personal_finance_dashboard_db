#### hcIncExpByCategory
# Plots income or expenses by category.


hcIncExpByCategory <- function(df, darkmode_on) {
  if (nrow(df) == 0) {
    return(
      shiny::validate(
        need((nrow(df) != 0), "No data available.")
      )
    )
  }
  
  res <- highchart2() |> 
    hc_plotOptions(column = list(borderWidth = 0, stacking = "normal"), tooltip = list(valueDecimals = 2)) |> 
    hc_xAxis(type = "category") |> 
    hc_yAxis(title = list(text = "Amount")) |> 
    hc_add_series(data = df, hcaes(x = Category, y = Amount, group = Category), type = "column")
  
  if (darkmode_on) {
    hc_add_theme(res, hc_theme_dark())
  } else {
    hc_add_theme(res, hc_theme_light())
  }
}


