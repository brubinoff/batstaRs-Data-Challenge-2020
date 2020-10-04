---
title: "README"
author: "Esther K"
date: "10/3/2020"
output: html_document
---

## Proposition 15 Data Exploration: Commercial Tax Revenue by Assessment Year in LA County
### About
This is the bat staRs submission to the UC Davis Datalab California Elections Data Challenge. This tool is intended to give voters context and information pertinent to Proposition 15. Proposition 15 would change the taxable value of commercial and industrial properties from their value at purchase (plus a 2% correction for inflation) to their current market value. 

Our interactive data viewer allows voters to explore how the tax burden is distributed in LA County between properties purchased decades ago and those purchased more recently, as well as within and between different commercial industries. Viewers will initially see a graph of commercial and industrial taxable value organized by assessment year. By clicking on an individual year, viewers will open a graph breaking that assessment year's data into eleven different industry types. Property values have risen much faster than inflation over the past 42 years; this tool allows viewers explore the relationship of those changes to specific commercial industries. 

### Cite As
Rubinoff, B., Heineke, M., Kennedy, E., (2020). BatstaRs Proposition 15 Submission. UC Davis Datalab CA Election Data Challenge. http://brubinoff.shinyapps.io/batstaRs_App

### Contributers 
- Benjamin Rubinoff 
- Marcella Heineke
- Esther Kennedy

### How to Access
You can access our data viewer [here](http://brubinoff.shinyapps.io/batstaRs_App).

### How to Provide Feedback
Issues, bugs, questions, or comments can all be submitted to our repo [issues list](https://github.com/brubinoff/batstaRs-Data-Challenge-2020/issues).

### Data Source and Handling
All data is from the [County of Los Angeles Open Data](https://data.lacounty.gov/) website. We used the ["Assessor's Parcel Data - 2006 thru 2019"](https://data.lacounty.gov/Parcel-/Assessor-Parcels-Data-2006-thru-2019/9trm-uz8i/data), filtered by the column "PropertyType" to include only commercial and industrial properties (listed as "C/I") and downloaded as a .csv file with no further processing. Data were then imported to R and converted to a .Rdata file. LA County metadata for the dataset can be found [here](https://data.lacounty.gov/Parcel-/Assessor-Parcels-Data-2006-thru-2019/9trm-uz8i).

Our analysis focused on the following data columns:
- RollYear: the year the properties were last assessed (note, this is _not_ equivalent to the year the property value is set to). 
- GeneralUseType: the broad designation of the parcel. We selected only "Commercial" and "Industrial" use types, both of which we broadly refer to as "commercial".
- SpecificUseType: the specific use of the parcel as defined by 39 catagories (e.g., "Animal Kennel" or "Theater"). We combined these to make a more concise list of 11 categories.
- LandBaseYear: the year the property tax rate is based on. This is set by the purchase year by law.

We compiled the original 39 specific use types into 11 categories. The code for this is included in our app.R script. Our eleven use categories and their components within the SpecificUseType column are as follows:
- Sports and Recreation: "Race Track", "Athletic and Amusement Facility", "Bowling Alley", "Golf Course", "Skating Rink", "Water Recreation", "Club, Lodge Hall, Fraternal Organization"
- Retail: "Shopping Center (Regional)", "Department Store", "Shopping Center (Neighborhood, Community)", "Store Combination", "Store", "Nursery or Greenhouse", "Non-Auto Service and Repair Shop, Paint Shot, or Laundry", "Commercial"
- Food Processing and Distribution: "Food Processing Plant", "Supermarket", "Restaurant", "Cocktail Lounge"
- Entertainment: "Motion Picture, Radio and Television Industry", "Theater"
- Manufacturing: "Heavy Manufacturing", "Wholesale and Manufacturing Outlet", "Light Manufacturing", "Service Station", "Lumber Yard", "Auto, Recreation Equipment, Construction Equipment Sales and Service"
- Professional Buildings and Offices: "Office Building", "Bank, Savings and Loan", "Professional Building"
- Mineral Processing: "Mineral Processing"
- Lodging: "Hotel and Motel"
- Parking: "Parking Lot (Commercial Use Property)", "Parking Lot (Industrial Use Property)"
- Storage: "Warehousing, Distribution, Storage", "Open Storage"
- Other: "Camp", "(Missing)", "(unavailable)", "Missing", "Animal Kennel", ""

### Repo Contents
The code for data cleaning, the shiny app and the shinyapp.io is stored in [batstaRs_App/](https://github.com/brubinoff/batstaRs-Data-Challenge-2020/tree/master/batstaRs_App) of this repo. The data cleaning and app code are in the same R script titled "app.R". Code has been commented extensively.

Our LA County Parcels data is stored as an .Rdata in the main repo with the title "Assessor_Parcels_Data_-_2006_thru_2019.Rdata". This includes all commercial and industrial parcel data from the LA County website (see previous section). It is cleaned and formatted in the app.R code. 

The main repo also includes a LA_2006-2019_Data.R script that we used for early data exploration and visualization. 


