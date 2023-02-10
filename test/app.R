

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

  softui::box(width = 12, title = "Content Manager", icon = bsicon("filetype-html", status = "info"),

    softui::fluid_row(
      column(6,
             softui::virtual_select_input("sel_key", "Selecteer content key",
                                          choices = .cm$list_keys(),
                                          width = 400,
                                          multiple = FALSE, autoSelectFirstOption = FALSE)
      ),
      column(6,

             textInput("txt_new_key", "Maak nieuwe content key") %>%
               tagAppendAttributes(style = "display: inline-block;margin-right: 40px;"),

             shinyjs::disabled(
               softui::action_button("btn_save_key", "Opslaan", status = "info", icon = bsicon("save")) %>%
                 tagAppendAttributes(style = "margin-top: 12px;")
             )

             )
    ),

    shinyjs::hidden(
      tags$div(id = "ui_edit_block",

        shintocatman::htmlInput("edit_content", label = "Content", value = ""),

        tags$br(),
        softui::action_button("btn_save_content", "Opslaan", status = "success", icon = bsicon("save")),
        uiOutput("ui_dirty", height = 30)

      )
    )



  )

)

server <- function(input, output, session) {

  db_ping <- reactiveVal()

  observe({
    updateVirtualSelect("sel_key", choices = .cm$list_keys())
  })

  observeEvent(input$sel_key, {
    content <- .cm$get(input$sel_key)
    shintocatman::updatehtmlInput("edit_content", value = content)
  })

  observe({
    key <- input$sel_key
    shinyjs::toggle("ui_edit_block", condition = nchar(key) > 0)
  })

  db_key_value <- reactive({
    db_ping()
    .cm$get(input$sel_key)
  })

  observe({
    keyname <- input$txt_new_key
    shinyjs::toggleState("btn_save_key", condition = nchar(keyname) > 0)
  })

  observeEvent(input$btn_save_key, {
    key <- input$txt_new_key
    .cm$set(key, value = "")
    updateVirtualSelect("sel_key", choices = .cm$list_keys(), selected = key)
    updateTextInput(session, "txt_new_key", value = "")
  })

  observeEvent(input$btn_save_content, {

    .cm$set(input$sel_key, input$edit_content)
    shinytoastr::toastr_success("Content opgeslagen")
    db_ping(runif(1))
  })


  output$ui_dirty <- renderUI({
    req(db_key_value() != input$edit_content)
    tags$p(bsicon("exclamation-triangle-fill", status = "danger"), tags$i("Er zijn niet opgeslagen wijzigingen"),
           style = "padding-top: 8px;pading-bottom:8px;")
  })

}

shinyApp(ui, server)
