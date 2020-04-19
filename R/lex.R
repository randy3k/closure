#' Lexical analysis for a closure
#' @importFrom utils hasName
lex <- function(constructor) {
    stopifnot(is.function(constructor))
    args <- as.list(formals(constructor))
    exprs <- body(constructor)

    fields <- list()
    methods <- list()

    for (i in seq_along(exprs)) {
        expr <- exprs[[i]]
        if (is.call(expr) && class(expr) == "<-") {
            lhs <- as.character(expr[[2]])
            rhs <- expr[[3]]
            if (length(rhs) > 1 && rhs[[1]] == "function" && !startsWith(lhs, ".")) {
                methods [lhs] <- list(rhs)
            } else if (!hasName(args, lhs) && lhs != "self" && !startsWith(lhs, ".")) {
                fields[lhs] <- list(rhs)
            }
        }
    }

    list(fields = fields, methods = methods)
}
