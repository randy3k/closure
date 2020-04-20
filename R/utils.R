generate_name <- function(var, syms = character(0)) {
    var <- as.character(var)
    syms <- as.character(syms)
    while (var %in% syms) {
        var <- paste0(var, random_string(4))
    }
    var
}


random_string <- function(n) {
    paste0(sample(c(LETTERS, letters), n, replace = TRUE), collapse = "")
}


fn_fmls_to_syms <- function(fmls) {
    nms <- names(fmls)
    fmls_syms <- as.list(nms)
    names(fmls_syms) <- nms
    names(fmls_syms)[match("...", nms)] <- ""
    syms(fmls_syms)
}


fn_photo_copy <- function(fn) {
    parse_expr(paste(deparse(fn), collapse = "\n"))
}
