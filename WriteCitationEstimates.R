# AB: util functions
isInstalled <- function(package) {
  is.element(package, installed.packages()[,1])
}

LoadOrInstallLibraries <- function(packages) {
  for (package in packages) {
    if (!isInstalled(package)) {
      install.packages(package,repos="http://cran.rstudio.com/")
    }
    require(package,character.only=TRUE,quietly=TRUE)
  }
}

LoadOrInstallLibraries(c("argparser", "RODBC", "futile.logger", "yaml"))
flog.appender(appender.file("expectations.log"), "quiet")

GetDBHandle <- function (config, city) {
  ct <- config[[city]]
  server <- paste("server", ct$server, sep="=")
  uid <- paste("uid", ct$username, sep="=")
  pwd <- paste("pwd", ct$password, sep="=")
  db <- paste("database", ct$db, sep="=")

  connector <- paste("driver={SQL Server}", server, db, uid, pwd, "trusted_connection=true", sep=";")
  dbhandle <- odbcDriverConnect(connector)
  return(dbhandle)
}

# AB: parse arguments
parser <- arg_parser("Write Citation Expectations Estimates")
parser <- add_argument(parser, "city", help="label in writeconfig.yml for DB credentials")

args <- parse_args(parser, commandArgs(trailingOnly=TRUE))

config <- yaml.load_file("writeconfig.yml")
dbhandle <- GetDBHandle(config, args$city)

flog.info("Deleting estimates for yesterday", name="quiet")
sqlQuery(dbhandle,paste("DELETE FROM CITATIONESTIMATES WHERE DATE=\'", Sys.Date(), "\'", sep=""))

flog.info("Bulk inserting estimates", name="quiet")
sqlQuery(dbhandle, "BULK INSERT CITATIONESTIMATES FROM 'citExpEstimatesToday.csv' WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a')")

sqlQuery(dbhandle,"IF OBJECT_ID('CITATIONESTIMATESCONVERTED', 'U') IS NOT NULL DROP TABLE CITATIONESTIMATESCONVERTED")

sqlQuery(dbhandle,"SELECT * INTO CITATIONESTIMATESCONVERTED FROM CITATIONESTIMATES")

sqlQuery(dbhandle,"ALTER TABLE CITATIONESTIMATESCONVERTED ALTER COLUMN DATE date")
