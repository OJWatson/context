% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/context.R
\name{context_save}
\alias{context_handle}
\alias{context_load}
\alias{context_read}
\alias{context_save}
\alias{contexts_list}
\title{Save and reload contexts}
\usage{
context_save(root, packages = NULL, sources = NULL, auto = FALSE,
  package_sources = NULL, envir = parent.frame(), storage_type = NULL,
  storage_args = NULL)

context_load(handle, install = TRUE, envir = .GlobalEnv, ...)

context_read(handle)

contexts_list(root, error = TRUE)

context_handle(root, id, db = NULL)
}
\arguments{
\item{root}{Root directory to store and retrieve files.  Files
will be added to the \code{contexts} subdirectory of this path.
This will change later to support alternative ways of saving
files, perhaps into a database instance.}

\item{packages}{A character vector of packages (or \code{NULL}) if
no packages are to be loaded.}

\item{sources}{A character vector of source files to load.}

\item{auto}{Attempt to create the context automatically.  In this
case, do not specify either \code{packages} or \code{sources}.}

\item{package_sources}{Optional information about where to find
non-CRAN packages.  See \code{\link{package_sources}}.}

\item{envir}{The current environment.  This is used to copy
\emph{local} enviroments around, as these are needed even in the
case of non-automatic contexts.  For \code{context_load} this
is the environment into which the global environment is copied.
Specify a non-global environment here to avoid clobbering the
workspace, but at the risk that some environments may not
restore exactly as desired.}

\item{storage_type}{Optional storage type.  Currently only 'rds'
storage is supported, so this is largely ignored.}

\item{storage_args}{Arguments used to open storage driver.  This
is only used when the context directory is created the first
time, and if given when the directory already exists a warning
will be given if the options differ to the saved options.}

\item{handle}{A \code{context_handle} object returned by
\code{context_save}.}

\item{install}{Install missing packages?}

\item{...}{Additional arguments passed through to
\code{install_packages} if it is used.}

\item{error}{For \code{contexts_list}, should we throw an error if
no context database exists at \code{root}?  The default does
throw an error, but \code{error=TRUE} might be useful in cases
where you want to know that no contexts have yet been saved to
the root.}

\item{id}{The context id.  If \code{NULL} we will try and load the
most recently saved context within root.}

\item{db}{The context db (used internally, and not intended for
end-user use)}
}
\description{
Save and reload contexts.  Contexts consist of packages and
sources, or (if \code{auto}) is \code{TRUE}) a copy of the current
global environment.  Environments saved with \code{context_save}
can be reloaded with \code{context_load}; note that doing this
will probably alter the search path by loading any number of
packages.
}
\details{
The \code{context_read} function simply reads the context, but
does not load it.  It is mostly useful for debugging.
}

