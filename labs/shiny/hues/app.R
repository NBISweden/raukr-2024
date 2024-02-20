## shiny-hues
## R shinyapp to generate distinct colours
## 2023 Roy Francis

library(shiny)
library(hues)
library(bslib)

shinyApp(
  ui = page_fixed(
    class = "app-container",
    tags$head(tags$style(HTML("
      .app-container {
          margin-top: 1em;
      }

      .grid-parent {
          display: grid;
          gap: 5px;
          grid-template-columns: repeat(auto-fit, minmax(40px, 40px));
      }

      .grid-child {
          height: 40px;
          width: 40px;
      }
    "))),
    title = "Hues",
    card(
      card_header(
        h2("Colour Generator"),
      ),
      layout_sidebar(
        sidebar(
          numericInput("in_n", "Number of colours", value = 15),
          sliderInput("in_hue", "Hue", min = 0, max = 360, value = c(0, 360)),
          sliderInput("in_chr", "Chroma", min = 0, max = 180, value = c(0, 180)),
          sliderInput("in_lig", "Lightness", min = 0, max = 100, value = c(0, 100)),
        ),
        htmlOutput("out_display"),
        hr(),
        textOutput("out_text")
      ),
      card_footer(
        div("Built on ", a("hues package", href = "https://github.com/johnbaums/hues"))
      )
    )
  ),
  server = function(input, output) {
    get_colours <- reactive({
      hues::iwanthue(
        n = input$in_n,
        hmin = min(input$in_hue),
        hmax = max(input$in_hue),
        cmin = min(input$in_chr),
        cmax = max(input$in_chr),
        lmin = min(input$in_lig),
        lmax = max(input$in_lig)
      )
    })

    output$out_display <- renderText({
      cols <- get_colours()
      paste("<div class='grid-parent'>", paste("<span class='grid-child' style='background-color:", cols, ";'>  </span>", collapse = ""), "</div>", sep = "", collapse = "")
    })

    output$out_text <- renderText({
      cols <- get_colours()
      paste(cols, collapse = ", ")
    })
  }
)
