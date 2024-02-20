## CALENDAR PLANNER
## R shinyapp to generate ggplot2 calendar
## 2019 Roy Mathew Francis
library(ggplot2)
library(shiny)
library(colourpicker)

## load colours
cols <- toupper(c(
  "#bebada","#fb8072","#80b1d3","#fdb462","#b3de69","#fccde5","#FDBF6F","#A6CEE3",
  "#56B4E9","#B2DF8A","#FB9A99","#CAB2D6","#A9C4E2","#79C360","#FDB762","#9471B4",
  "#A4A4A4","#fbb4ae","#b3cde3","#ccebc5","#decbe4","#fed9a6","#ffffcc","#e5d8bd",
  "#fddaec","#f2f2f2","#8dd3c7","#d9d9d9"))

shinyApp(

# UI ---------------------------------------------------------------------------

ui=fluidPage(
  pageWithSidebar(
    headerPanel(title="Calendar Planner",windowTitle="Calendar Planner"),
    sidebarPanel(
      h3("Duration"),
      fluidRow(
          column(6,style=list("padding-right: 5px;"),
              dateInput("in_duration_date_start","From",value=format(Sys.time(),"%Y-%m-%d"))
          ),
          column(6,style=list("padding-left: 5px;"),
              dateInput("in_duration_date_end","To",value=format(as.Date(Sys.time())+30,"%Y-%m-%d"))
          )
      ),
      h3("Tracks"),
      fluidRow(
          column(3,style=list("padding-right: 3px;"),
              textInput("in_track_name_1",label="Name",value="Vacation",placeholder="Vacation")
          ),
          column(3,style=list("padding-right: 3px; padding-left: 3px;"),
              dateInput("in_track_date_start_1",label="From",value=format(Sys.time(),"%Y-%m-%d"))
          ),
          column(3,style=list("padding-right: 3px; padding-left: 3px;"),
              dateInput("in_track_date_end_1",label="To",value=format(as.Date(Sys.time())+30,"%Y-%m-%d"))
          ),
          column(3,style=list("padding-left: 3px;"),
              colourpicker::colourInput("in_track_colour_1",label="Colour",
                                        palette="limited",allowedCols=cols,value=cols[1])
          )
      ),
      fluidRow(
          column(3,style=list("padding-right: 3px;"),
              textInput("in_track_name_2",label="Name",value="Offline",placeholder="Offline")
          ),
          column(3,style=list("padding-right: 3px; padding-left: 3px;"),
              dateInput("in_track_date_start_2",label="From",value=format(Sys.time(),"%Y-%m-%d"))
          ),
          column(3,style=list("padding-right: 3px; padding-left: 3px;"),
              dateInput("in_track_date_end_2",label="To",value=format(as.Date(Sys.time())+30,"%Y-%m-%d"))
          ),
          column(3,style=list("padding-left: 3px;"),
              colourpicker::colourInput("in_track_colour_2",label="Colour",
                                        palette="limited",allowedCols=cols,value=cols[2])
          )
      ),
      fluidRow(
          column(6,style=list("padding-right: 5px;"),
              colourpicker::colourInput("in_track_colour_available",label="Track colour (Available)",
                                        palette="limited",allowedCols=cols,value=cols[length(cols)-1])
          ),
          column(6,style=list("padding-left: 5px;"),
              colourpicker::colourInput("in_track_colour_weekend",label="Track colour (Weekend)",
                                        palette="limited",allowedCols=cols,value=cols[length(cols)])
          )
      ),
      tags$br(),
      h3("Settings"),
      selectInput("in_legend_position",label="Legend position",
                  choices=c("top","right","left","bottom"),selected="right",multiple=F),
      fluidRow(
          column(6,style=list("padding-right: 5px;"),
              selectInput("in_legend_justification",label="Legend justification",
                          choices=c("left","right"),selected="right",multiple=F)
          ),
          column(6,style=list("padding-left: 5px;"),
              selectInput("in_legend_direction",label="Legend direction",
                          choices=c("vertical","horizontal"),selected="vertical",multiple=F)
          )
      ),
      fluidRow(
          column(6,style=list("padding-right: 5px;"),
              numericInput("in_themefontsize",label="Theme font size",value=8,step=0.5)
          ),
          column(6,style=list("padding-left: 5px;"),
              numericInput("in_datefontsize",label="Date font size",value=2.5,step=0.1)
          )
      ),
      fluidRow(
          column(6,style=list("padding-right: 5px;"),
              numericInput("in_monthfontsize",label="Month font size",value=8,step=0.5)
          ),
          column(6,style=list("padding-left: 5px;"),
              numericInput("in_legendfontsize",label="Legend font size",value=5,step=0.5)
          )
      ),
      tags$br(),
      h3("Download"),
      helpText("Width is automatically calculated based on the number of weeks. File type is only applicable to download and does not change preview."),
      fluidRow(
          column(6,style=list("padding-right: 5px;"),
              numericInput("in_height","Height (cm)",step=0.5,value=5.5)
          ),
          column(6,style=list("padding-left: 5px;"),
              numericInput("in_width","Width (cm)",step=0.5,value=NA)
          )
      ),
      fluidRow(
          column(6,style=list("padding-right: 5px;"),
              selectInput("in_res","Res/DPI",choices=c("200","300","400","500"),selected="200")
          ),
          column(6,style=list("padding-left: 5px;"),
              selectInput("in_format","File type",choices=c("png","tiff","jpeg","pdf"),selected="png",multiple=FALSE,selectize=TRUE)
          )
      ),
      downloadButton("btn_downloadplot","Download Plot"),
      tags$hr(),
      helpText("RaukR")
    ),
    mainPanel(
      sliderInput("in_scale","Image preview scale",min=0.1,max=3,step=0.10,value=1),
      helpText("Scale only controls preview here and does not affect download."),
      tags$br(),
      imageOutput("out_plot")
    )
  )
),

# SERVER -----------------------------------------------------------------------

server=function(input, output, session) {

  store <- reactiveValues(week=NULL)

  ## RFN: fn_plot -----------------------------------------------------------
  ## core plotting function, returns a ggplot object

  fn_plot <- reactive({

    shiny::req(input$in_duration_date_start)
    shiny::req(input$in_duration_date_end)

    shiny::req(input$in_track_date_start_1)
    shiny::req(input$in_track_date_end_1)
    shiny::req(input$in_track_name_1)
    shiny::req(input$in_track_colour_1)

    shiny::req(input$in_track_date_start_2)
    shiny::req(input$in_track_date_end_2)
    shiny::req(input$in_track_name_2)
    shiny::req(input$in_track_colour_2)

    shiny::req(input$in_legend_position)
    shiny::req(input$in_legend_justification)
    shiny::req(input$in_legend_direction)
    shiny::req(input$in_themefontsize)
    shiny::req(input$in_datefontsize)
    shiny::req(input$in_monthfontsize)
    shiny::req(input$in_legendfontsize)

    validate(need(input$in_track_name_1!=input$in_track_name_2,"Duplicate track names are not allowed."))
    validate(need(as.Date(input$in_duration_date_start) < as.Date(input$in_duration_date_end),"End duration date must be later than start duration date."))

    # prepare dates
    dfr <- data.frame(date=seq(as.Date(input$in_duration_date_start),as.Date(input$in_duration_date_end),by=1))
    dfr$day <- factor(strftime(dfr$date,format="%a"),levels=rev(c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")))
    dfr$week <- factor(strftime(dfr$date,format="%V"))
    dfr$month <- strftime(dfr$date,format="%B")
    dfr$month <- factor(dfr$month,levels=unique(dfr$month))
    dfr$ddate <- factor(strftime(dfr$date,format="%d"))

    #add tracks
    dfr$track <- "Available"
    dfr$track[dfr$day=="Sat" | dfr$day=="Sun"] <- "Weekend"

    temp_start_date_1 <- as.Date(input$in_track_date_start_1)
    temp_end_date_1 <- as.Date(input$in_track_date_end_1)
    temp_track_name_1 <- input$in_track_name_1
    temp_track_col_1 <- input$in_track_colour_1
    validate(need(temp_start_date_1 < temp_end_date_1,"End track duration date must be later than start track duration date."))
    dfr$track[dfr$date>=temp_start_date_1 & dfr$date<=temp_end_date_1] <- temp_track_name_1

    temp_start_date_2 <- as.Date(input$in_track_date_start_2)
    temp_end_date_2 <- as.Date(input$in_track_date_end_2)
    temp_track_name_2 <- input$in_track_name_2
    temp_track_col_2 <- input$in_track_colour_2
    validate(need(temp_start_date_2 < temp_end_date_2,"End track duration date must be later than start track duration date."))
    dfr$track[dfr$date>=temp_start_date_2 & dfr$date<=temp_end_date_2] <- temp_track_name_2

    # create order factor
    fc <- vector(mode="character")
    if("Available" %in% unique(dfr$track)) fc <- c(fc,"Available")
    fc <- c(fc,temp_track_name_1,temp_track_name_2)
    if("Weekend" %in% unique(dfr$track)) fc <- c(fc,"Weekend")
    dfr$track <- factor(dfr$track,levels=fc)

    # prepare colours
    all_cols <- c(input$in_track_colour_available,temp_track_col_1,temp_track_col_2,input$in_track_colour_weekend)

    # plot
    p <- ggplot(dfr,aes(x=week,y=day))+
      geom_tile(aes(fill=track))+
      geom_text(aes(label=ddate),size=input$in_datefontsize)+
      scale_fill_manual(values=all_cols)+
      facet_grid(~month,scales="free",space="free")+
      labs(x="Week",y="")+
      theme_bw(base_size=input$in_themefontsize)+
      theme(legend.title=element_blank(),
            panel.grid=element_blank(),
            panel.border=element_blank(),
            axis.ticks=element_blank(),
            axis.title=element_text(colour="grey30"),
            strip.background=element_blank(),
            strip.text=element_text(size=input$in_monthfontsize),
            legend.position=input$in_legend_position,
            legend.justification=input$in_legend_justification,
            legend.direction=input$in_legend_direction,
            legend.text=element_text(size=input$in_legendfontsize),
            legend.key.size=unit(0.3,"cm"),
            legend.spacing.x=unit(0.2,"cm"))

    # add number of weeks to reactive value
    store$week <- length(levels(dfr$week))

    return(p)
  })

  ## OUT: out_plot ------------------------------------------------------------
  ## plots figure

  output$out_plot <- renderImage({

    shiny::req(fn_plot())
    shiny::req(input$in_height)
    shiny::req(input$in_res)
    shiny::req(input$in_scale)

    height <- as.numeric(input$in_height)
    width <- as.numeric(input$in_width)
    res <- as.numeric(input$in_res)

    if(is.na(width)) {
      width <- (store$week*1.2)
      if(width < 4.5) width <- 4.5
    }

    p <- fn_plot()
    ggsave("calendar_plot.png",p,height=height,width=width,units="cm",dpi=res)

    return(list(src="calendar_plot.png",
                contentType="image/png",
                width=round(((width*res)/2.54)*input$in_scale,0),
                height=round(((height*res)/2.54)*input$in_scale,0),
                alt="calendar_plot"))
  }, deleteFile=TRUE)

  # FN: fn_downloadplotname ----------------------------------------------------
  # creates filename for download plot

  fn_downloadplotname <- function()
  {
    return(paste0("calendar_plot.",input$in_format))
  }

  ## FN: fn_downloadplot -------------------------------------------------
  ## function to download plot

  fn_downloadplot <- function(){
    shiny::req(fn_plot())
    shiny::req(input$in_height)
    shiny::req(input$in_res)
    shiny::req(input$in_scale)

    height <- as.numeric(input$in_height)
    width <- as.numeric(input$in_width)
    res <- as.numeric(input$in_res)
    format <- input$in_format

    if(is.na(width)) width <- (store$week*1)+1

    p <- fn_plot()
    if(format=="pdf" | format=="svg"){
      ggsave(fn_downloadplotname(),p,height=height,width=width,units="cm",dpi=res)
      #embed_fonts(fn_downloadplotname())
    }else{
      ggsave(fn_downloadplotname(),p,height=height,width=width,units="cm",dpi=res)

    }
  }

  ## DHL: btn_downloadplot ----------------------------------------------------
  ## download handler for downloading plot

  output$btn_downloadplot <- downloadHandler(
    filename=fn_downloadplotname,
    content=function(file) {
      fn_downloadplot()
      file.copy(fn_downloadplotname(),file,overwrite=T)
    }
  )

  ## OBS: tracks dates ---------------------------------------------------------
  
  observe({
    
    shiny::req(input$in_duration_date_start)
    shiny::req(input$in_duration_date_end)
    
    validate(need(as.Date(input$in_duration_date_start) < as.Date(input$in_duration_date_end),"End duration date must be later than start duration date."))
    
    # create date intervals
    dseq <- seq(as.Date(input$in_duration_date_start),as.Date(input$in_duration_date_end),by=1)
    r1 <- unique(as.character(cut(dseq,breaks=3)))
    
    updateDateInput(session,"in_track_date_start_1",label="From",value=as.Date(r1[1],"%Y-%m-%d"))
    updateDateInput(session,"in_track_date_end_1",label="To",value=as.Date(r1[1+1],"%Y-%m-%d")-1)
    updateDateInput(session,"in_track_date_start_2",label="From",value=as.Date(r1[2],"%Y-%m-%d"))
    updateDateInput(session,"in_track_date_end_2",label="To",value=as.Date(r1[2+1],"%Y-%m-%d")-1)
    
  })
})

