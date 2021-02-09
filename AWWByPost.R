## This codes gets the address (from the address list) of those members who request AWW by post, and compares it with the
## file from the previous month (stored on this PC).  If it differs, it allows one to check where and to save the new
## version for sending to Aliz

## Set working directory
setwd('~/Anthroposophy/Publications')

## Get addresses of members who want AWW by post
newList <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/117-hjbsw2lKb-ywtbMZV7Yqvw_eo1j9j8kk07WuxUgw/edit#gid=7')
newList <- as.data.frame(newList)[, c('Joint mailing name','Address1','Address2','Address3a','Address3b','AWW - post')]
newList <- newList[!is.na(newList[,'AWW - post']) & !is.na(newList[,'Joint mailing name']),] 

oldList <- as.data.frame(readxl::read_excel('AWWByPost.xls', sheet='AWW by post'))

## Compare the two lists
all.equal(oldList, newList[,-ncol(newList)], check.attributes=FALSE) # hopefully this will be TRUE

## If they differ, here's some code to check the differences
# newList[newList[,'Joint mailing name'] != oldList[,'Joint mailing name'],]
# oldList[newList[,'Joint mailing name'] != oldList[,'Joint mailing name'],]
# 
# newList[!is.na(newList[,'Address2']) & newList[,'Address2'] != oldList[,'Address2'],]
# oldList[!is.na(newList[,'Address2']) &newList[,'Address2'] != oldList[,'Address2'],]
# 
# newList[newList[,'Address3a'] != oldList[,'Address3a'],]
# oldList[newList[,'Address3a'] != oldList[,'Address3a'],]

## Write the new list (only necessary if it differed from the old one
writexl::write_xlsx(list(AWWByPost=newList), 'AWWByPost.xlsx')
