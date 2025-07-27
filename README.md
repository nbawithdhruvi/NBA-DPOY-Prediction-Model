# NBA-DPOY-Prediction-Model
Over the past few weeks, I have been working on a data science project focused on predicting the NBA's Defensive Player of the Year (DPOY) using player and team-level statistics from 2000 to 2022. The idea was inspired by existing MVP prediction models, but I wanted to tackle a more defensive, less-publicized award where traditional box scores might not tell the full story.
What the Project Does
This project collects, cleans, merges, and models data from multiple sources to train a logistic regression model that tries to predict which player is most likely to win DPOY in a given season.
Here’s a high-level overview of the process:
 1. Data Collection & Cleaning
I gathered:
Player defensive stats like blocks, steals, Defensive Box Plus-Minus (DBPM), and Defensive Win Shares (DWS).


Team-level defensive stats (like opponent FG%, 3P%, 2P%) for context.


Basic per-game stats (like minutes, games played, rebounds, etc.)


I processed 23 seasons’ worth of data (2000–2022). I also had to handle name and team inconsistencies across files, especially tricky when franchises relocated or changed names (such as Charlotte Bobcats to Hornets, Seattle SuperSonics to OKC Thunder).
Then I manually labeled each season’s DPOY winner so the model could learn what patterns might lead to an actual award.
 2. Combining Player & Team Stats
I merged all the cleaned data into a single dataset that included both individual defensive performance and team defensive context. This allows the model to consider not just how well a player defends, but also how good their team was defensively that season.
 3. Training the Model
I trained a logistic regression model using a mix of:
Traditional box score stats: Games (G), Minutes (MP), Blocks (BLK), Steals (STL), Rebounds (TRB)


Advanced metrics: DWS, DBPM, BLK%, STL%
Team stats such as opponents' field goal percentage


The model outputs a probability for each player-season combo, which I then normalized within each season to rank the top candidates by predicted DPOY likelihood.
4. Results & Accuracy
So far, the model is doing reasonably well:
It correctly predicted 13 out of 23 DPOY winners when trained on all seasons from 2000 to 2022.


That’s just over a 56.5% accuracy, which is pretty solid for an award that factors in both narrative and defense.
However, I have noticed that accuracy drops significantly when I try to train the model on early seasons and predict the later ones.
Why the Accuracy Drops: Award Criteria May Have Shifted
One interesting insight is that the criteria for DPOY appear to have evolved over time.
In the early 2000s, the winners were almost exclusively big men, such as Ben Wallace, Dwight Howard, or Marcus Camby. These guys racked up blocks and dominated the paint.
But more recently, the award has shifted:
Kawhi Leonard, a perimeter wing, won twice.


Draymond Green, who defends every position, took it in 2017.


And Marcus Smart, a guard, won in 2022; the first guard to win in over 25 years.


This shift might explain why my model, which leans on traditional defensive metrics, does not fully capture modern DPOY dynamics. The model assumes that what made a great defender in 2003 is the same as in 2022, and that’s not always the case.


Predicting DPOY is not just about stats; it is about impact, narrative, and versatility, which numbers alone cannot always capture. But trying to quantify it has taught me a lot about both basketball and data science.
Thanks for reading! If you are into sports analytics or have ideas for how to improve the model, I would love to connect.
