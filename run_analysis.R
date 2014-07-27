library(car)
library(reshape2)

#Read the features.txt into R
finfo<-read.table("./data/features.txt")

#Extract only the variables related to mean and std
mean.std.vars<-rbind(finfo[grep("-mean()",finfo$V2,fixed=TRUE),],finfo[grep("-std()",finfo$V2,fixed=TRUE),])

##Clean the labels in features info by removing the () and replacing the '-' by '.'
mean.std.vars$V2 <- gsub("()","",mean.std.vars$V2,fixed=TRUE) #delete ()
mean.std.vars$V2 <- gsub("-",".",mean.std.vars$V2,fixed=TRUE) #replace "-" with "."

#Read in the files related to the variables, activities and subjects
testx<-read.table("./data/test/X_test.txt")
testy<-read.table("./data/test/y_test.txt")
testsub<-read.table("./data/test/subject_test.txt")
trainx<-read.table("./data/train/X_train.txt")
trainy<-read.table("./data/train/y_train.txt")
trainsub<-read.table("./data/train/subject_train.txt")

#Replace activity codes with descriptive activity names in testy and trainy
testy$V1<-recode(testy$V1,"1='Walking';2='Walking.Upstairs';3='Walking.Downstairs';4='Sitting';5='Standing';6='Laying'")
trainy$V1<-recode(trainy$V1,"1='Walking';2='Walking.Upstairs';3='Walking.Downstairs';4='Sitting';5='Standing';6='Laying'")


## Extract only the mean and std columns from test and train data
ftestx<-testx[,as.numeric(mean.std.vars$V1)]
ftrainx<-trainx[,as.numeric(mean.std.vars$V1)]

## Merge with subject and activity data
rawtestdata <-cbind(testsub,testy,ftestx)
rawtraindata <-cbind(trainsub,trainy,ftrainx)

##Merge test and train data
rawdata <-rbind(rawtestdata,rawtraindata)

##Rename the columns in the raw data files meaningfully
colnames(rawdata) <- c("Subject_ID","Activity",mean.std.vars$V2)

##Create a tidy data file
write.table(rawdata,file="./data/tidydata1.txt")

##Melt and cast the raw tidy data to obtain the averages for each combination of subject and activity
rawdatamelt<-melt(rawdata,id=c("Subject_ID","Activity"))
finaldata<-dcast(rawdatamelt,Subject_ID+Activity~variable,mean)

##Create the final tidy data file
write.table(finaldata,file="./data/tidydata2.txt")