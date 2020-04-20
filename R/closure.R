#' A foolproof construction of closure.
#' @import rlang
#' @export
new_closure <- function(members, parent_env = parent.frame(), keep_promise = character(0)) {
    member_names <- names(members)
    stopifnot(all(nzchar(member_names)))
    stopifnot(!anyDuplicated(member_names))

    main <- lapply(member_names, function(n) {
        obj <- members[[n]]
        if (is.function(obj)) {
            expr(!!sym(n) <- !!fn_photo_copy(obj))
        } else {
            expr(!!sym(n) <- !!obj)
        }
    })

    if ("initialize" %in% member_names) {
        args <- fn_fmls(members[["initialize"]])
        slots <- closure_slots(args, member_names)
        header <- slots$header
        footer <- slots$footer
    } else {
        args <- pairlist()
        header <- list()
        footer <- list()
    }

    new_function(
        args,
        expr({
            self <- environment()
            !!!header
            !!!main
            !!!footer
            self
        }),
        env = parent_env
    )
}


closure_slots <- function(args, member_names) {
    arg_names <- names(args)
    arg_names0 <- arg_names[arg_names != "..."]

    initialize_vars <- fn_fmls_to_syms(args)
    force_expr_list <- list()
    rm_expr_list <- list()
    for (i in seq_along(arg_names0)) {
        an <- arg_names[i]
        if (an %in% member_names) {
            rename_an <- generate_name(an, member_names)
            initialize_vars[[an]] <- sym(rename_an)
            member_names <- c(member_names, rename_an)
            force_expr_list <- append(
                force_expr_list,
                exprs(
                    !!sym(rename_an) <- !!sym(an),
                    force(!!sym(rename_an))
                )
            )
            rm_expr_list <- append(rm_expr_list, exprs(rm(!!sym(rename_an))))
        } else {
            force_expr_list <- append(force_expr_list, exprs(force(!!sym(an))))
            rm_expr_list <- append(rm_expr_list, exprs(rm(!!sym(an))))
        }
    }

    header <- list2(!!!force_expr_list)
    if (length(rm_expr_list) > 0) {
        header <- append(header, exprs(on.exit({
            !!!rm_expr_list
        })))
    }
    footer <- list2(
        call2(sym("initialize"), !!!initialize_vars),
    )
    list(header = header, footer = footer)
}
