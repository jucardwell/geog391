## Study Guide

### Format

- In class on Wednesday, February 10. A guest proctor will run the session.
- Closed book and handwritten. You will not write any code.
- Eight questions (sub-components), each worth 2 points.
- Most questions give you R output, graphs or maps from a North Carolina dataset you have not seen before and ask you to interpret them.

### You Should Be Able To

1. Describe the eras of geography and the Quantitative Revolution, explain an early law or model (Tobler's First Law, the gravity model, central place theory), and give a critique of it ([The Quantitative Revolution](reading-quantitative-revolution.qmd)).
2. Define spatial dependence and spatial non-stationarity, explain why they make spatial data different, and describe data sources, vector data and raster data ([Introduction to Space](reading-introduction-to-space.qmd)).
3. Identify the level of measurement of a variable (nominal, ordinal, interval, ratio) and describe central tendency, spread and shape from summary statistics, a histogram or a box plot ([Describing Data reading](reading-describing-data.qmd), [Describing Data tutorial](describing_data.qmd)).
4. Explain the modifiable areal unit problem and how the scale and zoning of units can change a result ([Describing Data reading](reading-describing-data.qmd)).
5. Explain how visual variables and equal interval, quantile and natural breaks classes change what a choropleth map shows, and how maps can mislead ([Describing Spatial Data reading](reading-describing-spatial-data.qmd), [Mapping with tmap](tmap.qmd)).
6. Interpret a mean center, weighted mean center, standard distance and standard deviational ellipse, and compare them between groups ([Describing Spatial Data tutorial](describing_spatial_data.qmd)).
7. Explain what a binomial or normal probability means in context, compare a model probability with an empirical one, and name the assumptions behind the model ([Probability reading](reading-probability.qmd), [Probability tutorial](probability.qmd)).
8. Compare sampling designs (simple random, systematic, stratified, cluster and spatial), explain the Central Limit Theorem, and interpret a confidence interval and how sample size changes it ([Sampling and Estimation](reading-sampling-and-estimation.qmd), [Central Limit Theorem](clt.qmd), [Estimation in Sampling](estimation_sampling.qmd)).

### How to Read the Output

**Levels of measurement**

- Nominal: categories with no order (land cover type). Ordinal: ordered categories (low, medium, high).
- Interval: equal steps but no true zero (temperature in °F). Ratio: equal steps and a true zero (percent, income, distance).
- The level of measurement limits which summaries make sense. A mean of a nominal variable means nothing.

**Summary statistics, histograms and box plots**

- `summary()` gives the minimum, first quartile, median, mean, third quartile and maximum.
- A mean well above the median means right skew: a few high values pull the mean up. A mean below the median means left skew.
- Skewness above 0 is right skewed and below 0 is left skewed. Values beyond about 1 or -1 are strongly skewed.
- The standard deviation is the typical distance from the mean, in the variable's units. The interquartile range (Q3 minus Q1) is the spread of the middle half.
- In a box plot, the line is the median, the box runs from Q1 to Q3, and points beyond the whiskers are outliers (more than 1.5 IQR from the box).
- Read the vertical lines on a histogram to compare the mean and the median directly.

**Classification schemes**

- Equal interval: classes of equal width. Shows extreme places clearly, but skewed data can put most places in one or two classes.
- Quantile: the same number of places in each class. Shows rank, but can make small differences look large and put very different values in one class.
- Natural breaks (Jenks): class breaks at gaps in the data.
- Always read the legend. The same data can look concentrated or widespread depending on the breaks.

**Centrography**

- Mean center: the average x and y location, or the balance point of the points.
- Weighted mean center: each location counts in proportion to a value such as population.
- Standard distance: how spread out locations are around the mean center, in distance units. Smaller means more concentrated.
- Standard deviational ellipse: shows spread in two directions. The long axis points in the direction of greatest spread, and a long, thin ellipse means a directional pattern.
- A mean center can fall where few people live, and a single large concentration can pull it far from everywhere else. Look at the map of the points too.

**Probability**

- `dbinom(k, n, p)` is the probability of exactly k successes, `pbinom(k, n, p)` is k or fewer, and `1 - pbinom(k, n, p)` is more than k.
- `pnorm(x, mean, sd)` is the probability of a value at or below x, and `1 - pnorm(x, mean, sd)` is above x.
- The binomial assumes a fixed number of trials, two outcomes, the same probability on every trial and independent trials.
- An empirical probability is the share of times something actually happened. If it is far from the model's probability, one of the model's assumptions probably fails.

**Sampling and confidence intervals**

- Stratified sampling guarantees each group is represented. Systematic and spatial samples spread points evenly across space.
- Central Limit Theorem: the means of many samples are close to normally distributed around the true mean, with a standard error of the standard deviation divided by the square root of n.
- Confidence interval: estimate plus or minus (critical value × standard error).
- "95%" describes the method: about 95% of intervals built this way would contain the true value. It is not a 95% chance for one interval.
- Four times the sample size gives half the standard error and an interval about half as wide.

### Practice Questions

1. Explain how the gravity model reflects the scientific goals of the Quantitative Revolution. Then give one critique of it from a feminist or humanist perspective.
2. Name the level of measurement of each variable: county name, rurality class (rural, suburban, urban), July temperature in °F and percent of residents over 65.
3. Here is the median age of North Carolina's 100 counties (ACS 2019 to 2023). Describe the center, spread and shape.

    ```
    > summary(nc_counties$median_age)
       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
       27.1    39.8    42.6    43.2    47.1    56.1 
    > sd(nc_counties$median_age)
    [1] 5.4
    ```

4. A map of median age uses quantile classes, and a classmate says, "Half of North Carolina's counties are very old." Explain how the classification scheme could lead to that reading.
5. Suppose the weighted mean center of North Carolina's population moved 12 miles east between 1990 and 2020, the standard distance got smaller, and the standard deviational ellipse became longer from southwest to northeast. Explain what these changes tell you, and suggest one process that could cause them.
6. Suppose a study finds that income and asthma rates are strongly related across counties but only weakly related across census tracts. Explain how the modifiable areal unit problem could cause this.
7. Suppose the July high temperature at RDU is approximately normal with a mean of 90°F and a standard deviation of 3°F. Interpret this output, and explain whether a normal model is reasonable for the hottest days.

    ```
    > 1 - pnorm(95, mean = 90, sd = 3)
    [1] 0.0478
    ```

8. Suppose a sample of 25 census tracts gives a 95% confidence interval of 25.4% to 37.0% for the mean percent of households that rent. Interpret the interval, explain what would happen to it with a sample of 100 tracts, and explain when a stratified sample would be better than a simple random sample.
