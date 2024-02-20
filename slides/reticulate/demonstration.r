#setwd('git/RaukR-2021/docs/reticulate_Nina/presentation_reticulate/')
library(reticulate)
use_condaenv("raukr", required = TRUE)
source_python("python_functions.py")
source_python("python_functions.py", convert = FALSE)


# single-element vector
r_var <- 1
typeof(r_var)
r_var2 <- check_python_type(r_var)
str(r_var2)

# multi-element vector
r_var <- c(1,2,3,4)
str(r_var)
r_var2 <- check_python_type(r_var)
str(r_var2)

# list of multiple types
r_var <- c(1L, TRUE, "foo")
str(r_var)
r_var2 <- check_python_type(r_var)
str(r_var2)

# Named list
r_var <- list(a = 1L, b = 2.0)
str(r_var)
r_var2 <- check_python_type(r_var)
str(r_var2)

# Matrix/Array
r_var <- matrix(c(1,2,3,4),nrow=2, ncol=2)
class(r_var)
r_var2 <- check_python_type(r_var)
class(r_var2)

# Data Frame
r_var <- data.frame(x = c(1,2,3), y = c('a','b','c'))
class(r_var)
r_var2 <- check_python_type(r_var)
class(r_var2)



  