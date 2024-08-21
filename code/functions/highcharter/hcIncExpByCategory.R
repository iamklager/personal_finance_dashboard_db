#### hcIncExpByCategory
# Plots income or expenses by category.


hcIncExpByCategory <- function(df) {
  if (nrow(df) == 0) {
    return(
      shiny::validate(
        need((nrow(df) != 0), "No data available based on your selection")
      )
    )
  }
  highchart() |> 
    hc_plotOptions(column = list(borderWidth = 0, stacking = "normal")) |> 
    hc_xAxis(type = "category") |> 
    hc_yAxis(title = list(text = "Amount")) |> 
    hc_add_series(data = df, hcaes(x = Category, y = Amount, group = Category), type = "column")
}


