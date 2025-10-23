list.of.packages <- c("readxl", "polyglotr", "magrittr", "pdftools", "stringr", 
                      "purrr", "dplyr", "tidyr")
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

# Clean the URLs for translation
removeURL <- function(x) gsub("http[[:alnum:][:punct:]]*", "", x)

# Translation process 
mtdocs_nested <- CountryDocs %>% 
  group_by(Country) %>% 
  unnest(cols = c(text, lang)) %>%
  select(code, id, Country, lang, filename, text) 

mtdocs_nested <- mtdocs_nested %>%
  rowwise() %>%  
  mutate(
    translation = if (lang == "en") {
      text
    } else {
      toString(google_translate_long_text(
        removeURL(text), 
        target_language = "en", 
        source_language = "auto"
      ))
    }
  ) %>%
  ungroup()

# Save data to a CSV file for further processing
write.csv(mtdocs_nested, paste0(directory,"BindDevtDocs.csv"))

# Check translation per Country
collapsed_text <- morocco_translation %>%
  +     group_by(Country) %>%
  +     summarise(Text = paste(translation, collapse = ". "))
collapsed_text$Text
fileConn<-file("data/output.txt")
writeLines(collapsed_text$Text, fileConn)
close(fileConn)