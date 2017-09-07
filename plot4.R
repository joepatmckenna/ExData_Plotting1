## install packages if necessary
for (package in c('dplyr', 'lubridate')) {
  if (!package %in% installed.packages()[,1]) {
    install.packages(package)
  }
}

## source packages
library(dplyr)
library(lubridate)

## download dataset if necessary
dataset_name = 'household_power_consumption'
dataset_archive = paste0(dataset_name,'.zip')
dataset_file = paste0(dataset_name,'.txt')
if (!file.exists(dataset_archive)) {
  dataset_url=paste0('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2F',dataset_archive)
  download.file(url=dataset_url, destfile=dataset_archive)
  download_date <- date()
}

## read dataset
dataset <- read.table(unz(dataset_archive, dataset_file),
                      colClasses=c(rep('character',2),rep('numeric',7)),
                      header=T,
                      sep=';',
                      na.strings='?')

## combine Date and Time columns to POSIXct column
dataset$datetime <- as.POSIXct(strptime(
  apply(
    dataset[,c('Date','Time')],
    1,
    paste,
    collapse='-'),
  '%d/%m/%Y-%H:%M:%S'))

# remove Date and Time columns
dataset <- select(dataset,-(Date:Time))

## extract data between time window
obs = with(dataset, datetime >= dmy(01022007) & datetime < dmy(03022007))
dataset <- dataset[obs,]

## 4
png(file='plot4.png',width=480,height=480)
par(mfrow=c(2,2))
## upper left
with(dataset, plot(datetime, Global_active_power, type='n', xlab='', ylab='Global Active Power'))
with(dataset, lines(datetime, Global_active_power, type='l'))
## upper right
with(dataset, plot(datetime, Voltage, type='n'))
with(dataset, lines(datetime, Voltage, type='l'))
# lower left
idx = list(list(dataset$Sub_metering_1,'black'),
           list(dataset$Sub_metering_2,'red'),
           list(dataset$Sub_metering_3, 'blue'))
plot(dataset$datetime, idx[[1]][[1]], type='n', xlab='', ylab='Energy sub metering')
for (pair in idx) {
  lines(dataset$datetime, pair[[1]], type='l', col=pair[[2]])
}
legend('topright',
       legend=names(dataset)[5:7],
       col=c('black','red','blue'),
       lty=c(1,1,1))
## lower right
with(dataset, plot(datetime, Global_reactive_power, type=,'n'))
with(dataset, lines(datetime, Global_reactive_power, type=,'l'))
dev.off()
