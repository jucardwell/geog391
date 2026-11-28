## Study Guide

### Format

- In class on Friday, March 5.
- Closed book and handwritten. You will not write any code.
- Eight questions (sub-components), each worth 2 points.
- Most questions give you R output, graphs or maps from a dataset you have not seen before and ask you to interpret them.

### You Should Be Able To

1. Write null and alternative hypotheses and choose a test that fits the data: one-sample t-test, two-sample t-test or chi-square ([Hypothesis Testing reading](reading-hypothesis-testing.qmd), [Hypothesis Testing tutorial](hypothesis_testing.qmd)).
2. Interpret a test statistic, p-value and confidence interval, and state a decision in context.
3. Explain Type I and Type II errors for a specific question, and how the significance level affects them.
4. Explain the difference between statistical significance and practical importance, and why very large samples matter here.
5. Explain why a significant result does not show causation, and how spatial dependence breaks the independence assumption.
6. Explain complete spatial randomness and the difference between first-order and second-order structure, and propose a process for each ([Point Pattern Analysis reading](reading-point-pattern-analysis.qmd), [Point Pattern Analysis tutorial](ppa.qmd)).
7. Interpret a quadrat test and a kernel density map, and explain how the bandwidth changes a kernel density map.
8. Interpret an average nearest neighbor result and a K or L-function with a simulation envelope, and explain why comparing against an inhomogeneous Poisson process separates first-order from second-order structure.

### How to Read the Output

**Hypothesis tests**

- p-value: the probability of a result at least this extreme if the null hypothesis were true. Below 0.05: reject the null hypothesis. Above 0.05: fail to reject it (never "accept" it).
- One-sample t-test: one mean against a fixed value. Two-sample t-test: the means of two independent groups. Chi-square: whether two categorical variables are independent.
- `t.test(y ~ group)` runs Welch's two-sample t-test, which does not assume equal variances. Read the t value, the p-value, the confidence interval for the difference and the two group means.
- The confidence interval for a difference in means: if it does not include 0, the difference is significant at that level. Its ends tell you how big the difference could plausibly be.
- `chisq.test()` compares observed counts with the counts expected if the variables were independent. Compare row percentages to see how large the difference is.
- Type I error: rejecting a true null (a false alarm). Type II error: failing to reject a false null (a missed effect). A smaller significance level lowers Type I error but raises Type II error.
- Assumptions: independent observations, random sampling, and roughly normal data or a large sample. Neighboring places are usually not independent.

**Quadrat test**

- Divides the study area into quadrats and compares the observed count in each with the count expected under CSR. In a plot, each quadrat shows observed, expected and the residual.
- A residual is (observed - expected) / √expected. Large positive residuals are places with more events than CSR predicts, large negative ones have fewer.
- A small p-value means the counts are too uneven for CSR. Uneven counts point to first-order structure (intensity that changes across space).
- The result depends on the size and placement of the quadrats.

**Kernel density estimation**

- A smoothed map of intensity (events per unit area). No p-value; use it to see where events are dense and to suggest first-order processes.
- Bandwidth (sigma): a small bandwidth gives a bumpy map with peaks around single events, and a large bandwidth gives a smooth map that hides local differences.
- The density surface can be used as the null model for later tests (an inhomogeneous Poisson process).

**Average nearest neighbor (ANN)**

- Compares the average distance from each point to its nearest neighbor with the same value in simulated patterns.
- An observed ANN shorter than the simulated values (a ratio below 1) means clustering. Longer (a ratio above 1) means dispersion.
- Best for very local structure, because it only looks at the single nearest point.

**K and L-functions**

- Count how many other points fall within distance r of each point, for many values of r. The L-function is a rescaled K that makes the expected line straight.
- Plotted as L(r) - r, the theoretical line is flat at 0. Above the simulation envelope means clustering at that distance, below means dispersion, and inside means consistent with the null model.
- Shows structure across a range of distances, so you can say at what distances clustering happens.

**Monte Carlo simulation and the null model**

- Simulates many patterns in the same study area and compares the observed value with them. The p-value is the share of simulations at least as extreme as the observed value. The envelope is the range of the simulated lines.
- Used because irregular study areas, edges and small samples make formula-based expectations unreliable.
- CSR as the null asks, "Is this pattern different from random?" First-order variation alone will make the answer "clustered."
- An inhomogeneous Poisson process from a kernel density as the null asks, "Is there clustering beyond what the uneven intensity explains?" That isolates second-order structure. In R these are `Kinhom()` and `Linhom()`.

### Practice Questions

1. You are studying the percent decrease in workplace mobility during COVID-19 across counties in the Carolinas, and you think rural counties had smaller decreases. State the null and alternative hypotheses, choose a test, and name one assumption to check.
2. The percent decrease is bounded between 0 and 100. Explain how this could affect the t-test. Then explain why spatial dependence among counties could make the p-value too small.
3. Suppose the test gives the output below. Interpret it in context, including what a Type II error would mean.

    ```
    	Welch Two Sample t-test

    data:  workplace_change by rural
    t = 1.84, df = 74.2, p-value = 0.0698
    95 percent confidence interval:
     -0.31  7.62
    sample estimates:
    mean in group rural mean in group urban 
                  -24.1               -27.8 
    ```

4. Suppose a chi-square test of 2 million commutes finds that bike commuters are significantly more likely than drivers to arrive on time (p < 0.001), with on-time rates of 91.2% and 90.9%. Explain whether this result is practically important.
5. Suppose a quadrat test of 300 cell towers in a county gives p = 0.004, with large positive residuals along the interstate and negative residuals in a state forest. Describe the structure and propose a process.
6. A kernel density map of coffee shops in Durham is made with a bandwidth of 200 m and again with 5 km. Describe how the two maps would differ and which is better for comparing neighborhoods.
7. Suppose the ANN for those cell towers is 1.31 times the value expected under CSR (p = 0.002). Describe the second-order structure and propose a process.
8. An L-function compared against CSR is above the envelope from 0 to 10 km. Compared against an inhomogeneous Poisson process from a kernel density surface, it is inside the envelope everywhere. Explain what the two results together tell you about first-order and second-order structure.
