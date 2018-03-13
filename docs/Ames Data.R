library(tidyverse)
library(rapportools)
library(ggplot2)
library(fastDummies)
library(gridExtra)
library(broom)
library(glmnet)
library(cowplot)
library(gbm)
library(pcaMethods)
library(vegan)
library(cluster)
library(fpc)
library(usdm)
library(DataExplorer)
library(ggbiplot)

AmesURL <- 'https://www.openintro.org/stat/data/ames.csv'
AmesData <- read.csv(url(AmesURL), sep = ",", header = TRUE, stringsAsFactors = FALSE)
names(AmesData) <- gsub('\\.', '', names(AmesData))
plot(AmesData$SalePrice, AmesData$GrLivArea)
points(AmesData$SalePrice[c(1499, 2181, 2182, 1761, 1768)], AmesData$GrLivArea[c(1499, 2181, 2182, 1761, 1768)], pch = 19, col = 'red')

sorted <- AmesData[order(AmesData$GrLivArea, decreasing = TRUE), ]
head(sorted)
dim(AmesData)
AmesData <- AmesData[-c(1499, 2181, 2182, 1761, 1768), ]
plot(AmesData$SalePrice, AmesData$GrLivArea)
dim(AmesData)
pryr::object_size(AmesData)
anyDuplicated(AmesData)
summary(AmesData)
str(AmesData)
sum(is.na(AmesData))
sum(is.empty(AmesData))
nan_sums <- colSums(is.na(AmesData))
nan_sums[nan_sums > 0]

medianLotFrontage <- median(AmesData$LotFrontage, na.rm = TRUE)
medianMasVnrArea <- median(AmesData$MasVnrArea, na.rm = TRUE)
medianBsmtFinSF1 <- median(AmesData$BsmtFinSF1, na.rm = TRUE)
medianBsmtFinSF2 <- median(AmesData$BsmtFinSF2, na.rm = TRUE)
medianBsmtUnfSF <- median(AmesData$BsmtUnfSF, na.rm = TRUE)
medianTotalBsmtSF <- median(AmesData$TotalBsmtSF, na.rm = TRUE)
medianGarageYrBlt <- median(AmesData$GarageYrBlt, na.rm = TRUE)
medianGarageArea <- median(AmesData$GarageArea, na.rm = TRUE)

AmesData$LotFrontage[is.na(AmesData$LotFrontage)] <- medianLotFrontage
AmesData$MasVnrArea[is.na(AmesData$MasVnrArea)] <- medianMasVnrArea
AmesData$BsmtFinSF1[is.na(AmesData$BsmtFinSF1)] <- medianBsmtFinSF1
AmesData$BsmtFinSF2[is.na(AmesData$BsmtFinSF2)] <- medianBsmtFinSF2
AmesData$BsmtUnfSF[is.na(AmesData$BsmtUnfSF)] <- medianBsmtUnfSF
AmesData$TotalBsmtSF[is.na(AmesData$TotalBsmtSF)] <- medianTotalBsmtSF
AmesData$GarageYrBlt[is.na(AmesData$GarageYrBlt)] <- medianGarageYrBlt
AmesData$GarageArea[is.na(AmesData$GarageArea)] <- medianGarageArea
nan_sums <- colSums(is.na(AmesData))
nan_sums[nan_sums > 0]
sum(is.empty(AmesData))

AmesData$Alley[is.na(AmesData$Alley)] <- 'w/o'
AmesData$BsmtQual[is.na(AmesData$BsmtQual)] <- 'w/o'
AmesData$BsmtCond[is.na(AmesData$BsmtCond)] <- 'w/o'
AmesData$BsmtExposure[is.na(AmesData$BsmtExposure)] <- 'w/o'
AmesData$BsmtFinType1[is.na(AmesData$BsmtFinType1)] <- 'w/o'
AmesData$BsmtFinType2[is.na(AmesData$BsmtFinType2)] <- 'w/o'
AmesData$BsmtFullBath[is.na(AmesData$BsmtFullBath)] <- 'w/o'
AmesData$BsmtHalfBath[is.na(AmesData$BsmtHalfBath)] <- 'w/o'
AmesData$FireplaceQu[is.na(AmesData$FireplaceQu)] <- 'w/o'
AmesData$GarageType[is.na(AmesData$GarageType)] <- 'w/o'
AmesData$GarageFinish[is.na(AmesData$GarageFinish)] <- 'w/o'
AmesData$GarageCars[is.na(AmesData$GarageCars)] <- 'w/o'
AmesData$GarageQual[is.na(AmesData$GarageQual)] <- 'w/o'
AmesData$GarageCond[is.na(AmesData$GarageCond)] <- 'w/o'
AmesData$PoolQC[is.na(AmesData$PoolQC)] <- 'w/o'
AmesData$Fence[is.na(AmesData$Fence)] <- 'w/o'
AmesData$MiscFeature[is.na(AmesData$MiscFeature)] <- 'w/o'

AmesData <- as.data.frame(unclass(AmesData))
str(AmesData)
sum(is.empty(AmesData))

ggplot(AmesData, aes(x = MasVnrType)) + geom_histogram(stat = 'count')
ggplot(AmesData, aes(x = Electrical)) + geom_histogram(stat = 'count')

AmesData$MasVnrType[AmesData$MasVnrType == ''] <- 'None'
AmesData$Electrical[AmesData$Electrical == ''] <- 'SBrkr'

nan_sums <- colSums(is.na(AmesData))
nan_sums[nan_sums > 0]
sum(is.empty(AmesData$Electrical))
sum(is.empty(AmesData$MasVnrType))
sum(is.empty(AmesData))

AmesTibble <- as_tibble(AmesData)
AmesTibble

table(AmesTibble$OverallCond)
round(table(AmesTibble$OverallCond)/length(AmesTibble$OverallCond), 3)
ggplot(AmesTibble, aes(x = OverallCond)) + geom_histogram(stat = 'count')
table(AmesTibble$RoofStyle)
round(table(AmesTibble$RoofStyle)/length(AmesTibble$RoofStyle), 3)
ggplot(AmesTibble, aes(x = RoofStyle)) + geom_histogram(stat = 'count')
ggplot(AmesTibble, aes(x = RoofMatl)) + geom_histogram(stat = 'count')

RoofTable <- table(AmesTibble$RoofStyle, AmesTibble$RoofMatl)
DecTable <- table(AmesTibble$RoofStyle, AmesTibble$RoofMatl)/length(AmesData$RoofStyle)
DecTable <- round(DecTable, 3)
RoofTable
DecTable

AmesRoofMelt <- melt(RoofTable)
ggplot(AmesRoofMelt, aes(Var.1, Var.2)) +
        geom_point(aes(size = value), shape = 21, color = 'black', fill = 'cornsilk') + 
        scale_size_area(max_size = 27) +
        ggtitle('Distributions of Roofing Styles and Materials in Ames, Iowa') +
        labs(x = 'Roof Style', y = 'Roof Material') +
        theme(panel.background = element_blank(), panel.border = element_rect(color = 'blue', fill = NA, size = 1))

ggplot(AmesData, aes(x = SalePrice)) + geom_density(fill = 'cornsilk') + 
        geom_vline(aes(xintercept = mean(SalePrice)), color = 'black', linetype = 'dashed', size = 1.25) + 
        geom_vline(aes(xintercept = median(SalePrice)), color = 'blue', linetype = 'dashed', size = 1.25) +
        ggtitle('Sales Price with Mean and Median') + 
        annotate(geom = 'text', x = 215000, y = 0.00000875, label = 'Mean') +
        annotate(geom = 'text', x = 124000, y = 0.00000875, label = 'Median') +
        scale_x_continuous(labels = scales::dollar) +
        scale_y_continuous(labels = scales::percent)

AmesPairs <- AmesTibble[c(6, 21, 28, 48, 79, 82)]
pairs(AmesPairs, upper.panel = NULL, col = AmesTibble$GarageCars, main = 'Select Ames Housing Features by Garage Capacity (Cars)')
par(xpd = TRUE)
legend(0.9, 0.7, as.vector(unique(AmesTibble$GarageCars)), fill = c('green', 'red', 'blue', 'black', 'turquoise', 'violet', 'pink'))

ggplot(AmesTibble, aes(x = Neighborhood, y = SalePrice/1000)) +
        geom_boxplot(aes(fill = AmesTibble$Neighborhood)) +
        stat_summary(fun.y = 'mean', geom = 'point', shape = 23, size = 2, fill = 'white') +
        ggtitle("Sales Prices ($ ,000) by Neighborhood in Ames, Iowa (2006 to 2010)") +
        theme(axis.text.x=element_blank())

AmesDummy <- dummy_cols(AmesTibble, remove_first_dummy = TRUE)
str(AmesDummy)
AmesDumNoTg <- AmesDummy[, -82]
AmesTarget <- AmesDummy[, 82]
names(Filter(is.factor, AmesDumNoTg))
dropCols <- c("MSZoning", "Street", "Alley", "LotShape", "LandContour", "Utilities", "LotConfig", "LandSlope", 
              "Neighborhood", "Condition1", "Condition2", "BldgType", "HouseStyle", "RoofStyle", "RoofMatl", 
              "Exterior1st", "Exterior2nd", "MasVnrType", "ExterQual", "ExterCond", "Foundation", "BsmtQual", 
              "BsmtCond", "BsmtExposure", "BsmtFinType1", "BsmtFinType2", "Heating", "HeatingQC", "CentralAir", 
              "Electrical", "BsmtFullBath", "BsmtHalfBath", "KitchenQual", "Functional", "FireplaceQu", "GarageType", 
              "GarageFinish", "GarageCars", "GarageQual", "GarageCond", "PavedDrive", "PoolQC", "Fence", 
              "MiscFeature", "SaleType", "SaleCondition")
AmesDumNoTg <- AmesDumNoTg %>% dplyr::select(-one_of(dropCols))
dim(AmesDumNoTg)
AmesDumScale <- scale(AmesDumNoTg, center = TRUE, scale = TRUE)
AmesDumScaleDF <- as.tibble(AmesDumScale)

p1 <- ggplot(AmesTibble, aes(x = LotFrontage)) + geom_histogram(binwidth = 10)
p2 <- ggplot(AmesDumScaleDF, aes(x = LotFrontage)) + geom_histogram(binwidth = .5)
p3 <- ggplot(AmesTibble, aes(x = MasVnrArea)) + geom_histogram(binwidth = 100)
p4 <- ggplot(AmesDumScaleDF, aes(x = MasVnrArea)) + geom_histogram(binwidth = .5)
p5 <- ggplot(AmesTibble, aes(x = GrLivArea)) + geom_histogram(binwidth = 250)
p6 <- ggplot(AmesDumScaleDF, aes(x = GrLivArea)) + geom_histogram(binwidth = .5)
p7 <- ggplot(AmesTibble, aes(x = GarageArea)) + geom_histogram(binwidth = 100)
p8 <- ggplot(AmesDumScaleDF, aes(x = GarageArea)) + geom_histogram(binwidth = .45)
grid.arrange(p1, p3, p2, p4, nrow = 2)
grid.arrange(p5, p7, p6, p8, nrow = 2)

Top10Intuitive <- c('LotArea', 'LotFrontage', 'Neighborhood', 'GrLivArea', 'PoolArea', 'X1stFlrSF', 'X2ndFlrSF', 'TotalBsmtSF', 'GarageArea', 'KitchenQual')
tibble(Top10Intuitive)
AmesDumScaleDF <- cbind(AmesTarget, AmesDumScaleDF)
lmRating <- lm(SalePrice ~ . , AmesDumScaleDF)
lmCoefs <- tidy(lmRating)
lmCoefs$abs_est <- sqrt(lmCoefs$estimate^2)
lmCoefsAbs <- lmCoefs[-c(2:5)]
lmCoefsAbs <- lmCoefsAbs[-1,]
head(lmCoefsAbs[order(-lmCoefsAbs$abs_est), ], 10)
tail(lmCoefsAbs[order(-lmCoefsAbs$abs_est), ], 10)

x <- as.matrix(AmesDumScaleDF[, -1])
y <- as.matrix(AmesDumScaleDF[, 1])
set.seed(805)
cv.ridge.g <- cv.glmnet(x, y, family = 'gaussian')
plot(cv.ridge.g)
cv.ridge.g$lambda.min
cv.ridge.g$lambda.1se
LassoCoefsG <- coef(cv.ridge.g, s = cv.ridge.g$lambda.min)
LassoCoefsG <- tidy(LassoCoefsG)
LassoCoefsG$abs_est <- sqrt(LassoCoefsG$value^2)
LassoCoefsG <- LassoCoefsG[-c(2:3)]
LassoCoefsG <- LassoCoefsG[-1,]
head(LassoCoefsG[order(-LassoCoefsG$abs_est), ], 10)
tail(LassoCoefsG[order(-LassoCoefsG$abs_est), ], 10)

set.seed(805)
cv.ridge.p <- cv.glmnet(x, y, family = 'poisson')
plot(cv.ridge.p)
cv.ridge.p$lambda.min
cv.ridge.p$lambda.1se
LassoCoefsP <- coef(cv.ridge.p, s = cv.ridge.p$lambda.min)
LassoCoefsP <- tidy(LassoCoefsP)
LassoCoefsP$abs_est <- sqrt(LassoCoefsP$value^2)
LassoCoefsP <- LassoCoefsP[-c(2:3)]
LassoCoefsP <- LassoCoefsP[-1,]
head(LassoCoefsP[order(-LassoCoefsP$abs_est), ], 10)
tail(LassoCoefsP[order(-LassoCoefsP$abs_est), ], 10)

AmesBoost <- gbm(SalePrice ~ . , data = AmesDumScaleDF, distribution = 'gaussian', n.trees = 100, shrinkage = 0.01, interaction.depth = 4)
summary(AmesBoost)
head(summary(AmesBoost), 10)

AmesPCAMeths <- as.tibble(AmesDumScaleDF[, c(15, 12, 17, 16, 33, 9, 19, 7, 250, 172, 27)])
str(AmesPCAMeths)

AmesPCA <- pca(AmesPCAMeths, method = 'svd', center = FALSE, nPcs = 10)
AmesPCA
summary(AmesPCA)
AmesPCA2 <- prcomp(AmesPCAMeths)
ggbiplot::ggbiplot(AmesPCA2, obs.scale = 1, var.scale = 1, ellipse = TRUE, circle = TRUE) +
        scale_color_discrete(name = '') +
        theme(legend.direction = 'horizontal', legend.position = 'top')
plot(sDev(AmesPCA), type = "lines", main = 'Skree Plot for Ames PCA')
plotPcs(AmesPCA)
plotPcs(AmesPCA, pcs = 1:4)
slplot(AmesPCA, pcs = c(1, 2))
slplot(AmesPCA, pcs = c(1, 3))
slplot(AmesPCA, pcs = c(1, 4))
slplot(AmesPCA, pcs = c(2, 3))
slplot(AmesPCA, pcs = c(2, 4))
slplot(AmesPCA, pcs = c(3, 4))

AmesLoad <- loadings(AmesPCA)
AmesMelt <- melt(AmesLoad)
colnames(AmesMelt)[1] <- 'names'
AmesMelt <- arrange(AmesMelt, names)
AmesMelt$X2 <- gsub('PC1', 'PC01', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC2', 'PC02', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC3', 'PC03', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC4', 'PC04', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC5', 'PC05', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC6', 'PC06', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC7', 'PC07', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC8', 'PC08', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC9', 'PC09', AmesMelt$X2)
AmesMelt$X2 <- gsub('PC010', 'PC10', AmesMelt$X2)
AmesMelt
ggplot(AmesMelt, aes(x = X2, y = value, fill = names)) + geom_bar(stat = 'identity', position = 'dodge') + guides(fill = guide_legend(reverse = FALSE))

q2svd <- Q2(AmesPCA, AmesPCAMeths, fold = 15, nruncv = 1)
q2svd
barplot(q2svd)

dis <- dist(AmesPCAMeths)^2
res <- kmeans(AmesPCAMeths, 4)
sil <- silhouette(res$cluster, dis)
windows()
plot(sil)

AmesCl <- kmeans(AmesPCAMeths, 4, nstart = 10)
AmesCl
clusplot(AmesPCAMeths, AmesCl$cluster, color = TRUE, main = 'Clustering Plot for Ames Housing Data Features')
plotcluster(AmesPCAMeths, AmesCl$cluster)

