import os

from ecflow import Defs, Suite, Task, Edit


print("Creating suite definition")
home = os.getcwd()
defs = Defs(Suite("test", Edit(ECF_HOME=home), Task("t1")))
print(defs)

print("Checking job creation: .ecf -> .job0")
print(defs.check_job_creation())

print("Saving definition to file 'test.def'")
defs.save_as_defs("test.def")
