% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{ngeoSD}
\alias{ngeoSD}
\title{Get the geometric standard deviation of a vector}
\usage{
ngeoSD(x, thresh = 0.5)
}
\arguments{
\item{x}{numeric vector}

\item{thresh}{minimum numeric value greater than 0 to have in vector}
}
\value{
numeric geometric standard deviation of vector
}
\description{
Get the geometric standard deviation of a vector
}
\examples{
ngeoSD(c(0, 1, 2, 2), thresh=0.1)

}
