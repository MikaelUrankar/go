// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package cpu

//import (
//	"io/ioutil"
//)

const (
	_AT_HWCAP  = 25
	_AT_HWCAP2 = 26

	uintSize = int(32 << (^uint(0) >> 63))
)

// For those platforms don't have a 'cpuid' equivalent we use HWCAP/HWCAP2
// These are initialized in cpu_$GOARCH.go
// and should not be changed after they are initialized.
var hwCap uint
var hwCap2 uint

func readHWCAP() error {
	return nil
}
