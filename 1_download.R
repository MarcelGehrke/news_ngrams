library(rvest)
library(tidyverse)
library(magrittr)
library(furrr)
library(tictoc)

plan(multisession)

tic()

url <-
  "https://blog.gdeltproject.org/announcing-the-television-news-ngram-datasets-tv-ngram/"

website <- read_html(url)

files <- website %>%
  html_nodes("a") %>%
  html_attr("href")

files <- files[grepl(pattern = "FILELIST", x = files)]

text <- files %>%
  map( ~ read_html(.x))

names(text) <- gsub("^.*FILELIST-|\\.TXT", "", files)

text %<>% map( ~ .x %>%
                 html_nodes("body") %>%
                 html_text() %>%
                 toString())

text %<>% future_map( ~ strsplit(.x, "[\r\n]+")[[1]])

future_map(names(text), ~ dir.create(paste0("in/", .x)))

# text_20 <- future_map(text, ~ str_subset(string = .x, pattern = "2020"))

text_20 %>%
  future_map( ~ .x %>%
                future_map( ~ download.file(.x, destfile = paste0(
                  "in/",
                  gsub("^\\d{8}\\.|\\.|1gram|2gram|txt|gz", "/", basename(.x)),
                  "/",
                  basename(.x)
                ))))

toc()
