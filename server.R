library(shiny)
library(shinyFiles)
library(DT)
#####################
# allez function
#####################


enrich_allez <- function(File, FileSep, alter, namev, alterTotal, nameTotalv, Local, LocalSep, outprefix, lib.v, side,  Lowersetsize, Uppersetsize, pcut ){

# csv or txt
FileType <- FileSep

if(alter==FALSE){
if(FileType=="csv"){
	cat("\n Read in csv file \n")
	prefix=strsplit(File,split="\\.csv")[[1]][1]
	In=read.csv(File,stringsAsFactors=F,row.names=1)
}
if(FileType!="csv"){
	cat("\n Read in tab delimited file \n")
	prefix=strsplit(File,split=paste0("\\.",FileType))[[1]][1]
	In=read.table(File,stringsAsFactors=F,row.names=1)
	if(!is.numeric(In[[1]]))In=read.table(File,stringsAsFactors=F,row.names=1,header=T)
}
Score=In[[1]]
names(Score)=rownames(In)
}
if(alterTotal==TRUE) {	
 allgnames <- unique(nameTotalv)
} else {
 allgnames <- unique(unlist(as.list(get(paste0(lib.v,"SYMBOL")))))
}
if(alter==TRUE){
	Score <- rep(0, length(allgnames))
	names(Score) <- as.vector(allgnames)
	Score[intersect(names(Score),namev)] <- 1
}


if(!is.null(Local)){
	FileType2=LocalSep

	if(FileType2=="csv"){
		cat("\n Read in csv file (gene list)\n")
		ListIn=read.csv(Local,stringsAsFactors=F,row.names=1)
	}
	if(FileType2!="csv"){
		cat("\n Read in tab delimited file (gene list)\n")
		ListIn=read.table(Local,stringsAsFactors=F,row.names=1)
	}
	if(nrow(ListIn)>1){
	List=sapply(1:nrow(ListIn),function(i)setdiff(as.vector(ListIn[i,]),c(""," ")))
	}
	if(nrow(ListIn)==1) {
		List=vector("list",1)
		List[[1]]=setdiff(unlist(ListIn),c(""," "))}

	names(List)=rownames(ListIn)

} else List=NULL

library(allez)
#browser()
Out=allez(score=Score,lib=lib.v,idtype="SYMBOL",locallist=List)

Mat=Out$setscores[,c("Term","set.mean","set.sd","set.size","z.score")]
message(c("one tailed p value?", side))
if(side=="F")Mat$p.value <- pnorm(-abs(Mat$z.score))# two tailed
if(side=="T"){
	prb <- pnorm(Mat$z.score)# one tailed
	Mat$p.value <- ifelse(1-prb>prb, prb, 1-prb)*2
}
Mat$p.adj <- p.adjust(Mat$p.value, method="BH")
Mat <- Mat[which(Mat$set.size>Lowersetsize),]
Mat <- Mat[which(Mat$set.size<Uppersetsize),]
MatOut <- Mat[order(Mat$p.value),c("Term","p.value","p.adj","z.score","set.size","set.mean","set.sd")]

message("sets with size < ",Lowersetsize, " or > ", Uppersetsize, " are not considered" )
LocalOut <- MatOut[which(is.na(MatOut[,"Term"])),]
MatOut2 <-  cbind(rownames(MatOut), MatOut)
LocalOut2 <- cbind(rownames(LocalOut), LocalOut)
colnames(MatOut2)[1] = colnames(LocalOut2)[1] = "GO_ID"

if(alter==TRUE){
Mat.Cats <- rownames(MatOut2)
Mat.Aux <- Out$aux$set.data
gInData <- names(which(Score==1))
Mat.Aux <- Mat.Aux[which(Mat.Aux$symbol %in% gInData),]

MaxCat <- pmin(length(Mat.Cats), 1000)

GenesInCats <- lapply(1:MaxCat, function(x) {
  useg <- Mat.Aux[which(Mat.Aux$go_id == Mat.Cats[x]),"symbol"]
  numOL <- length(useg)
  gcats <- paste0(useg, collapse=", ")
  return(list(gcats, numOL))
  })
NumInCats <- unlist(sapply(GenesInCats, function(x) x[2]))
if(length(Mat.Cats) > 1000) {NumInCats <- c(NumInCats, rep(0, length(Mat.Cats) - MaxCat))}
names(NumInCats) <- Mat.Cats
GenesInCats <- unlist(sapply(GenesInCats, function(x) x[1]))
if(length(Mat.Cats) > 1000) {GenesInCats <- c(GenesInCats, rep("", length(Mat.Cats) - MaxCat))}
names(GenesInCats) <- Mat.Cats


MatOut2 <- data.frame(MatOut2[Mat.Cats,], num.overlap = NumInCats[Mat.Cats], Genes = GenesInCats[Mat.Cats])
}

write.table(MatOut2,file=paste0(outprefix,"_enrichment_allsets.txt"),sep="\t", row.names=F)
if(!is.null(Local)){
  write.table(LocalOut2,file=paste0(outprefix,"_enrichment_localsets.txt"), sep="\t", row.names=F)
}

Mat.p <- MatOut2[which(MatOut2$p.adj <= pcut),]
Local.p <- LocalOut2[which(LocalOut2$p.adj <= pcut),]
write.table(Mat.p,file=paste0(outprefix,"_enrichment_allsets_sig.txt"),sep="\t", row.names=F)

if(!is.null(Local)){
  write.table(Local.p,file=paste0(outprefix,"_enrichment_localsets_sig.txt"), sep="\t", row.names=F)
}

Out <- list(Allres=MatOut2, Localres=LocalOut2, SigAllres=Mat.p, SigLocalres=Local.p)
}

#####################
# EASE david
#####################
enrich_ease <- function(File, FileSep, alter, namev, Local, LocalSep, outprefix, lib.v,  Lowersetsize, Uppersetsize, pcut ){
# csv or txt
FileType=FileSep

if(alter==FALSE){
if(FileType=="csv"){
	cat("\n Read in csv file \n")
	prefix=strsplit(File,split="\\.csv")[[1]][1]
	In=read.csv(File,stringsAsFactors=F,row.names=1)
}
if(FileType!="csv"){
	cat("\n Read in tab delimited file \n")
	prefix=strsplit(File,split=paste0("\\.",FileType))[[1]][1]
	In=read.table(File,stringsAsFactors=F,row.names=1)
	if(!is.numeric(In[[1]]))In=read.table(File,stringsAsFactors=F,row.names=1,header=T)
}
Score=In[[1]]
names(Score)=rownames(In)
}
if(alter==TRUE){
	allgnames <- unique(unlist(as.list(get(paste0(lib.v,"SYMBOL")))))
	Score <- rep(0, length(allgnames))
	names(Score) <- as.vector(allgnames)
	Score[intersect(names(Score),namev)] <- 1
}


if(!is.null(Local)){
	FileType2=LocalSep

	if(FileType2=="csv"){
		cat("\n Read in csv file (gene list)\n")
		ListIn=read.csv(Local,stringsAsFactors=F,row.names=1)
	}
	if(FileType2!="csv"){
		cat("\n Read in tab delimited file (gene list)\n")
		ListIn=read.table(Local,stringsAsFactors=F,row.names=1)
	}
	if(nrow(ListIn)>1){
	List=sapply(1:nrow(ListIn),function(i)setdiff(as.vector(ListIn[i,]),c(""," ")))
	}
	if(nrow(ListIn)==1) {
		List=vector("list",1)
		List[[1]]=setdiff(unlist(ListIn),c(""," "))}

	names(List)=rownames(ListIn)

} else List=NULL


library(EACI)
if(length(setdiff(Score,c(0,1)))>0) stop("EASE(DAVID) only takes binary inputs!")

Out=easetest(score=Score,lib=lib.v,idtype="SYMBOL",locallist=List, minsetsize=Lowersetsize)

Mat=Out$setscores[,c("Term","set.size","pval")]
Mat$p.adj <- p.adjust(Mat$pval, method="BH")
Mat <- Mat[which(Mat$set.size>Lowersetsize),]
Mat <- Mat[which(Mat$set.size<Uppersetsize),]
message("sets with size < ",Lowersetsize, " or > ", Uppersetsize, " are not considered" )
MatOut=Mat[order(Mat$pval),c("Term","pval","p.adj","set.size")]


LocalOut=MatOut[which(is.na(MatOut[,"Term"])),]
MatOut2 <-  cbind(rownames(MatOut), MatOut)
LocalOut2 <- cbind(rownames(LocalOut), LocalOut)
colnames(MatOut2)[1] = colnames(LocalOut2)[1] = "GO_ID"
write.table(MatOut2,file=paste0(outprefix,"_DavidEASEenrichment_allsets.txt"),sep="\t", row.names=F)
write.table(LocalOut2,file=paste0(outprefix,"_DavidEASEenrichment_localsets.txt"), sep="\t", row.names=F)

Mat.p <- MatOut2[which(MatOut2$p.adj<=pcut),]
Local.p <- LocalOut2[which(LocalOut2$p.adj<=pcut),]
write.table(Mat.p,file=paste0(outprefix,"_DavidEASEenrichment_enrichment_allsets_sig.txt"),sep="\t", row.names=F)
write.table(Local.p,file=paste0(outprefix,"_DavidEASEenrichment_enrichment_localsets_sig.txt"), sep="\t", row.names=F)

Out=list(Allres=MatOut2, Localres=LocalOut2, SigAllres=Mat.p, SigLocalres=Local.p)
}


#####################
# EACI
#####################

enrich_eaci <- function(File, FileSep,alter, namev, Local, LocalSep, outprefix, lib.v, side,  Lowersetsize, Uppersetsize, pcut ){
# csv or txt
FileType=FileSep

if(alter==FALSE){
if(FileType=="csv"){
	cat("\n Read in csv file \n")
	prefix=strsplit(File,split="\\.csv")[[1]][1]
	In=read.csv(File,stringsAsFactors=F,row.names=1)
}
if(FileType!="csv"){
	cat("\n Read in tab delimited file \n")
	prefix=strsplit(File,split=paste0("\\.",FileType))[[1]][1]
	In=read.table(File,stringsAsFactors=F,row.names=1)
	if(!is.numeric(In[[1]]))In=read.table(File,stringsAsFactors=F,row.names=1,header=T)
}
Score=In[[1]]
names(Score)=rownames(In)
}
if(alter==TRUE){
	allgnames <- unique(unlist(as.list(get(paste0(lib.v,"SYMBOL")))))
	Score <- rep(0, length(allgnames))
	names(Score) <- as.vector(allgnames)
	Score[intersect(names(Score),namev)] <- 1
}

if(!is.null(Local)){
	FileType2=LocalSep

	if(FileType2=="csv"){
		cat("\n Read in csv file (gene list)\n")
		ListIn=read.csv(Local,stringsAsFactors=F,row.names=1)
	}
	if(FileType2!="csv"){
		cat("\n Read in tab delimited file (gene list)\n")
		ListIn=read.table(Local,stringsAsFactors=F,row.names=1)
	}
	if(nrow(ListIn)>1){
	List=sapply(1:nrow(ListIn),function(i)setdiff(as.vector(ListIn[i,]),c(""," ")))
	}
	if(nrow(ListIn)==1) {
		List=vector("list",1)
		List[[1]]=setdiff(unlist(ListIn),c(""," "))}

	names(List)=rownames(ListIn)

} else List=NULL

library(EACI)
Out=eacitest(score=Score,lib=lib.v,idtype="SYMBOL",locallist=List,iter=10, minsetsize=Lowersetsize)

Mat=Out[[1]][,c("Term","set.mean","set.sd","set.size","pval")]
p.val.raw <- Mat$pval
if(side=="F") p.val <- p.val.raw
if(side=="T"){
	tmp <- (Mat$set.mean-Out$aux$meanbg)/sd(Mat$set.mean)
	p.val <- pnorm(-abs(tmp))
	}	
Mat$p.adj <- p.adjust(p.val, method="BH")
Mat <- Mat[which(Mat$set.size>Lowersetsize),]
Mat <- Mat[which(Mat$set.size<Uppersetsize),]
MatOut=Mat[order(Mat$pval),c("Term","pval","p.adj","set.size","set.mean","set.sd")]
message("sets with size < ",Lowersetsize, " or > ", Uppersetsize, " are not considered" )


LocalOut=MatOut[which(is.na(MatOut[,"Term"])),]

MatOut2 <-  cbind(rownames(MatOut), MatOut)
LocalOut2 <- cbind(rownames(LocalOut), LocalOut)
colnames(MatOut2)[1] = colnames(LocalOut2)[1] = "GO_ID"
write.table(MatOut2,file=paste0(outprefix,"_EACIenrichment_allsets.txt"),sep="\t", row.names=F)
write.table(LocalOut2,file=paste0(outprefix,"_EACIenrichment_localsets.txt"), sep="\t", row.names=F)

Mat.p <- MatOut2[which(MatOut2$p.adj<=pcut),]
Local.p <- LocalOut2[which(LocalOut2$p.adj<=pcut),]
write.table(Mat.p,file=paste0(outprefix,"_EACIenrichment_allsets_sig.txt"),sep="\t", row.names=F)
write.table(Local.p,file=paste0(outprefix,"_EACIenrichment_localsets_sig.txt"), sep="\t", row.names=F)


Out=list(Allres=MatOut2, Localres=LocalOut2, SigAllres=Mat.p, SigLocalres=Local.p)
}


getVolumesRB <- function () 
{
    osSystem <- Sys.info()["sysname"]
    if (osSystem == "Darwin") {
        volumes <- list.files("/Volumes/", full.names = T)
        names(volumes) <- basename(volumes)
    }
    else if (osSystem == "Linux") {
        volumes <- c(Computer = "/")
        media <- list.files("/media/", full.names = T)
        names(media) <- basename(media)
        volumes <- c(volumes, media)
    }
    else if (osSystem == "Windows") {
        volumes <- system("wmic logicaldisk get Caption", intern = T)
        volumes <- sub(" *\\r$", "", volumes)
        keep <- !tolower(volumes) %in% c("caption", "")
        volumes <- volumes[keep]
        volNames <- system("wmic logicaldisk get VolumeName", 
            intern = T)
        volNames <- sub(" *\\r$", "", volNames)
        volNames <- volNames[keep]
        volNames <- paste0(volNames, ifelse(volNames == "", "", 
            " "))
        volNames <- paste0(volNames, "(", volumes, ")")
        names(volumes) <- volNames
    }
    else {
        stop("unsupported OS")
    }
    volumes
}

#####################
#####################
# Define server logic for slider examples
#####################
#####################
shinyServer(function(input, output, session) {
		volumes <- getVolumesRB()
		shinyDirChoose(input, 'Outdir', roots=volumes, session=session, restrictions=system.file(package='base'))
  output$Dir <- renderPrint({parseDirPath(volumes, input$Outdir)})
    
		In <- reactive({

		outdir <- parseDirPath(volumes, input$Outdir)
  print(outdir)
  
		the.file <- input$filename$name #input
		file.tf <- ifelse(is.null(the.file),FALSE,TRUE)
		file.toread <- NULL
		file.sep <- NULL
		if(file.tf==TRUE){
			file.toread <- input$filename$datapath	
			file.sep0 <- strsplit(the.file,split="\\.")[[1]]
			file.sep <- file.sep0[length(file.sep0)]
		}
		
		Group.file <- input$markerlist$name # markerlist
  	GroupB <- ifelse(is.null(Group.file),FALSE,TRUE)
		mklist.toread <- NULL
		mklist.sep <- NULL
		if(GroupB==TRUE){
			mklist.toread <- input$markerlist$datapath
			mklist.sep0 <- strsplit(Group.file,split="\\.")[[1]]
			mklist.sep <- mklist.sep0[length(mklist.sep0)]
		}

		#browser()
		namev <- NULL
		gn.file <- input$genename$name
		gntf <- ifelse(is.null(gn.file),FALSE,TRUE)
		if(!is.null(gn.file))namev <- read.csv(input$genename$datapath,stringsAsFactors=F, header=F)[[1]]
		
 		namevAll <- NULL
 		gn.file.total <- input$allgenes$name
 		gntfAll <- ifelse(is.null(gn.file.total),FALSE,TRUE)
 		if(!is.null(gn.file.total))namevAll <- read.csv(input$allgenes$datapath,stringsAsFactors=F, header=F)[[1]]
		
  
		method.v <- c("allez","EACI","EASE")
		List <- list(
		alterinput = gntf,	namev=namev,		
  alterTotalInput = gntfAll, nameTotalv=namevAll,		
		Input = file.toread, Inputsep=file.sep,
		mkInput = mklist.toread, mkSep=mklist.sep,
		Dir=outdir, out_pre=input$exFileName,
		lower=as.numeric(input$llsize),
		upper=as.numeric(input$ulsize),
		species=ifelse(input$species_buttons=="1","human","mouse"),
		method_use = method.v[as.numeric(input$method_buttons)],
		one_tail=ifelse(input$tail_buttons=="1","T","F"),
		pval_cutoff=input$pcut
)
		# main function
		db.v <- List$species
		if(db.v=="human")lib.v <- "org.Hs.eg"
		if(db.v=="mouse")lib.v <- "org.Mm.eg"
		pkgname <- paste0(lib.v,".db")
		#browser()
		library(pkgname,character.only = TRUE)

		if(List$method_use=="allez"){
		Res <- enrich_allez(File=List$Input, FileSep=List$Inputsep, 
												alter=List$alterinput, namev=List$namev,
            alterTotal=List$alterTotalInput, nameTotalv=List$nameTotalv,
												outprefix=paste(List$Dir,List$out_pre,sep="/"),
							Local=List$mkInput, LocalSep=List$mkSep,
							lib.v=lib.v, side=List$one_tail,  
							Lowersetsize=List$lower, Uppersetsize=List$upper,
							pcut=List$pval_cutoff)
		
		}

		if(List$method_use=="EACI"){
		Res <- enrich_eaci(File=List$Input, FileSep=List$Inputsep, 
											 alter=List$alterinput,namev=List$namev,
												outprefix=paste(List$Dir,List$out_pre,sep="/"),
							Local=List$mkInput, LocalSep=List$mkSep,
							lib.v=lib.v, side=List$one_tail,  
							Lowersetsize=List$lower, Uppersetsize=List$upper,
							pcut=List$pval_cutoff)
		
		}

		if(List$method_use=="EASE"){
		Res <- enrich_ease(File=List$Input, FileSep=List$Inputsep,
											 alter=List$alterinput,namev=List$namev,
												outprefix=paste(List$Dir,List$out_pre,sep="/"),
							Local=List$mkInput, LocalSep=List$mkSep,
							lib.v=lib.v, 
							Lowersetsize=List$lower, Uppersetsize=List$upper,
							pcut=List$pval_cutoff)
		
		}



	 	List=c(List, Res)	
}) 

  Act <- eventReactive(input$Submit,{
		      In()})
	# Show the values using an HTML table
  output$print0 <- renderText({
				tmp <- Act()
				paste("# significant sets:",
							nrow(tmp$SigAllres),
							" (shown below); output directory:", tmp$Dir)
  })

output$tab <- DT::renderDataTable({
		tmp <- Act()$SigAllres[,1:9]
		tmp[,1] <- as.character(tmp[,1])
		tmp[3:9]<-round(tmp[3:9], 3)
		t1 <- tmp
		print("done")
		DT::datatable(t1, rownames = F)
		})

#	output$done <- renderText({"Done"})
})
