list.of.packages <- c("magrittr", "dplyr", "TraMineR", "cluster", "dendextend")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

# DENDOGRAM of SEQUENCE -- Tanglegram
directory <- "data/"
MatrixofRanks <- read.table(paste0(directory,"MatrixofRanks.csv"), header=TRUE, sep = ",")
MatrixofSDRRanks <- read.table(paste0(directory,"MatrixofSDRRanks.csv"), header=TRUE, sep = ",")
MatrixofRanks <- MatrixofRanks %>% 
  inner_join(MatrixofSDRRanks %>% select(Country), by = c("Country" = "Country"))
MatrixofSDRRanks <- MatrixofSDRRanks %>% 
  inner_join(MatrixofRanks %>% select(Country), by = c("Country" = "Country"))

seq_o <- as.data.frame(MatrixofRanks)
labRs <- c("1-Poverty", "2-Hunger", "3-Health", "4-Education", 
           "5-Gender", "6-Sanitation", "7-Energy", "8-Economy", 
           "9-Industry", "10-Inequality", "11-Settlements", 
           "12-Consumption", "13-Climate", "14-Aquatic", 
           "15-Terrestrial", "16-Peace", "17-Partnerships")
seqMat <- seqdef(seq_o, 3:19, labels=labRs, cpal=cbbPalette, right = NA)
dissim1 <- seqdist(seqMat, method="EUCLID", with.missing = TRUE)
agnes1 <- as.dist(dissim1) %>% agnes(method="ward", keep.diss=FALSE)
# Dendogram single
dend1 = as.dendrogram(agnes1)
labd1 <- seq_o$Country[agnes1$order]
d1 <- as.dendrogram(agnes1) %>% set_labels(labd1) %>% set('labels_cex', 0.6) %>% 
  color_branches(5, groupLabels = as.character,
                 col = c("skyblue3", "orange2", "grey60", "darkorchid1", "darkolivegreen4"))

# then do the SDG Score (SDR)
seq_p <- as.data.frame(MatrixofSDRRanks)
seqMatp <- seqdef(seq_p, 3:19, labels=labRs, cpal=cbbPalette, right = NA)
dissim2 <- seqdist(seqMatp, method="EUCLID")
agnes2 <- as.dist(dissim2) %>% agnes(method="ward", keep.diss=FALSE)
# Dendogram single
dend2 = as.dendrogram(agnes2)
labd2 <- seq_p$Country[agnes2$order]
d2 <- as.dendrogram(agnes2) %>% set_labels(labd2) %>% set('labels_cex', 0.6) %>% 
  color_branches(5, groupLabels = as.roman, 
                 col = c("skyblue3", "orange2", "grey60", "darkorchid1", "darkolivegreen4")) 

# Tanglegram
dl <- dendlist(
  d1 %>% 
    set("labels_col", value = c("skyblue3", "orange2", "grey60", "darkorchid1", "darkolivegreen4"), k=5) %>%
    set("branches_lty", 1),
  d2 %>% 
    set("labels_col", value = c("skyblue3", "orange2", "grey60","darkorchid1", "darkolivegreen4"), k=5) %>%
    set("branches_lty", 1) 
)
edl <- entanglement(dl)
dl %>% 
  tanglegram(common_subtrees_color_lines = FALSE, 
             highlight_distinct_edges  = TRUE, 
             highlight_branches_lwd=FALSE, 
             margin_inner=7.5,
             lwd=1,
             cex_main_left = 1,
             cex_main = 1,
             main_left = "NDPs",
             main_right = "SDG Performance",
             main = paste("Entanglement =",round(edl,2)))

all.equal(d1, d2)
