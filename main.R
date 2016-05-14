
library("seqinr")
getwd()
dnafile <- read.fasta("Fragaria_vesca.fasta")
length(dnafile)
n1<-dnafile[[2]]
table1 <- count(n1,1) #counts the number of nucleotides
table2 <- count(n1,2) #counts the number of dinucleotides
table3 <- count(n1,3) #counts the number of trinucleotides
GC(n1) #GC content
annotation <- getAnnot(dnafile) #storing the fasta header

#graphs for the fragaria vesca
barplot(table1, main="Nucleotides Count for the Fragaria Vesca", xlab="Nucleotides",las=1, col=blues9)
barplot(table2, main="Dinucleotides Count for the Fragaria Vesca", xlab="Dinucleotides", las=1, col=blues9)
barplot(table3, main="Trinucleotides Count for the Fragaria Vesca", xlab="Trinucleotides", las=1, col=blues9)

############################################################
dnafile2 <- read.fasta("Fragaria_ananassa.fasta")
length(dnafile2)
n2<-dnafile[[2]]
table4 <- count(n2,1)
table5 <- count(n2,2)
table6 <- count(n3,3)
GC(n1)
annotation <- getAnnot(dnafile2)

barplot(table4, main="Nucleotides Count for the Fragaria Ananassa", xlab="Nucleotides",las=1)
barplot(table5, main="Dinucleotides Count for the Fragaria Ananassa", xlab="Dinucleotides", las=1)
barplot(table6, main="Trinucleotides Count for the Fragaria Ananassa", xlab="Trinucleotides", las=1)


