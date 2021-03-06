##' Get a context db or root by way of some object.
##'
##' Valid options for \code{x} are
##'
##' \describe{
##'
##' \item{A character string}{Assumed to the the root directory for
##' the context.  \code{context} stores information in the root
##' directory about the database format and can load the database
##' given this}.
##'
##' \item{A storr database}{Assumed, without checking, to be the
##' correct database.}
##'
##' \item{A list-like or environment-like object}{If this object has
##' an element \code{db} that is a storr object it is assumed to the
##' be database.  Otherwise if it has a character element \code{root}
##' that is assumed to the root.  Otherwise it is an error.}
##' }
##'
##' This all seems a bit complicated but allows use from R functions
##' without requiring a lot of set-up while at the same time allows
##' other functions to efficiently interact with the database.
##'
##' @title Get the context db
##' @param x An object (see Details)
##' @return The storr database used by this context
##' @export
context_db <- function(x) {
  if (inherits(x, "storr")) {
    x
  } else if (is.recursive(x) && inherits(x$db, "storr")) {
    x$db
  } else {
    root <- context_root(x)
    context_db_open(root, readRDS(path_config(root)), FALSE)
  }
}

##' @export
##' @rdname context_db
context_root <- function(x) {
  if (is.character(x) && length(x) == 1L) {
    config <- path_config(x)
    if (!file.exists(config)) {
      stop("context database not set up at ", x)
    }
    x
  } else if (is.recursive(x) && !is.null(x$root)) {
    context_root(x$root)
  } else if (inherits(x, "storr")) {
    context_root(x$driver$path)
  } else {
    stop("Cannot determine context root")
  }
}

context_db_open <- function(root, config, create) {
  if (config$type == "environment") {
    if (!create) {
      stop("Cannot reconnect to environment storage")
    }
    ret <- storr::storr_environment()
  } else if (config$type == "rds") {
    defaults <- list(compress=FALSE, mangle_key=TRUE)
    v <- intersect(names(defaults), names(config$args))
    args <- c(list(path_db(root)),
              modifyList(defaults, as.list(config$args[v])))
    ret <- do.call(storr::storr_rds, args, quote=TRUE)
  } else {
    ## This is actually a little more difficult than this because
    ## we need to add any required packages (e.g., redux) to the
    ## bootstrap script.  That's also going to generate some
    ## issues with blowing out 'Suggests:' in the package
    ## perhaps.  For now leave this be.
    ## redis=storr::storr_redis_api(redux::redis(config=config$args)),
    stop("Unsupported storage type ", config$type)
  }
  ret
}
