# Load necessary libraries
library(shiny)
library(quantmod)
library(plotly)
library(DT)

base_path <- file.path("C:/Users/ronsh/eoddata/us/daily")


# Define the user interface
ui <- fluidPage(
    titlePanel("Stock Candlestick Plot"),
    sidebarLayout(
        sidebarPanel(
            textInput("stock_symbol", "Enter Stock Name", value="AAPL.US"),
            actionButton("submit", "Submit")
        ),
        mainPanel(
            tableOutput("file_contents")
            # plotlyOutput("candlestickPlot")
        )
    )
)

# Define the server logic
server <- function(input, output, session) {
    # Reactive expression to read the uploaded file
    stock_data <- eventReactive(input$submit, {
        # proceed if the user entered a value 
        req(input$stock_symbol)
        tryCatch({
            file_path <- file.path(base_path, paste0(input$stock_symbol, ".csv"))
            cat("Opening file: ", file_path, "\n")
            read.csv(file_path, stringsAsFactors = FALSE)

        }, error=function(e) {
            showModal(modalDialog(
                title = "Error",
                "File could not be read. Please check the file path and try again.",
                easyClose = TRUE,
                footer = NULL))
        NULL
        })        
    })
   

    # Render the table of file contents
    output$file_contents <- renderTable({
        req(stock_data())
    })
    
    
    # Render the candlestick plot
    output$candlestickPlot <- renderPlotly({

        print(stock_data)
        # Filter the data for the selected stock
        # stock_df <- stock_data # () %>% dplyr::filter(symbol == input$stock)

        # # Convert the data to an xts object for use with quantmod
        # stock_xts <- xts::xts(stock_df[, c("open", "high", "low", "close")],
        #     order.by = as.Date(stock_df$date)
        # )

        # # Create the candlestick plot
        # plot_ly(
        #     x = index(stock_xts),
        #     open = stock_xts$open,
        #     high = stock_xts$high,
        #     low = stock_xts$low,
        #     close = stock_xts$close,
        #     type = "candlestick"
        # ) %>%
        #     layout(
        #         title = paste("Candlestick Chart for", input$stock),
        #         xaxis = list(title = "date"),
        #         yaxis = list(title = "price")
        #     )
    })
}

# Run the application
shinyApp(ui = ui, server = server, options = list(port = 4659, autoreload = TRUE))
