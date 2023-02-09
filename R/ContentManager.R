

contentManager <- R6::R6Class(

  inherit = shintodb::databaseClass,
  lock_objects = FALSE,

  public = list(

    initialize = function(what, schema, table = "shintocm", database_connection = NULL){

      super$initialize(what = what, schema = schema, pool = TRUE)

      self$table <- table

    },

    get = function(key, content_only = TRUE){

      row <- self$read_table(self$table, lazy = TRUE) %>%
        filter(key == !!key) %>%
        collect

      if(nrow(row) == 0){
        return(NULL)
      }

      if(content_only){
        return(row[["content"]])
      } else {
        return(row)
      }
    },

    has_key = function(key){

      !is.null(self$get(key))

    },

    set = function(key, value, userid = "unknown_user"){

      if(!self$has_key(key)){

        self$append_data(
          self$table,
          data.frame(
            key = key,
            content = value,
            userid = userid
          )
        )

      } else {
        self$replace_value_where(self$table,
                          col_replace = "content",
                          val_replace = value,
                          col_compare = "key", val_compare = key)
        self$replace_value_where(self$table,
                          col_replace = "timestamp_updated",
                          val_replace = as.character(self$postgres_now()),
                          col_compare = "key", val_compare = key)
      }


    },

    delete = function(key){

      self$replace_value_where(self$table,
                        col_replace = "deleted",
                        val_replace = 1,
                        col_compare = "key", val_compare = key)

    }


  )


)


library(shintodb)
library(DBI)
library(dplyr)

.cm <- contentManager$new("Demo", schema = "wonmon")


.cm$set("tooltip_aantalwoningen", "Aantal woningen in het project")

.cm$set("tooltip_huurkoop", "huur of koop")
.cm$set("tooltip_huurkoop", "huur of koopof toch wat andr")

.cm$get("tooltip_aantalwoningen")

.cm$close()


