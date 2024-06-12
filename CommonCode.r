# Update R
library(installr)
updateR()
update.packages(ask = "graphics", checkBuilt = TRUE)


# Delete all objects in the environment
rm(list = ls())


# Set working directory
getwd()
setwd("E:/UKB/EWAS-IS")
workdir <- getwd()
dir.create("output")


# Load packages
pkgs <- c("dplyr", "lattice", "data.table", "ggplot2", "miceFast", "mice")
inst <- lapply(pkgs, require, character.only = TRUE)


# Save data
saveRDS(ISdata, file = "ISdata.RDS")


# Load data
ISdata <- haven::read_sas("E:/SAS 9.4 Explorer/Gut/isdata.sas7bdat", NULL)
data <- readRDS("E:/UKB/IS-EWAS & MR/ISdata_merged.RDS")


# Merge data
data_merged <- merge(data, suppl[c("n_eid", "n_54_0_0", "n_26248_0_0")], by = "n_eid", all.x = FALSE)


# 显示某变量某行观测是否存在于数据集
print(paste0("Old name: ", old_name, ", exists: ", dir.exists(old_name)))


# 查看数据集信息
names(data)
str(data)
summary(data)
head(data)
tail(data)
View(data)


# Merge data----
data_new <- dplyr::inner_join(inner_join(data, covariate, by = "id"), status, by = "id")


# Random sampling----
set.seed(123)
data_sample <- data[sample(nrow(data), 5000), ]


# 在 CRAN 上搜索 package----
packagefinder::findPackage(c("meta", "regression"), "and")
packagefinder::exploreFields(c("Package", "Title"), "logistic")
packagefinder::whatsNew()


# 分类变量因子化----
x.category.variables <- c(
    "male",
    "education",
    "currentSmoker",
    "BPMeds",
    "prevalentStroke",
    "prevalentHyp",
    "diabetes"
)
for (x.cat in x.category.variables) {
    prostate[, colnames(prostate) == x.cat] <-
        factor(prostate[, colnames(prostate) == x.cat])
}

framingham$education <- factor(
    framingham$education,
    levels = c(1, 2, 3, 4),
    labels = c("高中以下", "高中", "大学", "大学以上")
)


# Add labels to data----
varALL <- read.csv("E:/Desktop/Labels.csv")
for (i in seq_along(data)) {
    colname <- colnames(data)[i]
    label <- varALL$label[varALL$"VarName" == colname]
    attr(dataPARTall[, i], "label") <- label
}


# 批量重命名文件夹----
## 读取 Excel 文件中的重命名信息
sheet <- readxl::read_excel("E:/Desktop/rename_table.xlsx", sheet = "正离子2")
## 设置工作目录为需要重命名的文件夹
setwd("E:/Metabonomics-Jidong-202401/Raw/raw_data_remainder305")
## 遍历某 sheet 中的重命名信息, 并执行重命名操作
for (i in 1:nrow(sheet)) {
    old_name <- sheet$`old-name`[i]
    new_name <- sheet$`new-name`[i]

    if (dir.exists(old_name)) {
        file.rename(old_name, new_name)
        print(paste0("Renamed ", old_name, " to ", new_name))
    }
}
