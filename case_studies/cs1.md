## Study Guide

### Format

- In class on Wednesday, February 10. A guest proctor will run the session.
- Closed book and handwritten. You will not write any code.
- Seven questions (sub-components), each worth 2 points. About three sentences each is enough.
- Most questions give you R output, graphs or maps from a North Carolina dataset you have not seen before and ask you to interpret them.
- Covers Concepts 1 to 5. We will work through the practice questions below in pairs on the prep day, Friday, February 5.

### You Should Be Able To

1. Describe one model or law from the Quantitative Revolution, the discipline it came from, and one critique of it ([The Quantitative Revolution](reading-quantitative-revolution.qmd)).
2. Define spatial dependence and spatial non-stationarity, and explain why they make spatial data different ([Introduction to Space](reading-introduction-to-space.qmd)).
3. Describe central tendency, spread and shape from summary statistics and a histogram, and explain when the median is a better summary than the mean ([Describing Data reading](reading-describing-data.qmd), [Describing Data tutorial](describing_data.qmd)).
4. Explain how equal interval, quantile and natural breaks classes change what a choropleth map shows ([Describing Spatial Data reading](reading-describing-spatial-data.qmd), [Mapping with tmap](tmap.qmd)).
5. Interpret a weighted mean center and standard distance, and explain what they can hide ([Describing Spatial Data tutorial](describing_spatial_data.qmd)).
6. Explain what a binomial or normal probability means in context and name the assumptions behind it ([Probability reading](reading-probability.qmd), [Probability tutorial](probability.qmd)).
7. Interpret a confidence interval and explain how sample size changes it ([Sampling and Estimation](reading-sampling-and-estimation.qmd), [Central Limit Theorem](clt.qmd), [Estimation in Sampling](estimation_sampling.qmd)).

### How to Read the Output

**Summary statistics and histograms**

- A mean well above the median means right skew: a few high values pull the mean up.
- Skewness above 0 is right skewed and below 0 is left skewed. Values beyond about 1 or -1 are strongly skewed.
- The standard deviation is the typical distance from the mean, in the variable's units.

**Classification schemes**

- Equal interval: classes of equal width. Shows extreme places clearly, but skewed data can put most places in one or two classes.
- Quantile: the same number of places in each class. Shows rank, but can make small differences look large.
- Natural breaks: class breaks at gaps in the data.

**Centrography**

- Mean center: the average x and y location, or the balance point of the points.
- Weighted mean center: each location counts in proportion to a value such as population.
- Standard distance: how spread out locations are around the mean center, in distance units. Smaller means more concentrated.

**Probability**

- `dbinom(k, n, p)` is the probability of exactly k successes, `pbinom(k, n, p)` is k or fewer, and `1 - pbinom(k, n, p)` is more than k.
- `pnorm(x, mean, sd)` is the probability of a value at or below x.
- The binomial assumes a fixed number of trials, two outcomes, the same probability on every trial and independent trials.

**Confidence intervals**

- Estimate plus or minus (critical value × standard error), where the standard error is the standard deviation divided by the square root of n.
- "95%" describes the method: about 95% of intervals built this way would contain the true value.
- Four times the sample size gives half the standard error.

### Practice Questions

1. Explain how the gravity model reflects the scientific goals of the Quantitative Revolution. Then give one critique of it from a feminist perspective.
2. Here is the median age of North Carolina's 100 counties (ACS 2019 to 2023). Describe the center, spread and shape, and say whether the mean or the median better represents a typical county.

    ```
    > summary(nc_counties$median_age)
       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
       27.1    39.8    42.6    43.2    47.1    56.1 
    > sd(nc_counties$median_age)
    [1] 5.4
    ```

3. A map of median age uses quantile classes, and a classmate says, "Half of North Carolina's counties are very old." Explain how the classification scheme could lead to that reading.
4. Suppose the weighted mean center of North Carolina's population moved 12 miles east between 1990 and 2020, and the standard distance got smaller. Explain what these changes tell you, and suggest one process that could cause them.
5. Suppose the July high temperature at RDU is approximately normal with a mean of 90°F and a standard deviation of 3°F. Interpret this output, and explain whether a normal model is reasonable for the hottest days.

    ```
    > 1 - pnorm(95, mean = 90, sd = 3)
    [1] 0.0478
    ```

6. Suppose a sample of 25 census tracts gives a 95% confidence interval of 25.4% to 37.0% for the mean percent of households that rent. Interpret the interval, and explain what would happen to it with a sample of 100 tracts.
