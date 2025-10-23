list.of.packages <- c("readxl", "tidyr", "forcats", "ggplot2", "polyglotr", "magrittr",
                      "stringr", "stringi")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

directory <- "data/"
CountryData <- read_excel(paste0(directory,"CountryData.xlsx"), sheet = "CountryData") 

# Create a vector containing the names of the PDF files.
pdfs <- paste(directory,"/",list.files(directory, pattern = "*.pdf"), sep = "")
pdf_names <- list.files(directory, pattern = "*.pdf")

# Convert PDFs to text and store in a tibble.
pdfs_text <- map(pdfs, pdftools::pdf_text)
TextTibble <- tibble(filename = pdf_names, text = pdfs_text)
CountryDocs <- CountryData %>%
  inner_join(TextTibble, by = "filename") 

# Proces to detect language
mtdocs_tb <- CountryDocs %>% 
  group_by(Country) %>% 
  unnest(cols = c(text)) %>%
  select(code, id, Country, text) 

# Drop the empty texts
mtdocs_tb <- mtdocs_tb %>%
  filter(text!="")

# Detect language
mtdocs_tb <- mtdocs_tb %>%
  rowwise() %>%
  mutate(
    text_clean = iconv(clean_text(text), to = "UTF-8"),
    lang = tryCatch(language_detect(text_clean), error = function(e) NA)
  )

# Compare detected languages with document languages
check_lang <- mtdocs_tb %>% 
  group_by(Country) %>% 
  summarise(ln = paste(unique(lang), collapse = ', '))
compare_lang <- (CountryData %>% select(Country, lang) %>% left_join(check_lang))

# Confirm language for discrepancies between original and generated data
# Done manually by reviewing the documents