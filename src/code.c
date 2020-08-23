#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <stdlib.h>
#include <R_ext/Rdynload.h>

SEXP frast_get_jit_fn(SEXP sx) {
  const char* str_x = CHAR(STRING_ELT(sx, 0));
  long pi = atol(str_x);
  printf("%ld\n", pi);
  DL_FUNC p = (DL_FUNC ) pi;

  return R_MakeExternalPtrFn(p, R_NilValue, R_NilValue);
}

#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}

static const R_CallMethodDef CallEntries[] = {
  CALLDEF(frast_get_jit_fn, 1),
  {NULL, NULL, 0}};

void R_init_frast(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
