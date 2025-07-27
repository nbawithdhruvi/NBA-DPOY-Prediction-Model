library(tidyverse)

player_data <- read_csv("all_defensive_data.csv", show_col_types = FALSE)
team_data <- read_csv("team_defensive_stats_combined.csv", show_col_types = FALSE)

player_data <- player_data %>% mutate(season = as.integer(season))
team_data <- team_data %>% mutate(season = as.integer(season))

# Clean and standardize player team names
player_data <- player_data %>%
  mutate(
    Team = str_trim(gsub("\\*", "", Team)),  # Remove asterisks
    Team = case_when(
      Team == "San Antonio Spurs" ~ "SAS",
      Team == "Dallas Mavericks" ~ "DAL",
      Team == "Golden State Warriors" ~ "GSW",
      Team == "Los Angeles Lakers" ~ "LAL",
      Team == "Boston Celtics" ~ "BOS",
      Team == "Phoenix Suns" ~ "PHX",
      Team == "Miami Heat" ~ "MIA",
      Team == "New York Knicks" ~ "NYK",
      Team == "Toronto Raptors" ~ "TOR",
      Team == "Houston Rockets" ~ "HOU",
      Team == "Charlotte Hornets" & season < 2002 ~ "CHH",
      Team == "Charlotte Hornets" & season >= 2015 ~ "CHA",
      Team == "Charlotte Bobcats" ~ "CHA",
      Team == "Oklahoma City Thunder" ~ "OKC",
      Team == "Seattle SuperSonics" ~ "OKC",
      Team == "Utah Jazz" ~ "UTA",
      Team == "Minnesota Timberwolves" ~ "MIN",
      Team == "Portland Trail Blazers" ~ "POR",
      Team == "Detroit Pistons" ~ "DET",
      Team == "Indiana Pacers" ~ "IND",
      Team == "Cleveland Cavaliers" ~ "CLE",
      Team == "Milwaukee Bucks" ~ "MIL",
      Team == "Atlanta Hawks" ~ "ATL",
      Team == "Washington Wizards" ~ "WAS",
      Team == "New Orleans Hornets" & season <= 2013 ~ "NOP",
      Team == "New Orleans Pelicans" ~ "NOP",
      Team == "New Orleans/Oklahoma City Hornets" ~ "NOP",
      Team == "Sacramento Kings" ~ "SAC",
      Team == "Denver Nuggets" ~ "DEN",
      Team == "Los Angeles Clippers" ~ "LAC",
      Team == "Brooklyn Nets" ~ "BKN",
      Team == "New Jersey Nets" ~ "BKN",
      Team == "Chicago Bulls" ~ "CHI",
      Team == "Orlando Magic" ~ "ORL",
      Team == "Vancouver Grizzlies" ~ "MEM",
      Team == "Memphis Grizzlies" ~ "MEM",
      TRUE ~ Team
    )
  )

# Clean and standardize team_data team names
team_data <- team_data %>%
  mutate(
    Team = str_trim(gsub("\\*", "", Team)),
    Team = case_when(
      Team == "San Antonio Spurs" ~ "SAS",
      Team == "Dallas Mavericks" ~ "DAL",
      Team == "Golden State Warriors" ~ "GSW",
      Team == "Los Angeles Lakers" ~ "LAL",
      Team == "Boston Celtics" ~ "BOS",
      Team == "Phoenix Suns" ~ "PHX",
      Team == "Miami Heat" ~ "MIA",
      Team == "New York Knicks" ~ "NYK",
      Team == "Toronto Raptors" ~ "TOR",
      Team == "Houston Rockets" ~ "HOU",
      Team == "Charlotte Hornets" ~ "CHA",
      Team == "Charlotte Bobcats" ~ "CHA",
      Team == "Oklahoma City Thunder" ~ "OKC",
      Team == "Seattle SuperSonics" ~ "OKC",
      Team == "Utah Jazz" ~ "UTA",
      Team == "Minnesota Timberwolves" ~ "MIN",
      Team == "Portland Trail Blazers" ~ "POR",
      Team == "Detroit Pistons" ~ "DET",
      Team == "Indiana Pacers" ~ "IND",
      Team == "Cleveland Cavaliers" ~ "CLE",
      Team == "Milwaukee Bucks" ~ "MIL",
      Team == "Atlanta Hawks" ~ "ATL",
      Team == "Washington Wizards" ~ "WAS",
      Team == "New Orleans Hornets" ~ "NOH",
      Team == "New Orleans Pelicans" ~ "NOP",
      Team == "New Orleans/Oklahoma City Hornets" ~ "NOP",
      Team == "Sacramento Kings" ~ "SAC",
      Team == "Denver Nuggets" ~ "DEN",
      Team == "Los Angeles Clippers" ~ "LAC",
      Team == "Brooklyn Nets" ~ "BKN",
      Team == "New Jersey Nets" ~ "BKN",
      Team == "Chicago Bulls" ~ "CHI",
      Team == "Orlando Magic" ~ "ORL",
      Team == "Vancouver Grizzlies" ~ "VAN",
      Team == "Memphis Grizzlies" ~ "MEM",
      TRUE ~ Team
    )
  )

# Now join
combined_data <- player_data %>%
  left_join(team_data %>%
              select(Team, season, FG_percent, ThreeP_percent, TwoP_percent),
            by = c("Team", "season"))

cat("Rows before drop_na:", nrow(combined_data), "\n")

print(colSums(is.na(combined_data)))

combined_data_clean <- combined_data %>%
  filter(!is.na(dpoy)) %>%
  drop_na(G, MP, `STL%`, `BLK%`, DWS, DBPM)

cat("Rows after filtering dpoy and player stats:", nrow(combined_data_clean), "\n")

team_na_rows <- combined_data_clean %>%
  filter(is.na(FG_percent) | is.na(ThreeP_percent) | is.na(TwoP_percent)) %>%
  select(Team, season) %>%
  distinct()

print("Teams missing team stats after join:")
print(team_na_rows)

write_csv(combined_data_clean, "combined_player_team_data.csv")
