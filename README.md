# Data-Analysis-Using-SAS
# PREDICTING THE SALARIES OF MAJOR LEAGUE BASEBALL PLAYERS
## Abstract
This project analyses the salary of Major League Baseball (MLB) players and how much players are rewarded based on their performance information for the players’ previous season and MLB careers. Each salary was examined on both the yearly performance and the overall career production of the player. Several different performance statistics were collected for the 1986-1987 MLB seasons. A random sample of players was selected from each season and separate models were created for position players. Significant performance attributes that were helpful in predicting salary were selected for each different model. These models were deemed to be good models having a predictive r-squared value of at least 0.85 for each of the different models. After the regression models were found, the models were tested for accuracy by predicting the salaries of a random sample of players from the 1986-1987 MLB season.
The goal is to predict the salary of MLB players. It is needed to explore the variables which may affect the salaries and suggests a progressive approach to predict the salaries. There are some missing values and outliers so it is needed to explore the data and handle these kinds of before building the prediction models. Minimizing and selecting the optimal features are used to maximize the prediction accuracy. And, normality test and multicollinearity are performed to in order to fit the model properly. Because the target is the continuous variable, linear regression is implemented to predict the dependent variable. The feature selection and correlation analysis between the two variables are performed to uncover the most important variables. Choosing the optimum features are used to maximize the prediction accuracy.

## 1. Introduction
There is a hard salary cap in Major League Baseball (MLB). So, MLB teams are allowed to spend as much as they prefer on salaries. However, MLB tries to discourage overspending by the implementation of the Luxury Tax. Luxury Tax means that teams with a salary above the limitation have to pay a fine. Because of Luxury Tax and managerial reasons, MLB teams try to manage the players’ payroll efficiently. In this project, our objective is to increase the prediction accuracy by finding the main factors that predict the salary of MLB players. The baseball dataset is used to create a regression model to predict the value of a baseball player’s salary. Our first step before building our model, we viewed all the variables given to us and determined what the different variables mean and we check for any missing values or other ways to clean the dataset. Data preparations, namely Exploratory Data Analysis include handling the missing data, imbalanced data, outliers, selecting the important features. Also, the multicollinearity has to be detected and handled properly. After preprocessing the data, we build models based on our dataset and validate their predictive performance by using R- squared and RMSE.

## 2. The Objective of Analysis
The goal of this study is to examine the significant factors that determine the average yearly salary of the MLB player. Different statistics need to be evaluated for hitters. In this study, there are many different statistics examined for production instead of only using only one production statistic. By predicting possible salaries, MLB teams will be better able to manage its players by providing them with reasonable salaries and manage a roster on a limited budget. The following are the main goals of this project.
1. Visualize the data to understand the categories of each attribute and their influence on the dependent variable.
2. Data preprocessing (Handling the missing values and outliers in the dataset, feature selection, etc.).
3. Detect the multicollinearity by using the correlation matrix, variable inflation factor (V.I.F), conditional indices and resolve this issue through variable elimination, model re-specification, centering of regressors, Ridge Regression, Principal Component Regression.
4. Build the regression models (Forward, Backward, Stepwise, LASSO, etc.) and find the best model.
5. Compare and evaluate the R-squared and RMSE for all models.
6. Explaining the influence of each independent variable for the target variable.

## 3. Understanding the Data (Data descriptive)
Our data are related with 322 Major League Baseball (MLB) players who played at least one game in both the 1986 and 1987 seasons. The attributes are for only hitters, not pitchers. The salaries are for the 1987 season and the performance attributes are from 1986. There are 19 input variables and a target variable (Salary). It is needed to predict the salary. The main purpose of this step is data understanding. The data is uploaded to the SAS by using the DATA LOADING method. Then, it is performed to demonstrate if there will be null values and white space cells. To understand the unique category and its weight within each feature and how it would affect the output (the target), data visualization is performed. Surprisingly, it founds out that salary variable has 59 missing values.

## 4. Exploratory Data Analysis
4.1 Dealing with missing data and imbalance data
The presence of a lot of missing data affects the predictive behavior of a model. It can be found that there are 59 observations in the first output table with at least one of the input variables with missing values; These missing values are not used as building the linear regression model.

4.2 Variable transformation
The variable transformation, which make response to be normal, can improve the model fitting. The imbalance of the data is not easy to understand and it is required more attention to all input variables within training set and test set. An additional approach is performed on the target to handle the imbalanced dataset. The majority of the points within target distributed around zero, therefore keeping the original data can be biased toward one class. So, we need to handle this condition first. The distribution transformation method can be utilized here. The implementation of this technique is required either x or y axis to improve the model fitting. Figure 3 on the left shows the distribution of the original values of the response. One can see that the distribution is positively skewed. To get a good prediction, it prefers the distribution to be equally distributed over the given values. So, in order to handle this skewed data, the log transformation can be performed. In this project, it is better to predict the log salary value of a player instead of salary. Because the variation of salaries is much greater as the salaries are higher, it is proper to need a log transformation to the salaries before building the regression models. In order to adjust for the different variances in salary for a given set of production statistics and to make a better predictive model, the log of salary will be used for the dependent variable in all of the models.
Before model selections, check the model including all the regressors from original dataset and model including all variables after log transformation. From table 5 on the left, this is first full model which do not transform anything and just use the original dataset. From table 5 on the right, this is full model after the log transformation. We can check that the prediction accuracy gets better (R-square: 0.527899 -> 0.547909, RMSE: 321.1913 -> 0.269060).

4.5 Clinically significant regressors
In this part, we can create additional variables from the data by using the domain knowledge in baseball. Investigation on this site (http://en.wikipedia.org/wiki/Baseball_statistics) indicated other input variables that could be created from the original data. From this site, the following variables were created using a SAS Code because they were considered significant for predicting the baseball player’s salary:
BA (Batting average) - CHits / CAtBat
HR/H (Home runs per hit) – HmRun / Hits
The R-square is increased into 0.822607, which means that adding new variables are helpful. * If we have other variables, we can use the other important variables such as OPS (On-base plus slugging) – on-base percentage plus slugging average, SLG (slugging average) – TB (Total bases) / AB (At Bat), injury(health), etc.

4.6 Data Normalization
Different values in the dataset have a variety of ranges. Therefore, we normalize the data by using auto data preparation. In fact, most of the models request the data scaling. The input variables should be logic in terms of units and scaling.
* Dropping the insignificant variables
Too many variables can make the model overfitting. Overfitting can happen when data that over-presents the target event, and therefore it will produce a poor performing model when using real-world data as input.

Since several of the input values appear to have little predictive power on the target, we need to drop these variables, thereby reducing the need for that information to make a decent prediction. The p-value associated with each of the input variables provides the analyst with an insight into which variables have the biggest impact on helping to predict the target variable. In this case, the smaller the value, the higher the predictive value of the input variable. The dropping variables are: HmRun, CHmRun, CRBI, CWalks, Assists, Errors, and NewLeague. But, since it is not helpful for prediction accuracy, this method is not used.

## 5. Multicollinearity
From now, we finished data preprocessing but before building the regression model, multicollinearity is needed to resolve appropriately. If there are two highly correlated regressors in the models, they make the prediction accuracy worse. Here are methods for resolving the multicollinearity
- Detecting multicollinearity: CORR, VIF, Tol, and Collin
- Solving multicollinearity: (1) Drop a variable, (2) Use ridge regression (3) Utilize principal components regression.
First, we can check the correlation. In correlation matrix, if any variable has a high correlation about 0.8 or higher with other variables. It has to be removed. If there are correlations between two attributes, it can cause problems when we fit the model. They are needed to delete the variables which are highly correlated with each other. Next, we can check multicollinearity through the Variance Inflation Factor and Tolerance.

If tolerance fall below 0.1 and variance inflation is above the value of 10, it can be concluded that there is a threat of multicollinearity. 

If eigenvalues are getting small and the corresponding condition numbers become large, this is a clear indication of multicollinearity. Condition number is getting large as eigen value closes to zero so there is multicollinearity. So, we drop the variables: CAtBat2, Chits2, CABat, Chits, CRuns2, CRuns, CRBI2, CRBI, CWalks2, CWalks. In conclusion, multicollinearity has to be resolved. The easy way is to drop one of variables, which has correlation between two variables.
Because multicollinearity is solved after dropping the variables, ridge regression and PCR is not needed but we can also try these two methods. There are at least two alternative methods of resolving the issue of multicollinearity: ridge regression and principal component regression.
- Ridge Regression
Ridge regression is used when a multicollinearity is identified after standardizing regressors (centering and scaling) and dropping near-zero-coefficient. It is a variant to least squares regression. The traditional ordinary least squares (OLS) regression produces unbiased estimates for the regression coefficients, however, if there are the confounding issue of highly correlated explanatory variables, your resulting OLS parameter estimates end up with large variance. Thus, using ridge regression could be helpful to obtain a smaller variance in resulting parameter estimates.

These methods are from the eigenvalues of the correlation matrix and the scree plot. Through checking these plots, it is needed to decide the number of factors to build our model. Any factor with an eigenvalue higher than 1.000 can remain in the model as it explains at least 1 variable’s worth of information. Thus, our model includes 5 factors. And, from Appendix, we can check the output and the r-squared is 0.5636.
Ridge Regression and PCR is good for predicting the dependent variable but they can’t explain the relationship between the dependent and independent variables.
If multicollinearity is not resolved properly, it can have a negative impact on the accuracy of your model. Through the above methods, it is important to detect and solve the issue of multicollinearity before fitting the regression model.

## 6. Residual Analysis (Model diagnostics)
Before log transform, after log transform, and after adding new variables, residual analysis is implemented to check the model adequacy. Now, this part is for the final model. It is important to examine influence and fit diagnostics to see whether the model might be unfittingly influenced by a few outliers and whether the data support the assumptions that underset the linear regression.

There are five steps:
(a) Detection of Outliers
(b.1) Detection of Heteroscedasticity
(b.2) Detection of Correlation
(b.3) Detection of serious violation against Normality
(c) Misspecification of the model
Except for step b.3, only four steps will be conducted because normality will be checked finally.

So, we can see that Rstudent residual-leverage plot provides possible outlying information in both dimensions. As for (b.1), Detection of Heteroscedasticity, one can refers to the Rstudent residual-fitted response plot above. Excluding those possible outliers, there seems no serious violation against homoscedasticity.
As for (b.2), Detection of (auto-) Correlation, we will use Durbin-Watson test.
Note: Pr<DW is the p-value for testing positive autocorrelation, and Pr>DW is the p-value for testing negative autocorrelation.
The note in the printout indicates how to interpret the result already. Remind yourself that the two p-values (Pr<DW and Pr>DW) refer to two different tests (H0: no positive correlation; H0: no negative correlation, respectively). In this example, there is neither significant positive correlation nor significant negative correlation.
As for (b.3), Detection of serious violation against Normality, one could use the histogram and QQ-plot first.
  
  We see that there is no concern about serious violation against normality. We will also perform several hypothesis tests to confirm this. A SAS macro has
implemented, %NORMTEST(VAR, DATA), to facilitate this task. We will need to (1) Define the macro in SAS
(2) Extract the targeted quantity whose normality is to be tested (Rstudent residual) (3) Call the macro
Note that I have suppressed the printout and added an extra OUTPUT statement. OUT= specifies the name of dataset and R= specifies the name of raw residual; RSTUDENT= specifies the name of Rstudent residual residual; STUDENT= specifies the name of studentized residual; and PRESS= specifies the name of PRESS residual. (3) Call/Run the MACRO on EI in dataset fit.
%NORMTEST(EI, FIT)

## 7. Model selection
Normally, we do regression analyses using only continuous variables. However, our dataset includes categorical predictors in a regression analysis. So, PROG REG is not appropriate in this case because there are categorical variables in this dataset. it is need to use PROC GLM which handle the numerical regressors as well as categorical ones.
There are large numbers of candidate predictor variables so Statistical model selection is needed to find out which ones are important to predict the results accurately. Model selection is to estimate the performance of different models in order to choose the approximate best model. Methods include familiar methods such as forward, backward, and stepwise selection. Also, new methods such as LAR, LASSO are also used.

## 8. Conclusion (Evaluation)
The objective of regression analysis is 1) interpretation of regressors against response 2) prediction. Through this project, I attempt to check the relationship between the independent variable and dependent variable and increase the prediction accuracy. First, talk about doings to build the model properly. Because the dataset is small, extreme outlier can distort the prediction. So, deleting the outlier make the prediction accurate. Through domain knowledge, new variables are created and they become the significant variable for the target. And, variable transformation and resolving the multicollinearity also help fit the model.
When we check the “goodness-of-fit”, R-squared, RMSE, and p-values are considered. The Root Mean Squared Error (RMSE) and R-square are statistics that typically inform the analyst how good the model is in predicting the target. The R-square is a measure of the fit of the model and ranges from 0 to 1.0 with higher values typically indicating a better model. The higher the R-squared values typically indicate a better performing model but sometimes conditions or the data used to train the model over-fit and don’t represent the true value of the prediction power of that particular model. Third, p-value measures how likely the coefficient has no effect on the outcome. If p-value is too high, the variable becomes insignificant. “STEPWISE” has the highest R-Squared (0.8551), adjusted R-Squared (0.8497), and the lowest RMSE (0.14836). So, I have considered this model for prediction.
