#Starting a new project to automate the breaking out of table data from the Senate's website using the rvest package

library(tidyverse)
library(rvest)
library(janitor)

#Using tutorial found here https://cran.r-project.org/web/packages/rvest/vignettes/rvest.html to try to pull html from the senate website and then break out the table elements

#pull in html from senate website I want to scrape  
html <- read_html("https://www.senate.gov/legislative/Votearama1977present.htm")
class(html)

# Identify the information stored in a <table> tag and put it into a data.frame 
vote_a_rama_table <- html %>% 
  html_node("table") %>% 
  html_table() %>%
  #uses the janitor package to set the top row, as column names  -- for whatever reason the html_table( header = TRUE) just wasn't working. Probably user error.
  row_to_names(row_number = 1)


#using regex, extract the two groups of four numerals separated by a _ and create a new column with it.
#noted that the dates I want were conveniently at the beginning of the column, so I just peeled them off ... used this for inspiration. https://cran.r-project.org/web/packages/stringr/vignettes/stringr.html
votes_with_dates <- vote_a_rama_table %>% 
  mutate(new_date = str_extract(Date, ("([0-9]{4})[_]([0-9]{4})"))) 

#now lets make that new_date into an actual date so we can graph it. Using lubridate https://lubridate.tidyverse.org/index.html // using joels' solution I've also built columns for month/day/year and then created a column below that will give me a decade range that I can do some averages to later

votes_with_dates <- votes_with_dates %>% 
  mutate(newest_date = ymd(new_date)) %>% 
  mutate_at(vars(newest_date), funs(year, month, day)) %>%
  mutate (decade = if_else(year < 1988, "1977-1987", 
                    if_else(year < 1999, "1988-1998", 
                      if_else(year <2010, "1999-2009",
                        if_else(year < 2022, "2010 to present", "error")))))

#Using these two pieces of information I've made a table to join a CSV I hastily made in Excel with the table above. I will join on "year"  // https://www.senate.gov/legislative/YearstoCongress.htm // https://www.senate.gov/history/partydiv.htm

congress_party <- read_csv("congress_party_control.csv", trim_ws = TRUE)
                     
full_table <- left_join(votes_with_dates, congress_party, year=year)

#Now I've grouped by the majority party and the Congress and gotten the mean number of roll call votes?

summary_data <- full_table  %>%
  group_by(majority_party, congress) %>%
  summarise(mean = mean(as.integer(`Roll Call Votes`)))


#and let's graph the thing for good measure https://www.r-graph-gallery.com/connected_scatterplot_ggplot2.html


# plot

  ggplot(summary_data, aes(x=congress, y=mean, color=majority_party)) +
  geom_bar(stat="identity", fill="white") +
  scale_fill_manual( values = c("D" = "black", "D/R" = "orange", "R" = "blue"))

