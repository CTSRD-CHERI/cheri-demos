#!/usr/local/bin/python

import os
import re

END_RE=re.compile(r'\b(................) t end\b')
BINDIR="/usr/local/bin/"
TESTDIR="/usr/home/sson/src/cheritest/trunk/obj/"

def getendaddr(test):
    p = os.popen(BINDIR + "mips64-nm " + TESTDIR  + test + ".elf", "r")

    retaddr = "0"
    while 1:
        line = p.readline()
        if not line: break
        line = line.strip()
        addr = END_RE.search(line)
        if (addr):
            retaddr = addr.group(1)

    return retaddr

def runqemu(testname, breakaddr):
    p = os.popen(BINDIR + "qemu-system-cheri -D /var/tmp/testlog/" +
            testname + ".log -d in_asm,int -M mipssim -cpu R4000 -kernel " +
            TESTDIR + testname + ".elf -nographic -m 3072M -bp 0x" +
            breakaddr)
    while 1:
        line = p.readline()
        if not line: break
        print line;
    return


if __name__=='__main__':
    import sys
    if len(sys.argv) != 2:
        print "Usage: runtest [test_name]"
        sys.exit(100)
    endaddr = getendaddr(sys.argv[1])
    if endaddr == "0":
        sys.exit(101)
    runqemu(sys.argv[1], endaddr)
