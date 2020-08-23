; ModuleID = 'mod_addone.bc'
source_filename = "/tmp/mod_addone-09855b.ll"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct_iso_c_binding_10_ = type <{ [16 x i8] }>

@.C312_addone = internal constant i32 14
@.C318_addone = internal constant [4 x i8] c"Hi!\0A"
@.C283_addone = internal constant i32 0
@.C284_addone = internal constant i64 0
@.C308_addone = internal constant i32 6
@.C313_addone = internal constant [14 x i8] c"mod_addone.f90"
@.C315_addone = internal constant i32 12
@.C292_addone = internal constant double 1.000000e+00
@_iso_c_binding_10_ = external global %struct_iso_c_binding_10_, align 64

; Function Attrs: noinline
define i32 @mod_addone_() #0 {
.L.entry:
  ret i32 undef
}

define void @addone(i64* %x) !dbg !5 {
L.entry:
  %z__io_317 = alloca i32, align 4
  br label %L.LB2_325

L.LB2_325:                                        ; preds = %L.entry
  %0 = bitcast i64* %x to double*, !dbg !10
  %1 = load double, double* %0, align 8, !dbg !10
  %2 = fadd fast double %1, 1.000000e+00, !dbg !10
  %3 = bitcast i64* %x to double*, !dbg !10
  store double %2, double* %3, align 8, !dbg !10
  %4 = bitcast i32* @.C315_addone to i8*, !dbg !12
  %5 = bitcast [14 x i8]* @.C313_addone to i8*, !dbg !12
  %6 = bitcast void (...)* @f90io_src_info03a to void (i8*, i8*, i64, ...)*, !dbg !12
  call void (i8*, i8*, i64, ...) %6(i8* %4, i8* %5, i64 14), !dbg !12
  %7 = bitcast i32* @.C308_addone to i8*, !dbg !12
  %8 = bitcast i32* @.C283_addone to i8*, !dbg !12
  %9 = bitcast i32* @.C283_addone to i8*, !dbg !12
  %10 = bitcast i32 (...)* @f90io_print_init to i32 (i8*, i8*, i8*, i8*, ...)*, !dbg !12
  %11 = call i32 (i8*, i8*, i8*, i8*, ...) %10(i8* %7, i8* null, i8* %8, i8* %9), !dbg !12
  store i32 %11, i32* %z__io_317, align 4, !dbg !12
  %12 = bitcast [4 x i8]* @.C318_addone to i8*, !dbg !12
  %13 = bitcast i32 (...)* @f90io_sc_ch_ldw to i32 (i8*, i32, i64, ...)*, !dbg !12
  %14 = call i32 (i8*, i32, i64, ...) %13(i8* %12, i32 14, i64 4), !dbg !12
  store i32 %14, i32* %z__io_317, align 4, !dbg !12
  %15 = call i32 (...) @f90io_ldw_end(), !dbg !12
  store i32 %15, i32* %z__io_317, align 4, !dbg !12
  ret void, !dbg !13
}

declare signext i32 @f90io_ldw_end(...)

declare signext i32 @f90io_sc_ch_ldw(...)

declare signext i32 @f90io_print_init(...)

declare void @f90io_src_info03a(...)

attributes #0 = { noinline }

!llvm.module.flags = !{!0, !1}
!llvm.dbg.cu = !{!2}

!0 = !{i32 2, !"Dwarf Version", i32 4}
!1 = !{i32 2, !"Debug Info Version", i32 3}
!2 = distinct !DICompileUnit(language: DW_LANG_Fortran90, file: !3, producer: " F90 Flang - 1.5 2017-05-01", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !4, globals: !4, imports: !4)
!3 = !DIFile(filename: "mod_addone.f90", directory: "/home/tomasz/Dropbox/r-pkgs/frast/mod")
!4 = !{}
!5 = distinct !DISubprogram(name: "addone", scope: !6, file: !3, line: 9, type: !7, scopeLine: 9, spFlags: DISPFlagDefinition, unit: !2)
!6 = !DIModule(scope: !2, name: "mod_addone")
!7 = !DISubroutineType(types: !8)
!8 = !{null, !9}
!9 = !DIBasicType(name: "double precision", size: 64, align: 64, encoding: DW_ATE_float)
!10 = !DILocation(line: 11, column: 1, scope: !11)
!11 = !DILexicalBlock(scope: !5, file: !3, line: 9, column: 1)
!12 = !DILocation(line: 12, column: 1, scope: !11)
!13 = !DILocation(line: 13, column: 1, scope: !11)
