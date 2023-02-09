

library(shiny)

ui <- softui::simple_page(

  softui::box(



    shintocatman::htmlInput()

  )

)

server <- function(input, output, session) {

}

shinyApp(ui, server)
