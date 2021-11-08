#Starting a new project to automate the breaking out of table data from the Senate's website using the rvest package

install.packages("tidyverse")

#Using tutorial found here https://cran.r-project.org/web/packages/rvest/vignettes/rvest.html to try to pull html from the senate website and then break out the table elements

#pull in html from senate website I want to scrape  
html <- read_html("https://www.senate.gov/legislative/Votearama1977present.htm")
class(html)

# Identify the information stored in a <table> tag and put it into a data.frame 
vote_a_rama_table <- html %>% 
  html_node("table") %>% 
  html_table()

write.csv(vote_a_rama_table, "dates_table.csv")
