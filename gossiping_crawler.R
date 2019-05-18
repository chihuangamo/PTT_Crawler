library(xml2)
library(httr)
library(rvest)
library(tidyverse)
options(stringsAsFactors = F)


# url <- "https://www.ptt.cc/bbs/gossiping/index39252.html"
# get.content <- content(GET(url, set_cookies(`over18`=1)), "text")
# doc <- read_html(doc)
# css.post.url <-  html_nodes(doc, ".title > a")


#parsing posts url----
all.url <- list()
pre.url <- "https://www.ptt.cc/bbs/gossiping/index%s.html"
for(i in 39087:34408){
  message(i)
  url <- sprintf(pre.url, i)
  get.content <- content(GET(url, set_cookies(`over18`=1)), "text")
  doc <- read_html(get.content)
  
  css.post.url <-  html_nodes(doc, ".title > a")
  urls <- paste("www.ptt.cc", html_attr(css.post.url, "href"), sep="")
  
  all.url[[i+1]] <- urls
}

all.url <- unlist(all.url)
all.url <- paste("http://", all.url, sep="")

#parsing posts contents & push----

#all.url <- readRDS("gossiping_urls.rds")
for(i in c(0:9)){
  df.content <- data.frame(autor="", title="", time="", url="",story="")
  content.list= list()
  push.list = list()
  for(url in all.url[(i*10000+1):((i+1)*10000)]){
    tryCatch({
      get.content <- content(GET(url, set_cookies(`over18`=1)), "text")
      doc <- read_html(get.content)
      
      #parsing content
      css.header <- html_nodes(doc, ".article-meta-value")
      header <- html_text(css.header)[c(1,3:4)]
      
      path.story <- html_nodes(doc, xpath = '//*[@id="main-content"]/text()')
      story <- html_text(path.story)
      
      df.content[1:3] <- header
      df.content[4] <- url
      df.content[5] <- paste(story[nchar(story)>30], collapse = "")
      
      content.list[[length(content.list)+1]] <- df.content
      
      #parsing push
      css.pushtag <- html_nodes(doc, ".push-tag")
      css.pushuserid <- html_nodes(doc, ".push-userid")
      css.pushcontent <- html_nodes(doc, ".push-content")
      css.pushtimeid <- html_nodes(doc, ".push-ipdatetime")
      
      if(length(css.pushtag) != 0){
        push.tag <- html_text(css.pushtag)
        push.userid <- html_text(css.pushuserid)
        push.content <- html_text(css.pushcontent)
        
        push.time.id <- html_text(css.pushtimeid)
        push.time <- substr(push.time.id, 2,  nchar(push.time.id)-1)
#        push.id <- substr(push.time.id, 1, nchar(push.time.id)-13)
        
        df.push <- data.frame("url" = url, "push.tag" = push.tag, 
                              "push.content" = push.content, "push.time" = push.time)
        push.list[[length(push.list)+1]] <- df.push
      }
      
      message(length(content.list) + i*10000)
    }, error = function(e){paste(url, e, sep=", ")})
  }
  
  all.content <- do.call(bind_rows, content.list) 
  all.push <- do.call(bind_rows, push.list)
  
  content.file.name = sprintf("gossiping_content_4/gossiping_content_%s.rds", i+1)
  push.file.name = sprintf("gossiping_push_4/gossiping_push_%s.rds", i+1)
  
  all.content %>% saveRDS(content.file.name)
  all.push %>% saveRDS(push.file.name)
}


#test----
df.content <- data.frame(autor="", title="", time="", url="",story="")
content.list= list()
push.list = list()
for(url in all.url[(i*10000+1):(i+1)*10000]){
  tryCatch({
    get.content <- content(GET(url, set_cookies(`over18`=1)), "text")
    doc <- read_html(get.content)
    
    #parsing content
    css.header <- html_nodes(doc, ".article-meta-value")
    header <- html_text(css.header)[c(1,3:4)]
    
    path.story <- html_nodes(doc, xpath = '//*[@id="main-content"]/text()')
    story <- html_text(path.story)
    
    df.content[1:3] <- header
    df.content[4] <- url
    df.content[5] <- paste(story[nchar(story)>30], collapse = "")
    
    content.list[[length(content.list)+1]] <- df.content
    
    #parsing push
    css.pushtag <- html_nodes(doc, ".push-tag")
    css.pushuserid <- html_nodes(doc, ".push-userid")
    css.pushcontent <- html_nodes(doc, ".push-content")
    css.pushtimeid <- html_nodes(doc, ".push-ipdatetime")
    
    if(length(css.pushtag) != 0){
      push.tag <- html_text(css.pushtag)
      push.userid <- html_text(css.pushuserid)
      push.content <- html_text(css.pushcontent)
      
      push.time.id <- html_text(css.pushtimeid)
      push.time <- substr(push.time.id, 2,  nchar(push.time.id)-1)
  #    push.id <- substr(push.time.id, 1, nchar(push.time.id)-13)
      
      df.push <- data.frame("url" = url, "push.tag" = push.tag, 
                            "push.content" = push.content, "push.time" = push.time)
      push.list[[length(push.list)+1]] <- df.push
    }
    
    message(length(content.list))
  }, error = function(e){paste(url, e, sep=", ")})
}

all.content <- do.call(bind_rows, content.list) 
all.push <- do.call(bind_rows, push.list)

content.file.name = sprintf("gossiping_content/gossiping_content_%s.rds", i+1)
push.file.name = sprintf("gossiping_push/gossiping_push_%s.rds", i+1)

all.content %>% saveRDS(content.file.name)
all.push %>% saveRDS(push.file.name)

for(i in c(1:3)){
  print(i)
  for(x in c(i*10+1:(i+1)*10)){
    print(x)
  }
}

i = 2
for(x in c( (i*10+1) : ((i+1)*10))){
  print(x)
}
for(url in all.url[(i*10+1):((i+1)*10)]){
  print(url)
}
all.url[21:30]
