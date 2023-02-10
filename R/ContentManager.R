
#' Shinto Content Manager class
#' @export
#' @importFrom R6 R6Class
#' @importFrom shintodb databaseClass
#' @importFrom dplyr filter pull collect
contentManager <- R6::R6Class(

  inherit = shintodb::databaseClass,
  lock_objects = FALSE,

  public = list(

    initialize = function(what = NULL, schema, table = "shintocm",
                          db_connection = NULL, ...){

      super$initialize(what = what, schema = schema, pool = TRUE,
                       db_connection = db_connection, ...)

      self$table <- table

    },

    get = function(key, content_only = TRUE){

      if(nchar(key) == 0)return(NULL)

      row <- self$read_table(self$table, lazy = TRUE) |>
        filter(key == !!key) |>
        collect()

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

    is_deleted = function(key){

      val <- self$get(key, content_only = FALSE)
      val$deleted > 0

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
        # als nieuwe key gezet, maar deze bestond al als verwijderde key, undelete de key eerst
        self$replace_value_where(self$table,
                                 col_replace = "deleted",
                                 val_replace = 0,
                                 col_compare = "key", val_compare = key)
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

   list_keys = function(include_deleted = FALSE){

      out <- self$read_table(self$table, lazy = TRUE)

      if(!include_deleted){
        out <- dplyr::filter(out, deleted == 0)
      }

      dplyr::collect(out) |> dplyr::pull(key)

   },

   delete = function(key){

      self$replace_value_where(self$table,
                        col_replace = "deleted",
                        val_replace = 1,
                        col_compare = "key", val_compare = key)

   }


  )


)




