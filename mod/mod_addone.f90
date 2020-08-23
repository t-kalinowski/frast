
module mod_addone

  use iso_c_binding, only: c_int, c_double, c_double_complex, c_bool
  implicit none

contains

  subroutine addone(x) bind(c)
  real(c_double), intent(in out) :: x
  x = x + 1
  print *, "Hi!\n"
  end subroutine addone

end module mod_addone

! flang -emit-llvm -c -std=2018 mod_addone.f90
