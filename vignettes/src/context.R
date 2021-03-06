## ---
## title: "context"
## author: "Rich FitzJohn"
## date: "`r Sys.Date()`"
## output: rmarkdown::html_vignette
## vignette: >
##   %\VignetteIndexEntry{context}
##   %\VignetteEngine{knitr::rmarkdown}
##   %\VignetteEncoding{UTF-8}
## ---

##+ echo=FALSE,results="hide"
knitr::opts_chunk$set(error=FALSE)
writeLines(character(0), "file.R")

## The idea here is that we want to describe how to build a "context"
## and then evalute one or more expressions in it.  This is a little
## related to approaches like `docker` and `packrat` in that we want
## contexts to be isolated from one another, but different in that
## _portability_ is more important than isolation.

## Imagine that you have an analysis to run on another computer with:
##
## * packages to install from CRAN or any one of several other R package
##   repositories (e.g., a `drat`, bioconductor, etc).
## * packages to install from github
## * packages to install from local sources (e.g., private github
##   repos, unrelesed code)
## * A number of source files to read in
## * A local environment to recreate (e.g., if calling a function from
##  another function).

## The other computer may already have some packages installed, so you
## don't want to waste time and bandwidth re-installing them.  So
## things end up littered with constructs like
##
## ```r
## if (!require("mypkg")) {
##    install.packages("mypkg")
##    library(mypkg)
## }
## ```
##
## If these packages are coming from github (or worse also have
## dependencies on github) the bootstrap code gets out of hand very
## quickly and tends to be non-portable.

## Creating separate libraries (rather than sharing one from your
## personal computer) will be important if the architecture differs
## (e.g., you run Windows but you want to run code on a Linux
## cluster).

## The idea here is that `context` helps describe a context made from
## the above ingredients and then attempts to recreate it on a
## different computer (or in a different directory on your computer).

## ## Contexts

library(context)
context_log_start()

## A simple context might look like this:
ctx <- context_save(packages=c("pkg1", "pkg2"), sources="file.R",
                    root=tempfile())
ctx

## This will save all the required metadata at the path `root` (here,
## within the temporary directory).  The context information in this
## case is pretty simple:
context_read(ctx)

## Even more simple, contexts can be made _automatically_
##+ echo=FALSE
rm(ctx)
##+ echo=TRUE
ctx <- context_save(root=tempfile(), auto=TRUE)
context_read(ctx)

## which will look at the packages you currently have attached and
## loaded, plus save a copy of all the objects in the global
## environment.

## ## Tasks

## Once a context is defined, *tasks* can be defined in the context.
## These are simply R expressions associated with the identifier of a
## context.
ctx <- context_save(root=tempfile(), auto=TRUE)
ctx$id
t <- task_save(quote(sin(1)), context=ctx)
task_read(t)

## These tasks are loaded using the function `task_load` but this
## doesn't need to be done manually often.  Instead, to run this task,
## use the `task_run` function.
res <- task_run(t)

## This prints the result of restoring the context and running the task:
##
## * `root`: the directory within which all our context/task files will be
##   located
## * `id`: the task id
## * `context`: the context id
## * `lib`: A new library to install packages into (note that the path
##   contains information about the system type and R version to
##   increase the chance that packages will load successfully and not
##   interfere with other environments).
## * `library`: calls to `library()` to load packages and attach namespaces
## * `namespace`: calls to `loadNamespace()`; these packages were present
##    but not attached in the context.
## * `source`: There was nothing to `source()` here so this is blank,
##   otherwise it would be a list of filenames.
## * `global`: Load a global environment
## * `expr`: the expression to evaluate
## * `start`: start time
## * `result`: the filename that the result is written to
## * `end`: end time

## After all that, here is the result:
res

## The result can also be retrieved using `task_result()`:
task_result(t)

## More ordinarily, this task will be run elsewhere (or perhaps by a
## second process on the same machine).  To do this, first install the
## helper script (windows support coming soon):
context <- context::install_context(tempdir())

##+ eval=FALSE
system2(context, c(t$root, t$id))
##+ echo=FALSE
writeLines(context:::call_system(context, c(t$root, t$id)))

## which looks rather like the above, but has the additional lines
## `init` and `version`.  This is run in an entirely separate R
## process.

## This is a bit fragile though as it requires that `context` is
## already installed on the target machine.  So `context` also writes
## some bootstrap scripts that can set itself and its dependencies up.
##+ eval=FALSE
system2(file.path(t$root, "bin/context_runner"), c(t$root, t$id))
##+ echo=FALSE
writeLines(context:::call_system(file.path(t$root, "bin/context_runner"),
                                 c(t$root, t$id)))

## # Non-CRAN packages

## Especially in research code, which is in a state of flux or simply
## not widely useful enough to go on CRAN, packages will not be
## available on CRAN and therefore more complicated to install.  The
## `devtools::install_github` function is great for interactive use,
## but especially when there is a set of interdependent packages that
## are not on CRAN it can be difficult to coordinate installation.

## To get around this, `context` allows specifying package sources.
## For example:
src <- package_sources(github=c("traitecoevo/callr",
                                "richfitz/remake",
                                "richfitz/storr"))

## This can then be passed through to the `context_save` function above:
ctx <- context_save(root=tempfile(), packages="remake", package_sources=src)

## This takes a little while (though subsequent calls to the same root
## will be faster) as it downloads the required packages from github
## and builds a local `drat` repository.
dir(file.path(context_read(ctx)$package_sources$local_drat, "src", "contrib"))

## This repository will be made available to the computer that runs
## the context.

## An advantage of this approach over the `install_github` approach is
## that all the usual R install packages machinery works.  In
## particular, the dependency resolution will occur automatically so
## the order of installation will be worked out for you.
