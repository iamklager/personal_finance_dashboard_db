#### hcAssetGainCurves
# Function to get the cumulated asset gain curves.


hcAssetGainCurves <- function(df, type, from, to, darkmode_on) {
  if ((nrow(df) == 0) || (from == to)) {
    return(
      shiny::validate(
        need(((nrow(df) != 1) & (from != to)), "No data available.")
      )
    )
  }
  
  df <- df[(df$Date >= from) & (df$Date <= to) & (df$Type == type), ]
  df$RelVal <- df$Value / df$AcqVal
  df <- na.omit(df)
  df <- split(df, df$AssetID)
  df <- dplyr::bind_rows(lapply(df, function(x) {
    x$Gain = 100 * (x$RelVal - x$RelVal[x$Date == min(x$Date)])
    x
  }))
  df$Date <- as.Date(df$Date)
  
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
    hc_add_series(data = df, hcaes(x = Date, y = Gain, group = DisplayName), type = "line")
  
  if (darkmode_on) {
    hc_add_theme(res, hc_theme_dark())
  } else {
    hc_add_theme(res, hc_theme_light())
  }
}



