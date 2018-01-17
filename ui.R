library("rhandsontable")
library("shiny")
library("DT")
library("shinyjs")

appCSS <- "
#loading-content {
position: absolute;
background: #FFFFFF;
opacity: 0.9;
z-index: 100;
left: 0;
right: 0;
height: 100%;
text-align: center;
color: #000000;
}
"

navbarPage(
  "HBV Alignment Shiny App",
  tabPanel(
    "Visualisation",
    fluidPage(
      theme = "animate.min.css",
      useShinyjs(),
      inlineCSS(appCSS),
      tags$head(tags$style(
        HTML(".cell-border-right{border-right: 1px solid #000}")
      )),
      wellPanel(h4(HTML("Thank you for visiting our visualisation tool for hepatitis B virus (HBV). This site displays sequence data for HBV Pol and S genes, indicating sites that have been reported in association with resistance associated mutations (RAMs) and vaccine escape mutations (VEMs) in Africa. The sites of mutation are shown in red. Please note the code lives here: <a href='https://github.com/martinjhnhadley/hbv-alignment-viz' target='_blank'>https://github.com/martinjhnhadley/hbv-alignment-viz</a>"))),
      wellPanel(
        selectInput(
          "selected_protein",
          "Selected Protein",
          choices = c(
            "HBV S",
            "HBV Pol"
          )
        ),
        "Scroll through the sequence visualisation below and select sequences of interest. A table will appear below with information about each of the selected rows.",
        dataTableOutput("observe_show_inputs"),
        uiOutput("column_in_programmaticDT_UI")
      ),
      fluidPage(
        h2("Sequence Visualisation"),
        div(
          id = "loading-content",
          fluidPage(
            h2(class = "animated infinite pulse", "Loading data...")
            # HTML("<img src=images/cruk-logo.png width='50%'></img>")
          )
        ),
        uiOutput("programmatic_many_DT_UI"),
        style = "overflow-y:scroll; max-height: 600px"
      )
    )
  ),
  tabPanel(
    HTML(
      '<span class="glyphicon glyphicon-info-sign" aria-hidden="true""></span>'
    ),
    fluidPage(includeMarkdown(knitr::knit("tab_about.Rmd")))
  )
)