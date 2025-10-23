list.of.packages <- c("readxl", "tidyr", "forcats", "ggplot2", "magrittr",
                      "dplyr", "tidytext", "reshape2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

# Read SDG Indicator Dataset from Excel file
directory <- "data/"
SDGIndicators <- read_excel(paste0(directory,"SDG Indicators.xlsx"), sheet = "Indicator") 

# Create a new column 'text' by concatenating Target and Indicator, omitting NA values
SDGSelectedColumn <- SDGIndicators %>%
  select(Goal, SDG, Target, Indicator) %>%
  mutate(text = gsub("^NA(?:\\s+NA)*\\b\\s*|\\s*\\bNA(?:\\s+NA)*$", "", 
                     paste(SDG, Target, Indicator)))

rowText <- SDGSelectedColumn %>%
  select(Goal, text) 

# Transform into tidy text format by tokenising words
tidy_SDGs <- rowText %>%
  unnest_tokens(word, text) %>%
  count(Goal, word, sort = TRUE)

# Remove stop words
data("stop_words")
my_stop_words <- tibble(word = c("cent"))  

tidy_SDGs <- tidy_SDGs %>%
  anti_join(stop_words) %>%
  anti_join(my_stop_words)

word_count <- tidy_SDGs %>%
  group_by(Goal) %>%
  summarise(total = sum(n))

tidy_SDGs <- left_join(tidy_SDGs, word_count)

sdg_tf_idf <- tidy_SDGs %>%
  bind_tf_idf(word, Goal, n) %>%
  select(-total) %>%
  arrange(desc(tf_idf))

# Calculate TF-IDF
word_bank <- sdg_tf_idf %>%
  group_by(Goal) %>%
  slice_max(tf_idf, n=15) %>%
  ungroup()

# Remove numbers from the word bank
word_bank <- word_bank[grepl("[A-Za-z]", word_bank$word),]

# Save in CSV file for further steps
write.table(word_bank, file = paste0(directory,"WordBank.csv"))

# Plot SDG terms graph
SDGLabel <- tibble(Goal = c(1:17),
                   cbbPalette = c("#e5243b", "#DDA63A", "#4C9F38", "#C5192D", 
                                  "#FF3A21", "#26BDE2", "#FCC30B", "#A21942", 
                                  "#FD6925", "#DD1367", "#FD9D24", "#BF8B2E", 
                                  "#3F7E44", "#0A97D9", "#56C02B", "#00689D", 
                                  "#19486A"))

sdg_graph <- word_bank %>%
  group_by(Goal) %>%
  inner_join(SDGLabel) %>%
  slice_max(tf_idf, n = 5) %>%
  ungroup() %>%
  ggplot(aes(tf_idf, fct_reorder(word, tf_idf), fill=cbbPalette)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual("SDGs",values=SDGLabel$cbbPalette, breaks = SDGLabel$cbbPalette) +
  facet_wrap(~Goal, ncol = 4, scales = "free", 
             labeller = labeller(Goal = c('1'="1-Poverty", '2'="2-Hunger", '3'="3-Health", 
                                          '4'="4-Education", '5'="5-Gender", '6'="6-Sanitation", 
                                          '7'="7-Energy", '8'="8-Economy", '9'="9-Industry", 
                                          '10'="10-Inequality", '11'="11-Settlements", 
                                          '12'="12-Consumption", '13'="13-Climate", 
                                          '14'="14-Aquatic", '15'="15-Terrestrial", 
                                          '16'="16-Peace", '17'="17-Partnerships"))) +
  theme( text = element_text( family = "Times", size = 10 ) ) + 
  labs (x = "tf-idf", y = NULL)
print(sdg_graph)