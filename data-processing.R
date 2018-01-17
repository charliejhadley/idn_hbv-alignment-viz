hbv_sequence_data <- read_csv("data-raw/hbv-pol-data.csv")

hbv_pol <- read_csv("data-raw/2018-01-11_hbv_pol.csv")
hbv_s <- read_csv("data-raw/2018-01-11_hbv_s.csv")

colnames(hbv_pol)[11]

hbv_pol <- hbv_pol %>%
  mutate(position = `Baseline number`,
         sheet = "HBV Pol") %>%
  select(position, sheet, everything())

hbv_s <- hbv_s %>%
  mutate(position = `Baseline number`,
         sheet = "HBV S") %>%
  select(position, sheet, everything())

hbv_sequence_data <- hbv_pol %>%
  bind_rows(hbv_s)

sequence_region_colours <- tribble(
  ~label, ~colour, ~appears.in.hbv.pol, ~appears.in.hbv.s,
  "Reverse transcriptase" , "#ccfecc", TRUE, FALSE,
  "RNAse H" , "#f9fd74", TRUE, FALSE,
  "Spacer" , "#f4b084", TRUE, FALSE,
  "terminal protein" , "#bdd7ee", TRUE, FALSE,
  "Pre-S1" , "#fe6600", FALSE, TRUE,
  "Pre-S2" , "#00b0f0", FALSE, TRUE,
  "S" , "#a9d08e", FALSE, TRUE,
  "Mutation" , "#fc1111", TRUE, TRUE
)

hbv_table_data <- hbv_sequence_data %>%
  mutate(colour = plyr::mapvalues(label, from = names(sequence_region_colours),
                                  to = as.character(sequence_region_colours))) %>%
  select(-label)