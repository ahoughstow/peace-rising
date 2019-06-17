setwd(dirname(file.choose()))
install.packages("caret")
install.packages("caret", dependencies=c("Depends", "Suggests"))
library(caret)
# define the filename
data_by_nahia <- "data_by_nahia_no_headers_simplified_missing_excluded.csv"
# load the CSV file from the local directory
syria.data <- read.csv(data_by_nahia, header=FALSE)
View(syria.data)
# set the column names in the dataset
colnames(syria.data) <- c("FID", "area_sqkm",	"total_pop_06",	"log_pdens_06",	"latitude",	"longitude",	"closeness_06",	"total_pop_90",	"total_pop_00",	"cagr_1990_2000",	"total_pop_08",	"cagr_2006_2008",	"predrought_ndvi_avg",	"total_pop_10",	"log_total_pop_10",	"rainfall_2006",	"rainfall_diff_06",	"historical_drought",	"pct_ag_land",	"ag_prox",	"deaths",	"protest")
View(syria.data)



# create a list of 80% of the rows in the original dataset we can use for training
validation_index <- createDataPartition(syria.data$protest, p=0.80, list=FALSE)
# select 20% of the data for validation
validation <- syria.data[-validation_index,]
# use the remaining 80% of data to training and testing the models
training.dataset <- syria.data[validation_index,]
View(training.dataset)

# dimensions of dataset
dim(training.dataset)

# list types for each attribute
sapply(training.dataset, class)

# protest_sum_1_logit is stored as an integer, but it should be a binary factor variable, so we'll convert it
syria.data$protest <- factor(syria.data$protest)
validation$protest <- factor(validation$protest)
training.dataset$protest <- factor(training.dataset$protest)

# take a peek at the first 5 rows of the data
head(training.dataset)

# list the levels for the class
levels(training.dataset$protest_sum_1_logit)

# summarize the class distribution
percentage <- prop.table(table(training.dataset$protest)) * 100
cbind(freq=table(training.dataset$protest), percentage=percentage)

# summarize attribute distributions
summary(training.dataset)

##### Visualization #####

# split input and output
x <- training.dataset[,1:22]
y <- training.dataset[,23]

# boxplot for a few of the attributes attribute on one image
par(mfrow=c(2,6))
for(i in 2:6) {
  boxplot(x[,i], main=names(syria.data)[i])
}

# barplot for class breakdown
plot(y)

# scatterplot matrix
# choose a few of the variables so the scatterplot actually displays properly
x1 <- x[2:6]
featurePlot(x=x1, y=y, plot="ellipse")

# box and whisker plots for each attribute
featurePlot(x=x1, y=y, plot="box")

# density plots for each attribute by class value
scales <- list(x=list(relation="free"), y=list(relation="free"))
featurePlot(x=x1, y=y, plot="density", scales=scales)

##### Evaluate some algorithms #####

# Run algorithms using 10-fold cross validation
control <- trainControl(method="cv", number=10)
metric <- "Accuracy"

# a) linear algorithms
set.seed(7)
fit.lda <- train(protest~., data=training.dataset, method="lda", metric=metric, trControl=control)
# b) nonlinear algorithms
# CART
set.seed(7)
fit.cart <- train(protest~., data=training.dataset, method="rpart", metric=metric, trControl=control)
# kNN
set.seed(7)
fit.knn <- train(protest~., data=training.dataset, method="knn", metric=metric, trControl=control)
# c) advanced algorithms
# SVM
set.seed(7)
fit.svm <- train(protest~., data=training.dataset, method="svmRadial", metric=metric, trControl=control)
# Random Forest
set.seed(7)
fit.rf <- train(protest~., data=training.dataset, method="rf", metric=metric, trControl=control)

# There was a model fit error in fit.lda so we'll leave it out of the next things.
# Summarize accuracy of models
results <- resamples(list(cart=fit.cart, knn=fit.knn, svm=fit.svm, rf=fit.rf))
summary(results)

# Compare accuracy of models
dotplot(results)

# summarize Best Model
print(fit.cart)

##### Make predictions #####

# estimate skill of LDA on the validation dataset
predictions <- predict(fit.cart, validation)
confusionMatrix(predictions, validation$protest)
