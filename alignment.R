list.of.packages <- c("ggplot2", "magrittr", "dplyr", "readxl",
                      "TraMineR", "TraMineRextras")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

directory <- "data/"

# Load preprocessed data
MatrixofRanks <- read.table(paste0(directory,"MatrixofRanks.csv"), header=TRUE, sep = ",")
MatrixofSDRRanks <- read.table(paste0(directory,"MatrixofSDRRanks.csv"), header=TRUE, sep = ",")
MatrixofRanks <- MatrixofRanks %>% 
  inner_join(MatrixofSDRRanks %>% select(Country), by = c("Country" = "Country"))
MatrixofSDRRanks <- MatrixofSDRRanks %>% 
  inner_join(MatrixofRanks %>% select(Country), by = c("Country" = "Country"))
SDRscore <- read.table(paste0(directory,"SDRscore.csv"), header=TRUE, sep = ",")

REGData <- read_excel(paste0(directory,"IncomeGroup.xlsx"), sheet = "List of economies") 
REGColumn <- MatrixofRanks %>%
  select(Country) %>%
  left_join(REGData %>% select(`Economy`, `Income group`), 
            by=c("Country"="Economy"))

seq_o <- as.data.frame(MatrixofRanks)
seq_p <- as.data.frame(MatrixofSDRRanks)

seq_op <- bind_rows(seq_o, seq_p)
s.two <- seqdef(seq_op, 3:19, labels=labRs, cpal=cbbPalette, right = NA)
costsa <- seqcost(s.two, method="TRATE", with.missing = TRUE)

# Compute optimal matching (OM) distance for a single country (closest and farthest)
sa1 <- seqalign(s.two, c(94,94+144), indel=1, sm=costsa$sm, with.missing = TRUE) #Morocco
sa2 <- seqalign(s.two, c(56,56+144), indel=1, sm=costsa$sm, with.missing = TRUE) #Guinea-Bissau

print(sa1)
print(sa2)
par(mar=c(2,3,2,1) + 0.1)
plot(sa1)
plot(sa2)

# Calculate OM distances across all countries
set1 <- 1:144
set2 <- 145:288
sa <- seqdist(s.two, method = "OM", refseq = list(set1, set2), 
              with.missing = TRUE, sm=costsa$sm)
diagsa <- diag(sa)
c <- bind_cols(seq_o%>%select(Country), diagsa)
colnames(c) <- c("Country", "Distance")

# Plot alignment between OM distance and SDG scores
c <- c %>% inner_join(SDRscore, by = c("Country" = "Country")) %>%
  left_join (REGData, by=c("Country"="Economy")) %>%
  select(code, Country, Distance, sdgScore, `Income group`)
xdistance <- (max(c$Distance)-min(c$Distance))/2+min(c$Distance)
ysdgscore <- (max(c$sdgScore)-min(c$sdgScore))/2+min(c$sdgScore)

reglab <- data.frame(
  x   =c(16.25, 16.25, 26.25, 26.25),
  y   =c(80, 45, 80, 45),
  lab =as.roman(1:4)
)

c$`Income group` <- factor(c$`Income group`, 
                           levels = c("High income", "Upper middle income", 
                                      "Lower middle income", "Low income"))

cplot <- ggplot(c, aes(x=Distance, y=sdgScore, colour = `Income group`)) + 
  geom_point() + 
  scale_color_manual(values = c("#0e79b2", "#68993D", "#C89F10", "#ca054d")) +
  geom_label(
    data=c,
    aes(label=code)) +
  geom_vline(
    xintercept = xdistance, color = "black",
    linetype = "dashed", linewidth = 0.5
  ) +
  geom_hline(
    yintercept = ysdgscore, color = "black",
    linetype = "dashed", linewidth = 0.5
  ) +
  labs(x = "Alignment between NDP and SDG Score (Distance)",
       y = "SDG Score")

cplot +  
  geom_text(
    data=reglab, aes( x=x, y=y, label=lab),
    size = 7.5,
    color = 'black',
    show.legend = FALSE
  )
