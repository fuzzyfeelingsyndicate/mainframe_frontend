library(DT)
library(shinydashboard)
library(shiny)



dashboardPage(skin = "red",
              dashboardHeader(title = "ffs"),
              
              dashboardSidebar(
                collapsed = TRUE, 
                sidebarMenu(
                  menuItem("poapi", tabName = "poapi", icon = icon("dashboard")),
                  menuItem("ffs", tabName = "ffs", icon = icon("cogs"))
                ), width = 150
              ),
              
              dashboardBody(
                tabItems(
                  tabItem(tabName = "poapi",
                          fluidRow(
                            column(2, wellPanel(
                              h3("Input"),
                              textInput('eventid', "enter event id"),
                              actionButton('ReadcombinationResults', 'Read'),
                              style = "background-color: black; padding: 10px; border-radius: 5px; color:white;"
                            )),
                            column(10, box(title = h2('money line'),
                                           DT::DTOutput("eventdetailApi"),
                                           width = 12))
                          )
                  ),
                  tabItem(tabName = "ffs",
                          fluidRow(
                            column(2, wellPanel(
                              h3("Input"),
                              # textInput('eventid', "enter event id"),
                              actionButton('lolbutton', 'Read'),
                              style = "background-color: black; padding: 10px; border-radius: 5px; color:white;"
                            )),
                            column(10, box(title = h2('leagues list'),
                                           DT::DTOutput("list_of_leagues"),
                                           width = 12))
                          )
                  )
                  
                )
              )
)
