library(downloader)

file = "http://www.beardedanalytics.com/todd/iris.csv"
outputname="myfile.csv"
#Test is this works
if( round( file.info(file)$size/1000,1)*1000<=5 ){

    download(file,destfile=outputname);
    cat(
      paste0("File ",file," has been downloaded to \n",
             getwd(),"/",outputname)
    )
}else
  stop("File is larger than 5MB")

# Trying using COmmand in linux to obtain file size
# stat


#Load recently Downloaded File
mydata <-  read.csv("myfile.csv")
cat("Data Loaded...\n")

#Provide Summary of Data
summary(mydata)

#Additonal Data Info
cat(
  paste0("Your dataset has " , nrow(mydata) ," rows and ",
length(mydata) , " columns. \n You have ", length(complete.cases(mydata)=="TRUE") ,
" complete cases which makes for ",round(1- ( length(complete.cases(mydata)=="TRUE") / nrow(mydata) ),2),
       "% missing data.")
)
        





#Option 1 - parse this
wget --spider http://www.beardedanalytics.com/todd/iris.csv

#Option 2 
system("
wget http://www.beardedanalytics.com/todd/iris.csv --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'
")


system(
  paste0("wget ",file,"--spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'
       ")
)



> On debian-based platforms (like Ubuntu) always first attempt to install
> via
> apt-get. So:
  > apt-cache search rcurl
> (r-cran-rcurl should be a result)
> apt-get install -t <repoName> r-cran-rcurl



apt-get install -t <repoName> r-cran-rcurl
