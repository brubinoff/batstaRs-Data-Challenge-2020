setwd("~/Desktop")
library(readr)
library(dplyr)
library(forcats)

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

library(ggplot2)
library(cowplot)

### Land Value
# Plot of Land Assessed Value by year grouped by General Use Type
ggplot(data = LA_Data_2019, aes(x=LandBaseYear, y = LandValue, fill = GeneralUseType)) + 
  geom_bar(stat = 'identity', position = "stack") + 
  xlim(1975,2020) +
  labs(x = "Land Assessment Year", y = "Land Assessment Value", fill = "General Use Type") +
  theme_cowplot() 

# Plot of Land Assessed Value by year grouped by Specific Use Type
ggplot(data = LA_Data_2019, aes(x=LandBaseYear, y = LandValue, fill = SpecificUseType)) + 
  geom_bar(stat = 'identity', position = "stack") + 
  xlim(1975,2020) +
  labs(x = "Land Assessment Year", y = "Land Assessment Value", fill = "Specific Use Type") +
  theme_cowplot() +
  theme(legend.title = element_text(size = 5), 
          legend.text = element_text(size = 5)) +
  guides(color = guide_legend(override.aes = list(size = 1))) 

# Plot of Land Assessed Value by Specifc Use Type
LA_Data_2019_SpecUse <- LA_Data_2019 %>%
  group_by(SpecificUseType) %>%
  summarise(mean = mean(LandValue))

ggplot(data = LA_Data_2019_SpecUse, aes(x = reorder(SpecificUseType, mean), y = mean)) +
  geom_bar(stat = 'identity') +
  theme_cowplot() +
  labs(y = "Mean Land Value", x = "", title = "Mean Land Value Across Specific Use Types in LA County" ) +
  theme(axis.text.y = element_text(size = 6)) +
  coord_flip() 

### Net Taxable Value
# Plot of Net Taxable Value by year grouped by General Use Type 
# This is part of the app
ggplot(data = LA_Data_Current, aes(x=LandBaseYear, y = netTaxableValue, fill = GeneralUseType)) + 
  geom_col(position = "stack", color = NA, width = 0.9) + 
  scale_fill_grey() +
  xlim(1975,2020) +
  labs(x = "Land Assessment Year", 
       y = "Net Taxable Value in Billions (USD)", 
       fill = "General Use Type", 
       title = "Commercial and Industrial Property Value in LA County", 
       caption = "(Click at the base of each bar on the x-axis to display specific use types in each year)") +
  theme_cowplot() +
  theme(legend.title = element_text(size = 12, face = "bold"), 
        legend.text = element_text(size = 10),
        axis.text.y = element_text(),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5, face = "italic")
  ) +
  scale_y_continuous() +
  guides(color = guide_legend(override.aes = list(size = 1)))
ggsave("shinyapp_plot1.png", dpi = 320)

# Plot of Net Taxable Value by year grouped by Specific Use Type
ggplot(data = LA_Data_2019, aes(x=LandBaseYear, y = netTaxableValue, fill = SpecificUseType)) + 
  geom_bar(stat = 'identity', position = "stack") + 
  xlim(1975,2020) +
  labs(x = "Land Assessment Year", y = "Net Taxable Value (USD)", fill = "Specific Use Type", title = "Commercial and Industrial Property Value in LA County") +
  theme_cowplot() +
  theme(legend.title = element_text(size = 5), 
        legend.text = element_text(size = 5)) +
  guides(color = guide_legend(override.aes = list(size = 1))) 
# ggsave("SpecUse_NetTaxValue.jpeg", width = 10, height = 6, dpi = 320) # This is for my own use (BR)

# Plot of Net Taxable Value by Specifc Use Type
LA_Data_SpecUse_1978 <- LA_Data_Current %>%
  filter(LandBaseYear == "1978") %>%
  group_by(SpecificUseType) %>% 
  summarize(netTaxableValue = sum(netTaxableValue), LandBaseYear = mean(LandBaseYear)) 

# 1978
ggplot(data = LA_Data_SpecUse_1978, mapping = aes(x = SpecificUseType, y = netTaxableValue, fill = SpecificUseType)) +
  geom_bar(stat = 'identity') +
  geom_text(aes(label=paste0(SpecificUseType),
                hjust=ifelse(netTaxableValue < (max(netTaxableValue)*0.6), -0.03, 1.1)), fontface = 'bold') + # put labels inside
  theme_classic() +
  labs(y = "Net Taxable Value in Billions (USD)", x = "Specific Land Uses", title = "1978") +
  theme(axis.text.y = element_blank(),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        legend.position = "none",
        plot.title = element_text(face = "bold")) +
  scale_y_continuous() +
  guides(color = guide_legend(override.aes = list(size = 1))) +
  coord_flip() 
ggsave("shinyapp_plot2_1978.png", dpi = 320, width = 6.5, height = 5, units = "in")

# 2018
LA_Data_SpecUse_2018 <- LA_Data_Current %>%
  filter(LandBaseYear == "2018") %>%
  group_by(SpecificUseType) %>% 
  summarize(netTaxableValue = sum(netTaxableValue), LandBaseYear = mean(LandBaseYear)) 

ggplot(data = LA_Data_SpecUse_2018, mapping = aes(x = SpecificUseType, y = netTaxableValue, fill = SpecificUseType)) +
  geom_bar(stat = 'identity') +
  geom_text(aes(label=paste0(SpecificUseType),
                hjust=ifelse(netTaxableValue < (max(netTaxableValue)*0.6), -0.03, 1.1)), fontface = 'bold') + # put labels inside
  theme_classic() +
  labs(y = "Net Taxable Value in Billions (USD)", x = "Specific Land Uses", title = "2018") +
  theme(axis.text.y = element_blank(),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        legend.position = "none",
        plot.title = element_text(face = "bold")) +
  scale_y_continuous() +
  guides(color = guide_legend(override.aes = list(size = 1))) +
  coord_flip() 
ggsave("shinyapp_plot2_2018.png", dpi = 320, width = 6.5, height = 5, units = "in")

# 1988
LA_Data_SpecUse_1988 <- LA_Data_Current %>%
  filter(LandBaseYear == "1988") %>%
  group_by(SpecificUseType) %>% 
  summarize(netTaxableValue = sum(netTaxableValue), LandBaseYear = mean(LandBaseYear)) 

ggplot(data = LA_Data_SpecUse_1988, mapping = aes(x = SpecificUseType, y = netTaxableValue, fill = SpecificUseType)) +
  geom_bar(stat = 'identity') +
  geom_text(aes(label=paste0(SpecificUseType),
                hjust=ifelse(netTaxableValue < (max(netTaxableValue)*0.6), -0.03, 1.1)), fontface = 'bold') + # put labels inside
  theme_classic() +
  labs(y = "Net Taxable Value in Billions (USD)", x = "Specific Land Uses", title = "1988") +
  theme(axis.text.y = element_blank(),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        legend.position = "none",
        plot.title = element_text(face = "bold")) +
  scale_y_continuous() +
  guides(color = guide_legend(override.aes = list(size = 1))) +
  coord_flip() 
ggsave("shinyapp_plot2_1988.png", dpi = 320, width = 6.5, height = 5, units = "in")

# 1998
LA_Data_SpecUse_1998 <- LA_Data_Current %>%
  filter(LandBaseYear == "1998") %>%
  group_by(SpecificUseType) %>% 
  summarize(netTaxableValue = sum(netTaxableValue), LandBaseYear = mean(LandBaseYear)) 

ggplot(data = LA_Data_SpecUse_1998, mapping = aes(x = SpecificUseType, y = netTaxableValue, fill = SpecificUseType)) +
  geom_bar(stat = 'identity') +
  geom_text(aes(label=paste0(SpecificUseType),
                hjust=ifelse(netTaxableValue < (max(netTaxableValue)*0.6), -0.03, 1.1)), fontface = 'bold') + # put labels inside
  theme_classic() +
  labs(y = "Net Taxable Value in Billions (USD)", x = "Specific Land Uses", title = "1998") +
  theme(axis.text.y = element_blank(),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        legend.position = "none",
        plot.title = element_text(face = "bold")) +
  scale_y_continuous() +
  guides(color = guide_legend(override.aes = list(size = 1))) +
  coord_flip() 
ggsave("shinyapp_plot2_1998.png", dpi = 320, width = 6.5, height = 5, units = "in")

# 2008
LA_Data_SpecUse_2008 <- LA_Data_Current %>%
  filter(LandBaseYear == "2008") %>%
  group_by(SpecificUseType) %>% 
  summarize(netTaxableValue = sum(netTaxableValue), LandBaseYear = mean(LandBaseYear)) 

ggplot(data = LA_Data_SpecUse_2008, mapping = aes(x = SpecificUseType, y = netTaxableValue, fill = SpecificUseType)) +
  geom_bar(stat = 'identity') +
  geom_text(aes(label=paste0(SpecificUseType),
                hjust=ifelse(netTaxableValue < (max(netTaxableValue)*0.6), -0.03, 1.1)), fontface = 'bold') + # put labels inside
  theme_classic() +
  labs(y = "Net Taxable Value in Billions (USD)", x = "Specific Land Uses", title = "2008") +
  theme(axis.text.y = element_blank(),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        legend.position = "none",
        plot.title = element_text(face = "bold")) +
  scale_y_continuous() +
  guides(color = guide_legend(override.aes = list(size = 1))) +
  coord_flip() 
ggsave("shinyapp_plot2_2008.png", dpi = 320, width = 6.5, height = 5, units = "in")