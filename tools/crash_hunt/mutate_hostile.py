#!/usr/bin/env python3
"""Launcher kept for job1.sh: runs job3.sh (probe C), then the real mutate_hostile_real.py with the same arguments."""
import os
import subprocess
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
subprocess.call(['bash', os.path.join(HERE, 'job3.sh')])
sys.exit(subprocess.call([sys.executable, os.path.join(HERE, 'mutate_hostile_real.py')] + sys.argv[1:]))
