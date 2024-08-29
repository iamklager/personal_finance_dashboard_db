#### hcAssetGainCurves
# Function to get the cumulated asset gain curves.


hcAssetGainCurves <- function(df, type, darkmode_on) {
  if (nrow(df) == 0) {
    return(
      shiny::validate(
        need((nrow(df) != 0), "No data available.")
      )
    )
  }
  
  df <- df[df$Type == type, ]
  
  res <- highchart2() |> 
    hc_plotOptions(
      line = list(
        borderWidth = 0, 
        tooltip = list(
          valueDecimals = 2, 
          valueSuffix = " %"
        )
      )
    ) |> 
    hc_xAxis(type = "datetime", labels = list(text = "Date")) |> 
    hc_yAxis(labels = list(text = "Price", format = "{value} %")) |> 
    hc_add_series(data = df, hcaes(x = Date, y = Price, group = DisplayName), type = "line")
  
  if (darkmode_on) {
    hc_add_theme(res, hc_theme_dark())
  } else {
    hc_add_theme(res, hc_theme_light())
  }
}



