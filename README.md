# Mixed Martial Arts Analysis
An SQL analysis of the sport of modern MMA(2010-2024), with a focus on art prevalance and fight outcome trends.

## Introduction
This project is an in-depth analysis of UFC fight data aimed at uncovering key trends in fighter performance and
martial art prevalence. The dataset spans from 2010 onward and includes over 100 variables ranging from fighter attributes
(e.g., age, height, reach, stance) to fight-specific details (e.g., odds, finishing techniques, fight duration, win streaks).
The goal is to transform this messy and complex dataset into actionable insights that can benefit industry professionals,
coaches, fighters, and fans alike.

## Motivation and Objective
Understanding the various factors that contribute to the success in MMA requires more than just win/loss records. I started this project to answer several critical questions:

Finish Techniques: Which finishing techniques are most prevalent in different weight classes, and how do they influence outcomes?

Fighter Attributes: How do fighter characteristics (age, reach, height, stance) correlate with performance metrics like win streaks and fight outcomes?

Performance Trends: What patterns can be observed in fighter performance before and after losses?

Odds vs. Outcome: How accurate are pre-fight odds in predicting the actual outcomes, and what does this tell us about fighter performance?

By answering these questions, the project aims to provide a data-driven perspective on fighter success and strategic trends in the UFC.

## Approach
### Data Cleaning and Structuring (SQL)
Challenges: The raw dataset was highly unstructured with inconsistent entries, especially for fighter roles (appearing as either "RedFighter" or "BlueFighter") and free-text fields like "FinishDetails."
Techniques:
Advanced SQL Queries: Used Common Table Expressions (CTEs), window functions (e.g., ROW_NUMBER, LAG, LEAD), and conditional aggregations to clean and restructure the data.
Derived Metrics: Computed new fields such as “Most Recent Loss Date,” “Next Fight Outcome,” and various differential statistics (e.g., age difference, height difference) to facilitate deeper analysis.
### Data Visualization (Tableau)
Integration: Cleaned and structured data was exported to Tableau for visualization.
Dashboards:
Created interactive dashboards to explore trends such as finish type distributions across weight classes, fighter performance over time, and correlations between fighter attributes and outcomes.
Utilized built-in measures like “Number of Records” (equivalent to SQL’s COUNT(*)) to represent aggregated data visually.

## Results and Insights
Some of the notable findings include:

Finish Type Trends: Certain weight classes show a clear preference for specific finishing techniques (e.g., KO/TKO in heavier divisions and submissions in lighter divisions).

Fighter Attributes: There is a complex relationship between fighter attributes such as age and reach with fight outcomes, suggesting that physical advantages are nuanced by other factors like technique and strategy.

Performance Post-Loss: Analysis of win streaks and recovery times after losses revealed that fighters who return quickly after a loss tend to maintain higher overall success rates.

Odds Discrepancies: The integration of betting odds with fight outcomes highlighted discrepancies that may inform better predictive models and betting strategies.
## Conclusion
This project demonstrates the power of combining SQL, and Tableau to extract actionable insights from a complex and messy dataset.
The work not only enhanced my technical skills in data cleaning, visualization, and analysis but also provided valuable insights into the
strategic aspects of MMA fights.
