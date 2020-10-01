#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(readr)
library(dplyr)
library(cowplot)
library(forcats)

### Data Import and Cleaning
#Download filtered data to desktop as .csv. This is only PropertyType = C/I
setwd("~/Desktop")
LA_Data <- read_csv("Assessor_Parcels_Data_-_2006_thru_2019.csv")

# Make factors
LA_Data$GeneralUseType <- as.factor(LA_Data$GeneralUseType)
LA_Data$SpecificUseType <- as.factor(LA_Data$SpecificUseType)
LA_Data$SpecificUseType <-  fct_explicit_na(LA_Data$SpecificUseType, na_level = "Missing")
LA_Data$LandBaseYear <- as.character(LA_Data$LandBaseYear)


#Subset the data to be current assessment list
LA_Data_Current <- LA_Data %>% 
    filter(RollYear == 2019)

## UI
# Use a fluid Bootstrap layout
ui <- fluidPage(    
        
        # Give the page a title
        titlePanel("Net Taxable Value of Commercial and Industrial Properties in LA County"),
        
        # Generate a row with a sidebar
        sidebarLayout(      
            
            # Define the sidebar with one input
            sidebarPanel(
                selectInput("year", "Year:", 
                            choices=unique(LA_Data_Current$LandBaseYear)),
                hr(),
                helpText("Data from LA County Assessor updated last in 2019.")
            ),
            
            # Create a spot for the barplot
            mainPanel(
                plotOutput("BarPlot")  
            )
            
        )
    )

## Server

# Define a server for the Shiny app
server <- function(input, output) {
    
    # Fill in the spot we created for a plot
    output$BarPlot <- renderPlot({
        
        LA_Data_Current %>% 
            filter(LandBaseYear == input$year) %>% 
            group_by(SpecificUseType) %>%
            
            ggplot(data = LA_Data_Current, mapping = aes(x = reorder(SpecificUseType, netTaxableValue), y = netTaxableValue)) +
            geom_bar(stat = 'identity') +
            theme_cowplot() +
            labs(y = "Mean Net Taxable Value", x = "", title = "Mean Net Taxable Value Across Specific Use Types in LA County" ) +
            theme(axis.text.y = element_text(size = 6)) +
            coord_flip() 
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
