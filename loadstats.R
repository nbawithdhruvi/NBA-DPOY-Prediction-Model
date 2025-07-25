library(tidyverse)

# Load the combined player + team defensive stats dataset with DPOY label
dpoy_data <- read_csv("combined_player_team_data.csv", show_col_types = FALSE)

# Quick check of data structure and columns
glimpse(dpoy_data)

# Add .csv to all player stat files that are missing it
years <- 2000:2022

for (year in years) {
  old_name <- paste0("player_per_game_stats_", year)
  new_name <- paste0(old_name, ".csv")
  
  if (file.exists(old_name)) {
    file.rename(old_name, new_name)
  }
}

# Read and combine all CSV files
combined_stats <- map_dfr(years, function(year) {
  file_name <- paste0("player_per_game_stats_", year, ".csv")
  
  if (file.exists(file_name)) {
    read_csv(file_name, show_col_types = FALSE) %>%
      mutate(Season = year)  # Add a column to keep track of the season
  } else {
    warning(paste("Missing file:", file_name))
    NULL
  }
})

# Save the combined data to a new CSV file
write_csv(combined_stats, "player_per_game_stats_combined.csv")


# Load your original dataset
original_data <- read_csv("combined_player_team_data.csv", show_col_types = FALSE)
# Load combined per-game stats
player_per_game_stats_combined <- read_csv("player_per_game_stats_combined.csv", show_col_types = FALSE)

# For each Player + Season, keep the "2TM" row if it exists,
# otherwise keep the single-team row(s)

# First, separate 2TM and non-2TM rows
two_team_rows <- player_per_game_stats_combined %>%
  filter(Team == "2TM")

single_team_rows <- player_per_game_stats_combined %>%
  filter(Team != "2TM")

# Now keep all 2TM rows (one per player-season)
# For players without 2TM rows, keep their single-team rows

# Find player-season combos that have 2TM rows
players_with_2tm <- two_team_rows %>%
  distinct(Player, Season)

# Keep single-team rows only for players/seasons NOT in 2TM
single_team_no_2tm <- single_team_rows %>%
  anti_join(players_with_2tm, by = c("Player", "Season"))

# Combine the filtered data
player_stats_final <- bind_rows(two_team_rows, single_team_no_2tm)

# Load your original dataset
original_data <- read_csv("combined_player_team_data.csv", show_col_types = FALSE)

# Rename season if needed
original_data <- original_data %>%
  rename(Season = season)

# Merge datasets by Player and Season
merged_data <- original_data %>%
  left_join(player_stats_final, by = c("Player", "Season"))

# Save final merged dataset
write_csv(merged_data, "final_combined_player_data_clean.csv")
