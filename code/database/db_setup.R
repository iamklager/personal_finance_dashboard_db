#### Database setup
# Creating database and tables if not already existent.


### Database ----
dbConn <- dbConnect(SQLite(), "data/dbFinances")


### Income ----
dbSendQuery(
  conn = dbConn, 
  statement = "
  create table if not exists income
  (
    Date text not null,
    Amount real not null,
    Product text,
    Source text,
    Category text
  );
  "
)


### Expenses ----
dbSendQuery(
  conn = dbConn, 
  statement = "
  create table if not exists expenses
  (
    Date text not null,
    Amount real not null,
    Product text,
    Source text,
    Category text
  );
  "
)


### Assets ----
dbSendQuery(
  conn = dbConn,
  statement = "
  create table if not exists assets
  (
    Type text not null,
    [Group] text not null,
    TickerSymbol text not null,
    DisplayName text not null,
    Date text not null,
    Quantity real not null,
    PriceTotal real not null,
    TransactionType text not null,
    TransactionCurrency text not null,
    SourceCurrency text not null
  );
  "
)


### Price data ----
dbSendQuery(
  conn = dbConn, 
  statement = "
  create table if not exists price_data
  (
    Date text not null,
    Open real,
    High real,
    Low real,
    Close real,
    Volume real,
    Adjusted real,
    TickerSymbol text not null
  );
  "
)


# dbGetQuery(dbConn, "select * from income;")
# dbGetQuery(dbConn, "select * from expenses;")
# dbGetQuery(dbConn, "select * from assets;")
# dbGetQuery(dbConn, "select * from price_data;")
