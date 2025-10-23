list.of.packages <- c("tidyr", "forcats", "polyglotr", "dplyr", "purrr", 
                      "magrittr", "textclean", "text", "stringdist", "readxl")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

# Load preprocessed data
directory <- "data/"
BindDevtDocs <- read.table(paste0(directory,"BindDevtDocs.csv"), header=TRUE, quote="\"")
CountryData <- read_excel(paste0(directory,"CountryData.xlsx"), sheet = "CountryData") 

ndp_per_country <-  BindDevtDocs %>% 
  group_by(Country) %>%
  summarise(all_text = paste(text, collapse = ","),
            all_translation = paste(translation, collapse = ","))
ndp_per_country <- ndp_per_country %>%
  left_join(CountryData, by="Country") %>%
  select(Country, all_text, all_translation, confirm_lang)

clean_symbols <- function(text) {
  text <- as.character(text)
  text <- iconv(text, from = "", to = "UTF-8", sub = "")
  text <- gsub("(https?://\\S+|www\\.\\S+|[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}/\\S*)",
               " [URL] ", text, perl = TRUE)
  text <- gsub('[%*<>""]+', "", text, perl = TRUE)
  text <- gsub("\\s+", " ", text, perl = TRUE)
}

BackTranslatedTb <- ndp_per_country %>%
  mutate(clean_translation = clean_symbols(all_translation))
BackTranslatedTb <- BackTranslatedTb %>%
  rowwise() %>%
  mutate(back_translated_text = if(confirm_lang != "en"){
           google_translate_long_text(clean_translation, target_language = confirm_lang)}
         else {clean_translation})

# Back translation
BackTranslatedLast <- mtdocs %>%
  rowwise() %>%
  mutate(back_translated_text = if(confirm_lang != "en"){
    google_translate_long_text(translation, target_language = confirm_lang)}
    else {translation})

BackTranslatedTb <- BindDevtDocs %>% 
  left_join(ndp_per_country, by = join_by(Country == Country)) %>%
  select(Country, text, translation, confirm_lang) 

BackTranslatedTb <- BackTranslatedTb %>%
  mutate(
    lang = sub("-.*$", "", lang),
    lang = ifelse(lang %in% google_supported_languages$`ISO-639 code`, lang, "en")
  )

BackTranslatedTb <- BackTranslatedTb %>%
  rowwise() %>%
  mutate(
    back_translated_text = if (is.na(confirm_lang) | confirm_lang=='en') {
      translation
    } else {
      google_translate(translation, target = confirm_lang)
    }
  ) %>%
  ungroup()

write.table(BackTranslatedTb, file = paste0(directory,"BackTranslatedTb.csv"))
BackTranslatedTb <- read.table(paste0(directory,"BackTranslatedTb.csv"), header=TRUE, quote="\"")

# Check similarity
BackTranslatedTb <- BackTranslatedTb %>%
  mutate(similarity = 1 - stringdist(all_text, back_translated_text, method="jaccard"))

SimilarityTb <- BackTranslatedTb %>%
  select(Country, similarity) %>%
  group_by(Country) %>%
  summarise(Similarity = mean(similarity))

write.csv(SimilarityTb, file = paste0(directory,"SimilarityTb.csv"))

comparison <- SimilarityTb %>% 
  left_join(CountryData) %>% 
  select(Country,confirm_lang, Similarity)
comparison_nonen <- comparison %>% filter(confirm_lang != "en")
comparison_nonen <- comparison_nonen %>% 
  group_by(confirm_lang) %>% 
  summarise(mean_similarity = mean(Similarity))
comparison_nonen %>% summarise(mean_similarity = mean(Similarity))
write.csv(comparison_nonen, file = paste0(directory,"ComparisonNonEn.csv"))
