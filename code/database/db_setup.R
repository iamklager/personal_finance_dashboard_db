#### Database setup
# Creating database and tables if not already existent.


### Database ----
dbConn <- dbConnect(SQLite(), "data/dbFinances")


### Income ----
dbSendQuery(
  conn      = dbConn, 
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
  conn      = dbConn, 
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
  conn      = dbConn,
  statement = "
  create table if not exists assets
  (
    Date text not null,
    DisplayName text not null,
    Quantity real not null,
    PriceTotal real not null,
    TickerSymbol text not null,
    Type text not null,
    [Group] text not null,
    TransactionType text not null,
    TransactionCurrency text not null,
    SourceCurrency text not null
  );
  "
)


### Price data ----
dbSendQuery(
  conn      = dbConn, 
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


### Settings ----
dbSendQuery(
  conn      = dbConn,
  statement = "
  create table if not exists settings
  (
    DarkModeOn integer not null,
    ColorProfit not null,
    ColorLoss not null,
    DateFormat text not null,
    DateFrom text not null
  );
  "
)
dbSendQuery(
  conn = dbConn,
  statement = paste0("
  insert into settings
  select 0, '#90ed7d', '#f45b5b', 'yyyy-mm-dd', '", format(Sys.Date(), "%Y"), "-01-01'
  where not exists (
    select 1 from settings
  );
  ")
)

