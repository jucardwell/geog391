## Study Guide

### Format

- In class on Friday, April 9. A guest proctor will run the session.
- Closed book and handwritten. You will not write any code.
- Seven questions (sub-components), each worth 2 points. About three sentences each is enough.
- Most questions give you R output and maps from a dataset you have not seen before and ask you to interpret them.
- Covers Concepts 8 and 9, geographically weighted regression and geodemographic clustering. We will work through the practice questions below in pairs on the prep day, Wednesday, April 7.

### You Should Be Able To

1. Explain contiguity, distance and k-nearest neighbor definitions, and choose one that fits a process ([Spatial Modeling reading](reading-spatial-modeling.qmd), [Spatial Autocorrelation tutorial](autocorrelation.qmd)).
2. Interpret global Moran's I and a LISA cluster map.
3. Interpret an OLS model: coefficients, significance and R-squared ([Regression and Spatial Regression tutorial](regression.qmd)).
4. Use a residual map and Moran's I on the residuals to decide whether a spatial model is needed.
5. Choose between a spatial lag model and a spatial error model based on a process, and compare it with OLS.
6. Interpret a GWR coefficient map, the bandwidth and an AICc comparison ([Beyond One Model](reading-beyond-one-model.qmd)).
7. Explain standardization and the choice of k in k-means, name clusters from a profile table, and name the cautions of geodemographic labels ([Beyond One Model](reading-beyond-one-model.qmd)).

### How to Read the Output

**Neighborhoods**

- Contiguity: queen (shares a border or corner) or rook (shares a border).
- Distance: everything within a set distance. K-nearest: a fixed number of neighbors, common for points.
- The definition should match the process you think shapes the pattern.

**Moran's I and LISA**

- p-value: can we reject spatial randomness? The I value: how strong the pattern is.
- Near 1 is strong clustering, about -0.15 to 0.15 is essentially random, and negative values are dispersion.
- LISA: High-High and Low-Low are clusters of similar values. High-Low and Low-High are outliers that differ from their neighbors.

**OLS**

- Coefficient: the change in the outcome for a one-unit increase in a predictor, holding the others constant. Check its sign, size and p-value.
- R-squared: the share of variation in the outcome that the model explains.
- Moran's I on the residuals: clustered residuals mean the model is missing something spatial, and its p-values cannot be trusted.

**Spatial lag and spatial error models**

- Lag model: the outcome in one place depends on the outcome in neighboring places (spillover). Rho is the strength of that dependence.
- Error model: an unmeasured, spatially patterned factor sits in the errors. Lambda is the strength of that dependence.
- Choose based on the process. Compare coefficients, AIC (lower is better) and RMSE with OLS.

**GWR**

- A separate regression at each location, using nearby locations weighted by distance.
- Bandwidth: how many neighbors (adaptive) or how far (fixed) each local regression reaches. Small bandwidths give local, changeable coefficients, and large ones give smooth surfaces.
- Map the local coefficients and their significance. A lower AICc than OLS means letting relationships vary improves the model.

**K-means clustering**

- Standardize variables as z-scores so large-scale variables do not dominate.
- Elbow plot: choose k where adding clusters stops reducing within-cluster variation by much.
- Name clusters from their average profiles, then map them. Remember the ecological fallacy and that labels are the analyst's choice.

### Practice Questions

1. Suppose Moran's I for county median rent is 0.41 (p < 0.001), and the LISA map shows a High-High cluster around the Triangle. Interpret both, and suggest a process.
2. Suppose an OLS model of county obesity rate has a coefficient of -0.35 (p = 0.003) for percent with a bachelor's degree and an R-squared of 0.42. Interpret both.
3. Moran's I on the residuals of that model is 0.28 (p < 0.001). Explain what this means and what you would do next.
4. Describe a process for which a spatial lag model makes more sense than a spatial error model, and one for which the error model makes more sense.
5. Suppose a GWR with an adaptive bandwidth of 15 counties has an AICc of 612, and the OLS AICc is 640. The local coefficient for percent with a bachelor's degree ranges from -0.9 to 0.1. Interpret these results.
6. A k-means analysis uses median household income (in dollars) and percent renters without standardizing. Explain what goes wrong. Then explain how you would choose k from an elbow plot.
