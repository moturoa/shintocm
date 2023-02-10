

library(shiny)
library(shinyWidgets)
library(softui)
library(shinytoastr)

devtools::load_all()

key <- config::get("mce_apikey", config = "default", file = "conf/config.yml")$key
options(mce_api_key = key)

db_con <- shintodb::connect(what = "Demo", file = "conf/config.yml")

.cm <- contentManager$new(db_connection = db_con, schema = "wonmon")

ui <- softui::simple_page(
  shintocatman::useHtmlInput(),

  managerUI("man")

)

server <- function(input, output, session) {

  callModule(managerServer, "man", .cm = .cm)

}

shinyApp(ui, server)
