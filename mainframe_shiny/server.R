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

    # ===========Connecting to SUPABASE ================================
  
  pconn_rsql <- dbConnect(RPostgres::Postgres(),  
                          host='aws-1-eu-north-1.pooler.supabase.com',
                          port=5432,
                          user='postgres.jbreopqqqwaffxxjiphu',
                          password='dave@40s',
                          dbname = 'postgres')
  
  
  events <- "SELECT * FROM events"
  markets <- "SELECT * FROM markets"
  odds_history <- "SELECT * FROM odds_history"
  
  events <- dbGetQuery(pconn_rsql, events)
  markets <- dbGetQuery(pconn_rsql, markets)
  odds_history <- dbGetQuery(pconn_rsql, odds_history)
  
  side <- function(whichSide){
    odds_history %>% 
      left_join(markets, by = 'market_id') %>% 
      left_join(events, by='event_id') %>% 
      arrange(event_id) %>% 
      select(event_id, side,price, pulled_at, max_limit, market_id) %>% 
      filter(side == whichSide)
  }
  
  money_line <- side('home') %>%
    rename('home_price' = price) %>% 
    select(-side) %>% 
    inner_join(
      side('draw') %>% 
        select(price, market_id) %>% 
        rename('draw_price' = price),
      by = 'market_id'
    ) %>% 
    inner_join(
      side('away') %>% 
        select(price, market_id) %>% 
        rename('away_price' = price),
      by = 'market_id'
    ) %>% select(event_id,home_price,draw_price, away_price,max_limit, pulled_at) %>% 
    left_join(
      events %>% select(event_id, sport_id, league_name, home_team, away_team, starts),
      by='event_id'
    ) %>% select(event_id, league_name, home_team, away_team, starts, home_price,draw_price, away_price,max_limit, pulled_at )  
  
  money_line %>% group_by(event_id,pulled_at) %>% 


  dbDisconnect(pconn_rsql)
  

}





