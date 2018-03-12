# Ames Housing Data Problem Statement
### Steven Slezak
### 12 March 2018
<!--ts-->
<!--te-->
Table of Contents
=================

   * [Introduction](#introduction)
   * [Domain](#domain)
   * [Problem Statement](#problem-statement)
   * [Description of Data Set](#description-of-data-set)
   * [Proposed Solution](#proposed-solution)
   * [Benchmark Model](#benchmark-model)
   * [Performance Metrics](#performance-metrics)
   * [Citations](#citations)
   * [Markdown Notebook](#markdown-notebook)

# Introduction

In 2011, a new faculty member teaching his first university-level regression course was looking for a data set to allow students to showcase what they learned.  Dean De Cock was familiar with the *Boston Housing* data. But he was dissatisfied for a variety of reasons.  So he sought to find a new data set, one more modern in its structure and more informative in its data.  

Professor De Cock created the *Ames* data set for this purpose. He wrote up his experiences in the *Journal of Statistics Education*, offering the data as an "alternative" to the *Boston Housing* data.<sup>1</sup> De Cock's *Ames* data set will be the basis for this problem statement and analysis.

This problem statement includes the following:

1.  Domain:  Housing Data
2.  Problem Statement:  EDA, PCA, and K-means
3.  Description of Data Set:  2930 x 82 with a Mix of Nominal, Ordinal, Continuous, and Discrete Variables
4.  Proposed Solution:  Multivariate Regression
5.  Benchmark Model:  Simple Linear Regression
6.  Performance Metrics:  Bias, Maximum Deviation, MAD, MSE
7.  Citations
8.  Markdown Notebook with Associated Code

The problem statement and analysis utilize the *Ames* [data set found here.](https://www.openintro.org/stat/data/?data=ames)

# Domain

The *Ames* data set is a collection of features characterizing houses sold in the Ames, Iowa, individual residential housing market between 2006 and 2010.  The data come from the Office of the City Assessor, Ames, Iowa, and were used to compute assessment values for these properties.

The data set was created by Dean De Cock in 2011 for pedagogical purposes in an introductory regression analysis class. Ihe information is similar to the kinds of data included in a Multiple Listing Service printout on a residential property used by realtors, sellers, buyers. 

In the original data documentation for the data,<sup>2</sup> De Cock suggests removing certain observations which represent outliers. These can be found by plotting *SalePrice* against *GrLivArea*. This plot reveals five observations for houses larger than 4000 feet<sup>2</sup> of living area above ground. These were removed for this study.

# Problem Statement

For the purpose of this study, *Ames* data are examined in an Exploratory Data Analysis (EDA).  This involves cleaning and preparing the data for running an EDA.  The EDA itself includes contingency tables, distribution plots, and pairs plots.  Since there are 82 features in the data set, these tables and plots will be limited in number for illustrative purposes.

The data will be preprocessed using deskewing methods for certain numerical features, one-hot encoding (dummyfication) of certain categorical features, and visualizations of a small set of these transformations.

The study uses five methods to identify statistically interesting features.  They are multilinear regression, a lasso with gaussian response, a lasso with a poisson response, a gradient boost, and an intuitive guess. The filtering method for inclusion on the final list is simple:  features that score in the top ten in at least two of the methods are included on the final list.

The following table summarizes the different results each method identified:

|    **Feature**   | **Regression** | **Lasso (Gaussian)** | **Lasso (Poisson)** | **Gradient Boost** |  **Guess** |
|:------------:|:----------:|:----------------:|:---------------:|:--------------:|:------:|
|  **TotalBsmtSF** |      1     |         5        |        4        |        4       | Ranked |
|  **BsmtFinSF1**  |      3     |         4        |        6        |       10       |   NA   |
|   **X2ndFlrSF**  |      5     |        NA        |        NA       |        3       |   NA   |
|   **X1stFlrSF**  |      6     |        NA        |        NA       |        6       | Ranked |
|   **PoolArea**   |      8     |        NA        |        NA       |       NA       | Ranked |
|   **YearBuilt**  |      9     |         3        |        3        |        7       |   NA   |
|   **GrLivArea**  |     NA     |         1        |        1        |        2       | Ranked |
|  **OverallQual** |     10     |         2        |        2        |        1       |   NA   |
| **GarageCars_3** |     NA     |         7        |        NA       |        3       |   NA   |
|  **BsmtQual_Ex** |     NA     |        10        |        NA       |        5       |   NA   |
|  **GarageArea**  |     NA     |        NA        |        7        |        8       | Ranked |

The intuitive and statistical methods agree on five of the 11 features.  The statistical methods suggest 11 unique features can be further examined. This will be done with a PCA to narrow down the number of promising features to ten. Appropriate visualization will be provided.

Finally, a cluster analysis of these features will be rendered.

# Description of Data Set

The *Ames* data consist of 82 features and 2930 observations. Features include two identifiers, 46 categorical, 14 discrete (such as year built), and 20 continuous (such as square footage) variables. Variables focus on the quality and quantity of physical attributes of the properties, and include final sales values.  

The two identifiers are *PID* and *Neighborhood*. [Here is a map of the neighborhoods found in Ames:](https://github.com/seslezak/Ames_Housing_Study/blob/master/images/ResidentialAssessmentNeigh.pdf)

The 46 categorical variables (identified by De Cock as "nominal" and "ordinal") represent various types of dwellings, designs, building features, and environmental conditions. Discrete variables include years, numbers of bedrooms and bathrooms, and garage sizes (in terms of cars). The continuous variables describe dimensions of the properties, including square footage, lot frontage, and so on. For the purpose of selecting important features for this analysis, it will be necessary to create dummy variables for factors and scale features.

The data include 13,944 NA and 48,760 empty values. This is to be expected, since many properties lack certain features or characteristics, such as fences or swimming pools, or are missing descriptive measurements. Part of the problem of cleaning and preparing the data involves substituting proxy values for numeric features and plugging empty values in categorical features with an appropriate string.

In cleaning the data, five observations were removed as outliers, leaving 2925 observations. For a complete breakdown of all 82 features, please see the link<sup>2</sup> below.

Dean De Cock suggests in the data documentation<sup>2</sup> that there are two problems with the data:

1. homoscedacity in the data might impact assumptions made in selecting and building a model, depending on the intended purpose of the model.
2. outliers and unusual observations in the data need to be addressed. This analysis removes five observations De Cock suggests are extreme outliers.

The data set occupies 1.5 MB in memory.

# Proposed Solution

The data set was created for a class on regression, and the *Journal of Statistics Education* article<sup>1</sup> suggests students build a simple model and a more complicated version. In the simple model, it is suggested at least six variables be used. The more complicated model can use any number of variables.  The literature targets a minimum *R<sup>2</sup>* value of 73%.

# Benchmark Model

A linear regression model should be used as the benchmark. It is a simple and common classification which provides a base line to measure more sophisticated models against.

# Performance Metrics

The article in the *Journal of Statistics Education*<sup>1</sup> suggests the following metrics be used to evaluate model performance:

1. Bias:  *average (Y<sub>hat</sub> - Y)*
2. Maximium Deviation:  *Max|Y - Y<sub>hat</sub>|*
3. Mean Absolute Deviation:  *average |Y - Y<sub>hat</sub>|*
4. Mean Square Error:  *average (Y - Y<sub>hat</sub>)<sup>2</sup>*

# Citations

1. Dean De Cock, Ames, Iowa: Alternative to the Boston Housing Data as an End of Semester Regression Project. Journal of Statistics Education Volume 19, Number 3 (2011) [http://ww2.amstat.org/publications/jse/v19n3/decock.pdf]

2. Dean De Cock, Ames Housing Data Description. [https://ww2.amstat.org/publications/jse/v19n3/decock/DataDocumentation.txt]

3. OpenIntro Statistics [https://www.openintro.org/stat/data/?data=ames]

4. Package 'AmesHousing'. R Documentation, 2017. [https://cran.r-project.org/web/packages/AmesHousing/AmesHousing.pdf]

5. Chris Albon (@chrisalbon) [https://twitter.com/chrisalbon]

6. "Understanding PCA using Shiny and Stack Overflow data". Julia Silge. Presentation to rstudio::conf2018. [https://www.rstudio.com/resources/videos/understanding-pca-using-shiny-and-stack-overflow-data/]

# Markdown Notebook

An annotated Markdown Notebook with associated *R* code and graphics can be [found in the directory attached to this GitHub repository.](https://seslezak.github.io/Ames_Housing_Study/)
