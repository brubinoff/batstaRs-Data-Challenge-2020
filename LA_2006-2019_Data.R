setwd("~/Desktop")
library(readr)
library(dplyr)
library(forcats)

### Data Import and Cleaning
#Download filtered data to desktop as .csv. This is only PropertyType = C/I
LA_Data <- read_csv("Assessor_Parcels_Data_-_2006_thru_2019.csv")
head(LA_Data)

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
                                        Lodging = c("Hotel and Motel", "Animal Kennel"),
                                        Parking = c("Parking Lot (Commercial Use Property)", "Parking Lot (Industrial Use Property)"),
                                        Storage = c("Warehousing, Distribution, Storage", "Open Storage"),
                                        Other = c("Camp", "(unavailable)", "Missing")
)


#Subset the data to be only 2019
LA_Data_2019 <- LA_Data %>% 
  filter(RollYear == 2019)

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
ggplot(data = LA_Data_2019, aes(x=LandBaseYear, y = netTaxableValue, fill = GeneralUseType)) + 
  geom_bar(stat = 'identity', position = "stack") + 
  xlim(1975,2020) +
  labs(x = "Land Assessment Year", y = "Net Taxable Value", fill = "General Use Type") +
  theme_cowplot() 

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
LA_Data_2019_SpecUse <- LA_Data_2019 %>%
  group_by(SpecificUseType)

ggplot(data = LA_Data_2019_SpecUse, mapping = aes(x = reorder(SpecificUseType, -netTaxableValue), y = netTaxableValue)) +
  geom_bar(stat = 'identity') +
  theme_cowplot() +
  labs(y = "Net Taxable Value", x = "", title = "Net Taxable Value Across Specific Use Types in LA County" ) +
  theme(axis.text.y = element_text(size = 6)) +
  coord_flip() 


  
