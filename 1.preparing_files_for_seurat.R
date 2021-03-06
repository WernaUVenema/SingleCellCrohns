# script to prepare raw data files to convert them to the Seurat file format

#######preparing data#########
# repeat for all patients
temp= list.files(pattern="UMIs_counts_per_gene_exon") ## lists input files per pool, change pattern for using either UMIs or TPMs/datacounts
# paste pre- and suffix to all colnames 
# column GENE is renamed to ensembl_gene_id for merging with annotation file
# unique name is assigned to pool
number_iel=10
number_lpl=20
number_blood=1
for (i in 1:length(temp)) { ## paste suffix to all colnames except for column "GENE" and assigns name to file accordingly
  if (grepl("IEL", temp[i])){
    my_file=read.table(temp[i], header=TRUE) ## make a table of the first file in the list temp, with colnames in the header
    my_file=as.data.frame(my_file) ## makes a data.frame of this file
    colnames(my_file) <- paste("1_IEL_", colnames(my_file), number_iel,sep = "") # Hi_IEL_ as prefix to column names and poolnr as suffix
    colnames(my_file)[1]="ensembl_gene_id" # changes the first column back to GENE in order to be able to merge later
    assign(paste0("prePool",number_iel), my_file)
    rm(my_file)
    number_iel=number_iel+1 # makes sure the cells from the next prepool will be numbered accordingly
  } else if (grepl("LPL", temp[i])){ # takes all files in the list temp with LPL in the file name
    
    my_file=read.table(temp[i], header=TRUE) ## make a table of the first file in the list temp, with colnames in the header
    my_file=as.data.frame(my_file) ## makes a data.frame of this file
    colnames(my_file) <- paste("1_LPL_", colnames(my_file), number_lpl,sep = "") # pastes Hi_LPL_ as prefix to column names and poolnr as suffix
    colnames(my_file)[1]="ensembl_gene_id" # changes the first column back to ensembl_gene_id in order to be able to merge later
    assign(paste0("prePool",number_lpl), my_file) # assignes a unique poolname to each prePool file
    rm(my_file)
    number_lpl=number_lpl+1 # makes sure the cells from the next prepool will be numbered accordingly
  } else if (grepl("blood", temp[i])){ # takes all files in the list temp with blood in the file name
    my_file=read.table(temp[i], header=TRUE) ## make a table of the first file in the list temp, with colnames in the header
    my_file=as.data.frame(my_file) ## makes a data.frame of this file
    colnames(my_file) <- paste("1_BLOOD_", colnames(my_file), number_blood,sep = "") # pastes Hi_BLOOD_ as prefix to column names and poolnr as suffix
    colnames(my_file)[1]="ensembl_gene_id" # changes the first column back to ensembl_gene_id in order to be able to merge later
    assign(paste0("prePool",number_blood), my_file) # assignes a unique poolname to each prePool file
    rm(my_file)
    number_blood=number_blood+1 # makes sure the cells from the next prepool will be numbered accordingly
  } else {print ("Error!!!")}
}

## merge files named 'prePoolx' by ensembl_gene_id, keeping all genes, and change column ensembl_gene_id to rownames and store as numeric data matrix first_file
my_count=1
for (i in mget(ls(pattern="prePool"))) { ## mget searches for an r-object with a given name, ls makes sure the search is within the global environment
  if (my_count==1){ ##names the first file i that is found hereabove 'first_file'
    first_file=i
    my_count=my_count+1 ## makes sure the second file i enters the 'else' part
  }
  else{  
    first_file=merge(first_file,i, by="ensembl_gene_id", all=TRUE) ## merges first file with all the other files in the global environment that have the patter prePool. set all=F for merging only genes expressed in all pools
  }
  first_file[is.na(first_file)]<-0 ## all NAs to zero
  rm(i)
}
# give patient-specific id to first_file
first_file_pt1<-first_file
# and continue from '#######preparing data#########' with data of patient 2

# merge first_files of all patients
second_file<-merge(first_file_pt1, first_file_pt2, by="ensembl_gene_id", all=TRUE)
second_file<-merge(second_file, first_file_pt3, by="ensembl_gene_id", all=TRUE)
second_file<-merge(second_file, first_file_pt3.1, by="ensembl_gene_id", all=TRUE)

# add gene symbols to second_file
# create a file containing all ensembl_geneName_mapping<-read.csv("..") # get annotation file
second_file<-merge(ensembl_geneName_mapping, second_file, by="ensembl_gene_id") # merge second_file with annotationfile
second_file$ensembl_gene_id<-paste(second_file$ensembl_gene_id, second_file$NEW, sep="_") # paste ensebl gene, chromosome name and genesymbol
row.names(second_file)=second_file$ensembl_gene_id
third_file<-second_file # assign the second_file file to third_file
fourth_file<-third_file[,-c(1:10)] # remove all non-numeric columns

View(fourth_file)
fourth_file[is.na(fourth_file)]<-0 ## all NAs to zero

save(fourth_file, file="..")
