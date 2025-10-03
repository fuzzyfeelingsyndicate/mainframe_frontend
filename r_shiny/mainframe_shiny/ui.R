library(DT)
library(shinydashboard)
library(shiny)




fluidPage(
  
  dashboardPage(skin = "red",
                dashboardHeader(title = "test App"),
                
                dashboardSidebar(
                  collapsed = T, 
                  sidebarMenu(
                    menuItem("shop data", tabName = "shop data", icon = icon("dashboard")),
                    menuItem("RA data", tabName = "RA data", icon = icon("cogs"))
                  ), width=150
                ),
                
                dashboardBody(
                  tabItem(tabName = "shop data",
                          fluidRow(
                            column(2, wellPanel(
                              h3("Input"),
                              dateRangeInput('selectDate1', 'Select Date range'),
                              selectInput('selectshop', 'Select sh', c(
                                'sh1',
                                'sh2',
                                'sh3'
                              )),
                              actionButton('ReadcombinationResults', 'Read'),
                              style = "background-color: black; padding: 10px; border-radius: 5px; color:white;"
                            )),
                            column(10, box(title = h2('Top 10 shop query'),
                                           DT::DTOutput("BestCombinations"),
                                           width = 12))
                          )
                  )
                )
                
  )
