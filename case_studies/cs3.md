## Study Guide

### Format

- In class on Friday, April 9. A guest proctor will run the session.
- Closed book and handwritten. You will not write any code.
- Eight questions, each worth 2 points.
- Most questions give you R output and maps from a dataset you have not seen before and ask you to interpret them.

### You Should Be Able To

1. Explain contiguity (queen and rook), distance band and k-nearest neighbor definitions, read a neighbor summary, and choose a definition that fits a process ([Spatial Modeling reading](reading-spatial-modeling.qmd), [Spatial Autocorrelation tutorial](autocorrelation.qmd)).
2. Explain what row standardization does and what a spatial lag (the average of a place's neighbors) is.
3. Interpret global Moran's I, its p-value and a Moran scatterplot.
4. Interpret a LISA cluster map, including High-High and Low-Low clusters and High-Low and Low-High outliers, and propose a process.
5. Interpret an OLS model: coefficients, significance, R-squared and the F-test ([Regression and Spatial Regression tutorial](regression.qmd)).
6. Use a residual map and Moran's I on the residuals to decide whether a spatial model is needed.
7. Choose between a spatial lag model and a spatial error model based on a process, interpret rho or lambda, and compare the model with OLS using coefficients, AIC and RMSE.
8. Explain the ecological fallacy and the modifiable areal unit problem for area-based models, and why correlation is not causation.

### How to Read the Output

**Neighbors and weights**

- Queen contiguity: places that share a border or a single corner. Rook: places that share a border.
- Distance band: every place within a set distance. K-nearest: a fixed number of neighbors, common for points and for places with very uneven sizes.
- `summary(nb)` lists the number of regions, the average number of links, and the least and most connected regions. Places on the edge of the study area have fewer neighbors (edge effects).
- Row standardization (`style = "W"`) makes each place's weights sum to 1, so the spatial lag is the average of its neighbors.
- The definition should match the process you think shapes the pattern.

**Moran's I**

- p-value: can we reject spatial randomness (values arranged at random across the places)? The I value: how strong the pattern is.
- The expected value under randomness is close to 0 (-1 / (n - 1)). Near 1 is strong clustering of similar values, about -0.15 to 0.15 is essentially random, and negative values mean neighbors tend to be different (dispersion).
- Moran scatterplot: each place's value on the x axis against the average of its neighbors on the y axis. The slope of the line is Moran's I. Points in the upper right and lower left fit clustering; points in the other two quadrants are possible outliers.

**LISA**

- A local Moran's I for each place, tested by permutation, mapped only where significant.
- High-High and Low-Low are clusters of similar values. High-Low and Low-High are outliers that differ from their neighbors.
- Many local tests are run at once, so a few significant places will appear by chance.

**OLS**

- Coefficient: the change in the outcome for a one-unit increase in a predictor, holding the others constant. Check its sign, size and p-value.
- R-squared: the share of variation in the outcome that the model explains. Adjusted R-squared penalizes extra predictors.
- F-test: whether the model as a whole explains more than no predictors at all.
- Assumptions include a linear relationship and independent errors. A residual map and Moran's I on the residuals check the second.
- Clustered residuals mean the model is missing something spatial, and its standard errors and p-values cannot be trusted.

**Spatial lag and spatial error models**

- Lag model: the outcome in one place depends on the outcome in neighboring places (spillover, diffusion). Rho is the strength of that dependence.
- Error model: an unmeasured, spatially patterned factor sits in the errors. Lambda is the strength of that dependence.
- Choose based on the process, not only on which fits best.
- Compare with OLS: AIC (lower is better), RMSE (lower is better, in the outcome's units) and how the coefficients change. A coefficient that shrinks was partly picking up the spatial pattern.

**Scale and inference**

- Ecological fallacy: a relationship among places does not have to hold for the individuals in them.
- MAUP: results can change with the size (scale) and boundaries (zoning) of the units.

### Practice Questions

1. A study of county broadband access uses queen contiguity. Explain why Dare County, on the Outer Banks, might have very few neighbors, and suggest a neighbor definition that could work better for a coastal county.
2. Suppose Moran's I for county median rent is 0.41 (p < 0.001), and the LISA map shows a High-High cluster around the Triangle and one Low-High county next to it. Interpret all three results and suggest a process.
3. On a Moran scatterplot, most counties fall in the upper right and lower left quadrants, but Mecklenburg is far to the right with a neighbor average near the state mean. Explain what this means.
4. Suppose an OLS model of county obesity rate has a coefficient of -0.35 (p = 0.003) for percent with a bachelor's degree and an R-squared of 0.42. Interpret both.
5. Moran's I on the residuals of that model is 0.28 (p < 0.001). Explain what this means and what you would do next.
6. Describe a process for which a spatial lag model makes more sense than a spatial error model, and one for which the error model makes more sense.
7. Suppose a spatial error model of obesity has lambda = 0.52 (p < 0.001), an AIC of 540 compared with 571 for OLS, and a bachelor's degree coefficient of -0.21. Interpret these results.
8. A reporter writes, "People with college degrees are less likely to be obese," based on the county model. Explain the ecological fallacy here, and how the result might change with census tracts.
