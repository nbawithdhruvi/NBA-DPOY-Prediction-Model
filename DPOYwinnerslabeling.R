library(tidyverse)

# Define the years to load
years <- 2000:2022

# --- Player defensive stats ---

player_all_data <- map_dfr(years, function(yr) {
  file_name <- paste0("defensive_stats_", yr, ".csv")
  if (file.exists(file_name)) {
    read_csv(file_name, show_col_types = FALSE) %>%
      filter(G >= 45) %>%  # Filter out players with fewer than 45 games
      mutate(season = yr)
  } else {
    warning(paste("Missing player stats file:", file_name))
    NULL
  }
})

# Define DPOY winners for each season
dpoy_winners <- tribble(
  ~Player, ~season,
  "Alonzo Mourning", 2000,
  "Dikembe Mutombo", 2001,
  "Ben Wallace", 2002,
  "Ben Wallace", 2003,
  "Ron Artest", 2004,
  "Ben Wallace", 2005,
  "Ben Wallace", 2006,
  "Marcus Camby", 2007,
  "Kevin Garnett", 2008,
  "Dwight Howard", 2009,
  "Dwight Howard", 2010,
  "Dwight Howard", 2011,
  "Tyson Chandler", 2012,
  "Marc Gasol", 2013,
  "Joakim Noah", 2014,
  "Kawhi Leonard", 2015,
  "Kawhi Leonard", 2016,
  "Draymond Green", 2017,
  "Rudy Gobert", 2018,
  "Rudy Gobert", 2019,
  "Giannis Antetokounmpo", 2020,
  "Rudy Gobert", 2021,
  "Marcus Smart", 2022
)

# Label dpoy = 1 if player-season matches winner
player_all_data <- player_all_data %>%
  mutate(dpoy = if_else(paste(Player, season) %in% paste(dpoy_winners$Player, dpoy_winners$season), 1, 0))

# Select relevant columns and drop NA rows for modeling
player_clean <- player_all_data %>%
  select(Player, Team, season, G, MP, `STL%`, `BLK%`, DWS, DBPM, dpoy) %>%
  drop_na()

# --- Team defensive stats ---

team_all_data <- map_dfr(years, function(yr) {
  file_name <- paste0("team_defensive_stats_", yr, ".csv")
  if (file.exists(file_name)) {
    read_csv(file_name, show_col_types = FALSE) %>%
      mutate(season = yr) %>%
      # Rename % columns for clarity and easier join
      rename(
        FG_percent = `FG%`,
        ThreeP_percent = `3P%`,
        TwoP_percent = `2P%`
      )
  } else {
    warning(paste("Missing team stats file:", file_name))
    NULL
  }
})

# Optional: standardize Team names here if needed to match player dataset (e.g., abbreviations or full names)

# Save cleaned combined datasets
write_csv(player_clean, "all_defensive_data.csv")
write_csv(team_all_data, "team_defensive_stats_combined.csv")

# Glimpse data to verify
glimpse(player_clean)
glimpse(team_all_data)

