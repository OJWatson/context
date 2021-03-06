% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/task.R
\name{tasks_times}
\alias{tasks_times}
\title{Fetch task times}
\usage{
tasks_times(handle, unit_elapsed = "secs", sorted = TRUE)
}
\arguments{
\item{handle}{A task handle.  If the task handle has a
\emph{vector} of ids in it, then it represents a number of
tasks.  This will create a data.frame with that many rows.}

\item{unit_elapsed}{Elapsed time unit.  The default is "secs".
This is passed to the \code{as.numeric} method of a
\code{difftime} object.}

\item{sorted}{Sort the output in terms of submitted time?  If
\code{FALSE} then the output is sorted based on task ids.}
}
\description{
Fetch times taken to queue, run, and since running a task.
}
\author{
Rich FitzJohn
}

