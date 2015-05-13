#!/usr/bin/env perl
# Copyright 2009 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

use strict;

my $command = "mksysnum_linux.pl ". join(' ', @ARGV);

print <<EOF;
// $command
// MACHINE GENERATED BY THE ABOVE COMMAND; DO NOT EDIT

package unix

const(
EOF

sub fmt {
	my ($name, $num) = @_;
	if($num > 999){
		# ignore deprecated syscalls that are no longer implemented
		# https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/uapi/asm-generic/unistd.h?id=refs/heads/master#n716
		return;
	}
	$name =~ y/a-z/A-Z/;
	print "	SYS_$name = $num;\n";
}

my $prev;
open(GCC, "gcc -E -dD $ARGV[0] |") || die "can't run gcc";
while(<GCC>){
	if(/^#define __NR_syscalls\s+/) {
		# ignore redefinitions of __NR_syscalls
	}
	elsif(/^#define __NR_(\w+)\s+([0-9]+)/){
		$prev = $2;
		fmt($1, $2);
	}
	elsif(/^#define __NR3264_(\w+)\s+([0-9]+)/){
		$prev = $2;
		fmt($1, $2);
	}
	elsif(/^#define __NR_(\w+)\s+\(\w+\+\s*([0-9]+)\)/){
		fmt($1, $prev+$2)
	}
}

print <<EOF;
)
EOF
