
#' @useDynLib frast, .registration = TRUE
NULL

#' @export
get_jit_fn <- function(string) {
  .Call(frast_get_jit_fn, string)
}
