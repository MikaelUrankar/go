// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build !386 && !amd64 && !arm && !arm64
// +build !386 && !amd64 && !arm && !arm64

package cpu

func archInit() {
// XXX mik
//	if err := readHWCAP(); err != nil {
//		return
//	}
	doinit()
	Initialized = true
}
