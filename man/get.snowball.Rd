% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get.snowball.R
\name{get.snowball}
\alias{get.snowball}
\title{Generates dataframe with all dependencies needed to install a package, in the order they will be loaded}
\usage{
get.snowball(pkg, date, include.suggests = FALSE, force.source = FALSE)
}
\arguments{
\item{pkg}{character string, name of target package to load (and install if needed),}

\item{date}{character string  (yyyy-mm-dd), or date value, with the date which determines the
version of the package, and all dependencies, to be loaded (and installed if needed).}

\item{include.suggests}{logical, defaults to \code{FALSE}. When set to \code{TRUE}, includes
dependencies classified in the DESCRIPTION file as \code{suggested}.}

\item{force.source}{logical (defaults to \code{FALSE}). When set to \code{TRUE}, will not attempt
installing binary from CRAN or MRAN and instead download source file and install it.}
}
\value{
a dataframe with all packages that need to be installed, their version , whether they are installed, where
to obtain them if not locally available (CRAN vs MRAN), which date to use for MRAN,
installation time from source (in seconds), and local path for storage
}
\description{
Generates dataframe with all dependencies needed to install a package, in the order they will be loaded
}
\examples{
\dontrun{
get.snowball("rio", "2020-07-12")
}
}
