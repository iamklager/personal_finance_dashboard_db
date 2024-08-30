#### InvestedCurves
# Function to compute the total investments into each asset in USD.


InvestedCurves <- function(conn) {
  
  # "Raw" data
  dist_assets <- dbGetQuery(conn, "SELECT * FROM vDistAssets;")
  if (nrow(dist_assets) == 0) {
    return(NULL)
  }
  
  # Summing price curves and total quantities
  investments <- dplyr::bind_rows(lapply(1:nrow(dist_assets), function(i) {
    prices <- dbGetQuery(
      conn,
      "
        SELECT *
        FROM vPricesUSD
        WHERE TickerSymbol = ?
      ",
      params = dist_assets[i, "TickerSymbol"]
    )
    transactions <- dbGetQuery(
      conn,
      "
        SELECT *
        FROM vAssetsUSD
        WHERE AssetID = ?
      ",
      params = dist_assets[i, "AssetID"]
    )
    
    res <- data.frame(Date = prices$Date, Value = 0, Quantity = 0, AcqVal = 0)
    for (t in 1:nrow(transactions)) {
      res$Value    <- res$Value + ifelse(prices$Date < transactions[t, "Date"], 0, prices$PriceUSD) * transactions[t, "Quantity"]
      res$Quantity <- res$Quantity + ifelse(prices$Date < transactions[t, "Date"], 0, transactions[t, "Quantity"])
      if (transactions[t, "Quantity"] > 0) {
        res$AcqVal <- res$AcqVal + ifelse(prices$Date < transactions[t, "Date"], 0, transactions[t, "PriceTotalUSD"])
      } else {
        res$AcqVal <- res$AcqVal - ifelse(prices$Date < transactions[t, "Date"], 0, mean(res[nrow(res), "AcqVal"]) * transactions[t, "Quantity"])
      }
    }
    res$AssetID = dist_assets[i, "AssetID"]
    
    res
  }))
  
  na.omit(res)
}

