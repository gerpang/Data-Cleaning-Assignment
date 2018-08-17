## instructions ## 
# Merge training and test data sets
# Extract mean and sd for each measurement
# Name activities descriptively
# Label data set with descriptive variable names 
# Create 2nd tidy data set from (4.) with 
#   avg of each variable for each activity and each subject

library(reshape2)

# 1. Download, unzip dataset 
filename <- "getdata_dataset.zip"

if(!file.exists(filename)){
    fileURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    download.file(fileURL,filename,method="curl")
}
if(!file.exists("UCI HAR Dataset")){
    unzip(filename)
}

# 2. Load labels, features, data
activitylabels <- read.table('UCI HAR Dataset/activity_labels.txt')
activitylabels[,2] <- as.character(activitylabels[,2])
allfeatures <- read.table('UCI HAR Dataset/features.txt')
allfeatures[,2] <- as.character(allfeatures[,2])

# 3. Subset only mean/std data, tidy column names
features <- grep(".(mean|std)()",allfeatures[,2])
features.nm <- allfeatures[features,2]
features.nm <- gsub('-mean','Mean',features.nm)
features.nm <- gsub('-std','Std',features.nm)
features.nm <- gsub('[-()]','',features.nm)

# 4. Load data (using features subset)
train <- read.table('UCI HAR Dataset/train/X_train.txt')[features]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# 5. Merge datasets, add labels
full <- rbind(train,test)
colnames(full) <- c("Subject","Activity", features.nm)

    #str(full) # Check 

# 6. Convert to factors 
full$Activity <- factor(full$Activity, levels = activitylabels[,1], labels = activitylabels[,2])
full$Subject <- as.factor(full$Subject)

fullmelt <- melt(full, id = c("Subject", "Activity"))
fullmean <- dcast(fullmelt, Subject + Activity ~ variable, mean)

write.table(fullmean, "tidy.txt", row.names = FALSE, quote = FALSE)

