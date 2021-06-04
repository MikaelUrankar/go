// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build freebsd && (ppc64 || ppc64le)
// +build ppc64 ppc64le

// System calls and other sys.stuff for ppc64, FreeBSD

#include "go_asm.h"
#include "go_tls.h"
#include "textflag.h"
#include "asm_ppc64x.h"

#define CLOCK_REALTIME		0
#define CLOCK_MONOTONIC		4
#define FD_CLOEXEC		1
#define F_SETFD			2
#define F_GETFL			3
#define F_SETFL			4
#define O_NONBLOCK		4

#define SYS_exit		1
#define SYS_read		3
#define SYS_write		4
#define SYS_open		5
#define SYS_close		6
#define SYS_getpid		20
#define SYS_kill		37
#define SYS_sigaltstack		53
#define SYS_munmap		73
#define SYS_madvise		75
#define SYS_setitimer		83
#define SYS_fcntl		92
#define SYS___sysctl		202
#define SYS_nanosleep		240
#define SYS_clock_gettime	232
#define SYS_sched_yield		331
#define SYS_sigprocmask		340
#define SYS_kqueue		362
#define SYS_kevent		363
#define SYS_sigaction		416
#define SYS_thr_exit		431
#define SYS_thr_self		432
#define SYS_thr_kill		433
#define SYS__umtx_op		454
#define SYS_thr_new		455
#define SYS_mmap		477
#define SYS_cpuset_getaffinity	487
#define SYS_pipe2 		542

TEXT runtime·emptyfunc(SB),0,$0-0
	RET

// func sys_umtx_op(addr *uint32, mode int32, val uint32, uaddr1 uintptr, ut *umtx_time) int32
TEXT runtime·sys_umtx_op(SB),NOSPLIT,$0
	MOVD	addr+0(FP), R3
	MOVW	mode+8(FP), R4
	MOVW	val+12(FP), R5
	MOVD	uaddr1+16(FP), R6
	MOVD	ut+24(FP), R7
	SYSCALL	$SYS__umtx_op
	MOVW	R3, ret+32(FP)
	RET

// func thr_new(param *thrparam, size int32) int32
TEXT runtime·thr_new(SB),NOSPLIT,$0
	MOVD	param+0(FP), R3
	MOVW	size+8(FP), R4
	SYSCALL	$SYS_thr_new
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+16(FP)
	RET

// func thr_start()
#ifdef GOARCH_ppc64le
// ppc64le doesn't need function descriptors
TEXT runtime·thr_start(SB),NOSPLIT,$0
#else
TEXT runtime·thr_start(SB),NOSPLIT|NOFRAME,$0
	DWORD	$thr_start<>(SB)
	DWORD	$0
	DWORD	$0
TEXT thr_start<>(SB),NOSPLIT,$0
#endif
	// initialize essential registers (just in case)
	BL	runtime·reginit(SB)
	// set up g
	MOVD	m_g0(R3), g
	MOVD	R3, g_m(g)
	BL	runtime·emptyfunc(SB) // fault if stack check is wrong
	BL	runtime·mstart(SB)

	MOVD	$2, R8  // crash (not reached)
	MOVD	R8, (R8)
	RET

// func exit(code int32)
TEXT runtime·exit(SB),NOSPLIT|NOFRAME,$0-4
	MOVW	code+0(FP), R3
	SYSCALL	$SYS_exit
	RET

// func exitThread(wait *uint32)
TEXT runtime·exitThread(SB),NOSPLIT|NOFRAME,$0-8
	MOVD	wait+0(FP), R1
	// We're done using the stack.
	MOVW	$0, R2
	SYNC
	MOVW	R2, (R1)
	MOVW	$0, R3	// exit code
	SYSCALL	$SYS_exit
	JMP	0(PC)

// func open(name *byte, mode, perm int32) int32
TEXT runtime·open(SB),NOSPLIT|NOFRAME,$0-20
	MOVD	name+0(FP), R3
	MOVW	mode+8(FP), R4
	MOVW	perm+12(FP), R5
	SYSCALL	$SYS_open
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+16(FP)
	RET

// func closefd(fd int32) int32
TEXT runtime·closefd(SB),NOSPLIT|NOFRAME,$0-12
	MOVW	fd+0(FP), R3
	SYSCALL	$SYS_close
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+8(FP)
	RET

// func pipe() (r, w int32, errno int32)
TEXT runtime·pipe(SB),NOSPLIT|NOFRAME,$0-12
	ADD	$FIXED_FRAME, R1, R3
        MOVW    $0, R4
	SYSCALL	$SYS_pipe2
	MOVW	R3, errno+8(FP)
	RET

// func pipe2(flags int32) (r, w int32, errno int32)
TEXT runtime·pipe2(SB),NOSPLIT|NOFRAME,$0-20
	ADD	$FIXED_FRAME+8, R1, R3
	MOVW	flags+0(FP), R4
	SYSCALL	$SYS_pipe2
	MOVW	R3, errno+16(FP)
	RET

// func write1(fd uintptr, p unsafe.Pointer, n int32) int32
TEXT runtime·write1(SB),NOSPLIT|NOFRAME,$0-28
	MOVD	fd+0(FP), R3
	MOVD	p+8(FP), R4
	MOVW	n+16(FP), R5
	SYSCALL	$SYS_write
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+24(FP)
	RET

// func read(fd int32, p unsafe.Pointer, n int32) int32
TEXT runtime·read(SB),NOSPLIT|NOFRAME,$0-28
	MOVW	fd+0(FP), R3
	MOVD	p+8(FP), R4
	MOVW	n+16(FP), R5
	SYSCALL	$SYS_read
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+24(FP)
	RET

// func usleep(usec uint32)
TEXT runtime·usleep(SB),NOSPLIT,$24-4
	MOVW	usec+0(FP), R3
	MOVD	R3, R5
	MOVW	$1000000, R4
	DIVD	R4, R3
	MOVD	R3, 8(R1)
	MULLD	R3, R4
	SUB	R4, R5
	MOVW	$1000, R4
	MULLD	R4, R5
	MOVD	R5, 16(R1)

	// nanosleep(&ts, 0)
	ADD	$8, R1, R3
	MOVD	$0, R4
	SYSCALL	$SYS_nanosleep
	RET

// func thr_self() thread
TEXT runtime·thr_self(SB),NOSPLIT,$0-8
       // thr_self(&0(FP))
       MOVD    ret+0(FP), R3   // arg 1
       SYSCALL $SYS_thr_self
       RET

// func thr_kill(t thread, sig int)
TEXT runtime·thr_kill(SB),NOSPLIT,$0-16
       // thr_kill(tid, sig)
       MOVW    tid+0(FP), R3   // arg 1 id
       MOVW    sig+8(FP), R4   // arg 2 sig
       SYSCALL $SYS_thr_kill
       RET

//TEXT runtime·raise(SB),NOSPLIT,$8
//	MOVD	$8(R1), R3	// arg 1 &8(RSP)
//	SYSCALL	$SYS_thr_self
//	MOVD	8(R1), R3	// arg 1 pid
//	MOVW	sig+0(FP), R4	// arg 2 sig
//	SYSCALL	$SYS_thr_kill
//	RET

TEXT runtime·raiseproc(SB),NOSPLIT|NOFRAME,$0
	SYSCALL	$SYS_getpid
	MOVW	R3, R3	// arg 1 pid
	MOVW	sig+0(FP), R4	// arg 2
	SYSCALL	$SYS_kill
	RET

// func setitimer(mode int32, new, old *itimerval)
TEXT runtime·setitimer(SB),NOSPLIT|NOFRAME,$0-24
	MOVW	mode+0(FP), R3
	MOVD	new+8(FP), R4
	MOVD	old+16(FP), R5
	SYSCALL	$SYS_setitimer
	RET

// func fallback_walltime() (sec int64, nsec int32)
TEXT runtime·fallback_walltime(SB),NOSPLIT,$24-12
	MOVD	$CLOCK_REALTIME, R3
	MOVD	$8(R1), R4
	SYSCALL	$SYS_clock_gettime
	MOVD	8(R1), R3	// sec
	MOVD	16(R1), R5	// nsec
	MOVD	R3, sec+0(FP)
	MOVW	R5, nsec+8(FP)
	RET

// func fallback_nanotime() int64
TEXT runtime·fallback_nanotime(SB),NOSPLIT,$24-8
	MOVD	$CLOCK_MONOTONIC, R3
	MOVD	$8(R1), R4
	SYSCALL	$SYS_clock_gettime
	MOVD	8(R1), R3	// sec
	MOVD	16(R1), R5	// nsec
	// sec is in R3, nsec in R5
	// return nsec in R3
	MOVD	$1000000000, R4
	MULLD	R4, R3
	ADD	R5, R3
	MOVD	R3, ret+0(FP)
	RET

// func asmSigaction(sig uintptr, new, old *sigactiont) int32
TEXT runtime·asmSigaction(SB),NOSPLIT,$-8
	MOVD	sig+0(FP), R3		// arg 1 sig
	MOVD	new+8(FP), R4		// arg 2 act
	MOVD	old+16(FP), R5		// arg 3 oact
	SYSCALL	$SYS_sigaction
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+24(FP)
	RET

// func sigfwd(fn uintptr, sig uint32, info *siginfo, ctx unsafe.Pointer)
TEXT runtime·sigfwd(SB),NOSPLIT,$0-32
	MOVW	sig+8(FP), R3
	MOVD	info+16(FP), R4
	MOVD	ctx+24(FP), R5
	MOVD	fn+0(FP), R12
	MOVD	R12, CTR
	BL	(CTR)
	MOVD	24(R1), R2
	RET

// func sigtramp()
#ifdef GOARCH_ppc64le
// ppc64le doesn't need function descriptors
TEXT runtime·sigtramp(SB),NOSPLIT,$64
#else
// function descriptor for the real sigtramp
TEXT runtime·sigtramp(SB),NOSPLIT|NOFRAME,$0
	DWORD	$runtime·_sigtramp(SB)
	DWORD	$0
	DWORD	$0
TEXT runtime·_sigtramp(SB),NOSPLIT,$64
#endif
	// initialize essential registers (just in case)
	BL	runtime·reginit(SB)

	// this might be called in external code context,
	// where g is not set.
	MOVBZ	runtime·iscgo(SB), R6
	CMP 	R6, $0
	BEQ	2(PC)
	BL	runtime·load_g(SB)

	MOVW	R3, FIXED_FRAME+0(R1)
	MOVD	R4, FIXED_FRAME+8(R1)
	MOVD	R5, FIXED_FRAME+16(R1)
	MOVD	$runtime·sigtrampgo(SB), R12
	MOVD	R12, CTR
	BL	(CTR)
	MOVD	24(R1), R2
	RET

#ifdef GOARCH_ppc64le
// ppc64le doesn't need function descriptors
TEXT runtime·cgoSigtramp(SB),NOSPLIT|NOFRAME,$0
	// The stack unwinder, presumably written in C, may not be able to
	// handle Go frame correctly. So, this function is NOFRAME, and we
	// save/restore LR manually.
	MOVD	LR, R10

	// We're coming from C code, initialize essential registers.
	CALL	runtime·reginit(SB)

	// If no traceback function, do usual sigtramp.
	MOVD	runtime·cgoTraceback(SB), R6
	CMP	$0, R6
	BEQ	sigtramp

	// If no traceback support function, which means that
	// runtime/cgo was not linked in, do usual sigtramp.
	MOVD	_cgo_callers(SB), R6
	CMP	$0, R6
	BEQ	sigtramp

	// Set up g register.
	CALL	runtime·load_g(SB)

	// Figure out if we are currently in a cgo call.
	// If not, just do usual sigtramp.
	CMP	$0, g
	BEQ	sigtrampnog // g == nil
	MOVD	g_m(g), R6
	CMP	$0, R6
	BEQ	sigtramp    // g.m == nil
	MOVW	m_ncgo(R6), R7
	CMPW	$0, R7
	BEQ	sigtramp    // g.m.ncgo = 0
	MOVD	m_curg(R6), R7
	CMP	$0, R7
	BEQ	sigtramp    // g.m.curg == nil
	MOVD	g_syscallsp(R7), R7
	CMP	$0, R7
	BEQ	sigtramp    // g.m.curg.syscallsp == 0
	MOVD	m_cgoCallers(R6), R7 // R7 is the fifth arg in C calling convention.
	CMP	$0, R7
	BEQ	sigtramp    // g.m.cgoCallers == nil
	MOVW	m_cgoCallersUse(R6), R8
	CMPW	$0, R8
	BNE	sigtramp    // g.m.cgoCallersUse != 0

	// Jump to a function in runtime/cgo.
	// That function, written in C, will call the user's traceback
	// function with proper unwind info, and will then call back here.
	// The first three arguments, and the fifth, are already in registers.
	// Set the two remaining arguments now.
	MOVD	runtime·cgoTraceback(SB), R6
	MOVD	$runtime·sigtramp(SB), R8
	MOVD	_cgo_callers(SB), R12
	MOVD	R12, CTR
	MOVD	R10, LR // restore LR
	JMP	(CTR)

sigtramp:
	MOVD	R10, LR // restore LR
	JMP	runtime·sigtramp(SB)

sigtrampnog:
	// Signal arrived on a non-Go thread. If this is SIGPROF, get a
	// stack trace.
	CMPW	R3, $27 // 27 == SIGPROF
	BNE	sigtramp

	// Lock sigprofCallersUse (cas from 0 to 1).
	MOVW	$1, R7
	MOVD	$runtime·sigprofCallersUse(SB), R8
	SYNC
	LWAR    (R8), R6
	CMPW    $0, R6
	BNE     sigtramp
	STWCCC  R7, (R8)
	BNE     -4(PC)
	ISYNC

	// Jump to the traceback function in runtime/cgo.
	// It will call back to sigprofNonGo, which will ignore the
	// arguments passed in registers.
	// First three arguments to traceback function are in registers already.
	MOVD	runtime·cgoTraceback(SB), R6
	MOVD	$runtime·sigprofCallers(SB), R7
	MOVD	$runtime·sigprofNonGoWrapper<>(SB), R8
	MOVD	_cgo_callers(SB), R12
	MOVD	R12, CTR
	MOVD	R10, LR // restore LR
	JMP	(CTR)
#else
// function descriptor for the real sigtramp
TEXT runtime·cgoSigtramp(SB),NOSPLIT|NOFRAME,$0
	DWORD	$runtime·_cgoSigtramp(SB)
	DWORD	$0
	DWORD	$0
TEXT runtime·_cgoSigtramp(SB),NOSPLIT,$0
	JMP	runtime·_sigtramp(SB)
#endif

TEXT runtime·sigprofNonGoWrapper<>(SB),NOSPLIT,$0
	// We're coming from C code, set up essential register, then call sigprofNonGo.
	CALL	runtime·reginit(SB)
	CALL	runtime·sigprofNonGo(SB)
	RET

// func mmap(addr uintptr, n uintptr, prot int, flags int, fd int, off int64) (ret uintptr, err error)
TEXT runtime·mmap(SB),NOSPLIT|NOFRAME,$0
	MOVD	addr+0(FP), R3
	MOVD	n+8(FP), R4
	MOVW	prot+16(FP), R5
	MOVW	flags+20(FP), R6
	MOVW	fd+24(FP), R7
	MOVW	off+28(FP), R8

	SYSCALL	$SYS_mmap
	BVC	ok
	MOVD	$0, p+32(FP)
	MOVD	R3, err+40(FP)
	RET
ok:
	MOVD	R3, p+32(FP)
	MOVD	$0, err+40(FP)
	RET

// func munmap(addr uintptr, n uintptr) (err error)
TEXT runtime·munmap(SB),NOSPLIT|NOFRAME,$0
	MOVD	addr+0(FP), R3
	MOVD	n+8(FP), R4
	SYSCALL	$SYS_munmap
	BVC	2(PC)
	MOVD	R0, 0xf0(R0)
	RET

// func madvise(addr unsafe.Pointer, n uintptr, flags int32) int32
TEXT runtime·madvise(SB),NOSPLIT|NOFRAME,$0
	MOVD	addr+0(FP), R3
	MOVD	n+8(FP), R4
	MOVW	flags+16(FP), R5
	SYSCALL	$SYS_madvise
	MOVW	R3, ret+24(FP)
	RET

// func sysctl(mib *uint32, miblen uint32, out *byte, size *uintptr, dst *byte, ndst uintptr) int32
TEXT runtime·sysctl(SB),NOSPLIT,$0
	MOVD	mib+0(FP), R3		// arg 1 - name
	MOVW	miblen+8(FP), R4	// arg 2 - namelen
	MOVD	out+16(FP), R5		// arg 3 - oldp
	MOVD	size+24(FP), R6		// arg 4 - oldlenp
	MOVD	dst+32(FP), R7		// arg 5 - newp
	MOVD	ndst+40(FP), R8		// arg 6 - newlen
	SYSCALL	$SYS___sysctl
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+48(FP)
	RET

// func sigaltstack(new, old *stackt)
TEXT runtime·sigaltstack(SB),NOSPLIT|NOFRAME,$0
	MOVD	new+0(FP), R3
	MOVD	old+8(FP), R4
	SYSCALL	$SYS_sigaltstack
	BVC	2(PC)
	MOVD	R0, 0xf0(R0)  // crash
	RET

// func osyield()
TEXT runtime·osyield(SB),NOSPLIT|NOFRAME,$0
	SYSCALL	$SYS_sched_yield
	RET

// func sigprocmask(how int32, new, old *sigset)
TEXT runtime·sigprocmask(SB),NOSPLIT|NOFRAME,$0-28
	MOVW	how+0(FP), R3
	MOVD	new+8(FP), R4
	MOVD	old+16(FP), R5
	SYSCALL	$SYS_sigprocmask
	BVC	2(PC)
	MOVD	R0, 0xf0(R0)	// crash
	RET

// func cpuset_getaffinity(level int, which int, id int64, size int, mask *byte) int32
TEXT runtime·cpuset_getaffinity(SB),NOSPLIT|NOFRAME,$0-44
	MOVD	level+0(FP), R3
	MOVD	which+8(FP), R4
	MOVD	id+16(FP), R5
	MOVD	size+24(FP), R6
	MOVD	mask+32(FP), R7
	SYSCALL	$SYS_cpuset_getaffinity
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+40(FP)
	RET

// func kqueue() int32
TEXT runtime·kqueue(SB),NOSPLIT|NOFRAME,$0
	SYSCALL	$SYS_kqueue
	BVC	2(PC)
	MOVW	$-1, R3
	MOVW	R3, ret+0(FP)
	RET

// func kevent(kq int, ch unsafe.Pointer, nch int, ev unsafe.Pointer, nev int, ts *Timespec) (n int, err error)
TEXT runtime·kevent(SB),NOSPLIT,$0
	MOVW	kq+0(FP), R3	// arg 1 - kq
	MOVD	ch+8(FP), R4	// arg 2 - changelist
	MOVW	nch+16(FP), R5	// arg 3 - nchanges
	MOVD	ev+24(FP), R6	// arg 4 - eventlist
	MOVW	nev+32(FP), R7	// arg 5 - nevents
	MOVD	ts+40(FP), R8	// arg 6 - timeout
	SYSCALL	$SYS_kevent
	BVC	2(PC)
	NEG	R3, R3
ok:
	MOVW	R3, ret+48(FP)
	RET

// func closeonexec(fd int32)
TEXT runtime·closeonexec(SB),NOSPLIT|NOFRAME,$0
	MOVW    fd+0(FP), R3  // fd
	MOVD    $2, R4  // F_SETFD
	MOVD    $1, R5  // FD_CLOEXEC
	SYSCALL	$SYS_fcntl
	RET

// func runtime·setNonblock(int32 fd)
TEXT runtime·setNonblock(SB),NOSPLIT|NOFRAME,$0-4
       MOVW    fd+0(FP), R3 // fd
       MOVD    $3, R4  // F_GETFL
       MOVD    $0, R5
       SYSCALL $SYS_fcntl
       OR      $0x800, R3, R5 // O_NONBLOCK
       MOVW    fd+0(FP), R3 // fd
       MOVD    $4, R4  // F_SETFL
       SYSCALL $SYS_fcntl
       RET
