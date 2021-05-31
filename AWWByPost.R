## This code gets the address (from the address list) of those members who request AWW by post, and compares it with the
## file from the previous month (stored on this PC).  If it differs, it allows one to check where and to save the new
## version.  It then sends the regional representatives the list for the region

## Set working directory
setwd('~/Anthroposophy/Publications')

## Regional representative email addresses
emails <- c(Auckland='emma.ratcliff@gmail.com',
            'Bay of Plenty'='stellahamiltonbaker@gmail.com',
            Canterbury='robinms@tutanota.com',
            Christchurch='robinms@tutanota.com',
            Coromandel='judyjannis@gmail.com',
            Dunedin='cpsuggate@gmail.com',
            'Hawkes Bay'='robyn@wellspoken.co.nz',
            Kerikeri='rldeboer@xtra.co.nz',
            'Nelson/Marlborough'='heatheric.verstappen@gmail.com',
            Northland='twoflyingowls@tutanota.com',
            Otago='cpsuggate@gmail.com',
            Tasman='jane.cumberworth@hotmail.com',
            Waikato='sarah@spheres.co.nz',
            Wellington='anthropsocwb@gmail.com')
            

## Get addresses of members who want AWW by post
newList <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/117-hjbsw2lKb-ywtbMZV7Yqvw_eo1j9j8kk07WuxUgw/edit#gid=7')
newList <- as.data.frame(newList)[, c('Joint mailing name','Address1','Address2','Address3a','Address3b','AWW - post','Region')]
newList <- newList[!is.na(newList[,'AWW - post']) & !is.na(newList[,'Joint mailing name']),] 

oldList <- as.data.frame(readxl::read_excel('AWWByPost.xlsx', sheet='AWWByPost'))

## Compare the two lists
all.equal(oldList, newList, check.attributes=FALSE) # hopefully this will be TRUE

## If they differ, here's some code to check the differences
# newList[newList[,'Joint mailing name'] != oldList[,'Joint mailing name'],]
# oldList[newList[,'Joint mailing name'] != oldList[,'Joint mailing name'],]
# 
# newList[!is.na(newList[,'Address1']) & newList[,'Address1'] != oldList[,'Address1'],]
# oldList[!is.na(newList[,'Address1']) & newList[,'Address1'] != oldList[,'Address1'],]
# 
# newList[!is.na(newList[,'Address2']) & newList[,'Address2'] != oldList[,'Address2'],]
# oldList[!is.na(newList[,'Address2']) & newList[,'Address2'] != oldList[,'Address2'],]
# 
# newList[newList[,'Address3a'] != oldList[,'Address3a'],]
# oldList[newList[,'Address3a'] != oldList[,'Address3a'],]

## Write the new list (only necessary if it differed from the old one
writexl::write_xlsx(list(AWWByPost=newList), 'AWWByPost.xlsx')

## Send appropriate addresses to each regional member

newList[!(newList$Region %in% names(emails)),]
newList[newList$Region=='Manawatu', 'Region'] <- 'Wellington'
regions <- table(newList$Region)
for (i in names(regions))
{
  email <- emails[i]
  
  content <- paste("Subject: AWW by Post\n
                   Kia ora\n
                   Below are the addresses of members from your region who have requested AWW by post.  Please ensure they get the latest copy.\n
                   The June copy is available at https://anthroposophie.org/en/pdf-archive.\n
                   Nga mihi ...\n
                   P\n")
  regList <- newList[newList$Region==i, 1:5]
  regList <- paste(apply(regList, 1, paste, collapse=', \t'), collapse='\n')
  writeLines(paste(content, regList, sep='\n\n'), 'AWWTemp.txt')
  cmd <- paste('/usr/sbin/sendmail', email, '< AWWTemp.txt')
  system(cmd)
}
