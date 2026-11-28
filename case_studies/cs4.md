## Study Guide

### Format

- In class on Monday, April 26.
- Closed book and handwritten. You will not write any code.
- Six questions (sub-components), each worth 2 points. About three sentences each is enough.
- The questions give you maps, a semivariogram and R output from a dataset you have not seen before and ask you to interpret them.
- Covers Concept 10, with links back to ideas from earlier in the semester. We will work through the practice questions below in pairs on the prep day, Friday, April 23.

### You Should Be Able To

1. Explain why spatial dependence makes interpolation possible, and where an interpolated surface is least reliable ([Continuous Surfaces reading](reading-continuous-surfaces.qmd)).
2. Explain how inverse distance weighting works and how the power changes the surface ([Continuous Surfaces tutorial](continuous_surfaces.qmd)).
3. Interpret an empirical semivariogram and a fitted model: nugget, sill and range.
4. Explain how kriging differs from IDW and interpret a kriging variance map.
5. Explain leave-one-out cross-validation and use RMSE to compare surfaces.
6. Explain the limits of an interpolated surface and how covariates can improve it.

### How to Read the Output

**IDW**

- Each prediction is a weighted average of nearby values, with weights that fall with distance.
- Power: higher power gives nearby points much more weight (more local detail and spots around points). Lower power gives a smoother surface pulled toward the overall average.
- Deterministic: it gives no measure of uncertainty.

**Semivariogram**

- Each point is the average semivariance for pairs of locations at about that distance apart. Low semivariance means similar values.
- Nugget: semivariance at a distance of nearly 0 (measurement error or very small-scale variation).
- Sill: where the curve levels off, about the total variance.
- Range: the distance where the curve levels off. Beyond it, locations are no longer spatially correlated.
- A curve that keeps rising and never levels off suggests a broad trend across the study area.

**Kriging**

- Treats the surface as a Gaussian random field and uses the fitted semivariogram to set the weights.
- Prediction map: the estimated value everywhere. Variance map: how uncertain each prediction is, lowest at and near sample locations.

**Cross-validation**

- Leave one location out, predict it from the rest, record the error, and repeat for every location.
- RMSE is the typical size of the prediction error in the variable's units. Lower is better.

### Practice Questions

1. You have nitrate concentrations from 40 monitoring wells in a rural agricultural region. Explain why Tobler's First Law makes it possible to estimate nitrate between the wells, and name one situation where it would not.
2. Compare an IDW surface with a power of 1 and one with a power of 4. Describe how each would look and which would better show a small contamination hotspot near one well.
3. Suppose a fitted semivariogram for the nitrate data has a nugget of 0.8, a sill of 3.2 and a range of 6,000 meters. Interpret each value.
4. Explain why the kriging variance is highest at the edges of the region and lowest at the wells, and why a planner would want this map.
5. Suppose leave-one-out cross-validation gives an RMSE of 1.9 mg/L for IDW (power 2) and 1.4 mg/L for ordinary kriging. Explain what these numbers mean and which surface you would choose.
6. Nitrate is often higher near fields that use more fertilizer. Explain how you could use that information to improve the kriging predictions.
