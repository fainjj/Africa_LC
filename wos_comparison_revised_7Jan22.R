#' Create two folders containing all of the subsets for each the original
#' records and the records with expanded search criteria. Place these both
#' in your Data folder.

if (!require(tidyverse)) { install.packages('tidyverse') }; require(tidyverse)
if (!require(data.table)) { install.packages('data.table') }; require(data.table)
if (!require(readxl)) { install.packages('readxl') }; require(readxl)
if (!require(here)) { install.packages('here') }; require(here)

# Compare Records Function ----
compare_records <- function(old_files_folder, new_files_folder, join_key) {

  read_many <- function(file_list) {
    map(file_list, read_xls) %>%
      rbindlist
  }

  old_recs <- read_many(list.files(here('Data/', old_files_folder),
                                   full.names = T,
                                   pattern = 'xls$'))

  new_recs <- read_many(list.files(here('Data/', new_files_folder),
                                   full.names = T,
                                   pattern = 'xls$'))

  non_match <- merge(anti_join(new_recs, old_recs, by=join_key),
                     anti_join(old_recs, new_recs, by=join_key),
                     by = join_key,
                     all=T)

  non_match
}

## Example 1 ----
# test <- compare_records('old_records', 'new_records', 'UT (Unique WOS ID)')



# Compare Decisions Function -----
compare_decisions <- function(decider_one_file,
                              decider_two_file,
                              outfile_folder) {

  initials <- c(d1_init = str_extract(decider_one_file %>%
                                        basename(),
                                      '[A-Z]{2}'),
                d2_init = str_extract(decider_two_file %>%
                                        basename(),
                                      '[A-Z]{2}'))

  initial_tag <- paste(initials["d1_init"], initials["d2_init"], sep='_')

  d1 <- read_excel(decider_one_file) %>%
    mutate(Decision = str_extract(Decision, '.') %>% tolower)

  d2 <- read_excel(decider_two_file) %>%
    mutate(Decision = str_extract(Decision, '.') %>% tolower)

  comparison_bools <- data.frame(agree_keep = (d1$Decision == 'y' & d2$Decision == 'y'),
                                 agree_drop = (d1$Decision == 'n' & d2$Decision == 'n') | (is.na(d1$Decision) & is.na(d2$Decision)),
                                 disagree = d1$Decision != d2$Decision)

  write_csv(filter(d1, comparison_bools$agree_keep),
            file = here(outfile_folder,
                        paste('records',
                              initial_tag,
                              'agree_keep.csv',
                              sep = '_')))

  write_csv(filter(d1, comparison_bools$agree_drop),
            file = here(outfile_folder,
                        paste('records',
                              initial_tag,
                              'agree_drop.csv',
                              sep = '_')))

  write_csv(filter(d1, comparison_bools$disagree),
            file = here(outfile_folder,
                        paste('records',
                              initial_tag,
                              'disagree.csv',
                              sep = '_')))
}

## Example 2 ----
# compare_decisions("/Volumes/Yggdrasil/Projects/Africa_LC/Data/decision_comp/Abstract_RA_471_705.xlsx",
#                   "/Volumes/Yggdrasil/Projects/Africa_LC/Data/decision_comp/Abstract_SL_471_705.xlsx",
#                   "/Volumes/Yggdrasil/Projects/Africa_LC/Outs/RA_SL")
