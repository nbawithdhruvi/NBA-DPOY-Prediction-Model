library(tidyverse)
library(gt)

# ----------------------
# 1. Load and Prepare Data
# ----------------------

df_all <- read_csv("final_combined_player_data_clean.csv", show_col_types = FALSE)

# ----------------------
# 2. Train Logistic Regression Model on All Seasons
# ----------------------

dpoy_model <- glm(dpoy ~ G.x + MP.x + `BLK%` + DWS + DBPM + BLK + STL + DRB,
                  data = df_all, family = binomial)

# ----------------------
# 3. Predict and Normalize per Season
# ----------------------

df_all <- df_all %>%
  mutate(dpoy_prob = predict(dpoy_model, newdata = df_all, type = "response")) %>%
  group_by(Season) %>%
  mutate(dpoy_prob_norm = dpoy_prob / sum(dpoy_prob) * 100) %>%
  arrange(desc(dpoy_prob_norm)) %>%
  mutate(rank = row_number()) %>%
  ungroup()

# ----------------------
# 4. Evaluate Accuracy Across All Seasons
# ----------------------

accuracy_check <- df_all %>%
  group_by(Season) %>%
  slice_max(dpoy_prob_norm, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  summarise(correct = sum(dpoy == 1),
            total = n(),
            accuracy = correct / total * 100)

cat("✅ Model correctly predicted DPOY in", accuracy_check$correct, "of", accuracy_check$total, "seasons.\n")
cat("🎯 Accuracy:", round(accuracy_check$accuracy, 1), "%\n")

# ----------------------
# 5. View Predictions for a Specific Year
# ----------------------

show_dpoy_table_for_year <- function(year) {
  df_all %>%
    filter(Season == year) %>%
    arrange(desc(dpoy_prob_norm)) %>%
    slice_head(n = 6) %>%
    select(Player, Team.x, Season, dpoy_prob_norm, dpoy) %>%
    gt() %>%
    tab_header(
      title = paste("Top 6 DPOY Predictions for", year),
      subtitle = "Model trained on all seasons"
    ) %>%
    fmt_number(columns = dpoy_prob_norm, decimals = 1, suffix = "%") %>%
    cols_label(
      Player = "Player",
      Team.x = "Team",
      Season = "Season",
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

# ----------------------
# 6. Example Usage
# ----------------------

show_dpoy_table_for_year(2020)
