# Example taken from : http://horicky.blogspot.ca/2013/07/olap-operation-in-r.html?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed:+blogspot/jwqut+(Pragmatic+Programming+Techniques)

# Setup the dimension tables

state_table <- 
    data.frame(key=c("CA", "NY", "WA", "ON", "QU"),
               name=c("California", "new York", "Washington", "Ontario", "Quebec"),
               country=c("USA", "USA", "USA", "Canada", "Canada"))

month_table <- 
    data.frame(key=1:12,
               desc=c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
               quarter=c("Q1","Q1","Q1","Q2","Q2","Q2","Q3","Q3","Q3","Q4","Q4","Q4"))

prod_table <- 
    data.frame(key=c("Printer", "Tablet", "Laptop"),
               price=c(225, 570, 1120))

# Function to generate the Sales table
gen_sales <- function(no_of_recs) {
    # Generate transaction data randomly
    loc <- sample(state_table$key, no_of_recs, replace=T, prob=c(2,2,1,1,1))
    time_month <- sample(month_table$key, no_of_recs, replace=T)
    time_year <- sample(c(2012, 2013), no_of_recs, replace=T)
    prod <- sample(prod_table$key, no_of_recs, replace=T, prob=c(1, 3, 2))
    unit <- sample(c(1,2), no_of_recs, replace=T, prob=c(10, 3))
    amount <- unit*prod_table[prod,]$price
    
    sales <- data.frame(month=time_month,
                        year=time_year,
                        loc=loc,
                        prod=prod,
                        unit=unit,
                        amount=amount)
    
    # Sort the records by time order
    sales <- sales[order(sales$year, sales$month),]
    row.names(sales) <- NULL
    return(sales)
}

# Now create the sales fact table
sales_fact <- gen_sales(500)

# Build up a cube
revenue_cube <- 
    tapply(sales_fact$amount, 
           sales_fact[,c("prod", "month", "year", "loc")], 
           FUN=function(x){return(sum(x))})

# Showing the cells of the cube
revenue_cube

# Showing dimensions of the cube
dimnames(revenue_cube)

###########################
# Slice
###########################

# "Slice" is about fixing certain dimensions to analyze the remaining dimensions.  
# For example, we can focus in the sales happening in "2012", "Jan", or we can 
# focus in the sales happening in "2012", "Jan", "Tablet".

# Slice cube data in Jan, 2012
revenue_cube[, "1", "2012",]

# Slice cube data for Tablets in Jan, 2012
revenue_cube["Tablet", "1", "2012",]

###########################
# Dice
###########################

# "Dice" is about limited each dimension to a certain range of values, while 
# keeping the number of dimensions the same in the resulting cube.  For example,
# we can focus in sales happening in [Jan/ Feb/Mar, Laptop/Tablet, CA/NY].

revenue_cube[c("Tablet","Laptop"), 
             c("1","2","3"), 
             ,
             c("CA","NY")]

###########################
# Rollup
###########################

# "Rollup" is about applying an aggregation function to collapse a number of 
# dimensions.  For example, we want to focus in the annual revenue for each 
# product and collapse the location dimension (ie: we don't care where we sold 
# our product).  

apply(revenue_cube, c("year", "prod"),
      FUN=function(x) {return(sum(x, na.rm=TRUE))})

###########################
# Drilldown
###########################

# "Drilldown" is the reverse of "rollup" and applying an aggregation function 
# to a finer level of granularity.  For example, we want to focus in the annual 
# and monthly revenue for each product and collapse the location dimension 
# (ie: we don't care where we sold our product).

apply(revenue_cube, c("year", "month", "prod"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})

###########################
# Pivot
###########################

# "Pivot" is about analyzing the combination of a pair of selected dimensions.  
# For example, we want to analyze the revenue by year and month.  Or we want to 
# analyze the revenue by product and location.

apply(revenue_cube, c("year", "month"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})

apply(revenue_cube, c("prod", "loc"),
      FUN=function(x) {return(sum(x, na.rm=TRUE))})