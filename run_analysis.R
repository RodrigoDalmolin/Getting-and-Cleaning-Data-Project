##Getting and Cleaning Data Course Project

##### Chunk 1: Getting the data ##########################################################################

#creating the directory
if (!file.exists("CourseProject")){
      dir.create("CourseProject")
}

#downloading the data
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url = url, destfile = "./CourseProject/Dataset.zip")

#extracting the data
unzip("./CourseProject/Dataset.zip", files = NULL, list = FALSE, overwrite = FALSE,
      junkpaths = FALSE, exdir = "./CourseProject", unzip = "internal",
      setTimes = FALSE)

#loading data features
features<-read.table("./CourseProject/UCI HAR Dataset/features.txt", 
                     colClasses = c("numeric", "character"), comment.char = "")

##loading Training set (Tr) data
TrSet<-read.table("./CourseProject/UCI HAR Dataset/train/X_train.txt", 
                  colClasses = "numeric", comment.char = "")

TrLabels<-read.table("./CourseProject/UCI HAR Dataset/train/y_train.txt",
                    comment.char = "")

TrSubject<-read.table("./CourseProject/UCI HAR Dataset/train/subject_train.txt",
                     comment.char = "")

##making Training Set data.frame
TrainingSet<-TrSet
colnames(TrainingSet)<-features[,2]
TrainingSet<-cbind(TrSubject, TrLabels, TrainingSet)
colnames(TrainingSet)[1:2]<-c("Subject", "Labels")

##loading Test set (Te) data
TeSet<-read.table("./CourseProject/UCI HAR Dataset/test/X_test.txt", 
                  colClasses = "numeric", comment.char = "")

TeLabels<-read.table("./CourseProject/UCI HAR Dataset/test/y_test.txt",
                     comment.char = "")

TeSubject<-read.table("./CourseProject/UCI HAR Dataset/test/subject_test.txt",
                      comment.char = "")

##making Test Set data.frame
TestSet<-TeSet
colnames(TestSet)<-features[,2]
TestSet<-cbind(TeSubject, TeLabels, TestSet)
colnames(TestSet)[1:2]<-c("Subject", "Labels")


##### Chunk 2: Merging the data ######################################################################

#checking Subjects 
sum(TrainingSet$Subject %in% TestSet$Subject)
sum(TestSet$Subject %in% TrainingSet$Subject)

MergedData<-rbind(TrainingSet, TestSet)

##### Chunk 3:Extracting only the measurements on the mean and standard deviation for each measurement. 
mean.std <- grep("-(mean|std)\\(\\)", features[, 2])
mean.std.Data<-MergedData[,-c(1,2)]
mean.std.Data<-mean.std.Data[,mean.std]
mean.std.Data<-cbind(MergedData[,1:2],mean.std.Data)


##### Chunk 4:naming the activities in the data set#####################################################
activities <- read.table("./CourseProject/UCI HAR Dataset/activity_labels.txt")
mean.std.Data<-merge(x=mean.std.Data, y=activities, by.x = "Labels", by.y="V1")
mean.std.Data<-mean.std.Data[,c(2,69,3:68)]
colnames(mean.std.Data)[2]<-"activity"


##### Chunk 4:data set with the average of each variable for each activity and each subject##############
averages_data <- ddply(mean.std.Data, .(Subject, activity), function(x) colMeans(x[, 3:68]))
write.table(averages_data, "averages_data.txt", row.name=FALSE)
