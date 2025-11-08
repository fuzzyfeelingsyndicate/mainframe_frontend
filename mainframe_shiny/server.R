library(shiny)
library(httr)
library(jsonlite)
library(dplyr)

function(input, output, session) {
  
  test <- eventReactive( input$ReadcombinationResults, {
    testva <- input$eventid
    url <- "https://pinnacle-odds.p.rapidapi.com/kit/v1/details"
    queryString <- list(event_id = testva)
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
  
  output$testtext <- renderDataTable({
    test()
  })

}


# 
# 
# url <- "https://pinnacle-odds.p.rapidapi.com/kit/v1/details"
# queryString <- list(event_id = "1618172621")
# response <- VERB("GET", url, query = queryString, 
#                  add_headers('x-rapidapi-key' = '67356f377fmsh90217b51616e9d8p11c494jsnf87faa9470db', 'x-rapidapi-host' = 'pinnacle-odds.p.rapidapi.com'),
#                  content_type("application/octet-stream"))
# df <- content(response, "text")
# 
# home_ml <-  as.data.frame(fromJSON(df)$events$periods$num_0$history$moneyline$home)
# draw_ml <-  as.data.frame(fromJSON(df)$events$periods$num_0$history$moneyline$draw)
# away_ml <-  as.data.frame(fromJSON(df)$events$periods$num_0$history$moneyline$away)
# 
# 
# test_home <- as.data.frame(fromJSON(df)$events$periods$num_0$history$moneyline$home) %>% 
#   rename('timestamp' = X1, 'home' = X2, 'limit' =  X3) %>% 
#   mutate(timestamp = as.POSIXct(timestamp, origin = "1970-01-01", tz = "CET"))
# 
# df$events$periods$num_0$history$moneyline$home
# # library(httr)
# # 
# 
# # 
# 
# data <- read_json()
# data <- fromJSON("test.json")
# 
# moneyline_history <- df$events$periods$num_0$history$moneyline
# 
# home_history <- moneyline_history$home
# away_history <- moneyline_history$away
# 
# # Convert to data frames for easier handling
# home_df <- data.frame(
#   timestamp = sapply(home_history, function(x) x[1]),
#   odds = sapply(home_history, function(x) x[2]),
#   limit = sapply(home_history, function(x) x[3])
# )
# 
# away_df <- data.frame(
#   timestamp = sapply(away_history, function(x) x[1]),
#   odds = sapply(away_history, function(x) x[2]),
#   limit = sapply(away_history, function(x) x[3])
# )



