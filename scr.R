files <- list.files("in/ALJAZ/", pattern = "^2020\\d+.ALJAZ.1gram.txt.gz", full.names = TRUE)

map(files, ~ gunzip(filename = .x, skip = TRUE))

           

files_txt <- list.files("in/ALJAZ", pattern = ".txt$", full.names = TRUE)

safely_read <- safely(read.table)

data <- map(files_txt, ~ safely_read(.x, sep = "\t", header = FALSE))

tmp <- map(data, ~ .x$result %>% bind_rows())

tmp %<>% bind_rows()

colnames(tmp) <-
  c("Date",
    "Channel",
    "Time",
    "Word",
    "Count")

tmp %<>%
  filter(!Word %in% tm::stopwords())

tmp %<>% mutate(Date = lubridate::ymd(Date))

tmp %<>% filter(!grepl(pattern = "\\d", x = Word))


