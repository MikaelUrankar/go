// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build freebsd && (ppc64 || ppc64le)
// +build ppc64 ppc64le

package runtime

import "unsafe"

type sigctxt struct {
	info *siginfo
	ctxt unsafe.Pointer
}

//go:nosplit
//go:nowritebarrierrec
func (c *sigctxt) regs() *mcontext { return &(*ucontext)(c.ctxt).uc_mcontext }

func (c *sigctxt) r0() uint64  { return c.regs().mc_frame[0] }
func (c *sigctxt) r1() uint64  { return c.regs().mc_frame[1] }
func (c *sigctxt) r2() uint64  { return c.regs().mc_frame[2] }
func (c *sigctxt) r3() uint64  { return c.regs().mc_frame[3] }
func (c *sigctxt) r4() uint64  { return c.regs().mc_frame[4] }
func (c *sigctxt) r5() uint64  { return c.regs().mc_frame[5] }
func (c *sigctxt) r6() uint64  { return c.regs().mc_frame[6] }
func (c *sigctxt) r7() uint64  { return c.regs().mc_frame[7] }
func (c *sigctxt) r8() uint64  { return c.regs().mc_frame[8] }
func (c *sigctxt) r9() uint64  { return c.regs().mc_frame[9] }
func (c *sigctxt) r10() uint64 { return c.regs().mc_frame[10] }
func (c *sigctxt) r11() uint64 { return c.regs().mc_frame[11] }
func (c *sigctxt) r12() uint64 { return c.regs().mc_frame[12] }
func (c *sigctxt) r13() uint64 { return c.regs().mc_frame[13] }
func (c *sigctxt) r14() uint64 { return c.regs().mc_frame[14] }
func (c *sigctxt) r15() uint64 { return c.regs().mc_frame[15] }
func (c *sigctxt) r16() uint64 { return c.regs().mc_frame[16] }
func (c *sigctxt) r17() uint64 { return c.regs().mc_frame[17] }
func (c *sigctxt) r18() uint64 { return c.regs().mc_frame[18] }
func (c *sigctxt) r19() uint64 { return c.regs().mc_frame[19] }
func (c *sigctxt) r20() uint64 { return c.regs().mc_frame[20] }
func (c *sigctxt) r21() uint64 { return c.regs().mc_frame[21] }
func (c *sigctxt) r22() uint64 { return c.regs().mc_frame[22] }
func (c *sigctxt) r23() uint64 { return c.regs().mc_frame[23] }
func (c *sigctxt) r24() uint64 { return c.regs().mc_frame[24] }
func (c *sigctxt) r25() uint64 { return c.regs().mc_frame[25] }
func (c *sigctxt) r26() uint64 { return c.regs().mc_frame[26] }
func (c *sigctxt) r27() uint64 { return c.regs().mc_frame[27] }
func (c *sigctxt) r28() uint64 { return c.regs().mc_frame[28] }
func (c *sigctxt) r29() uint64 { return c.regs().mc_frame[29] }
func (c *sigctxt) r30() uint64 { return c.regs().mc_frame[30] }
func (c *sigctxt) r31() uint64 { return c.regs().mc_frame[31] }
func (c *sigctxt) sp() uint64  { return c.regs().mc_frame[1] }

//go:nosplit
//go:nowritebarrierrec
func (c *sigctxt) pc() uint64 { return c.regs().mc_frame[36] }   // mc_srr0

func (c *sigctxt) trap() uint64 { return c.regs().mc_frame[38] } // mc_exc
func (c *sigctxt) ctr() uint64  { return c.regs().mc_frame[35] } // mc_ctr
func (c *sigctxt) link() uint64 { return c.regs().mc_frame[32] } // mc_lr
func (c *sigctxt) xer() uint64  { return c.regs().mc_frame[34] } // mc_xer
func (c *sigctxt) ccr() uint64  { return c.regs().mc_frame[33] } // mc_cr

func (c *sigctxt) fault() uint64  { return c.info.si_addr }

func (c *sigctxt) sigcode() uint64 { return uint64(c.info.si_code) }
func (c *sigctxt) sigaddr() uint64 { return c.info.si_addr }

func (c *sigctxt) set_r0(x uint64)   { c.regs().mc_frame[0] = x }
func (c *sigctxt) set_r12(x uint64)  { c.regs().mc_frame[12] = x }
func (c *sigctxt) set_r30(x uint64)  { c.regs().mc_frame[30] = x }
func (c *sigctxt) set_pc(x uint64)   { c.regs().mc_frame[36] = x } // mc_srr0
func (c *sigctxt) set_sp(x uint64)   { c.regs().mc_frame[1] = x }
func (c *sigctxt) set_link(x uint64) { c.regs().mc_frame[32] = x } // mc_lr

func (c *sigctxt) set_sigcode(x uint64) { c.info.si_code = int32(x) }
func (c *sigctxt) set_sigaddr(x uint64) { c.info.si_addr = x }
