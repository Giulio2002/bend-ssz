#!/usr/bin/env python3
"""Launcher kept for job1.sh: runs job2.sh (the corrected job) instead of the original scale step."""
import os
import subprocess
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.exit(subprocess.call(['bash', os.path.join(HERE, 'job2.sh')] + sys.argv[1:]))
