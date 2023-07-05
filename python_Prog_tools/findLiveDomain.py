#!/usr/bin/python3
import  os, argparse as ag, subprocess as sp
from subprocess import run

psr = ag.ArgumentParser(description = "Find alive domain")
psr.add_argument("-sub", type=str, help="provide subdomain file", required=True)
psr.add_argument("-out", type=str, help="provide to save alive subdomain file", required=True)
rs=psr.parse_args()

f = open(rs.sub, "r")
for i in f.readlines():
    #print(i.strip())
    g = open(rs.out, "ab")
    try:
        g.write(sp.check_output("host -t a {}".format(i).strip('\n'), shell=True))
    except:
        pass
    g.close()
f.close()

