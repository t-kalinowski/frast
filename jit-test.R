
reticulate::py_run_file("run_bc.py")

func_ptr_val <- reticulate::py_eval("str(func_ptr)")
ptr <- frast::get_jit_fn(func_ptr_val)
class(ptr) <- "NativeSymbol"
RFI::.ModernFortran(ptr, array(1))

