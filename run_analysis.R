######## 1. Merge Training and Test to one dataset (= Data_All)############
## create folder ./Data | downlaod file | destfile = dataset.zip | unzip dataset
if(!file.exists("./Data")) {dir.create("./Data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./Data/dataset.zip", method = "curl")
unzip(zipfile = "./Data/dataset.zip", exdir = "./Data")

# read data from files: Features files | Subject files | Activity files
dataFeaturesTest <- read.table("./Data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
dataFeaturesTrain <- read.table("./Data/UCI HAR Dataset/train/X_train.txt", header = FALSE)

dataSubjectTest <- read.table("./Data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
dataSubjectTrain <- read.table("./Data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)

dataActivityTest <- read.table("./Data/UCI HAR Dataset/test/y_test.txt", header = FALSE)
dataActivityTrain <- read.table("./Data/UCI HAR Dataset/train/y_train.txt", header = FALSE)

# Merge test and training datasets
# row-bind test (561) and tranining (7352)
dataFeature <- rbind (dataFeaturesTest, dataFeaturesTrain)
## label col features
features <- read.table("./Data/UCI HAR Dataset/features.txt", header = FALSE)
featureNames <- as.character(features$V2)
colnames(dataFeature) <- featureNames

dataSubject <- rbind (dataSubjectTest, dataSubjectTrain)
colnames(dataSubject) <- c("Subject")

dataActivity <- rbind (dataActivityTest, dataActivityTrain)
colnames(dataActivity) <- c("Activity")

# column-bind Features, Subject and Activity
Feature_Subject <- cbind(dataFeature, dataSubject)
MergedData <- cbind(Feature_Subject, dataActivity)


########## 2. Extract Mean and SD for each measurement from Features #########
MeanStd <- features$V2[grep("-(mean|std)\\(\\)", features$V2)]

# subset the desired columns
SelectedColNames <- c(as.character(MeanStd), "Subject", "Activity")
SelectedData <- subset(MergedData, select = SelectedColNames)

## confirm dim
dim(SelectedData)  ## return 10299 68


######## 3. Use descriptive names to name the activities in Data_All_Mean_SD #######
ActivityLabel <-read.table("./Data/UCI HAR Dataset/activity_labels.txt")
SelectedData[, 68] <- ActivityLabel[SelectedData[, 68], 2]  ## update activity labels at col 68 "Activity"

####### 4. Appropriately labels the data set with descriptive variable names #########
## replace prefix t with time
names(SelectedData) <- gsub("^t", "time", names(SelectedData))

## replace prefix f with freq
names(SelectedData) <- gsub("^f", "freq", names(SelectedData))

## replace Acc with Accelerometer
names(SelectedData) <- gsub("Acc", "Accelerometer", names(SelectedData))

## replace Gyro with Gyroscope
names(SelectedData) <- gsub("Gyro", "Gyroscope", names(SelectedData))

## replace Mag with Magnitude
names(SelectedData) <- gsub("Mag", "Magnitude", names(SelectedData))

## replace Mag with Magnitude
names(SelectedData) <- gsub("BodyBody", "Body", names(SelectedData))

########## 5. creates a second, independent tidy data set 
#######  with the average of each variable for each activity and each subject###

## load plyr package
library(plyr)
Data <- aggregate(. ~Subject + Activity, SelectedData, mean)
Data <- Data[order(Data$Subject, Data$Activity),]
write.table(Data, file = "MyTidyData.txt", row.name=FALSE)














