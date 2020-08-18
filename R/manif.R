
#' @export
Var <- function(name, type, rank=NULL, shape=NULL, modifiable = NULL) {
  type <- switch(
    type,
    "r" = , "real" = , "d" = , "dbl" = , "double" = "double",
    "i" = , "int" = , "integer" = "integer",
    "c" = , "cmp" = , "complex" = "complex",
    "l" = , "lgl" = , "logical" = "logical"
  )

  if (is.null(shape))
    shape <- vector("list", as.integer(rank %||% 0L))
  else if (is.character(shape)) {
    shape <-
      lapply(strsplit(shape, ",", fixed = TRUE)[[1]], function(d) {
        if(d %in% c("", ":")) return(NULL)
        as.integer(d)
      })
  } else if (!is.list(shape))
    shape <- as.list(shape)

  stopifnot(map_lgl(shape, ~is.null(.x) || rlang::is_scalar_integerish(.x)))
  name <- deparse(substitute(name))

  # browser() # need infer intent here
  structure(list(
    name = name,
    modifiable = modifiable,
    type = type,
    shape = shape
  ),
  class = "Var")
}





#' @importFrom glue glue
as_decl <- function(x) {
  stopifnot(inherits(x, "Var"))

  type <- switch(
    x$type,
    "double" = "real(c_double)",
    "integer" = "integer(c_int)",
    "complex" = "complex(c_double_complex)",
    "logical" = "logical(c_bool)"
  )

  if(is.null(x$modifiable))
    intent <- NULL
  else {

  intent <- if (x$modifiable) "in out" else "in"
  intent <- glue("intent({intent})")
  }
  #  local only vars don't need intent

  shape_suffix <- if (length(x$shape)) {
    shp <- lapply(x$shape, function(s) as.character(s %||% ":"))
    paste0("(",  paste0(shp, collapse = ","), ")")
  } else
    ""

  # browser()
  if (is.null(intent))
    glue("{type} :: {x$name}{shape_suffix}")
  else
    glue("{type}, {intent} :: {x$name}{shape_suffix}")
}


#' @export
manif <- function(x) {
  # stopifnot(is.list(x), vapply(x, inherits, "Var", TRUE))
  # paste0(vapply(x, decl, ""), collapse = "\n")
  vapply(x, decl, "")
}


