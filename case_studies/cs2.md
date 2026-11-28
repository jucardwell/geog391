## Study Guide

### Format

- In class on Friday, March 5.
- Closed book and handwritten. You will not write any code.
- Seven questions (sub-components), each worth 2 points. About three sentences each is enough.
- Most questions give you R output, graphs or maps from a dataset you have not seen before and ask you to interpret them.
- Covers Concepts 6 and 7, and uses ideas from Concepts 1 to 5. We will work through the practice questions below in pairs on the prep day, Wednesday, March 3.

### You Should Be Able To

1. Write null and alternative hypotheses and choose a test that fits the data: one-sample t-test, two-sample t-test or chi-square ([Hypothesis Testing reading](reading-hypothesis-testing.qmd), [Hypothesis Testing tutorial](hypothesis_testing.qmd)).
2. Interpret a test statistic, p-value and confidence interval, and state a decision in context.
3. Explain Type I and Type II errors for a specific question.
4. Explain the difference between statistical significance and practical importance, and why very large samples matter here.
5. Explain why a significant result does not show causation, and how spatial dependence breaks the independence assumption.
6. Explain complete spatial randomness and the difference between first-order and second-order structure ([Point Pattern Analysis reading](reading-point-pattern-analysis.qmd), [Point Pattern Analysis tutorial](ppa.qmd)).
7. Interpret a quadrat test, kernel density map, average nearest neighbor result and L-function, and explain why Monte Carlo simulation is used.

### How to Read the Output

**t-tests and chi-square tests**

- p-value below 0.05: reject the null hypothesis. Above 0.05: fail to reject it (never "accept" it).
- The confidence interval for a difference in means: if it does not include 0, the difference is significant at that level.
- `t.test(y ~ group)` runs Welch's two-sample t-test, which does not assume equal variances.
- `chisq.test()` tests whether two categorical variables are independent. Compare row percentages to see how large the difference is.
- Type I error: rejecting a true null. Type II error: failing to reject a false null.

**Quadrat test**

- Compares observed counts in each quadrat with the counts expected under CSR.
- A small p-value means the counts are too uneven for CSR. Large differences between observed and expected counts point to first-order structure (intensity that changes across space).

**Kernel density estimation**

- A smoothed map of intensity. No p-value; use it to see where events are dense and to suggest first-order processes.

**Average nearest neighbor (ANN)**

- Compares the average distance from each point to its nearest neighbor with the same value under CSR.
- R below 1, or an observed ANN smaller than the simulated values, means clustering. R above 1 means dispersion.
- Best for very local structure.

**L-function**

- Above the simulation envelope means clustering at that distance, below means dispersion, inside means consistent with CSR.
- Shows structure across a range of distances.

**Monte Carlo simulation**

- Simulates many CSR patterns in the same study area and compares the observed value with them. The p-value is the share of simulations at least as extreme as the observed value.
- Used because irregular study areas, edges and small samples make formula-based expectations unreliable.

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
5. Suppose a quadrat test of 300 cell towers in a county gives p = 0.004, and an ANN analysis gives R = 1.31 and p = 0.002. Describe the first-order and second-order structure, and propose a process for each.
6. An L-function is above the envelope from 0 to 2 km and inside the envelope beyond 2 km. Explain what this means, and why the result could change if you compared it with an inhomogeneous Poisson process based on a kernel density surface.
