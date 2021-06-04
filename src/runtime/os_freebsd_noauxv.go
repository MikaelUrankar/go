// Copyright 2018 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build freebsd && !(arm || ppc64 || ppc64le)
// +build freebsd,!arm
// +build freebsd,!ppc64
// +build freebsd,!ppc64le

package runtime

func archauxv(tag, val uintptr) {
}
