# First load the town and suburb positions as saved by AIMSComponents.R
load('townAndSuburbPositions')

# Get addresses of members
addList <- gsheet::gsheet2tbl('https://docs.google.com/spreadsheets/d/117-hjbsw2lKb-ywtbMZV7Yqvw_eo1j9j8kk07WuxUgw/edit#gid=7')
addList <- as.data.frame(addList)[, c('Address2','Address3a','Region','Status')]
addList <- addList[tolower(addList$Status) %in% c('life member','member'),]
addList <- addList[!is.na(addList$Address2) | !is.na(addList$Address3a),]
addList[is.na(addList$Address3a), 'Address3a'] <- addList[is.na(addList$Address3a), 'Address2']
addList <- addList[addList$Region!='Overseas',]

# Identify central town for each region
regCent <- data.frame(Region=c('Auckland','Bay of Plenty','Canterbury','Christchurch','Coromandel','Dunedin','Hawkes Bay',
                               'Manawatu','Nelson/Marlborough','Northland','Otago','Taranaki','Waikato','Wellington','West Coast'),
                      Reo=c('T\u101maki-makau-rau','Te Moana-a-Toi','Waitaha','Waitaha','Hauraki','\u14ct\u101kou','Te Matau-a-M\u101ui',
                            'Manawat\u16b','Te Tau Ihu o Te Waka a M\u101ui','Te Tai Tokerau','\u14ct\u101kou','Taranaki','Waikato',
                            'Te Whanganui-a-Tara','Te Tai Poutini'),
                      Centre=c('Auckland','Tauranga','Christchurch','Christchurch','Thames','Dunedin','Napier',
                               'Palmerston North','Nelson','Whangarei','Dunedin','New Plymouth','Hamilton','Wellington','Greymouth'),
                      stringsAsFactors=FALSE)
addList <- merge(addList, regCent)

# Regional numbers
cexReg <- table(addList$Centre)
nosByReg <- data.frame(cex=cexReg, townPos[townPos$town %in% names(cexReg), -1])
nosByReg <- merge(regCent[!(regCent$Region %in% c('Christchurch','Dunedin')),], nosByReg, by.x='Centre', by.y='cex.Var1')

par(xpd=TRUE, mar=rep(0, 4))
myCol <- col2rgb('lightBlue')
maps::map('nz', fill=TRUE, col='lightGreen')
points(nosByReg[,'shape_X'], nosByReg[,'shape_Y'], pch=16, cex=sqrt(cexReg)/2,
       col=rgb(myCol[1], myCol[1], myCol[1], max=255, alpha=180))
points(nosByReg[,'shape_X'], nosByReg[,'shape_Y'], pch=1, cex=sqrt(cexReg)/2, col='darkBlue')
myAdj <- c(1,0,0,1,1,0,1,1,1,0,0,0,0)
myOff <- (1-2*myAdj)*0.3
for (i in 1:nrow(nosByReg))
{
  # text(nosByReg[i, 'shape_X']+myOff[i], nosByReg[i, 'shape_Y'], nosByReg[i, 'Region'], adj=myAdj[i], cex=0.8)
  # text(nosByReg[i, 'shape_X']+myOff[i], nosByReg[i, 'shape_Y'], nosByReg[i, 'Reo'], adj=myAdj[i], cex=0.8)
  text(nosByReg[i, 'shape_X']+myOff[i], nosByReg[i, 'shape_Y'], paste(nosByReg[i, 'Region'], nosByReg[i, 'Reo'], sep='\n'),
       adj=myAdj[i], cex=0.6)
}

