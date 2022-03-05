library(rsconnect)
library(shiny)
library(shinydashboard)
library(tidyverse)
library(ggplot2)
library(plotly)
library(reshape2)
library(shinyWidgets)
library(sf)
library(tmap)
library(leaflet)
library(ggmosaic)
library(htmltools)
library(raster)
library(rgdal)
library(rgeos)
require(maps)
require(mapdata)
library('treemap')
library(RColorBrewer)
library(htmlwidgets)
library(dplyr)
library(ggrepel)
library(scales)
library(sp)
library(chorddiag)
library(data.table)


#----------------------------------------Package installation--------------------------------------------
packages = c('rsconnect', 'tinytex','plotly', 'RColorBrewer','classInt','ggthemes',
             'tidyverse', 'pivottabler', 'dplyr','shiny','shinythemes', 'lubridate',
             'sf', 'tmap', 'shinyWidgets', 'leaflet', 'ggmosaic', 'htmltools', 'raster', 'rgdal', 'rgeos', 'remotes',
             'ggrepel','devtools', 'scales', 'd3Tree', 'data.table')
for(p in packages){
    if(!require(p, character.only = T)){
        install.packages(p)
    }
    library(p, character.only = T)
}
devtools::install_github("mattflor/chorddiag")
#--------------------------------------------------------------------------------------------------------

#-----------------------------------------CODE TO STYLE THE FONT OF TREEMAP------------------------------

#---------------------------------------------------------------------------------------------------------

#---------------------------------------- Total Import and Export of Indonesia (Dashboard 1-1a)----------
#TOTAL EXPORT GROUP_BY YEAR
total_export <- read_csv("data/Total Export.csv")
export_by_year <- aggregate(total_export$Total,
                            by = list(total_export$Year),
                            FUN = sum,
                            na.rm = TRUE)
names(export_by_year)[names(export_by_year) == "Group.1"] <- "Year"
names(export_by_year)[names(export_by_year) == "x"] <- "EXPORT"

#TOTAL IMPORT GROUP_BY YEAR
total_import <- read_csv("data/Total Import.csv")
import_by_year <- aggregate(total_import$Total,
                            by = list(total_import$Year),
                            FUN = sum,
                            na.rm = TRUE)
names(import_by_year)[names(import_by_year) == "Group.1"] <- "Year"
names(import_by_year)[names(import_by_year) == "x"] <- "IMPORT"

#COMBINE IMPORT AND EXPORT DATA
export <- data.frame(cbind("Type" = "Import", "Year" = import_by_year$Year, "Total" = import_by_year$IMPORT))
import <- data.frame(cbind("Type" = "Export", "Year" = export_by_year$Year, "Total" = export_by_year$EXPORT))
export_import <- data.frame(cbind("Year" = import_by_year$Year, "Import" = import_by_year$IMPORT, 
                                  "Export" = export_by_year$EXPORT))
#-----------------------------------------------------------------------------------------------------------


#---------------------------------Proportion of Exported Goods (Dashboard 1-1b)-----------------------------
export_oilgas <- read_csv("data/Export_Oil_Gas.csv")
export_nonoilgas <- aggregate(total_export[,6:9],
                              by = list(total_export$Year),
                              FUN = sum,
                              na.rm=TRUE)
names(export_nonoilgas)[names(export_nonoilgas) == "Group.1"] <- "Year"
export_nonoilgas <- export_nonoilgas[-c(24),]

testing <- export_oilgas %>% gather("Subcategory", "Import", -Year)
testing$Category <- "Oil&Gas"
names(testing)[names(testing) == "Crude Oil"] <- "Crude.Oil"
names(testing)[names(testing) == "Oil Product"] <- "Oil.Product"

testing_nonoilgas <- export_nonoilgas %>% gather("Subcategory", "Import", -Year)
testing_nonoilgas$Category <- "NonOil&Gas"

export_proportion <- data.frame(rbind(testing_nonoilgas, testing))
#-----------------------------------------------------------------------------------------------------------


#---------------------------Proportion of Imported Goods (Dashboard 1-1c)-----------------------------------
import_proportion <- aggregate(total_import[,4:6],
                               by = list(total_import$Year),
                               FUN = sum,
                               na.rm=TRUE)
names(import_proportion)[names(import_proportion) == "Group.1"] <- "Year"
names(import_proportion)[names(import_proportion) == "Consumption Goods"] <- "ConsumptionGoods"
names(import_proportion)[names(import_proportion) == "Raw Material Support"] <- "RawMaterialSupport"
names(import_proportion)[names(import_proportion) == "Capital Goods"] <- "CapitalGoods"

#-----------------------------------------------------------------------------------------------------------

#---------------------------------------Dashboard 1-2a------------------------------------------------------
export_partners <- read.csv("data/Export_by_country.csv")
filter_export_partners <- filter(export_partners, Year == max(export_partners$Year))
sorted_export_partners <- filter_export_partners[order(-filter_export_partners$Export),]

# upload raw data of indonesia export countries
import_partners <- read.csv("data/Import_by_country.csv")
filter_import_partners <- filter(import_partners, Year == max(import_partners$Year))
sorted_import_partners <- filter_import_partners[order(-filter_import_partners$Import),]
#-----------------------------------------------------------------------------------------------------------

#---------------------------------------Dashboard 1-2b------------------------------------------------------
export_import_by_country <- read_csv("data/ExportImportByCountries.csv")
names(export_import_by_country)[names(export_import_by_country) == "Import Value"] <- "Import.Value"
names(export_import_by_country)[names(export_import_by_country) == "Export Value"] <- "Export.Value"
#-----------------------------------------------------------------------------------------------------------

#---------------------------------------Dashboard 1-2c------------------------------------------------------
#Export_Import by country on map
export_import_map <- read_csv("data/ExportImportByCountriesLongLat.csv")
global_map <- map_data("world")
#-----------------------------------------------------------------------------------------------------------

#-----------------------------Data Preprocessing for Product Category---------------------------------------
exportCategory <- read_csv("data/Export_Goods_Category_LongLat.csv")
exportCategory$label <- paste(exportCategory$Destination, ", US$ ", exportCategory$Export, " Millions")
importCategory <- read_csv("data/Import_Goods_Category_LongLat.csv")
importCategory$label <- paste(importCategory$Origin, ", US$ ", importCategory$Import, " Millions")

exportCategoryTotal <- aggregate(exportCategory$Export,
                                 by = list(exportCategory$Year, exportCategory$Type),
                                 FUN = sum,
                                 na.rm = TRUE)
names(exportCategoryTotal)[names(exportCategoryTotal) == "Group.1"] <- "Year"
names(exportCategoryTotal)[names(exportCategoryTotal) == "Group.2"] <- "Type"
names(exportCategoryTotal)[names(exportCategoryTotal) == "x"] <- "Export"
exportCategoryTotal$label <- paste0("US$ ", exportCategoryTotal$Export)


importCategoryTotal <- aggregate(importCategory$Import,
                                 by = list(importCategory$Year, importCategory$Type),
                                 FUN = sum,
                                 na.rm = TRUE)
names(importCategoryTotal)[names(importCategoryTotal) == "Group.1"] <- "Year"
names(importCategoryTotal)[names(importCategoryTotal) == "Group.2"] <- "Type"
names(importCategoryTotal)[names(importCategoryTotal) == "x"] <- "Import"
importCategoryTotal$label <- paste0("US$ ", importCategoryTotal$Import)
#-----------------------------------------------------------------------------------------------------------

#-----------------------------Data preprocessing for Dashboard 3 (Trade Balance)----------------------------
ImportExport <- read.csv("data/IndonesiaExportImport.csv")

#change month to date
ImportExport$Year <- format(as.Date(ImportExport$Month, "%d/%m/%Y"), "%Y")

#Clean Data
CleanedData <- ImportExport %>%
    group_by(Year = ImportExport$Year) %>%
    summarise(TotalImport = sum(Total.Import), TotalExport = sum(Total.Export))

# Add Trade Balance column
Tradebalance = CleanedData$TotalExport - CleanedData$TotalImport
CleanedData= cbind(CleanedData, Tradebalance)

# Change year format to integer
#CleanedData$Year <- as.integer(CleanedData$Year)

#reshape
ds <- reshape2::melt(CleanedData, id = "Year")
ds2 <- filter(ds,variable == "Tradebalance")
ds <- filter(ds,variable != "Tradebalance")

# Set some colors
plotcolor <- "#F5F1DA"
papercolor <- "#E3DFC8"
col <- reactive({ifelse(ds2$value >=0, "#5B84B1FF","FC766AFF")})

data <- read.csv("data/ExportImportByCountries.csv")
tempdata = mutate(data, Importpercentile = ntile(data$Import.Value,100))
finaldata = mutate(tempdata, Exportpercentile = ntile(tempdata$Export.Value,100))
finaldata$Tradebalance <- finaldata$Export.Value - finaldata$Import.Value
#-----------------------------------------------------------------------------------------------------------

#------------------------------------------------PERCENTILE-------------------------------------------------
percentile_data <- export_import_by_country
percentile_data$Importpercentile <- ntile(percentile_data$Import.Value,100)
percentile_data$Exportpercentile <- ntile(percentile_data$Export.Value,100)
percentile_data$Tradebalance <- percentile_data$Export.Value - percentile_data$Import.Value
#-------------------------------------------------------------------------------------------------------------

#-------------------------------------------------Map of Indonesia's Port-----------------------------------
exportPorts <- read_csv("data/Export_by_Port_LongLat.csv")
importPorts <- read_csv("data/Import_by_Ports_LongLat.csv")
#-----------------------------------------------------------------------------------------------------------

#-------------------------------------------------Slope graph----------------------------------------------
#upload data
country_lists_export <- read.csv("data/SlopeGraphExportPartners.csv")
#rename column year from X2000 to 2000 and so on
colnames(country_lists_export) <- c("Destination", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", 
                                    "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018")

country_lists_import <- read.csv("data/SlopeGraphImportPartners.csv")
colnames(country_lists_import) <- c("Destination", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", 
                                    "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018")

yearList <- c("2000" = "2000", "2001" = "2001", "2002" = "2002", "2003" = "2003", "2004" = "2004", "2005" = "2005",
              "2006" = "2006", "2007" = "2007", "2008" = "2008", "2009" = "2009", "2010" = "2010","2011" = "2011",
              "2012" = "2012", "2013" = "2013", "2014" = "2014", "2015" = "2015", "2016" = "2016", "2017" = "2017",
              "2018" = "2018")
#-----------------------------------------------------------------------------------------------------------

#-------------------------------------------------Info box--------------------------------------------------
mostRecentYear <- max(export_by_year$Year)
infoBox_export <- filter(export_by_year, Year == mostRecentYear)
title_total_export <- paste("Total Export (", mostRecentYear, ")")
value_total_export <- paste("US", dollar_format()(infoBox_export$EXPORT*1000))

mostRecentYearIm <- max(import_by_year$Year)
infoBox_import <- filter(import_by_year, Year == mostRecentYearIm)
title_total_import <- paste("Total Import (", mostRecentYearIm, ")")
value_total_import <- paste("US", dollar_format()(infoBox_import$IMPORT*1000))

value_tradebalance <- paste("US", dollar_format()(infoBox_export$EXPORT*1000 - infoBox_import$IMPORT*1000))
#-----------------------------------------------------------------------------------------------------------

#-----------------------------------------CHORD DIAGRAM DATA------------------------------------------------
data <- read_csv("data/ExportImportByCountries.csv", locale = locale(encoding = "Latin1"))
#-----------------------------------------------------------------------------------------------------------

ui <- dashboardPage(
    dashboardHeader(
        tags$li(class = "dropdown",
                tags$style(".main-header {max-height: 100px}")
                #tags$style(".main-header .logo {height: 100px}")
        ),
        # Use image in title
        title = tags$a(href='https://christine2016.shinyapps.io/Cakrawala/',
                       tags$img(src='Cakrawala.png', height=50, width=180))
        #title = img(src = "Cakrawala.png", height=100, width=230), = 600
    ),
    dashboardSidebar(
        sidebarMenu(
            menuItem("ABOUT US", tabName = "MAINPAGE", icon = icon("dashboard")),
            
            menuItem("HOME", tabName = "HOME", icon = icon("dashboard"),
                     menuItem("TRADE BALANCE", tabName = "TRADEBALANCE", icon = icon("dashboard")),
                     menuItem("MAGIC QUADRANT", tabName = "MAGICQUADRANT", icon = icon("dashboard"))),
            
            menuItem("IMPORT", tabName = "TABIMPORT", icon = icon("dashboard"),
                     menuItem("PRODUCT CATEGORY", tabName = "PRODUCTCATEGORY", icon = icon("dashboard")),
                     menuItem("TOP IMPORTERS", tabName = "TOPIMPORTERS", icon = icon("dashboard")),
                     menuItem("LOCATION OF IMPORTERS", tabName = "LOCATIONIMPORTERS", icon = icon("dashboard")),
                     menuItem("PRODUCT SUBCATEGORY", tabName = "PRODUCTSUBCATEGORY", icon = icon("dashboard")),
                     menuItem("TREND BY SUBCATEGORY", tabName = "PRODUCTSUBCATEGORYTREND", icon = icon("dashboard")),
                     menuItem("IMPORTERS BY SUBCATEGORY", tabName = "PRODUCTSUBCATEGORYIMPORTERS", icon = icon("dashboard"))),
            
            menuItem("EXPORT", tabName = "TABEXPORT", icon = icon("dashboard"),
                     menuItem("PRODUCT CATEGORY", tabName = "PRODUCTCATEGORYEX", icon = icon("dashboard")),
                     menuItem("TOP EXPORTERS", tabName = "TOPEXPORTERS", icon = icon("dashboard")),
                     menuItem("LOCATION OF EXPORTERS", tabName = "LOCATIONEXPORTERS", icon = icon("dashboard")),
                     menuItem("PRODUCT SUBCATEGORY", tabName = "PRODUCTSUBCATEGORYEX", icon = icon("dashboard")),
                     menuItem("TREND BY SUBCATEGORY", tabName = "PRODUCTSUBCATEGORYTRENDEX", icon = icon("dashboard")),
                     menuItem("EXPORTERS BY SUBCATEGORY", tabName = "PRODUCTSUBCATEGORYEXPORTERS", icon = icon("dashboard"))),
            
            menuItem("TREND OF TRADE", tabName = "SLOPEGRAPH", icon = icon("dashboard")),
            menuItem("TRADE FLOWS", tabName = "CHORDDIAGRAM", icon = icon("dashboard")),
            menuItem("PORTS OF INDONESIA", tabName = "PORTINDO", icon = icon("dashboard"))
        )
    ),
    dashboardBody(
        tabItems(
            #------------------------------------------------MAINPAGE DASHBOARD-------------------------------------------------
            tabItem(tabName = "MAINPAGE",
                    fluidRow(
                        #column(12, tags$img(src = 'Cakrawala.png', height = 150, width = 1000)),
                        column(12, h1("Problem and Motivation")),
                        column(12, h4("Being one of the 25th largest export economies, Indonesia enjoys a positive trade balance of 
                                US$35 in 2017. Despite that, Indonesia's export and import have been declining at an annualized rate of 
                                -2.4% and -3.9% respectively. Based on the current trends, our group aims to visualize the export and 
                                import patterns, and demand and supply of goods in Indonesia through a dashboard.")),
                        column(12, h4("Our motivation is to provide a user-friendly and comprehensive application that visualizes 
                                      the impact of export and import on Indonesia's trade balance. Additionally, the application 
                                      will address the lack of visualization application, as Kementrian Perdagangan Republik 
                                      Indonesia (Ministry of Trade) displays the information in the table form report and separated 
                                      infographics uploaded on a different segment of the website.")),
                        column(12, h1("Our Objective")),
                        column(12, tags$div(
                            tags$ul(
                                tags$li(h4("Gain the overall insight on the yearly pattern of Indonesia's export and import, and 
                                           the top trading partners from the year 2002 until now.")),
                                tags$li(h4("Identify the demand for the product and gain insight into the customers' preference 
                                           based on the goods being exported and imported to Indonesia.")),
                                tags$li(h4("Gain overall insights into Indonesia's economic performance based on the Trade 
                                           Balance trends."))
                            )
                        ))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            
            #-------------------------------------------------------TRADE BALANCE DASHBOARD------------------------------------------
            tabItem(tabName = "TRADEBALANCE",
                    fluidRow(
                        
                        infoBox(title_total_export, value_total_export, icon = icon("arrow-up")),
                        infoBox(title_total_import, value_total_import, icon = icon("arrow-down")),
                        infoBox("Total Trade Balance (2019)", value_tradebalance, icon = icon("money-bill-alt")),
                        
                        column(12, 
                               h2("Indonesia Trade Balance"),
                               plotlyOutput(outputId = "timeseries", height="450px"))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            #-------------------------------------------------------MAGIC QUADRANT DASHBOARD------------------------------------------
            tabItem(tabName = "MAGICQUADRANT",
                    fluidRow(
                        
                        column(12, h1("Magic Quadrant for Indonesia Trading Partner")),
                        
                        column(10, plotOutput("percentileGraph", height = "500px")),
                        
                        column(2, 
                               sliderInput(
                                   inputId = "FilterYearDash1",
                                   label="Year",
                                   min = 2002,
                                   max = 2018,
                                   value = 2002,
                                   sep = "",
                                   animate = animationOptions(loop = TRUE)))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            #------------------------------------------------PRODUCTCATEGORY DASHBOARD---------------------------------------------------
            tabItem(tabName = "PRODUCTCATEGORY",
                    fluidRow(
                        column(10, 
                               h1("Import Goods by Category"),
                               plotlyOutput("ImportProportion", height = "500px")),
                        
                        column(2,
                               sliderInput(
                                   inputId = "FilterYearImport",
                                   label = "Year",
                                   min = min(export_import_map$Year),
                                   max = max(export_import_map$Year),
                                   value = max(export_import_map$Year),
                                   sep = "",
                                   animate = animationOptions(loop = TRUE)))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            #------------------------------------------------TOPIMPORTERS DASHBOARD---------------------------------------------------
            tabItem(tabName = "TOPIMPORTERS",
                    fluidRow(
                        column(12, h1("Top Importer of Indonesia")),
                        column(10, plotlyOutput("LineImport", height = "500px")),
                        
                        column(2,
                               selectInput(inputId = "orderImport",
                                           label = "Top K",
                                           choices = c("All" = "All",
                                                       "5" = "5",
                                                       "10" = "10",
                                                       "15" = "15",
                                                       "20" = "20")))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            #------------------------------------------------LOCATIONIMPORTERS DASHBOARD---------------------------------------------------
            tabItem(tabName = "LOCATIONIMPORTERS",
                    fluidRow(
                        column(12, h1("Location of Indonesia Importer")),
                        column(10, plotlyOutput("ImportPartnerMap", height = "500px")),
                        column(2,
                               sliderInput(
                                   inputId = "FilterYearImportLocMap",
                                   label = "Year",
                                   min = min(export_import_map$Year),
                                   max = max(export_import_map$Year),
                                   value = max(export_import_map$Year),
                                   sep = "",
                                   animate = animationOptions(loop = TRUE)))
                        
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            #---------------------------------------------PRODUCTSUBCATEGORY DASHBOARD----------------------------------------------
            tabItem(tabName = "PRODUCTSUBCATEGORY",
                    fluidRow(
                        column(12, h1("Import by Product Subcategory")),
                        column(10, plotOutput("ImportGoodsCategory", height="500px")),
                        column(2, sliderInput(
                            inputId = "FilterYearImportProduct",
                            label = "Year",
                            min = min(export_import_map$Year),
                            max = max(export_import_map$Year),
                            value = max(export_import_map$Year),
                            sep = "",
                            animate = animationOptions(loop = TRUE)))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            #---------------------------------------------PRODUCTSUBCATEGORYTREND DASHBOARD----------------------------------------------
            tabItem(tabName = "PRODUCTSUBCATEGORYTREND",
                    fluidRow(
                        column(10, 
                               h1("Import Trend by Product Subcategory"),
                               plotlyOutput(outputId = "ImportProductPerCategory", height = "500px")),
                        column(2, radioButtons(
                            inputId = "FilterImportCategoryType",
                            label = "Category:",
                            choices = unique(importCategory$Type),
                            selected = NULL
                        ))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            #---------------------------------------------PRODUCTSUBCATEGORYIMPORTERS DASHBOARD----------------------------------------------
            tabItem(tabName = "PRODUCTSUBCATEGORYIMPORTERS",
                    fluidRow(
                        column(10, 
                               h1("Location of Indonesia Importer by Product Subcategory"),
                               plotlyOutput(outputId = "ImportProductCategoryMap", height = "500px")),
                        column(2, 
                               sliderInput(
                                    inputId = "FilterImportCategoryYear",
                                    label = "Year",
                                    min = min(importCategory$Year),
                                    max = max(importCategory$Year),
                                    value = max(importCategory$Year),
                                sep = ""),
                                radioButtons(
                                    inputId = "FilterImportCategoryTypeMap",
                                    label = "Category:",
                                    choices = unique(importCategory$Type),
                                    selected = NULL
                        ))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            #------------------------------------------------PRODUCTCATEGORYEX DASHBOARD---------------------------------------------------
            tabItem(tabName = "PRODUCTCATEGORYEX",
                    fluidRow(
                        column(10, 
                               h1("Proportion of Indonesia Exports"),
                               plotlyOutput("ExportProportion", height = "500px")),
                        column(2,
                               sliderInput(
                                   inputId = "FilterYearExport",
                                   label = "Year",
                                   min = min(export_import_map$Year),
                                   max = max(export_import_map$Year),
                                   value = max(export_import_map$Year),
                                   sep = "",
                                   animate = animationOptions(loop = TRUE)))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            #------------------------------------------------TOPEXPORTERS DASHBOARD---------------------------------------------------
            tabItem(tabName = "TOPEXPORTERS",
                    fluidRow(
                        column(12, h1("Top Exporter of Indonesia")),
                        column(10, plotlyOutput("LineExport", height = "500px")),
                        
                        column(2,
                               selectInput(inputId = "orderExport",
                                           label = "Top K",
                                           choices = c("All" = "All",
                                                       "5" = "5",
                                                       "10" = "10",
                                                       "15" = "15",
                                                       "20" = "20")))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            #------------------------------------------------LOCATIONEXPORTERS DASHBOARD---------------------------------------------------
            tabItem(tabName = "LOCATIONEXPORTERS",
                    fluidRow(
                        column(12, h1("Location of Indonesia Exporter")),
                        column(10, plotlyOutput("ExportPartnerMap", height = "500px")),
                        column(2,
                               sliderInput(
                                   inputId = "FilterYearExportMap",
                                   label = "Year",
                                   min = min(export_import_map$Year),
                                   max = max(export_import_map$Year),
                                   value = max(export_import_map$Year),
                                   sep = "",
                                   animate = animationOptions(loop = TRUE))),
                        
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            #---------------------------------------------PRODUCTSUBCATEGORYEX DASHBOARD----------------------------------------------
            tabItem(tabName = "PRODUCTSUBCATEGORYEX",
                    fluidRow(
                        column(12, h1("Export by Product Subcategory")),
                        column(10, plotOutput("ExportGoodsCategory", height="500px")),
                        column(2, sliderInput(
                            inputId = "FilterYearExportProduct",
                            label = "Year",
                            min = min(export_import_map$Year),
                            max = max(export_import_map$Year),
                            value = max(export_import_map$Year),
                            sep = "",
                            animate = animationOptions(loop = TRUE)))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            #---------------------------------------------PRODUCTSUBCATEGORYTRENDEX DASHBOARD----------------------------------------------
            tabItem(tabName = "PRODUCTSUBCATEGORYTRENDEX",
                    fluidRow(
                        column(10, 
                               h1("Export Trend by Product Subcategory"),
                               plotlyOutput(outputId = "ExportProductPerCategory", height = "500px")),
                        column(2, radioButtons(
                            inputId = "FilterExportCategoryType",
                            label = "Category:",
                            choices = unique(exportCategory$Type),
                            selected = NULL
                        ))
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            #---------------------------------------------PRODUCTSUBCATEGORYEXPORTERS DASHBOARD----------------------------------------------
            tabItem(tabName = "PRODUCTSUBCATEGORYEXPORTERS",
                    fluidRow(
                        column(12, h1("Location of Indonesia Exporter by Product Subcategory")),
                        column(9, plotlyOutput(outputId = "ExportProductCategoryMap", height = "500px")),
                        column(3, sliderInput(
                            inputId = "FilterExportCategoryYear",
                            label = "Year",
                            min = min(exportCategory$Year),
                            max = max(exportCategory$Year),
                            value = max(exportCategory$Year),
                            sep = ""),
                               radioButtons(
                            inputId = "FilterExportCategoryTypeMap",
                            label = "Category:",
                            choices = unique(exportCategory$Type),
                            selected = NULL
                            )),
                        
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            #---------------------------------------------------SLOPE GRAPH DASHBOARD-------------------------------------------
            tabItem(tabName = "SLOPEGRAPH",
                    fluidRow(
                        column(12, h1("Trend of Trade")),
                        sidebarPanel(
                            selectInput(inputId = "ImportExportSlope",
                                        label = "Import / Export:",
                                        choices = c("Import" = "Import",
                                                    "Export" = "Export"),
                                        selected = "Import"),
                            selectInput(inputId = "Year1",
                                        label = "From:",
                                        choices = yearList,
                                        selected = "2000"),
                            selectInput(inputId = "Year2",
                                        label = "From:",
                                        choices = yearList,
                                        selected = "2018")
                        ),
                        column(8, plotlyOutput("slopegraph", height="550px")),
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
            
            #------------------------------------------------CHORD DIAGRAM DASHBOARD--------------------------------------------
            tabItem(tabName = "CHORDDIAGRAM",
                    fluidRow(
                        column(12, h1("Export and Import Partner of Indonesia")),
                        column(10, chorddiagOutput("chord", height="550px")),
                        column(2, sliderInput(
                            inputId = "FilterYearChord",
                            label = "Year",
                            min = 2002,
                            max = 2018,
                            value = 2002,
                            sep = "",
                            animate = animationOptions(loop = FALSE)
                        )),
                        
                    )
            ),
            #-------------------------------------------------------------------------------------------------------------------
            
    
            
            #---------------------------------------------PORT DISTRIBUTION OF INDONESIA-----------------------------------------
            tabItem(tabName = "PORTINDO",
                    fluidRow(
                        column(12, h1("Port Distribution of Indonesia")),
                        column(10, plotlyOutput(outputId = "PortMapIndo", height="500px")),
                        column(2, selectInput(inputId = "ImportOrExport",
                                              label = "Import / Export:",
                                              choices = c("Import" = "Import",
                                                          "Export" = "Export"))),
                        column(2, sliderInput(
                            inputId = "FilterPortYear",
                            label = "Year",
                            min = min(exportPorts$Year),
                            max = max(exportPorts$Year),
                            value = max(exportPorts$Year),
                            sep = ""))
                    )
            )
            #---------------------------------------------------------------------------------------------------------------------
        )
    )
)

server <- function(input, output) {
    set.seed(122)
    histdata <- rnorm(500)
    
    #-------------------------------------------------------------HOME DASHBOARD GRAPH------------------------------------------
    output$timeseries <- renderPlotly({
        plot_ly(source = "source") %>%
            add_lines(data = ds, x= ~Year, y=~value,color=~variable,
                      mode = 'lines', marker = list(width = 3))%>%
            add_trace(data = ds2,x= ~Year, y=~value,
                      marker =list(color = col(), width = 10),yaxis = "y2", name = "TradeBalance", opacity = 0.6)%>%
            layout(
                xaxis = list(title = "Year", domain = c(0, 0.98)),
                yaxis = list(title = "Amount (USD million)", domain = c(0, 0.98)),
                hovermode = 'compare',
                yaxis2 = list(overlaying = "y",
                              title = "Trade Balance Amount (USD million)", side = "right")
            )
    })
    
    output$percentileGraph <- renderPlot({
        finaldata_Year <- filter(percentile_data, percentile_data$Year == input$FilterYearDash1)
        
        p <- ggplot(finaldata_Year, aes(x=Exportpercentile, y=Importpercentile, color=Tradebalance))+
            #text=paste('</br>Country: ', Countries,
            #         '</br>Export: ', Export.Value,
            #         '</br>Import: ', Import.Value))) + 
            
            geom_point(aes(text=paste('</br>Export: ',finaldata_Year$Export.Value, '</br>Import: ', finaldata_Year$Import.Value))) + 
            geom_text_repel(aes(x=Exportpercentile,y=Importpercentile,label=Countries, nudge_x= -0.35, direction="y"))+
            #geom_text_repel(aes(x=Exportpercentile,y=Importpercentile,label=Tradebalance, nudge_x= -0.5, direction="y"))+
            #geom_line(aes(x = 50, y = 50)) +
            #geom_text_repel(aes(x=Exportpercentile, y=Importpercentile, label=Countries)) +
            scale_color_gradient(low="red", high="green") +
            coord_cartesian(xlim =c(0, 100), ylim = c(0, 100)) +
            geom_hline(yintercept=50, linetype="dashed", color = "grey")+
            geom_vline(xintercept=50, linetype="dashed", color = "grey") +
            theme(panel.background = element_blank())
        p <- p + annotate("text", x=25,y=100,label="Low Export, High Import") + annotate("text", x=80,y=100,label="Top Partners")+
            annotate("text", x=25,y=45,label="Untapped Market") + annotate("text", x=80,y=45,label="High Export, Low Import")
        p
        
    })
    #---------------------------------------------------------------------------------------------------------------------------
    
    
    #-----------------------------------------------------IMPORT DASHBOARD GRAPH------------------------------------------------
    #IMPORT PROPORTION
    output$ImportProportion <- renderPlotly({
        plot_ly(data = import_proportion) %>%
            filter(Year %in% input$FilterYearImport) %>%
            group_by(Year) %>%
            add_trace(x = "Consumption Goods", y = ~ConsumptionGoods, name = "Consumption Goods", 
                      text = ~ConsumptionGoods, textposition = 'auto') %>%
            add_trace(x = "Raw Material Support", y = ~RawMaterialSupport, name = "Raw Material Support",
                      text = ~RawMaterialSupport, textposition = 'auto') %>%
            add_trace(x = "Capital Goods", y = ~CapitalGoods, name = "Capital Goods",
                      text = ~CapitalGoods, textposition = 'auto') %>%
            layout(yaxis = list(title = "Amount (USD Million)", range = c(0, 200000)), 
                   barmode = NULL, legend = list(orientation = 'h'))
    })
    
    #LINE IMPORT
    output$LineImport <- renderPlotly({
        inputOrder <- ifelse(input$orderImport == "All", nrow(import_partners), input$orderImport)
        final_data <- sorted_import_partners[c(1:inputOrder), c(1:3)]
        subset_data <- subset(import_partners, import_partners$Destination %in% final_data$Destination)
        
        plot_ly(source = "source") %>%
            add_lines(data = subset_data, x = ~Year, y = ~Import, color = ~Destination, mode= 'lines')%>%
            add_markers(x = ~Year, y = ~Import, color = ~Destination,
                        hoverinfo = 'text',
                        text = ~paste('<br> Country: ', Destination,
                                      '<br> Year: ', Year,
                                      '<br> Import Value: $ ', Import),
                        showlegend = FALSE
            )%>%
            layout(xaxis=list(zeroline = FALSE, showline=FALSE, showticklabels=FALSE, showgrid=FALSE))
    })
    
    #IMPORT PARTNER MAP
    output$ImportPartnerMap <- renderPlotly({
        mapImport <- filter(export_import_map, Year == input$FilterYearImportLocMap)
        map <- ggplot()+
            geom_polygon(data=global_map, aes(x=long, y=lat, group=group), alpha=0.5) +  
            geom_point(data=mapImport, aes(x=Longitude, y=Latitude, size=ImportValue,
                                           label=Countries, label2=Year), color="#F12424") +
            theme(panel.background = element_blank())
        
        ggplotly(map)
    })
    #---------------------------------------------------------------------------------------------------------------------------
    
    
    #----------------------------------------------------IMPORT PRODUCT CATEGORY DASHBOARD-----------------------------------------------
    output$ImportGoodsCategory <- renderPlot({
        category <- filter(importCategory, Year == input$FilterYearImportProduct)
        newTitle <- paste0("Category of Product imported in ", input$FilterYearImportProduct)
        treemap <- treemap(category,
                           index = c("Type", "label"),
                           vSize="Import",
                           vColor="Import",
                           type="value",
                           palette=brewer.pal(n=8, "Spectral"),
                           title=newTitle,
                           title.legend = "Amount (Million US$)",
                           align.labels = list(c("left", "top"), c("right", "bottom")), fontsize.labels=20
        )
        treemap
    })
    
    #LINE TREND OF IMPORT PER PRODUCT CATEGORY
    output$ImportProductPerCategory <- renderPlotly({
        final_filtered <- filter(importCategoryTotal, Type == input$FilterImportCategoryType)
        plot_ly(source = "source") %>%
            add_lines(data = final_filtered, x = ~Year, y = ~Import, color = ~Type, mode= 'lines',
                      showlegend = FALSE)%>%
            add_markers(x=~Year, y=~Import,color = ~Type,
                        hoverinfo = 'text',
                        text = ~paste('<br> Product: ', Type,
                                      '<br> Year: ', Year,
                                      '<br> Export Value: $ ', Import),
                        showlegend = FALSE
            ) %>%
            add_text(x=~Year, y=~Import, text=~label, repel=TRUE) %>%
            layout(xaxis=list(zeroline = FALSE, showline=FALSE, showticklabels=TRUE, showgrid=FALSE))
    })
    
    #MAP OF IMPORT PER PRODUCT CATEGORY
    output$ImportProductCategoryMap <- renderPlotly({
        filtered <- filter(importCategory, Type == input$FilterImportCategoryTypeMap)
        final_filtered <- filter(filtered, Year == input$FilterImportCategoryYear)
        
        map <- ggplot()+
            geom_polygon(data=global_map, aes(x=long, y=lat, group=group), alpha=0.5) +  
            geom_point(data=final_filtered, aes(x=Longitude, y=Latitude, size=Import,
                                                label=Origin, label2=Year, label3=Import), color="#F12424") +
            theme(panel.background = element_blank())
        
        ggplotly(map)
    })
    #---------------------------------------------------------------------------------------------------------------------------
    
    
    #--------------------------------------------------------EXPORT DASHBOARD---------------------------------------------------
    output$ExportProportion <- renderPlotly({
        filtered_export_proportion <- filter(export_proportion, Year == input$FilterYearExport)
        YearValue <- paste("Export at", filtered_export_proportion$Year)
        a <- ggplot(data = filtered_export_proportion, label="Year", 
                    text = ~paste('<br> Category: ', Category, " (", Subcategory, ")",
                                  '<br> Year: ', Year,
                                  '<br> Export Value: $ ', Import)) +
            geom_mosaic(aes(x = product(Subcategory, Category), fill=Subcategory, weight = Import), divider = ddecker(), 
                        na.rm=TRUE, offset = 0.002) +
            #scale_fill_manual(values = c("#d8b365", "#f5f5f5", "#5ab4ac", "#d8b365", "#f5f5f5", "#5ab4ac", "#5ab4ac"))+
            scale_y_continuous(labels=scales::percent)+
            labs(x = YearValue) +
            theme(panel.background = element_blank())
        ggplotly(a, tooltip=c("text"))
    })
    
    output$LineExport <- renderPlotly({
        inputOrder <- ifelse(input$orderExport == "All", nrow(export_partners), input$orderExport)
        final_data <- sorted_export_partners[c(1:inputOrder), c(1:3)]
        subset_data <- subset(export_partners, export_partners$Destination %in% final_data$Destination)
        
        plot_ly(source = "source") %>%
            add_lines(data = subset_data, x = ~Year, y = ~Export, color = ~Destination, mode= 'lines')%>%
            add_markers(x=~Year, y=~Export,color = ~Destination,
                        hoverinfo = 'text',
                        text = ~paste('<br> Country: ', Destination,
                                      '<br> Year: ', Year,
                                      '<br> Export Value: $ ', Export),
                        showlegend = FALSE
            ) %>%
            layout(xaxis=list(zeroline = FALSE, showline=FALSE, showticklabels=FALSE, showgrid=FALSE))
    })
    
    output$ExportPartnerMap <- renderPlotly({
        mapExport <- filter(export_import_map, Year == input$FilterYearExportMap)
        map <- ggplot()+
            geom_polygon(data=global_map, aes(x=long, y=lat, group=group), alpha=0.5) +  
            geom_point(data=mapExport, aes(x=Longitude, y=Latitude, size=ExportValue,
                                           label=Countries, label2=Year), color="#33AF13") +
            theme(panel.background = element_blank())
        
        ggplotly(map)
    })
    #---------------------------------------------------------------------------------------------------------------------------
    
    
    #----------------------------------------------------EXPORT PRODUCT DASHBOARD-----------------------------------------------
    output$ExportGoodsCategory <- renderPlot({
        category <- filter(exportCategory, Year == input$FilterYearExportProduct)
        newTitle <- paste0("Category of Product exported in ", input$FilterYearExportProduct)
        treemap <- treemap(category,
                           index = c("Type", "label"),
                           vSize="Export",
                           vColor="Export",
                           type="value",
                           palette=brewer.pal(n=8, "Spectral"),
                           title=newTitle,
                           title.legend = "Amount (Million US$)",
                           align.labels = list(c("left", "top"), c("right", "bottom")), fontsize.labels=20
        )
        treemap
    })
    
    output$ExportProductPerCategory <- renderPlotly({
        final_filtered <- filter(exportCategoryTotal, Type == input$FilterExportCategoryType)
        plot_ly(source = "source") %>%
            add_lines(data = final_filtered, x = ~Year, y = ~Export, color = ~Type, mode= 'lines',
                      showlegend = FALSE)%>%
            add_markers(x=~Year, y=~Export,color = ~Type,
                        hoverinfo = 'text',
                        text = ~paste('<br> Product: ', Type,
                                      '<br> Year: ', Year,
                                      '<br> Export Value: $ ', Export),
                        showlegend = FALSE
            ) %>%
            add_text(x=~Year, y=~Export, text=~label) %>%
            layout(xaxis=list(zeroline = FALSE, showline=FALSE, showticklabels=TRUE, showgrid=FALSE))
    })
    
    output$ExportProductCategoryMap <- renderPlotly({
        filtered <- filter(exportCategory, Type == input$FilterExportCategoryTypeMap)
        final_filtered <- filter(filtered, Year == input$FilterExportCategoryYear)
        
        map <- ggplot()+
            geom_polygon(data=global_map, aes(x=long, y=lat, group=group), alpha=0.5) +  
            geom_point(data=final_filtered, aes(x=Longitude, y=Latitude, size=Export,
                                                label=Destination, label2=Year, label3=Export), color="#33AF13") +
            theme(panel.background = element_blank())
        
        ggplotly(map)
    })
    #---------------------------------------------------------------------------------------------------------------------------
    
    
    #---------------------------------------------SLOPE GRAPH GRAPH------------------------------------------------------------
    output$slopegraph <- renderPlotly({
        country_lists <- country_lists_import
        year1input <- input$Year1
        year2input <- input$Year2
        
        if(input$ImportExportSlope == "Import"){
            country_lists = country_lists_import
        } else{
            country_lists = country_lists_export
        }
        
        year1 <- match(input$Year1,names(country_lists))
        year2 <- match(input$Year2, names(country_lists))
        
        Year_1_filter <- country_lists[,c("Destination", input$Year1)]
        Year_1_filter$Year <- input$Year1
        names(Year_1_filter)[names(Year_1_filter) == input$Year1] <- "Value"
        Year_1_filter$log <- log10(Year_1_filter$Value)
        
        Year_2_filter <- country_lists[,c("Destination", input$Year2)]
        Year_2_filter$Year <- input$Year2
        names(Year_2_filter)[names(Year_2_filter) == input$Year2] <- "Value"
        Year_2_filter$log <- log10(Year_2_filter$Value)
        
        mergeCol <- merge(Year_1_filter, Year_2_filter, by="Destination")
        mergeCol$status <- ifelse(mergeCol$Value.y - mergeCol$Value.x >0, "Increase", "Decrease")
        
        total <- rbind(Year_1_filter, Year_2_filter)
        total$status <- plyr::mapvalues(total$Destination, from = mergeCol$Destination, to = mergeCol$status)
        
        slope_graph <- ggplot(total, aes(x=Year, y=log, y1=Value, group=Destination, color=status)) +
            geom_line()+
            scale_color_manual(values=c(Increase = "#00ba38", Decrease = "#f8766d"))+
            scale_x_discrete()+
            scale_y_discrete(name = input$ImportExportSlope)+
            theme(panel.background = element_blank(),
                  axis.text.y=element_blank())
        
        ggplotly(slope_graph)
    })
    #---------------------------------------------------------------------------------------------------------------------------
    
    
    #----------------------------------------------------CHORD DIAGRAM GRAPH------------------------------------------------------------------------
    output$chord <- renderChorddiag({
        #plotOutput(data = sorted_import_partners)%>%
        testdata = filter(data, Year==input$FilterYearChord)
        destinationImport = cbind(testdata$Countries,testdata$`Import Value`, row.names=NULL)
        destinationExport = cbind(testdata$Countries,testdata$`Export Value`,row.names=NULL)
        destinationImport = as.data.frame(destinationImport)
        destinationExport = as.data.frame(destinationExport)
        #View(destination)
        destinationImport$V2  <- as.numeric(as.character(destinationImport$V2))
        destinationExport$V2  <- as.numeric(as.character(destinationExport$V2))
        tdestinationImport <- transpose(destinationImport)
        names(tdestinationImport) <- tdestinationImport[1,]
        tdestinationImport <- tdestinationImport[-1,]
        tdestination <- cbind(Indonesia = destinationExport$V2, tdestinationImport)
        tdestination[nrow(tdestination)+1,] <- 0
        row.names(tdestination) <- c("Indonesia",names(tdestinationImport))
        #colnames(tdestinationImport) <- c("Indonesia")
        #View(tdestination)
        tdestination<-as.matrix(tdestination)
        #glimpse(tdestination)
        tdestination[c(2:34),c(2:34)] <- 0
        tdestination[c(2:34)] <- tdestination[c(1:34)]
        tdestination[1,1] <- 0
        class(tdestination) <- "numeric"
        
        groupColor <- c("#ffb997","#f67e7d","#843b62","#ObO32d","#74546a",
                        "#247ba0", "#70c1b3", "#b2dbbf", "#f3ffbd", "#ff1654", "#fe938c", "#e6b89c", "#ead2ac", 
                        "#9cafb7", "#4281a4", "#50514f", "#f25f5c", "#ffe066", "#247ba0", "#70c1b3", "#773344", 
                        "#e3b5a4", "#f5e9e2", "#0b0014", "#d44d5c", "#c9e4ca", "#87bba2", "#55828b", "#3b6064", 
                        "#364958", "#071e22", "#1d7874", "#679289", "#ee2e31")
        #         #461220, #8c2f39, #b23a48, #fcb9b2, #fed0bb, #faf3dd, #c8d5b9, #8fc0a9, #68b0ab, #4a7c59, #faa275, #ff8c61, #ce6a85, #985277, #5c374c)
        # 
        
        #View(tdestination)
        chorddiag(
            tdestination, 
            showTicks = F, 
            groupColors = groupColor, 
            groupedgeColor = groupColor, 
            chordedgeColor = groupColor, 
            width = 10000,
            height = 10000, 
            groupnameFontsize = 10, 
            groupnamePadding = 1, 
            margin = 100,
            categorynamePadding = 10
        )
    })
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    
    
    #------------------------------------------------PORT DISTRIBUTION OF INDONESIA--------------------------------------------
    output$PortMapIndo <- renderPlotly({
        initial_data <- importPorts
        color <- "red"
        if(input$ImportOrExport == "Import"){
            initial_data = importPorts
            color <- "#F12424"
        } else{
            initial_data = exportPorts
            color <- "#33AF13"
        }
        
        final_filtered <- filter(initial_data, Year == input$FilterPortYear)
        title <- paste(input$ImportOrExport, " Ports of Indonesia")
        mapWorld <- ggplot()+
            geom_polygon(data=global_map, aes(x=long, y=lat, group=group), alpha=0.5)
        
        indoMap <- mapWorld + xlim(94, 142) + ylim(-11, 7.5) +
            geom_point(data=final_filtered, aes(x=Longitude, y=Latitude, size=Values,
                                                label=MajorPorts, label2=Year), color=color) +
            labs(title = title) +
            theme(panel.background = element_blank())
        
        ggplotly(indoMap)
    })
    #---------------------------------------------------------------------------------------------------------------------------
}

shinyApp(ui = ui, server = server)