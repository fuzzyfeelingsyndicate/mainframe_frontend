library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)

function(input, output, session) {
  
  eventdetails <- eventReactive( input$ReadcombinationResults, {
    eventid <- input$eventid
    url <- "https://pinnacle-odds.p.rapidapi.com/kit/v1/details"
    queryString <- list(event_id = eventid)
    response <- VERB("GET", url, query = queryString, add_headers('x-rapidapi-key' = '67356f377fmsh90217b51616e9d8p11c494jsnf87faa9470db', 'x-rapidapi-host' = 'pinnacle-odds.p.rapidapi.com'), content_type("application/octet-stream"))
    df <- content(response, "text")

    home <- as.data.frame(fromJSON(df)$events$periods$num_0$history$moneyline$home) %>% 
      rename('timestamp' = X1, 'home' = X2, 'limit' =  X3) %>% 
      mutate(timestamp = as.POSIXct(timestamp, origin = "1970-01-01", tz = "CET")) %>% arrange(timestamp)
    draw <- as.data.frame(fromJSON(df)$events$periods$num_0$history$moneyline$draw) %>% 
      rename('timestamp' = X1,'draw' = X2) %>% 
      mutate(timestamp = as.POSIXct(timestamp, origin = "1970-01-01", tz = "CET")) %>% 
      select(timestamp, draw) %>% arrange(timestamp)
    away <- as.data.frame(fromJSON(df)$events$periods$num_0$history$moneyline$away)%>% 
      rename('timestamp' = X1, 'away' = X2) %>%
      mutate(timestamp = as.POSIXct(timestamp, origin = "1970-01-01", tz = "CET")) %>% 
      select(timestamp, away) %>% arrange(timestamp)
    
    moneyline <-  merge(merge(home, away, all = TRUE), draw, all = TRUE) %>% 
      select(timestamp, limit, home, draw, away) %>% 
      fill(limit, home, draw, away, .direction = "down")
    
    return(moneyline)
  })
  
  
  listOfLeagues_er <- eventReactive(input$lolbutton, {
    lol <- read.csv('leaguesList.csv')
    lol <- lol %>% select(
      id, sport_id, name, container) %>% 
      rename('league_id' = id)
    
    return(lol)
  })
  
  output$eventdetailApi <- renderDataTable({
    eventdetails()
  })
  
  output$list_of_leagues <- renderDataTable({
    listOfLeagues_er()
  })
  

}





