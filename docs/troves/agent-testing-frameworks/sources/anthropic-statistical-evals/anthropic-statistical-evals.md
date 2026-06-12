# A Statistical Approach to Model Evaluations — Anthropic

Published Nov 19, 2024. Paper: arxiv.org/abs/2411.00640

## Problem

When one model outperforms another on a benchmark, is the difference real or could one model simply have gotten lucky in the choice of questions?

## Recommendation #1: Use the Central Limit Theorem

Eval questions are drawn from an unseen "question universe." The theoretical average (underlying skill) can be measured using statistical theory. Report the Standard Error of the Mean (SEM) alongside each eval score. A 95% confidence interval = mean ± 1.96 × SEM.

## Recommendation #2: Cluster Standard Errors

Many evals consist of groups of closely related questions (e.g., multiple questions about the same passage of text). When questions are non-independent, clustered standard errors can be over three times as large as naive standard errors. Cluster on the unit of randomization.

## Recommendation #3: Reduce Variance Within Questions

Decompose a model's score on a question into mean score + random component. Reducing variance in the random component leads to greater statistical precision.

Two strategies:
- **If using chain-of-thought reasoning:** Resample answers from the same model several times, use question-level averages as scores fed into CLT.
- **If NOT using chain-of-thought:** The random component may be eliminated using next-token probabilities (e.g., probability of producing token "B" for a multiple-choice question where B is correct).

## Recommendation #4: Analyze Paired Differences

Since the question list is shared across models, conducting a paired-differences test eliminates variance in question difficulty. The correlation of question scores on popular evals between frontier models is substantial (0.3 to 0.7). Paired-difference analysis is a "free" variance reduction technique.

## Recommendation #5: Use Power Analysis

Power analysis helps formulate hypotheses (Model A outperforms Model B by 3 percentage points) and calculate the number of questions needed. Also informs the number of times to resample answers and the number of questions in a random subsample while retaining desired power properties.