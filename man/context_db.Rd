% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/storr.R
\name{context_db}
\alias{context_db}
\alias{context_root}
\title{Get the context db}
\usage{
context_db(x)

context_root(x)
}
\arguments{
\item{x}{An object (see Details)}
}
\value{
The storr database used by this context
}
\description{
Get a context db or root by way of some object.
}
\details{
Valid options for \code{x} are

\describe{

\item{A character string}{Assumed to the the root directory for
the context.  \code{context} stores information in the root
directory about the database format and can load the database
given this}.

\item{A storr database}{Assumed, without checking, to be the
correct database.}

\item{A list-like or environment-like object}{If this object has
an element \code{db} that is a storr object it is assumed to the
be database.  Otherwise if it has a character element \code{root}
that is assumed to the root.  Otherwise it is an error.}
}

This all seems a bit complicated but allows use from R functions
without requiring a lot of set-up while at the same time allows
other functions to efficiently interact with the database.
}

