#### TrackIncExp
# Function to track income/expenses (i.e., add entries to the database after pressing the ui button).

TrackIncExp <- function(conn, table_name, date, amount, product, source, category) {
  dbSendQuery(
    conn = conn,
    statement = paste0("
    insert into ", table_name, "
    values ('", date, "', ", amount, ", '", product, "', '", source, "', '", category, "');
    ")
  )
}

