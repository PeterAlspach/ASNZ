# This reads the address componets and saves the relevant bits for future use

# The address location data was downloaded from LINZ comprehensive AIMS adress tables (https://data.linz.govt.nz/set/87),
# as csv files under the WGS 84 projection (to match the mapping used in R).
# Only aims-address-position.csv and aims-address-components.csv are used

# Read address position
adPos <- read.csv('~/LINZCoordinates/aims-address-position/aims-address-position.csv', stringsAsFactors=FALSE)
# nrow(adPos[duplicated(adPos$address_id),]) # one duplicate address_id
# adPos[adPos$address_id==361207,]                        # which we'll omit
adPos <- adPos[!duplicated(adPos$address_id),]

# Read address components
adComp <- read.csv('~/LINZCoordinates/aims-address-component/aims-address-component.csv', stringsAsFactors=FALSE)
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

save(subPos, townPos, file='townAndSuburbPositions')
