#!/usr/bin/python3

import platform
import subprocess
import os


if __name__ == "__main__":
    if platform.system() == "Windows":
        # Dos tuff
        print("Running powershell setup")
        subprocess.Popen("powershell.exe", os.path.join(__file__, "setup.ps1")).communicate()
        
    else:
        # Assume bash-compatible
        print("Running bash setup")
        subprocess.Popen(os.path.join(__file__, "setup.sh")).communicate()
