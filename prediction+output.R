library(tidyverse)
library(gt)

# 1. Load and Prepare Data

df_all <- read_csv("combined_player_team_data.csv", show_col_types = FALSE)

# Make sure dpoy is numeric 0/1
df_all <- df_all %>%
  mutate(dpoy = as.numeric(dpoy))

# 2. Filter relevant variables for modeling

model_data <- df_all %>%
  select(Player, Team, season, dpoy, G, MP, `STL%`, `BLK%`, DWS, DBPM) %>%
  drop_na()

# 3. Fit logistic regression model (baseline)

dpoy_model <- glm(dpoy ~ G + MP + `STL%` + `BLK%` + DWS + DBPM,
                  data = model_data, family = binomial)

# 4. Predict probabilities and normalize within each season

model_data <- model_data %>%
  mutate(dpoy_prob = predict(dpoy_model, newdata = model_data, type = "response")) %>%
  group_by(season) %>%
  mutate(dpoy_prob_norm = dpoy_prob / sum(dpoy_prob) * 100) %>%
  ungroup()

# 5. Evaluate accuracy: how often the top predicted player won

accuracy_check <- model_data %>%
  group_by(season) %>%
  slice_max(dpoy_prob_norm, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  summarise(correct = sum(dpoy == 1),
            total = n(),
            accuracy = correct / total * 100)

cat("Model correctly predicted DPOY in", accuracy_check$correct, "of", accuracy_check$total, "seasons.\n")
cat("Overall Accuracy:", round(accuracy_check$accuracy, 1), "%\n")


# 6. Display top predictions for a specific year

show_dpoy_table_for_year <- function(year) {
  model_data %>%
    filter(season == year) %>%
    arrange(desc(dpoy_prob_norm)) %>%
    slice_head(n = 6) %>%
    select(Player, Team, season, dpoy_prob_norm, dpoy) %>%
    gt() %>%
    tab_header(
      title = paste("Top 6 DPOY Predictions for", year),
      subtitle = "By normalized predicted probability (sums to 100%)"
    ) %>%
    fmt_number(
      columns = dpoy_prob_norm,
      decimals = 1,
      suffix = "%"
    ) %>%
    cols_label(
      Player = "Player",
      Team = "Team",
      season = "Season",
      dpoy_prob_norm = "Predicted % Chance",
      dpoy = "Actual DPOY"
    ) %>%
    data_color(
      columns = dpoy_prob_norm,
      colors = scales::col_numeric(
        palette = c("white", "lightblue", "blue"),
        domain = c(0, 100)
      )
    ) %>%
    print()
}


# 7. Example: Show predictions for a given year

show_dpoy_table_for_year(2019)
