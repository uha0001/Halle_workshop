import os
import sys
import json

print(sys.argv[1])
print(sys.argv[2])
values = json.load(open(sys.argv[1] + "/data/dataset_catalog.json"))
src = values["assemblies"][1]["files"][0]["filePath"]
os.symlink(os.getcwd() + "/" + sys.argv[1] + "/data/" + src, sys.argv[2])
