list.of.packages <- c("readxl", "tidytext", "tidyverse", "ggplot2", "ggraph",
                      "ggrepel", "dplyr", "igraph", "widyr", "ggpubr", "tidygraph",
                      "circlize", "qdap", "stopwords", "tm", "textclean")
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

# Correlation between words
corr <- tidy_SDGs %>%
  group_by(word) %>%
  filter(n() >= 8) %>%
  pairwise_cor(Goal, word) %>%
  filter(!is.na(correlation),
         correlation > 0) 

# Create a sankey diagram 
cbbPaletteR <- c("Goal 1" = "#e5243b", "Goal 2" = "#DDA63A", "Goal 3" = "#4C9F38", 
                 "Goal 4" = "#C5192D", "Goal 5" = "#FF3A21", "Goal 6" = "#26BDE2", 
                 "Goal 7" = "#FCC30B", "Goal 8" = "#A21942", "Goal 9" = "#FD6925",
                 "Goal 10" = "#DD1367", "Goal 11" = "#FD9D24", "Goal 12" = "#BF8B2E", 
                 "Goal 13" = "#3F7E44", "Goal 14" = "#0A97D9", "Goal 15" = "#56C02B",  
                 "Goal 16" = "#00689D", "Goal 17" = "#19486A")

corr_show <- corr %>%
  mutate(item1 = paste("Goal", item1), item2 = paste("Goal", item2))
chordDiagram(corr_show, grid.col = cbbPaletteR)

# Create a network diagram
cbbPaletteS <- c("1-No Poverty" = "#e5243b", "2-Zero Hunger" = "#DDA63A",
                 "3-Good Health and Well-Being" = "#4C9F38", "4-Quality Education" = "#C5192D", 
                 "5-Gender Equality" = "#FF3A21","6-Clean Water and Sanitation" = "#26BDE2", 
                 "7-Affordable and Clean Energy" = "#FCC30B","8-Decent Work and Economic Growth" = "#A21942", 
                 "9-Industry, Innovation and Infrastructure" = "#FD6925",
                 "10-Reduced Inequalities" = "#DD1367","11-Sustainable Cities and Communities" = "#FD9D24", 
                 "12-Responsible Consumption and Production" = "#BF8B2E", "13-Climate Action" = "#3F7E44", 
                 "14-Life Below Water" = "#0A97D9", "15-Life on Land" = "#56C02B",  
                 "16-Peace, Justice and Strong Institutions" = "#00689D","17-Partnerships for the Goals" = "#19486A")

labRs <- c("1-No Poverty", "2-Zero Hunger", "3-Good Health and Well-Being", 
           "4-Quality Education", "5-Gender Equality", "6-Clean Water and Sanitation", 
           "7-Affordable and Clean Energy", "8-Decent Work and Economic Growth", 
           "9-Industry, Innovation and Infrastructure", "10-Reduced Inequality", 
           "11-Sustainable Cities and Communities", "12-Responsible Consumption and Production", 
           "13-Climate Action", "14-Life Below Water", "15-Life on Land", 
           "16-Peace, Justice and Strong Institutions", "17-Partnerships for the Goals")

rSDG_nodes_v2 <- data.frame(name = labRs)
corr_degree <- tbl_graph(nodes = rSDG_nodes_v2, edges = corr) %>% 
  activate(nodes) %>%
  mutate( degree = centrality_degree() ) %>% 
  mutate( closeness = closeness(.G()) ) %>% 
  mutate( farness = 1 / closeness ) %>% 
  mutate( betweenness = betweenness(.G()) ) 

corr_graph <- tbl_graph(nodes = rSDG_nodes_v2, edges = corr) %>%
  activate(nodes) %>% 
  mutate(degree  = centrality_degree()) %>% 
  mutate(betweenness = betweenness(.G())) %>%
  ggraph(layout = "fr") +
  geom_edge_link(colour = "grey", aes(edge_alpha = correlation), width = 1.5, 
                 show.legend = FALSE) +
  geom_node_point(aes(size = degree, color = as.factor(name)), 
                  show.legend = F)+
  scale_color_manual(values=cbbPaletteS) +
  geom_node_text(aes(label = name), repel = TRUE, check_overlap = TRUE,
                 position = "jitter") +
  theme_void()

corr_graph
