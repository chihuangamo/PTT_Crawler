#10-12----
path = 'gossiping_push_10_12'
all_list = list()
for(i in 1:length(list.files(path))){
    
  file_name = sprintf('gossiping_push_10_12/gossiping_push_%s.rds',i)
  print(file_name)
  df <- readRDS(file_name) %>% 
    mutate(time = substr(push.time, 2, 6)) %>% 
    mutate(time = as.POSIXct(time,  format="%H:%M")) %>%
    mutate(time = format(time, "%H:%M")) %>% 
    select(-c(push.id, push.time)) 

  all_list[[length(all_list)+1]] <- df
}
#hate_politics_push_10_12 = do.call(bind_rows, all_list)
#gossiping_push_10_12 = do.call(bind_rows, all_list)

#not 10_12----
path <- 'gossiping_push_4'
all_list = list()
for(i in 1:length(list.files(path))){
  file_name = sprintf('gossiping_push_4/gossiping_push_%s.rds',i)
  print(file_name)
  
  df <- readRDS(file_name) %>% 
    mutate(time = as.POSIXct(push.time,  format="%m/%d %H:%M")) %>% 
    mutate(time = format(time, "%m/%d %H:%M")) %>% 
    select(-push.time) 
  
  all_list[[length(all_list)+1]] <- df
}
#hate_politics_push_1_3 <- do.call(bind_rows, all_list)
#hate_politics_push_4 <- do.call(bind_rows, all_list)

gossiping_push_4 <-  do.call(bind_rows, all_list)

#bind_rows----
hate_politics_push <- bind_rows(hate_politics_push_10_12, hate_politics_push_1_3, hate_politics_push_4) %>% 
  distinct(url, push.tag, push.content ,.keep_all=T) %>% 
  rename(tag = push.tag, content =  push.content)

gossiping_push <- bind_rows(gossiping_push_10_12, gossiping_push_1_3, gossiping_push_4) %>% 
  distinct(url, push.tag, push.content ,.keep_all=T) %>% 
  rename(tag = push.tag, content =  push.content)

#insert to SQL----
con <- dbConnect(MySQL(), 
                 dbname = "ptt", 
                 host = "140.112.153.64", 
                 user = "AmoLiu", password = "news_317", client.flag=CLIENT_MULTI_RESULTS)
dbSendQuery(con,"SET NAMES gbk")

dbWriteTable(con, value = hate_politics_push, name = "hate_politic_push", append = TRUE, row.names=F)
dbWriteTable(con, value = gossiping_push, name = "gossiping_push", append = TRUE, row.names=F)
