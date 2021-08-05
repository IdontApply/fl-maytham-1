#!/usr/bin/python
import sys

def genrate_index(name: str) -> None:

    index_string = "{name}".format(name = name)

    with open("/tmp/index.html", 'w+') as index:
        index.write(index_string)
        index.close()
    return

if __name__ =="__main__":
    genrate_index(sys.argv[1])
