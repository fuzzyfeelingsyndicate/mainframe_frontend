library(DT)
library(shinydashboard)
library(shiny)



dashboardPage(skin = "red",
              dashboardHeader(title = "test App"),
              
              dashboardSidebar(
                collapsed = TRUE, 
                sidebarMenu(
                  menuItem("shwe data", tabName = "shwe_data", icon = icon("dashboard")),
                  menuItem("RA data", tabName = "RA_data", icon = icon("cogs"))
                ), width = 150
              ),
              
              dashboardBody(
                tabItems(
                  tabItem(tabName = "shwe_data",
                          fluidRow(
                            column(2, wellPanel(
                              h3("Input"),
                              textInput('eventid', "enter event id"),
                              actionButton('ReadcombinationResults', 'Read'),
                              style = "background-color: black; padding: 10px; border-radius: 5px; color:white;"
                            )),
                            column(10, box(title = h2('money line'),
                                           DT::DTOutput("testtext"),
                                           width = 12))
                          )
                  )
                )
              )
)
