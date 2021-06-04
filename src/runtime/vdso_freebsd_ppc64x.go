// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build freebsd && (ppc64 || ppc64le)
// +build ppc64 ppc64le

package runtime

//go:nosplit
func (th *vdsoTimehands) getTimecounter() (uint32, bool) {
	return 0, false
}
