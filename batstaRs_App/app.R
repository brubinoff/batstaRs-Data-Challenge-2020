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
LA_Data$SpecificUseType <- fct_collapse(LA_Data$SpecificUseType, 
    Sports_and_Recreation = c("Race Track", "Athletic and Amusement Facility", "Bowling Alley", "Golf Course", "Skating Rink", "Water Recreation", "Club, Lodge Hall, Fraternal Organization"),
    Retail = c("Shopping Center (Regional)", "Department Store", "Shopping Center (Neighborhood, Community)", "Store Combination", "Store", "Nursery or Greenhouse", "Non-Auto Service and Repair Shop, Paint Shop, or Laundry", "Commercial"),
    Food_Processing_and_Distribution = c("Food Processing Plant", "Supermarket", "Restaurant, Cocktail Lounge"),
    Entertainment = c("Motion Picture, Radio and Television Industry", "Theater"),
    Manufacturing = c("Heavy Manufacturing", "Wholesale and Manufacturing Outlet", "Light Manufacturing", "Service Station", "Lumber Yard", "Auto, Recreation Equipment, Construction Equipment Sales and Service", "Industrial"),
    Professional_Buildings_and_Offices = c("Office Building", "Bank, Savings and Loan", "Professional Building"),
    Mineral_Processing = "Mineral Processing",
    Lodging = "Hotel and Motel",
    Parking = c("Parking Lot (Commercial Use Property)", "Parking Lot (Industrial Use Property)"),
    Storage = c("Warehousing, Distribution, Storage", "Open Storage"),
    Other = c("Camp", "(Missing)", "(unavailable)", "Missing", "Animal Kennel")
     )

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
                selectInput("LandBaseYear", "Year:", 
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
            filter(LandBaseYear == input$LandBaseYear) %>% 
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


### A second Shiny App option

## UI
ui2 <- fluidPage(    
        plotOutput("plot", click = "plot_click"),
        tableOutput("Data")
    )

## Server

# Define a server for the Shiny app
server2 <- function(input, output, session) {
    output$plot <- renderPlot({
            ggplot(data = LA_Data_Current, aes(x=LandBaseYear, y = netTaxableValue, fill = SpecificUseType)) + 
            geom_bar(stat = 'identity', position = "stack") + 
            xlim(1975,2020) +
            labs(x = "Land Assessment Year", y = "Net Taxable Value (USD)", fill = "Specific Use Type", title = "Commercial and Industrial Property Value in LA County") +
            theme_cowplot() +
            theme(legend.title = element_text(size = 5), 
                  legend.text = element_text(size = 5)) +
            guides(color = guide_legend(override.aes = list(size = 1))) })
    
    output$Data <- renderTable({
        nearPoints(LA_Data_Current, input$plot_click, xvar = LA_Data_Current$SpecificUseType, yvar=sum(LA_Data_Current$netTaxableValue))
    })
}

# Run the application 
shinyApp(ui = ui2, server = server2)

