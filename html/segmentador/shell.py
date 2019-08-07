#!/usr/bin/env python
# -*- coding: UTF-8 -*-


import subprocess
bashCommand = "who am i "
process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
output, error = process.communicate()
print output
print error

