library(shiny)
library(shinythemes)
library(RNASeqPower)

# returns a message if condition is true
fn_validate <- function(input,message) if(input) print(message)

shinyApp(
  ui=fluidPage(
    theme=shinytheme("spacelab"),
    titlePanel("RNA-Seq | Power analysis"),
    sidebarLayout(
      sidebarPanel(
        selectInput("in_pa_est","Variable to estimate",choices=c("n","cv","effect","alpha","power"),selected=1,multiple=FALSE),
        uiOutput("ui_pa")
      ),
      mainPanel(
        verbatimTextOutput("out_pa")
      )
    )
  ),
  server=function(input,output){
    
    output$ui_pa <- renderUI({
      div(
        textInput("in_pa_depth","Sequencing depth",value=100),
        if(input$in_pa_est != "n")  textInput("in_pa_n","Sample size",value=12),
        if(input$in_pa_est != "cv")  textInput("in_pa_cv","Coefficient of variation",value=0.4),
        if(input$in_pa_est != "effect")  textInput("in_pa_effect","Effect",value=2),
        if(input$in_pa_est != "alpha")  textInput("in_pa_alpha","Alpha",value=0.05),
        if(input$in_pa_est != "power")  textInput("in_pa_power","Power",value=0.8)
      )
    })
    
    output$out_pa <- renderPrint({
      
        depth <- as.numeric(unlist(strsplit(gsub(" ","",input$in_pa_depth),",")))
        validate(fn_validate(any(is.na(depth)),"Sequencing depth must be a numeric."))
        
        if(input$in_pa_est != "n") {
          n <- as.numeric(unlist(strsplit(gsub(" ","",input$in_pa_n),",")))       
          validate(fn_validate(any(is.na(n)),"Sample size must be a numeric."))
        }
        
        if(input$in_pa_est != "cv") {
          cv <- as.numeric(unlist(strsplit(gsub(" ","",input$in_pa_cv),",")))
          validate(fn_validate(any(is.na(cv)),"Coefficient of variation must be a numeric."))
        }
        
        if(input$in_pa_est != "effect") {
          effect <- as.numeric(unlist(strsplit(gsub(" ","",input$in_pa_effect),",")))
          validate(fn_validate(any(is.na(effect)),"Effect must be a numeric."))
        }
        
        if(input$in_pa_est != "alpha")  {
          alpha <- as.numeric(unlist(strsplit(gsub(" ","",input$in_pa_alpha),",")))
          validate(fn_validate(any(is.na(alpha)),"Alpha must be a numeric."))
          validate(fn_validate(any(alpha>=1|alpha<=0),"Alpha must be a numeric between 0 and 1."))
        }
        
        if(input$in_pa_est != "power")  {
          power <- as.numeric(unlist(strsplit(gsub(" ","",input$in_pa_power),",")))
          validate(fn_validate(any(is.na(power)),"Power must be a numeric."))
          validate(fn_validate(any(power>=1|power<=0),"Power must be a numeric between 0 and 1."))
        }
        
        switch(input$in_pa_est,
               "n"=rnapower(depth=depth, cv=cv, effect=effect, alpha=alpha, power=power),
               "cv"=rnapower(depth=depth, n=n, effect=effect, alpha=alpha, power=power),
               "effect"=rnapower(depth=depth, cv=cv, n=n, alpha=alpha, power=power),
               "alpha"=rnapower(depth=depth, cv=cv, effect=effect, n=n, power=power),
               "power"=rnapower(depth=depth, cv=cv, effect=effect, alpha=alpha, n=n)
        )
    })
  }
)

