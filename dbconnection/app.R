#Keep in mind, this code will not work if you do not have the same database as mine.
library(RMySQL)

#This will connect to the database. user is your user name, password is password, dbname is the name of the 
#database that you are trying to connect to, for host just leave it as 'localhost', the on.exit is for
#what to do when you want to disconnect.
mydb = dbConnect(MySQL(), user='bjolivarez', password='insertpassword', dbname='recipes', host='localhost')
on.exit(dbDisconnect(mydb))

#This is just a variable that provides an example of data to insert into the database.
kat = "mustard"

#This function will show all tables in the database
dbListTables(mydb)

#This is a variable that holds an SQL command to insert the kat variable into the database. The id is NULL,
#because, the database is configured ina way to give ids to new data inserted
sql = sprintf("INSERT INTO `recipes`.`ingredients` (`id`, `name`) VALUES (NULL, '%s');", kat)

#This is another variable that holds a command to grab all info in the table labeled "ingredients" 
#uncomment to use this command instead.
#rs = dbSendQuery(mydb, "SELECT * FROM ingredients order by id ASC;")

#Here is the next example of a variable that represents sending a command to the database. mydb is the 
#database connection from earlier sql is the insert sql command from earlier
rs = dbSendQuery(mydb, sql)

#This variable stores the data from rs, the command used on the specified database. n=20 is simply how many rows
#from the table you wish to grab
data = fetch(rs, n = 20)

#This clears the query that was stored in rs so you can use rs for another command
dbClearResult(rs)

#This simply gets the id of the last piece of data you inserted into the table
id <- dbGetQuery(mydb, "select last_insert_id();")[1,1]

#Shows the id
id