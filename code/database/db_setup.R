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
# Cumulative assets
dbSendQuery(
  conn      = dbConn,
  statement = "
  CREATE VIEW IF NOT EXISTS vAssetsCumQuant AS
  SELECT 
  	Date,
  	DisplayName, 
  	TickerSymbol, 
  	Type,
  	[Group],
    	SUM(
  		CASE
  			WHEN TransactionType = 'Buy' THEN Quantity
  			ELSE -Quantity
  		END
  	) OVER (
  		PARTITION BY
  			TickerSymbol,
  			Type,
  			[Group]
  		ORDER BY Date ASC
  	) AS QuantityCum,
  	TransactionCurrency,
  	SourceCurrency
  FROM assets
  ORDER BY
  Date ASC;
  "
)
# All Dates
dbSendQuery(
  conn      = dbConn,
  statement = "
  CREATE VIEW IF NOT EXISTS vAssetsAllDates AS
  SELECT DISTINCT Date
  FROM (
  	SELECT Date FROM assets
  	UNION
  	SELECT Date FROM xrates
  	UNION
  	SELECT Date FROM price_data
  )
  WHERE Date >= (SELECT DATE(MIN(Date), '-7 day') FROM assets)
  ORDER BY Date ASC;
  "
)
# All xrates
dbSendQuery(
  conn      = dbConn,
  statement = "
  CREATE VIEW IF NOT EXISTS vAssetsXRates AS
  WITH AllCombs AS (
  	SELECT DISTINCT
  		ad.Date,
  		cr.Currency,
  		xr.Adjusted
  	FROM vAssetsAllDates ad
  	CROSS JOIN (
  		SELECT Currency
  		FROM currencies
  		WHERE Currency != 'USD'
  	) cr
  	LEFT JOIN xrates xr
  		ON ad.Date = xr.Date
  		AND cr.Currency = xr.Currency
  )
  SELECT
  	Date,
  	Currency,
  	COALESCE (
  		Adjusted,
  		(
  			SELECT ac2.Adjusted
  			FROM AllCombs ac2
  			WHERE ac2.Date < ac.Date
  			AND ac2.Currency = ac.Currency
        AND ac2.Adjusted IS NOT NULL
  			ORDER BY ac2.Date DESC
  			LIMIT 1
  		)
  	) AS XRate
  FROM AllCombs ac
  WHERE Currency != 'USD'
  ORDER BY Date ASC;
  "
)
# Assets in USD
dbSendQuery(
  conn      = dbConn,
  statement = "
    CREATE VIEW IF NOT EXISTS vAssetsUSD AS
    SELECT
    	a.Date,
    	a.DisplayName,
    	CASE
        WHEN a.TransactionType = 'Buy' THEN a.Quantity
    		ELSE -a.Quantity
    	END AS Quantity,
    	CASE
    		WHEN a.TransactionType = 'Buy' THEN
    			CASE
    				WHEN a.TransactionCurrency != 'USD' THEN
    					(
    						SELECT xr1.XRate
    						FROM vAssetsXRates xr1
    						WHERE xr1.Date = a.Date
    							AND xr1.Currency = a.TransactionCurrency
    					) * a.PriceTotal
    				ELSE a.PriceTotal
    			END
    		ELSE 0
    	END AS PriceUSD,
    	a.TickerSymbol,
    	a.Type,
    	a.[Group]
    FROM assets a;
  "
)
