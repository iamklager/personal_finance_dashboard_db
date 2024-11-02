#### Database setup
# Creating database and tables if not already existent.


### Database ----
dbConn <- dbConnect(SQLite(), "data/dbFinances.sqlite3")


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
    Category text,
    Currency text not null
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
    Category text,
    Currency text not null
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
  CREATE TABLE IF NOT EXISTS price_data
  (
    Date TEXT NOT NULL,
    Open REAL,
    High REAL,
    Low REAL,
    Close REAL,
    Volume REAL,
    Adjusted REAL,
    TickerSymbol TEXT NOT NULL,
    SourceCurrency TEXT NOT NULL
  );
  "
)
DBI::dbSendStatement(
  conn = dbConn,
  statement = "CREATE INDEX IF NOT EXISTS index_price_data ON price_data (Date, TickerSymbol);"
)
# All xrates are based on USD. Hence, an entry where Currency = 'EUR' presents the xrate EUR/USD.
dbSendQuery(
  conn      = dbConn, 
  statement = "
  create table if not exists xrates
  (
    Date text not null,
    Open real,
    High real,
    Low real,
    Close real,
    Volume real,
    Adjusted real,
    Currency text not null
  );
  "
)
DBI::dbSendStatement(
  conn = dbConn,
  statement = "CREATE INDEX IF NOT EXISTS index_xrates ON xrates (Date, Currency);"
)


### Currency stuff ----
dbSendQuery(
  conn      = dbConn, 
  statement = "
  create table if not exists currencies
  (
    Currency text not null
  );
  "
)
dbSendQuery(
  conn      = dbConn,
  statement = "
  insert into currencies (Currency)
  select 'EUR'
  where not exists (
    select 1 from currencies
  )
  union all
  select 'USD'
  where not exists (
    select 1 from currencies
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
    DateFrom text not null,
    MainCurrency text not null
  );
  "
)
dbSendQuery(
  conn      = dbConn,
  statement = paste0("
  insert into settings
  select 0, '#90ed7d', '#f45b5b', 'yyyy-mm-dd', '", format(Sys.Date(), "%Y"), "-01-01', 'EUR'
  where not exists (
    select 1 from settings
  );
  ")
)


### Views ----
# Distinct assets
dbSendQuery(
  conn      = dbConn,
  statement = "
    CREATE VIEW IF NOT EXISTS vDistAssets AS
    SELECT DISTINCT
      DisplayName,
      TickerSymbol,
      Type,
      [Group],
      TransactionCurrency,
      SourceCurrency,
      SUM(
        CASE
          WHEN TransactionType = 'Buy' THEN Quantity
          ELSE -Quantity
        END
      ) AS TotalQuantity,
      (
        DisplayName || '_' || 
        TickerSymbol || '_' || 
        Type || '_' || 
        [Group] || '_' || 
        TransactionCurrency
      )AS AssetID
    FROM Assets
    GROUP BY AssetID;
  "
)

# Assets in USD
dbSendQuery(
  conn      = dbConn,
  statement = "
    CREATE VIEW IF NOT EXISTS vAssetsUSD AS
    WITH AssetsSigned AS (
    	SELECT
    		Date,
    		DisplayName,
    		CASE
    			WHEN TransactionType = 'Buy' THEN Quantity
    			ELSE -Quantity
    		END AS Quantity,
    		Case
    			WHEN TransactionType = 'Buy' THEN PriceTotal
    			ELSE -PriceTotal
    		END AS PriceTotal,
    		TickerSymbol,
    		Type,
    		[Group],
    		TransactionCurrency,
    		SourceCurrency
    	FROM assets
    )
    SELECT 
    	a.Date,
    	a.DisplayName,
    	a.Quantity,
    	a.TickerSymbol,
    	a.Type,
    	a.[Group],
    	CASE
    		WHEN a.TransactionCurrency = 'USD' THEN a.PriceTotal
    		ELSE a.PriceTotal * (
    			SELECT xr.Adjusted
    			FROM xrates xr
    			WHERE xr.Date <= a.Date
    				AND xr.Currency = a.TransactionCurrency
    			ORDER BY xr.Date DESC
    			LIMIT 1
    		)
    	END AS PriceTotalUSD,
      (
        a.DisplayName || '_' || 
    	  a.TickerSymbol || '_' || 
    	  a.Type || '_' || 
    	  a.[Group] || '_' || 
    	  a.TransactionCurrency
    	) AS AssetID
    FROM AssetsSigned a;
  "
)

# Prices in USD
dbSendQuery(
  conn      = dbConn,
  statement = "
    CREATE VIEW IF NOT EXISTS vPricesUSD AS
    SELECT 
    	pd.Date,
    	pd.TickerSymbol,
    	CASE
    		WHEN pd.SourceCurrency = 'USD' THEN pd.Adjusted
    		ELSE pd.Adjusted * (
    		  SELECT xr.Adjusted
    			FROM xrates xr
    		  WHERE xr.Date <= pd.Date
    		    AND xr.Currency = pd.SourceCurrency
    			ORDER BY xr.Date DESC
    			LIMIT 1
    		)
    	END AS PriceUSD
    FROM price_data pd;
  "
)

