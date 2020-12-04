# The address location data was downloaded from LINZ comprehensive AIMS adress tables (https://data.linz.govt.nz/set/87),
# as csv files under the WGS 84 projection (to match the mapping used in R).
# Only aims-address-position.csv and aims-address-components.csv are used

# Read address position
adPos <- read.csv('LINZsCoordinates/aims-address-position/aims-address-position.csv', stringsAsFactors=FALSE)
# nrow(adPos[duplicated(adPos$address_id),]) # one duplicate address_id
# adPos[adPos$address_id==361207,]                        # which we'll omit
adPos <- adPos[!duplicated(adPos$address_id),]

# Read address components
adComp <- read.csv('LINZCoordinates/aims-address-component/aims-address-component.csv', stringsAsFactors=FALSE)
adComp <- adComp[adComp$address_component_type %in% c('Town/City Name', 'Suburb/Locality Name'),]

# Rearrange the components
tt <- merge(adComp[adComp$address_component_type=='Suburb/Locality Name', c('address_id','address_component_value')],
            adComp[adComp$address_component_type=='Town/City Name', c('address_id','address_component_value')],
            by='address_id')
names(tt)[2:3] <- c('suburb','town')
# nrow(tt[duplicated(tt$address_id),])  # rather a lot of duplicated address_id
tt <- tt[!duplicated(tt$address_id),] # which we will omit

tt[tt$town=='', 'town'] <- tt[tt$town=='', 'suburb'] # if no town, copy suburb to town

# tt[tt$suburb=='',] # only 7 address_id with no suburb, 6 of which have no town either
tt <- tt[tt$suburb!='',] # so we will omit these

# Now merge with positions
tt <- merge(tt, adPos[, c('address_id','shape_X', 'shape_Y')])

rm(adComp, adPos) # remove adComp and adPos as they are large objects and no longer needed

# Now need to get 'average' location of each suburb and town
subPos <- aggregate(tt[, c('shape_X','shape_Y')], tt[, c('suburb','town')], mean)
townPos <- aggregate(tt[, c('shape_X','shape_Y')], list(tt$town), mean)
names(townPos)[1] <- 'town'

rm(tt) # remove tt as it is large objects and no longer needed


# Get addresses of members
addList <- gsheets::gsheet2tbl('https://docs.google.com/spreadsheets/d/117-hjbsw2lKb-ywtbMZV7Yqvw_eo1j9j8kk07WuxUgw/edit#gid=7')
addList <- as.data.frame(addList)[, c('Address2','Address3a','Region','Status')]
addList <- addList[tolower(addList$Status) %in% c('life member','member'),]
addList <- addList[!is.na(addList$Address2) | !is.na(addList$Address3a),]
addList[is.na(addList$Address3a), 'Address3a'] <- addList[is.na(addList$Address3a), 'Address2']
addList <- addList[addList$Region!='Overseas',]

# Identify central town for each region
regCent <- data.frame(Region=c('Auckland','Bay of Plenty','Canterbury','Christchurch','Coromandel','Dunedin','Hawkes Bay',
                               'Manawatu','Nelson/Marlborough','Northland','Otago','Taranaki','Waikato','Wellington'),
                      Centre=c('Auckland','Tauranga','Christchurch','Christchurch','Thames','Dunedin','Napier',
                               'Palmerston North','Nelson','Whangarei','Dunedin','New Plymouth','Hamilton','Wellington'),
                      stringsAsFactors=FALSE)
addList <- merge(addList, regCent)

# Regional numbers
cexReg <- table(addList$Centre)
posReg <- townPos[townPos$town %in% names(cexReg),]

?par
par(xpd=TRUE)
myCol <- col2rgb('lightBlue')
maps::map('nz', fill=TRUE, col='lightGreen')
points(posReg[,'shape_X'], posReg[,'shape_Y'], pch=16, cex=sqrt(cexReg)/2,
       col=rgb(myCol[1], myCol[1], myCol[1], max=255, alpha=180))
points(posReg[,'shape_X'], posReg[,'shape_Y'], pch=1, cex=sqrt(cexReg)/2, col='darkBlue')
myAdj <- c(1,0,0,1,0,1,1,1,0,0,0,0)
myOff <- -(myAdj*0.2 + (myAdj-1)*0.4)
for (i in 1:nrow(posReg))
{
  text(posReg[i,2]+myOff[i], posReg[i,3], posReg[i,1], adj=myAdj[i])
  # text(posReg[i,2]+myOff[i], posReg[i,3], names(cexReg)[i], adj=myAdj[i])
}
# Names should be regions not the main towns (e.g., Bay of Plenty rather than Tauranga)
# Also, consider Maori names