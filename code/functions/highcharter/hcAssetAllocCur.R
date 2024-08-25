#### hcAssetAllocCur
# Plots the user's asset allocation at the current value for his selected currency.


hcAssetAllocCur <- function(df, main_currency, darkmode_on) {
  if (nrow(df) == 0) {
    return(
      shiny::validate(
        need((nrow(df) != 0), "No data available.")
      )
    )
  }
  
  res <- highchart2() |> 
    hc_plotOptions(
      column = list(
        borderWidth = 0, 
        stacking = "normal",
        tooltip = list(
          valueDecimals = 2, 
          valueSuffix = paste0(" ", main_currency)
        )
      )
    ) |> 
    hc_xAxis(type = "category") |> 
    hc_yAxis(title = list(text = "Position Size")) |> 
    hc_add_series(data = df, hcaes(x = Type, y = PositionSize, group = DisplayName), type = "column")
  
  if (darkmode_on) {
    hc_add_theme(res, hc_theme_dark())
  } else {
    hc_add_theme(res, hc_theme_light())
  }
}


