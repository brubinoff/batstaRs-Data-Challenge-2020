# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
# http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(readr)
library(dplyr)
library(cowplot)
library(forcats)
library(scales)
library(rsconnect)

### Data Import and Cleaning
#Download filtered data to desktop as .csv. This is only PropertyType = C/I
# Note, CSV needs to be converted to .Rdata for size reasons. Remove the # below and run code to do this.
# LA_Data <- read.csv("Assessor_Parcels_Data_-_2006_thru_2019.csv")
# save(LA_Data, file = "Assessor_Parcels_Data_-_2006_thru_2019.Rdata")
load("Assessor_Parcels_Data_-_2006_thru_2019.Rdata")

#MH: removing non-essential columns to ease formatting
LA_Data <- LA_Data %>% select(GeneralUseType, LandBaseYear, SpecificUseType, netTaxableValue, RollYear)

# Make factors
LA_Data$GeneralUseType <- as.factor(LA_Data$GeneralUseType) #change General Use Type from character to factor (so that we can sort by these categories later)
LA_Data$SpecificUseType <- as.factor(LA_Data$SpecificUseType) #change Specific USe Type from character to factor
LA_Data$SpecificUseType <-  fct_explicit_na(LA_Data$SpecificUseType, na_level = "Missing") #recode NAs as Missings to make sorting easier

#the original data set had 39 different categories, which was too many for our purposes so we made consilidated broader categories
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
                                        Other = c("Camp", "(Missing)", "(unavailable)", "Missing", "Animal Kennel", "", " ") #MH: added blank option
)
LA_Data$SpecificUseType <- fct_relevel(LA_Data$SpecificUseType, sort) #Reorder the factor levels alphabetically
levels(LA_Data$SpecificUseType) = c("Entertainment", 
                                    "Food, Processing, and Distribution",
                                    "Lodging",
                                    "Manufacturing",
                                    "Mineral Processing",
                                    "Other",
                                    "Parking",
                                    "Professional Buildings and Offices",
                                    "Retail",
                                    "Sports and Recreation",
                                    "Storage") #Type out full name for better display on graph


# Remove extraneous rows that have LandBaseYear as 0 
LA_Data <- subset(LA_Data, LandBaseYear !=0)
# Subset the data to be the most recent land assessment list
LA_Data_Current <- LA_Data %>% 
  filter(RollYear == 2019)

# List the years in descending order so that when we call the dropdown menu it's in a sensible order
LA_Data_Current <- LA_Data_Current[order(-LA_Data_Current$LandBaseYear),]

# Convert the taxable value to billions
LA_Data_Current <- LA_Data_Current %>% 
  mutate(netTaxableValue = netTaxableValue/1e9)

# Now, that the data is cleaned up, we are going to begin writing the ShinyApp, which will produce an interactive graph

### shiny App
# Requires two separate entities: the User Interface (UI) and the Server

## UI
# Fluid page layout auto decides how big to make each part of the page based on the resolution of each image, 
# This makes it easier than having to define the size of each individual component 

ui <- fluidPage( 
  mainPanel(
    plotOutput("plot", click = "plot_click", width = "100%"),
    plotOutput("plot2", width = "75%")
  )
)

## Server
# The Server is where you create the information that feeds into the UI  

server <- function(input, output, session) {
  # Create main plot with data on all years
  output$plot <- renderPlot({
    ggplot(data = LA_Data_Current, aes(x=LandBaseYear, y = netTaxableValue, fill = GeneralUseType)) + 
      geom_col(position = "stack", color = NA, border = NA, size = 0) + 
      scale_fill_grey() +
      xlim(1975,2020) +
      labs(x = "Land Assessment Year", 
           y = "Net Taxable Value in Billions (USD)", 
           fill = "General Use Type", 
           title = "Commercial and Industrial Property Value in LA County", 
           subtitle = "Data Visualization for Prop 15 by the bat staRs",
           caption = "(Click at the base of each bar on the x-axis to display specific use types in each year)") +
      theme_cowplot() +
      theme(legend.title = element_text(size = 12, face = "bold"), 
            legend.text = element_text(size = 10),
            axis.text.y = element_text(),
            plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5),
            plot.caption = element_text(hjust = 0.5, face = "italic")
      ) +
      scale_y_continuous(labels = comma) +
      guides(color = guide_legend(override.aes = list(size = 1))) })
  
  # Extract data from click on first plot (Year)
  observeEvent(input$plot_click, 
               {
                 p <- nearPoints(LA_Data_Current, input$plot_click)
                 # Get the year of the click, then filter for second plot
                 selectionyear <- median(p$LandBaseYear)
                 LA_Data_2019_SpecUse <- LA_Data_Current %>%
                   filter(LandBaseYear == selectionyear) %>%
                   group_by(SpecificUseType) %>% 
                   summarize(netTaxableValue = sum(netTaxableValue), LandBaseYear = mean(LandBaseYear)) 
                 
                 # Input click data as year filter and create second plot
                 output$plot2 <- renderPlot ({
                   ggplot(data = LA_Data_2019_SpecUse, mapping = aes(x = SpecificUseType, y = netTaxableValue, fill = SpecificUseType)) +
                     geom_bar(stat = 'identity') +
                     geom_text(aes(label=paste0(SpecificUseType),
                                   hjust=ifelse(netTaxableValue < (max(netTaxableValue)*0.6), -0.03, 1.1)),) +# put labels inside
                     theme_classic() +
                     labs(y = "Net Taxable Value in Billions (USD)", x = "Specific Land Uses", title = round(input$plot_click$x, digits = 0)) +
                     theme(axis.text.y = element_blank(),
                           axis.text.x = element_text(size = 12),
                           axis.title.y = element_text(size = 12),
                           legend.position = "none",
                           plot.title = element_text(face = "bold")) +
                     scale_y_continuous(labels = comma) +
                     guides(color = guide_legend(override.aes = list(size = 1))) +
                     coord_flip() 
                 })
               })
}

# Run the application 
shinyApp(ui, server)