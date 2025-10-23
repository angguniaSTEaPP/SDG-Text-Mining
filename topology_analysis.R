list.of.packages <- c("magrittr", "dplyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

tib_temp1 <- tibble(Country = c("Korea, Rep.", "Afghanistan", "Angola", "Congo, Dem. Rep.", 
                                "Mozambique", "Kenya", "Tanzania", "Madagascar", 
                                "Bangladesh", "Gambia, The", "Nigeria", "Benin", 
                                "Guinea", "Djibouti", "Togo", "Mauritania", "Burkina Faso", 
                                "South Sudan", "Central African Republic", "Niger", 
                                "Chad", "Mali", "Guinea-Bissau", "Papua New Guinea", 
                                "Malawi", "Sierra Leone", "Namibia", "Bosnia and Herzegovina", 
                                "Yemen, Rep.", "Georgia", "Sudan", "Liberia", "Pakistan", 
                                "South Africa", "Indonesia", "Nepal", "Tajikistan", 
                                "Somalia", "Syrian Arab Republic"))
tib_temp1 <- tib_temp1 %>% left_join(seq_o, by = 'Country')
tib_temp1 <- tib_temp1 %>% left_join(seq_p, by = 'Country')

tib_temp2 <- tibble(Country = c("Albania", "Lebanon", "United Arab Emirates", 
                                "Algeria", "North Macedonia", "India", "Malaysia", 
                                "Gabon", "Italy", "Bulgaria", "Uruguay", "Chile", 
                                "Israel", "Jamaica", "Thailand", "Mauritius", 
                                "Turkiye", "Iraq", "Jordan", "China", "Trinidad and Tobago", 
                                "Iran, Islamic Rep.", "Mongolia", "Egypt, Arab Rep.", 
                                "Japan", "Sweden", "Belize", "Suriname", "Guyana", 
                                "Morocco", "Sri Lanka", "Fiji", "Romania", "Greece", 
                                "Maldives", "Montenegro", "Serbia", "Portugal", 
                                "Russian Federation"))
tib_temp2 <- tib_temp2 %>% left_join(seq_o, by = 'Country')
tib_temp2 <- tib_temp2 %>% left_join(seq_p, by = 'Country')

tib_temp3 <- tibble(Country = c("Argentina", "Costa Rica", "Cabo Verde", "Tunisia", 
                                "Comoros", "Uzbekistan", "Turkmenistan", "Armenia", 
                                "Bhutan", "Vietnam", "Azerbaijan", "Kyrgyz Republic", 
                                "Belarus", "Moldova", "Colombia", "El Salvaldor", 
                                "Honduras", "Guatemala", "Nicaragua", "Ecuador", 
                                "Mexico"))
tib_temp3 <- tib_temp3 %>% left_join(seq_o, by = 'Country')
tib_temp3 <- tib_temp3 %>% left_join(seq_p, by = 'Country')

tib_temp4 <- tibble(Country = c("Australia", "Denmark", "United Kingdom", "Ireland", 
                                "Croatia", "Latvia","Lithuania","Cyprus", "Netherlands", 
                                "Slovenia","Czechia","Malta","Hungary","Kazakhstan",
                                "Poland","Austria","Belgium","Germany","Luxembourg",
                                "Canada", "Switzerland", "Iceland", "Norway", 
                                "Estonia", "Spain", "Finland", "United States", 
                                "France", "Slovak Republic"))
tib_temp4 <- tib_temp4 %>% left_join(seq_o, by = 'Country')
tib_temp4 <- tib_temp4 %>% left_join(seq_p, by = 'Country')

tib_temp5 <- tibble(Country = c("Botswana", "Eswatini", "Burundi", "Congo, Rep.", 
                                "Lesotho", "Zambia", "Rwanda", "Zimbabwe", "Brazil",
                                "Ghana", "Cameroon", "Lao PDR", "Paraguay", "Ethiopia",
                                "Uganda", "Philippines"))
tib_temp5 <- tib_temp5 %>% left_join(seq_o, by = 'Country')
tib_temp5 <- tib_temp5 %>% left_join(seq_p, by = 'Country')

tib_temp %>% group_by(Rank.17.y) %>% summarise(n = n())