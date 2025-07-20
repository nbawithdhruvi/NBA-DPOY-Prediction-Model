library(tidyverse)

# Load the combined player + team defensive stats dataset with DPOY label
dpoy_data <- read_csv("combined_player_team_data.csv", show_col_types = FALSE)

# Quick check of data structure and columns
glimpse(dpoy_data)
