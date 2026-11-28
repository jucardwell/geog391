## Study Guide

### Format

- In class on Monday, April 26.
- Closed book and handwritten. You will not write any code.
- Eight questions (sub-components), each worth 2 points.
- The questions give you maps, plots and R output from datasets you have not seen before and ask you to interpret them.

### You Should Be Able To

1. Explain why one global regression can hide relationships that change across space (non-stationarity), and how GWR fits a separate regression at each location ([Beyond One Model](reading-beyond-one-model.qmd)).
2. Interpret a GWR bandwidth, a summary of local coefficients, a local coefficient map with significance, and an AICc and R-squared comparison with OLS.
3. Explain why variables are standardized before k-means clustering, and choose k from an elbow plot ([Beyond One Model](reading-beyond-one-model.qmd)).
4. Name clusters from a profile table and a map, and explain the cautions of geodemographic labels.
5. Explain why spatial dependence makes interpolation possible, and compare Thiessen polygons, IDW and kriging ([Continuous Surfaces reading](reading-continuous-surfaces.qmd), [Continuous Surfaces tutorial](continuous_surfaces.qmd)).
6. Interpret an empirical semivariogram and a fitted model: nugget, partial sill, sill and range.
7. Interpret a kriging prediction map and a kriging variance map, and explain what kriging gives that IDW cannot.
8. Explain leave-one-out cross-validation, use RMSE to compare surfaces, and explain how covariates can improve a surface.

### How to Read the Output

**GWR**

- A separate regression at each location, using nearby locations weighted by distance (the kernel, often bisquare).
- Bandwidth: how many neighbors (adaptive) or how far (fixed) each local regression reaches. Small bandwidths give local, changeable coefficients, and large ones give smooth surfaces. `bw.gwr()` chooses it by AICc.
- The coefficient summary (minimum, quartiles, maximum) shows how much each relationship varies. Compare it with the single OLS coefficient.
- Map the local coefficients and mark where they are significant. A coefficient that changes sign or is significant only in one region is non-stationary.
- AICc lower than OLS (by more than about 3) means letting relationships vary improves the model. R-squared will almost always rise, so rely on AICc.
- Local coefficients come from overlapping samples, so neighboring estimates are not independent, and many local tests are run at once.

**K-means clustering**

- Groups places so that places in the same cluster are as similar as possible on the chosen variables.
- Standardize variables as z-scores so variables with large ranges do not dominate the distances.
- Elbow plot: total within-cluster sum of squares for each k. Choose k where adding clusters stops reducing it by much. The elbow is often not sharp, so whether the clusters make sense matters too.
- Name clusters from their average profiles compared with the overall average, then map them.
- Results depend on the variables, k and the units (MAUP). Remember the ecological fallacy, and that labels are the analyst's choice and can stereotype places.

**Thiessen polygons and IDW**

- Thiessen (Voronoi) polygons give every location the value of its nearest sample point. The surface jumps at polygon edges.
- IDW: each prediction is a weighted average of nearby values, with weights that fall with distance.
- Power: higher power gives nearby points much more weight (more local detail and spots around points). Lower power gives a smoother surface pulled toward the overall average.
- Both are deterministic: they give no measure of uncertainty, and IDW never predicts beyond the highest or lowest sample value.

**Semivariogram**

- Each point is the average semivariance for pairs of locations about that distance apart. Low semivariance means similar values.
- Nugget: semivariance at a distance of nearly 0 (measurement error or very small-scale variation).
- Partial sill: how much the curve rises above the nugget. Sill (nugget plus partial sill): where the curve levels off, about the total variance.
- Range: the distance where the curve levels off. Within it, closer locations are more alike; beyond it, locations are no longer spatially correlated.
- A curve that keeps rising and never levels off within the distances shown suggests a broad trend across the study area.
- `fit.variogram()` prints the nugget (Nug) and partial sill (Sph psill) and the range in map units, usually metres.

**Kriging**

- Uses the fitted semivariogram to set the weights, so the weights reflect the spatial structure of the data.
- Prediction map (`var1.pred`): the estimated value everywhere. Variance map (`var1.var`): how uncertain each prediction is. It is lowest at and near sample locations and highest far from them, and depends on where the samples are, not on their values.
- Universal or regression kriging adds covariates that explain part of the pattern.

**Cross-validation**

- Leave one location out, predict it from the rest, record the error, and repeat for every location.
- RMSE is the typical size of the prediction error in the variable's units. Lower is better.
- Compare RMSE with the differences that matter, such as how far values are from a standard.

### Practice Questions

1. Suppose a GWR of county median rent on percent with a bachelor's degree uses an adaptive bandwidth of 15 counties. Its AICc is 612 and the OLS AICc is 640. The local coefficient ranges from -0.9 to 6.1, and the OLS coefficient is 3.2. Interpret these results.
2. A local coefficient map shows a strong positive coefficient around the Triangle and Charlotte and a coefficient that is not significant in the northeast. Suggest one reason for the difference, and one caution in reading the map.
3. A k-means analysis uses median household income (in dollars) and percent renters without standardizing. Explain what goes wrong. Then explain how you would choose k from an elbow plot.
4. A cluster has the highest median income, the lowest percent renters and the longest commutes. Give it a name, and explain one risk of using that name in a public report.
5. You have nitrate concentrations from 40 monitoring wells in a rural agricultural region. Explain why Tobler's First Law makes it possible to estimate nitrate between the wells. Then compare a Thiessen polygon surface with an IDW surface with a power of 1 and one with a power of 4.
6. Suppose a fitted semivariogram for the nitrate data has a nugget of 0.8, a partial sill of 2.4 and a range of 6,000 metres. Interpret each value.
7. Explain why the kriging variance is highest at the edges of the region and lowest at the wells, and how a planner could use this map to add new wells.
8. Suppose leave-one-out cross-validation gives an RMSE of 1.9 mg/L for IDW (power 2) and 1.4 mg/L for ordinary kriging, and the safety limit is 10 mg/L. Explain what these numbers mean, which surface you would choose, and how fertilizer use near each location could improve the predictions.
