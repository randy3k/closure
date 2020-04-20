# Lexical analysis for an expression
lex <- function(exprs) {
    # TODO: handle { }
    fields <- list()
    methods <- list()

    for (i in seq_along(exprs)) {
        expr <- exprs[[i]]
        if (is.call(expr) && (class(expr) == "<-" || class(expr) == "=")) {
            lhs <- as.character(expr[[2]])
            rhs <- expr[[3]]
            if (length(rhs) > 1 && rhs[[1]] == "function") {
                methods [lhs] <- list(rhs)
            } else {
                fields[lhs] <- list(rhs)
            }
        }
    }

    list(fields = fields, methods = methods)
}
