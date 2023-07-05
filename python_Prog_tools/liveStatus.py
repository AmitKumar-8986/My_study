#!/usr/bin/python3
import  os, argparse as ag, subprocess as sp
import requests as req

psr = ag.ArgumentParser(description = "Find alive domain")
psr.add_argument("-sub", type=str, help="provide subdomain file", required=True)
rs=psr.parse_args()

f = open(rs.sub, "r")
for i in f.readlines():
    try:
        url="http://{}".format(i).strip('\n')
        #print(url)
        #g.write(sp.check_output("host -t a {}".format(i).strip('\n'), shell=True))
        response= req.get(url)
        if response.status_code == 200:
            print(url+"["+response.status_code+"]")
        elif response.status_code == 302:
            print(url+"["+response.status_code+"]")
        else:
            print(url+"["+response.status_code+"]")
    except:
        pass
f.close()

