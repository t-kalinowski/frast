


module <- function(fns, name = deparse(substitute(fns))) {
  force(name)
  name <- make.names(name)
  if(is.function(fns)) {
    fns <- list(fns)
    names(fns) <- name
  }
  else
    stopifnot(map_lgl(fns, is.function))

  subs <- paste0(imap_chr(fns, ~translate(.x, name = .y)),
                 collapse = "\n")

  glue(
  "module mod_{name}

    use iso_c_binding, only: c_int, c_double, c_double_complex, c_bool
    implicit none

  contains

    {subs}

  end module mod_{name}
")
}


if(FALSE) {
  devtools::load_all(".")
  addone <- function(x) {
    manifest(Var(x, "d", shape=":"))
    x = x + 1
  }
  (ptr <- load_so(addone))
  RFI::.ModernFortran(ptr, array(1))
  .Fortran(ptr, array(1))

  addone <- function(x) {
    manifest(Var(x, "d", shape=":"))
    x = x + 1
  }
  (ptr <- load_so(addone))

  devtools::load_all()
  convolve_c_ <- inline::cfunction(
  signature(a="double", na="integer", b="double", nb = "integer", ab = "double"),
  body = "
//void convolve(double *a, int *na, double *b, int *nb, double *ab)
{
    int nab = *na + *nb - 1;

    for(int i = 0; i < nab; i++)
        ab[i] = 0.0;
    for(int i = 0; i < *na; i++)
        for(int j = 0; j < *nb; j++)
            ab[i + j] += a[i] * b[j];
}", convention = ".C")

  convolve_c <- function(a, b) {
    convolve_c_(a, length(a), b, length(b), double(length(a) + length(b) -1))[[5L]]
  }

  convolve_r <- function(a, b) {
    ab = double(length(a) + length(b)-1)
    for (i in seq_along(a))
      for (j in seq_along(b))
        ab[i + j-1] = ab[i + j-1] + a[i] * b[j]
    ab
  }
  library(RFI)

  convolve_rf <- function(a, b, ab) {
    manifest(
      Var(i, "i"),
      Var(j, "i"),
      Var(a, "d", 1, modifiable = FALSE),
      Var(b, "d", 1, modifiable = FALSE),
      Var(ab, "d", 1, modifiable = TRUE)
    )
    for (i in seq_along(a))
      for (j in seq_along(b))
        ab[i + j-1] = ab[i + j-1] + a[i] * b[j]
  }

  ptr <- load_so(convolve_rf)

  convolve_f <- function(a, b) {
    .ModernFortran(ptr, a, b, double(length(a) + length(b)-1),
                        DUP = FALSE)[[3L]]
  }

  a <- runif(100)
  b <- runif(30)
  all.equal(convolve_r(a, b), convolve_f(a, b))
  all.equal(convolve_r(a, b), convolve_c(a, b))

  a <- runif(100000)
  b <- runif(300)
  r <- bench::mark(convolve_f(a, b), convolve_c(a, b), convolve_r(a, b))
  plot(r); r


  convolve_r2 <- function(a, b) {
    ab = double(length(a) - length(b)+1)
    for (i in seq_along(ab)) {
      ab[i] = sum(a[(i-length(b)+1):i] * rev(b))
    }
    ab
  }

  all.equal(convolve_r(a, b), convolve_r2(a, b))


}


# https://thinkingeek.com/2017/06/17/walk-through-flang-part-2/

#' @export
load_so <- function(fns, name = deparse(substitute(fns))) {
  dir.create(d <- tempfile())
  owd <- setwd(d)
  on.exit({
    setwd(owd)
    # unlink(d, recursive = TRUE)
  })
  force(name)
  name <- make.names(name)
  if(is.function(fns)) {
    fns <- list(fns)
    names(fns) <- name
  }
  else
    stopifnot(map_lgl(fns, is.function))

  mod <- module(fns, name)
  fi <- tempfile(fileext = ".f90")
  writeLines(mod, fi)
  cat(mod, "\n")

  so <- sub("\\.f90$", .Platform$dynlib.ext, fi)
  errfile <- sub("\\.f90$", ".err.txt", fi)
  cmd <- paste("PKG_FFLAGS=-std=f2018",
               file.path(R.home("bin"), "R"), "CMD SHLIB",
               shQuote(fi), "-o", shQuote(so),
               " 2> ", errfile)

  cmd <- sprintf(
    "gfortran -std=f2018 -shared -lgfortran -O3 -lm -lquadmath %s -o %s  2> %s",
     shQuote(fi), shQuote(so), shQuote(errfile))

  system(cmd)
  errmsg <- readLines( errfile )
  unlink( errfile )
  writeLines( errmsg )
  cat("\n")
  # browser()

  dll <- dyn.load(so)
  # system(glue("nm -D {so}"))
  ptr <- getNativeSymbolInfo(name, dll)$address
  ptr
}
