# patch symbols recursively
patch_symbols <- function(expr, public = character(0), private = character(0)) {
    if (is.symbol(expr)) {
        if (as.character(expr) %in% public) {
            return(as.call(list(as.name("$"), as.name("self"), expr)))
        } else if (as.character(expr) %in% private) {
            return(as.call(list(as.name("$"), as.name("self"), expr)))
        } else {
            return(expr)
        }
    } else if (is.expression(expr)) {
        as.expression(lapply(expr, patch_symbols, public = public, private = private))
    } else if (is.call(expr)) {
        if (expr[[1]] == "$" && is.symbol(expr[[3]])) {
            return(as.call(list(as.name("$"), patch_symbols(expr[[2]]), expr[[3]])))
        }
        if (expr[[1]] == "function") {
            # remove arguments from known variables
            argnames <- names(as.list(expr[[2]]))
            public <- setdiff(public, argnames)
            private <- setdiff(private, argnames)
        }
        as.call(lapply(expr, patch_symbols, public = public, private = private))
    } else {
        return(expr)
    }
}



#' @export
toR6 <- function(classname, constructor, portable = TRUE, ...) {
    stopifnot(is.function(constructor))

    env <- environment(constructor)

    arg_names <- c(names(formals(constructor)), "self")
    lex_results <- lex(body(constructor))

    fields <- lex_results$fields
    methods <- lex_results$methods

    public <- c(names(methods), setdiff(names(fields), arg_names))
    private <- list()

    if (portable) {
        for (m in seq_along(methods)) {
            methods[[m]] <- patch_symbols(methods[[m]], public, private)
        }
    }

    cls <- R6::R6Class(classname, portable = portable, parent_env = env, ...)
    for (n in names(fields)) {
        x <- eval(fields[[n]], envir = env)
        cls$set("public", n, x)
    }
    for (n in names(methods)) {
        f <- eval(methods[[n]], envir = env)
        cls$set("public", n, f)
    }
    cls
}
