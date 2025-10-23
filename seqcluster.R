list.of.packages <- c("readxl", "magrittr", "dplyr", "TraMineR", "cluster",
                      "maptree", "dendextend")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

# MULTICHANNEL DENDOGRAM (NDPs and SDG Performance)
directory <- "data/"
MatrixofRanks <- read.table(paste0(directory,"MatrixofRanks.csv"), header=TRUE, sep = ",")
MatrixofSDRRanks <- read.table(paste0(directory,"MatrixofSDRRanks.csv"), header=TRUE, sep = ",")
MatrixofRanks <- MatrixofRanks %>% 
  inner_join(MatrixofSDRRanks %>% select(Country), by = c("Country" = "Country"))
MatrixofSDRRanks <- MatrixofSDRRanks %>% 
  inner_join(MatrixofRanks %>% select(Country), by = c("Country" = "Country"))

REGData <- read_excel(paste0(directory,"IncomeGroup.xlsx"), sheet = "List of economies") 
REGColumn <- MatrixofRanks %>%
  select(Country) %>%
  left_join(REGData %>% select(`Economy`, `Income group`), 
            by=c("Country"="Economy"))
labRs <- c("1-Poverty", "2-Hunger", "3-Health", "4-Education", 
           "5-Gender", "6-Sanitation", "7-Energy", "8-Economy", 
           "9-Industry", "10-Inequality", "11-Settlements", 
           "12-Consumption", "13-Climate", "14-Aquatic", 
           "15-Terrestrial", "16-Peace", "17-Partnerships")

seq_o <- as.data.frame(MatrixofRanks)
seq_p <- as.data.frame(MatrixofSDRRanks)

s.tf <- seqdef(seq_o, 3:19, labels=labRs, cpal=cbbPalette, right = NA)
s.sdr <- seqdef(seq_p, 3:19, labels=labRs, cpal=cbbPalette, right = NA)

cost.tf <- seqcost(s.tf, method="TRATE", with.missing=TRUE)
cost.sdr <- seqcost(s.sdr, method="TRATE", with.missing=TRUE)

# Create dendrogram combining NDPs and SDG scores
dissimc <- seqdistmc(list(s.tf,s.sdr), 
                     sm=list(cost.tf$sm, cost.sdr$sm),
                     with.missing=c(TRUE,TRUE),
                     what = "diss",
                     method = "OM",
                     indel = "auto")
agnesmc <- as.dist(dissimc) %>% agnes(method="ward", keep.diss=TRUE)
dendmc = as.dendrogram(agnesmc)
labdmc <- seq_o$Country[agnesmc$order]

# Determine optimal clusters
# Perform hierarchical clustering using KGS 
# Kelley-Gardner-Sutcliffe penalty for pruning hierarchical clusters
b <- kgs (agnesmc, agnesmc$diss, maxclust=20)
plot (names (b), b, xlab="# clusters", ylab="penalty")

nbcl <- 5
part <- cutree(agnesmc, nbcl)

Dintra <- integer(length=nbcl)
for(i in 1:nbcl) Dintra[i] <- round(mean(dissimc[part==i, part==i]),1)
dissassoc(dissimc, part)$groups

#Dendogram k=5
col_branch <- c("black", "grey", "black", "grey", "black")
clust.cutree <- dendextend:::cutree(dendmc, k=nbcl, order_clusters_as_data = FALSE)
df.merge <- merge(part,clust.cutree,by='row.names')
df.merge.sorted <- df.merge[order(df.merge$y),]
lbls<-unique(df.merge.sorted$x)

dmc <- as.dendrogram(agnesmc) %>% set_labels(labdmc) %>% set('labels_cex', 0.6) %>% 
  color_branches(k = nbcl, col = col_branch, groupLabels = lbls)

colors_to_use <- as.numeric(as.factor(REGColumn[,2]))
list_of_color <- c("#0e79b2", "#ca054d", "#90a959", "#e9b872")
colors_to_use <- list_of_color[colors_to_use]
colors_to_use <- colors_to_use[order.dendrogram(dmc)]
labels_colors(dmc) <- colors_to_use

par(mar = c(8,2,1,1))
{plot(dmc) 
  colored_bars(colors = colors_to_use, demd = dmc, y_shift = -50, rowLabels = "Income", sort_by_labels_order = FALSE) 
  legend("topleft",
         legend = c("High income","Upper middle income","Lower middle income","Low Income"), 
         fill = c("#0e79b2", "#e9b872", "#90a959", "#ca054d"), 
         pt.cex = 1, cex = 0.6 ,
         text.col = "black", horiz = FALSE, inset = c(0.025,0.025))}

# Typology per cluster
line = 1
cex = 1.5
side = 3
adj = -0.05

par(mfrow=c(3,nbcl), mar=c(2.5, 2.1, 2.1, 2.1), oma=c(1,6,1,1))
for(i in 1:nbcl) {
  if (i==1){
    seqdplot(s.tf[part==i,], xtlab=14:60, border=NA, with.legend=FALSE, main=paste('cluster',i))
    mtext("NDPs", side=side, line=line, cex=cex, adj=adj)
  } 
  else {seqdplot(s.tf[part==i,], xtlab=14:60, border=NA, with.legend=FALSE, main=paste('cluster',i))}
}

for(i in 1:nbcl) {
  if (i==1){
    seqdplot(s.sdr[part==i,], xtlab=1:17, border=NA, with.legend=FALSE)
    mtext("SDG Score", side=side, line=line, cex=cex, adj=adj)
  } 
  else {
    seqdplot(s.sdr[part==i,], xtlab=1:17, border=NA, with.legend=FALSE)
  }
}

seqlegend(s.tf, ncol = 2, cex=0.9)

# Print list of countries and their clusters
cl_frame <- as.data.frame(clust.cutree)
cd_frame <- cl_frame
cd_frame$X <- as.integer(row.names(cl_frame))
tb_clust <- seq_o %>% left_join(cd_frame, by='X') %>% left_join(seq_p, by='Country')
tb_clust <- tb_clust %>% 
  select(-X.x, -X.y) %>%
  rename_with(~ gsub("\\.x$", ".ndp", .), matches("^Rank\\.\\d+\\.x$")) %>%
  rename_with(~ gsub("\\.y$", ".sdr", .), matches("^Rank\\.\\d+\\.y$")) %>%
  rename(Cluster = clust.cutree) %>%
   relocate(Cluster, .after = Country)
write.csv(tb_clust, file = paste0(directory,"ClusterTb.csv"))
