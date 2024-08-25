#### hcAssetAllocAcq
# Plots the user's asset allocation at acquisition value for his selected currency.


hcAssetGains <- function(acq, cur, type, darkmode_on) {
  if (nrow(acq) == 0 | nrow(cur) == 0) {
    return(
      shiny::validate(
        need((nrow(df) != 0), "No data available.")
      )
    )
  }
  
  df <- merge(x = acq, y = cur, by = c("DisplayName", "TickerSymbol", "Type", "Group"), all = FALSE)
  df$Gain <- ((df$PositionSize.y / df$PositionSize.x) - 1) * 100
  df <-  df[df$Type == type, ]
  
  res <- highchart2() |> 
    hc_plotOptions(
      column = list(
        borderWidth = 0,
        grouping = FALSE,
        tooltip = list(
          valueDecimals = 2, 
          valueSuffix = " %"
        )
      )
    ) |> 
    hc_xAxis(type = "category", title = list(text = type)) |> 
    hc_yAxis(labels = list(format = "{value} %")) |> 
    hc_add_series(data = df, hcaes(x = DisplayName, y = Gain, group = Group), type = "column")
  
  if (darkmode_on) {
    hc_add_theme(res, hc_theme_dark())
  } else {
    hc_add_theme(res, hc_theme_light())
  }
}

