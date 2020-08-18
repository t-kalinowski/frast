

#' @export
#' @import purrr glue
translate <- function(rfun, name = deparse(substitute(rfun))) {
  force(name)
  name <- make.names(name)
  args <- paste(names(formals(rfun)), collapse = ",")
  body <- .tr(body(rfun))
  glue("subroutine {name}({args}) bind(c)
       {body}
       end subroutine {name}")
  # browser()
  # formals(rfun)
  #
  # .tr(rfun)

  # body <- as.character(.tr(body(rfun)))
  # # sig <- as.character(as_fsub_sig(formals(rfun),
  # #                                 name = deparse(substitute(rfun))))
  #
  # paste0(collapse="\n",
  #        sig, body, )
}

tr_manifest <- function(m) {
  m <- eval(m)
  stopifnot(inherits(m, "manifest"))
  paste0(map_chr(m, as_decl), collapse = "\n")
}


#' @export
manifest <- function(...) {
  invisible(structure(list(...), class = "manifest"))
}

if(FALSE) {

  add1 <- function(x) {
    manifest(Var(x, "d"))
    x + 1
  }

  x <- translate(add1)
  cat(x)

}




# translate
.tr <- function(e) {
  # browser()
  if (typeof(e) %in% c("integer", "double", "character", "logical"))
    return(as.character(e))
  if (is.symbol(e))
    return(as.character(e))

  # if(is.function(e)) {
  #   browser()
  # }

  stopifnot(is.call(e))
  op <- e[[1]]
  ar <- e[-1]
  if (op == quote(`{`)) {
    stmts <- map_chr(ar, .tr)
    return(paste(stmts, collapse = "\n"))
  }
  if(op == quote(manifest)) {
    m <- eval.parent(e)
    return(tr_manifest(m))
  }



  if (is_infix(op)) {

    op <- as.character(e[[1]])
    left <- .tr(e[[2]])
    right <- .tr(e[[3]])
    return(paste(left, op, right))
  }
  if (op == quote(`if`)) {
    cond <- .tr(e[[2]])
    true <- .tr(e[[3]])
    # need recursion here to add {else if} without newline
    if (length(e) > 3) {
      false <-  .tr(e[[4]])

      return(glue("if ({cond}) then
            {true}
           else
              {false}
           end if
           "))
    } else {
      return(glue("if ({cond}) then
                      {true}
                   end if
                    "))

    }
  }
  if (op == quote(`for`)) {
    var <- .tr(e[[2]])
    iterable <- tr_iterable(e[[3]])
    body <- .tr(e[[4]])
    return(glue("do {var} = {iterable}
                  {body}
                  end do"))
  }
  if (op == quote(`[`)) {
    # browser()
    x <- .tr(e[[2]])
    idxs <- map_chr(as.list(e[-(1:2)]), .tr)
    idxs <- paste0(idxs, collapse = ", ")
    return(glue("{x}({idxs})"))
  }
}

tr_iterable <- function(cl) {
  # browser()
  if (cl[[1]] == quote(seq)) {
    # cl <- match.call(seq, cl)
    start <- .tr(cl[[2]])
    end <- .tr(cl[[3]])
    if (length(cl) > 3) {
      by <- .tr(cl[[4]])
      return(glue("{start}, {end}, {by}"))
    }
  }
  if (cl[[1]] == quote(`:`)) {
    start <- .tr(cl[[2]])
    end <- .tr(cl[[3]])
    return(glue("{start}, {end}"))
  }
  if (cl[[1]] == quote(seq_along)) {
    start = 1
    end = sprintf("size(%s)", .tr(cl[[2]]))
    return(glue("{start}, {end}"))
  }
  if (cl[[1]] == quote(seq_len)) {
    start = 1
    end = .tr(cl[[2]])
    return(glue("{start}, {end}"))
  }
}



is_infix <- function(op) {
  as.character(op) %in%
    c("+", "-", "*", "/", "^", "%%",
      "%/%", "&", "|", "!", "==", "!=",
      "<", "<=", ">=", ">", "=")
}


# translate(function(x) if(x> 0) x^2 else if(x<0) x^3)%>% cat

