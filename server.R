library("shiny")
library("tidyverse")
library("DT")
library("shinyjs")
# devtools::install_github("martinjhnhadley/gene.alignment.tables")
library("gene.alignment.tables")


source("data-processing.R", local = TRUE)

table_width <- 15

function(input, output, session) {
  output$sequence_legend <- renderPlot({
    
    legend_data <- switch(input$selected_protein,
                          "HBV Pol" = {
                            sequence_region_colours %>%
                              filter(appears.in.hbv.pol == TRUE)
                          },
                          "HBV S" = {
                            sequence_region_colours %>%
                              filter(appears.in.hbv.s == TRUE)
                          })

    coding_region_legend(data = legend_data)
    
  })
  
  alignment.dt.unique.id <- alignment_DT_unique_id()
  
  output$programmatic_many_DT_UI <- renderUI({

    the_datatables <- hbv_table_data %>%
      filter(sheet == input$selected_protein) %>%
      select(position:`Geno E`,-Reference,-sheet) %>%
      generate_dts(table.width = table_width,
                   alignment.table.id = alignment.dt.unique.id)
    
    fluidPage(the_datatables)
    
  })
  
  selected_col_values <- reactiveValues()
  
  observe({
    if (!is.null(input[[paste0(alignment.dt.unique.id,
                               "_1_",
                               table_width,
                               "_rows_current")]])) {
      selected_col_values[["previous"]] <-
        isolate(selected_col_values[["current"]])
      
      all_inputs <- isolate(reactiveValuesToList(input))
      
      inputs_selected_cols <-
        grepl(
          paste0(
            alignment.dt.unique.id,
            "_[0-9]{1,}_[0-9]{1,}_columns_selected"
          ),
          names(all_inputs)
        )
      
      inputs_with_nulls <- all_inputs[inputs_selected_cols]
      
      inputs_selected_cols <-
        setNames(inputs_with_nulls, names(all_inputs)[inputs_selected_cols])
      
      selected_positions <-
        lapply(names(inputs_selected_cols), function(id) {
          id_to_sequence_position(id, shiny.input = input)
        }) %>%
        unlist()
      
      selected_positions
      
      
    } else {
      if (is.null(selected_col_values[["current"]])) {
        selected_positions <- NULL
      }
      else {
        selected_positions <- selected_col_values[["current"]]
      }
    }
    
    selected_col_values[["current"]] <- selected_positions
  })
  
  
  output$observe_show_inputs <- renderDataTable({
    selected_positions <- selected_col_values[["current"]] %>%
      sort()
    
    if (is.null(selected_positions)) {
      show("loading-content")
    }
    
    hide("loading-content")
    
    data_to_display <- hbv_table_data %>%
      filter(sheet == input$selected_protein) %>%
      select(-sheet) %>%
      filter(position %in% selected_positions) %>%
      select(-position, -colour)
    
    if (nrow(data_to_display) == 0) {
      data_to_display[0, 1:2] %>%
        datatable(
          options = list(
            "language" = list("emptyTable" = "Please select a position in the table below."),
            # columnDefs = list(
            # list(className = 'dt-center', targets = 0:2)
            dom = "t"
          )
        )
      
    } else {
      data_to_display %>%
        datatable(
          rownames = FALSE,
          extensions = 'FixedColumns',
          selection = "none",
          options = list(
            # columnDefs = list(
            # list(className = 'dt-center', targets = 0:2)
            autoWidth = TRUE,
            scrollX = TRUE,
            fixedColumns = list(leftColumns = 2),
            dom = "t"
          )
        )
    }
    
    
  })
  
  
  
}