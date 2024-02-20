library(shiny)
library(ggplot2)
library(colourpicker)

shinyApp(
  ui=pageWithSidebar(
  headerPanel("ggplot2 plot builder"),
  sidebarPanel(
    colourInput("in_plot_title", "Plot title", value="#4daf4a"),
    colourInput("in_plot_subtitle", "Plot subtitle", value="#984ea3"),
    colourInput("in_legend_title", "Legend title", value="#ffff33"),
    colourInput("in_legend_text", "legend text", value="#ff7f00"),
    selectInput("in_legend_pos","Legend position", choices=c("right","left","top","bottom"), selected="right"),
    colourInput("in_axis_title", "Axis title", value="#e41a1c"),
    colourInput("in_axis_text", "Axis text", value="#377eb8"),
    colourInput("in_strip_text", "Strip text", value="#a65628"),
    colourInput("in_plot_background", "Plot background", value="#b3e2cd"),
    colourInput("in_panel_background", "Panel background", value="#fdcdac"),
    colourInput("in_panel_border", "Panel border", value="#cbd5e8"),
    colourInput("in_legend_background", "Legend background", value="#f4cae4"),
    colourInput("in_legend_box_background", "Legend box background", value="#e6f5c9"),
    colourInput("in_strip_background", "Strip background", value="#fff2ae")
  ),
  mainPanel(
    plotOutput("plot")
  )
),
server=function(input,output){
    output$plot <- renderPlot({
        ggplot(iris,aes(Sepal.Length,Petal.Length,col=Species))+
        geom_point()+
        facet_wrap(~Species)+
        labs(title="Iris dataset",subtitle="Scatterplots of Sepal and Petal lengths",caption="The iris dataset by Edgar Anderson")+
        theme_grey(base_size=16)+
        theme(
          plot.title=element_text(color=input$in_plot_title),
          plot.subtitle=element_text(color=input$in_plot_subtitle),
          legend.title=element_text(color=input$in_legend_title),
          legend.text=element_text(color=input$in_legend_text),
          legend.position=input$in_legend_pos,
          axis.title=element_text(color=input$in_axis_title),
          axis.text=element_text(color=input$in_axis_text),
          strip.text=element_text(color=input$in_strip_text),

          plot.background=element_rect(fill=input$in_plot_background),
          panel.background=element_rect(fill=input$in_panel_background),
          panel.border=element_rect(fill=NA,color=input$in_panel_border,size=3),
          legend.background=element_rect(fill=input$in_legend_background),
          legend.box.background=element_rect(fill=input$in_legend_box_background),
          strip.background=element_rect(fill=input$in_strip_background)
        )
    })
})

