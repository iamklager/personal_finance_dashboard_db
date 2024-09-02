#### txtPLRatio
# Function to compute the total profit/loss within the given time period as percentage of income.


txtPLRatio <- function(income, expenses, invested_curves, from, to, col_pos, col_neg) {
  invested_curves <- invested_curves[(invested_curves$Date >= from) & (invested_curves$Date <= to), ]
  invested_curves <- split(invested_curves, invested_curves$AssetID)
  invested_curves <- sum(unlist(lapply(invested_curves, function(x) {
    x <- x[x$Date %in% c(min(x$Date), max(x$Date)), ]
    x$Value[2] - ((x$Value[1] / x$Quantity[1]) * x$Quantity[2])
  })))
  
  res <- round(100 * ((sum(income$Amount) - sum(expenses$Amount) + invested_curves) / sum(income$Amount)), 2)
  res   <- as.character(res)
  dot_pos <-  unlist(gregexpr("\\.", res))
  if (dot_pos > 4) {
    res <- paste0(
      substr(res, 1, dot_pos - 4),
      " ",
      substr(res, dot_pos - 3, nchar(res))
    )
  }
  res <- paste0(res, " %")
  shiny::tags$span(
    style = paste0(
      "color:", ifelse(res >= 0, col_pos, col_neg), "; ",
      "margin: auto; text-align: center; ",
      "font-size: 96px;"
    ),
    res
  )
}

