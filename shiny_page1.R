# Load necessary libraries
library(shiny)
library(zoo)
library(xts)
library(DT)

# Generate sample daily data
set.seed(123)
dates <- seq.Date(from = as.Date("2023-01-01"), to = as.Date("2024-12-31"), by = "day")
values <- round(runif(length(dates), 50, 100), 2)
data_xts <- xts(values, order.by = dates)

# Define UI
ui <- fluidPage(
  titlePanel("Daily Data with Monthly Pagination"),
  sidebarLayout(
    sidebarPanel(
      actionButton("prev_month", "Previous Month"),
      actionButton("next_month", "Next Month"),
      textOutput("current_month")
    ),
    mainPanel(
      DTOutput("table")
    )
  )
)

# Define Server
server <- function(input, output, session) {
  # Reactive values to keep track of the current month
  current_month <- reactiveVal(as.Date("2023-01-01"))
  
  # Update current month text
  output$current_month <- renderText({
    format(current_month(), "%B %Y")
  })
  
  # Observe event for previous month button
  observeEvent(input$prev_month, {
    current_month <- current_month() - months(1)
    update_current_month(current_month)
  })
  
  # Observe event for next month button
  observeEvent(input$next_month, {
    current_month <- current_month() + months(1)
    update_current_month(current_month)
  })
  
  # Function to update current month and data displayed
  update_current_month <- function(new_month) {
    current_month(new_month)
    
    start_date <- as.Date(format(new_month, "%Y-%m-01"))
    end_date <- as.Date(format(new_month + months(1) - days(1), "%Y-%m-%d"))
    
    filtered_data <- data_xts[paste0(start_date, "/", end_date)]
    
    output$table <- renderDT({
      datatable(
        data.frame(Date = index(filtered_data), Value = coredata(filtered_data)),
        options = list(pageLength = nrow(filtered_data))
      )
    })
  }
  
  # Initialize table with data for the first month
  observe({
    update_current_month(current_month())
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
