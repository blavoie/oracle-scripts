# here is a pdf for mining
url <- "http://www.oracle.com/pls/db112/to_pdf?pathname=server.112/e25789.pdf"
dest <- tempfile(fileext = ".pdf")
download.file(url, dest, mode = "wb")

# set path to pdftotxt.exe and convert pdf to text
exe <- "C:\\Program Files (x86)\\GnuWin32\\bin\\pdftotext.exe"
system(paste("\"", exe, "\" \"", dest, "\"", sep = ""), wait = F)

# get txt-file name and open it
filetxt <- sub(".pdf", ".txt", dest)
shell.exec(filetxt); shell.exec(filetxt) # strangely the first try always throws an error..

# do something with it, i.e. a simple word cloud
library(tm)
library(wordcloud)
library(Rstem)

txt <- readLines(filetxt) # don't mind warning..

txt <- tolower(txt)
txt <- removeWords(txt, c("\\f", stopwords()))

corpus <- Corpus(VectorSource(txt))
corpus <- tm_map(corpus, removePunctuation)
tdm <- TermDocumentMatrix(corpus)
m <- as.matrix(tdm)
d <- data.frame(freq = sort(rowSums(m), decreasing = TRUE))

# Stem words
d$stem <- wordStem(row.names(d), language = "english")

# and put words to column, otherwise they would be lost when aggregating
d$word <- row.names(d)

# remove web address (very long string):
d <- d[nchar(row.names(d)) < 20, ]

# aggregate freqeuncy by word stem and
# keep first words..
agg_freq <- aggregate(freq ~ stem, data = d, sum)
agg_word <- aggregate(word ~ stem, data = d, function(x) x[1])

d <- cbind(freq = agg_freq[, 2], agg_word)

# sort by frequency
d <- d[order(d$freq, decreasing = T), ]

# print wordcloud:
wordcloud(d$word, d$freq)

# remove files
file.remove(dir(tempdir(), full.name=T)) # remove files