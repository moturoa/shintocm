

#db <- shintodb::databaseClass$new(what = "Demo", schema = "wonmon")



library(shintodb)
library(DBI)

con <- shintodb::connect("Demo")

dbExecute(con, "drop table wonmon.shintocm")

dbExecute(con, "

          create table if not exists wonmon.shintocm (

            id serial,
            key text not null unique,
            content text,
            timestamp_created timestamp without time zone default current_timestamp,
            timestamp_updated timestamp without time zone default current_timestamp,
            userid text,
            deleted integer default 0

          )


          ")

dbExecute(con, "create index on wonmon.shintocm (key)")
