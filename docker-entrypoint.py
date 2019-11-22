#!/usr/bin/python

import os
import sys
import subprocess
import yaml

f = open("/entrypoint.yaml")
entrypoint = yaml.safe_load(f)

# Required
if 'required_vars' in entrypoint:
    for required_var in entrypoint['required_vars']:
        plugin_var = "PLUGIN_" + required_var
        if plugin_var in os.environ:
            os.environ[required_var] = os.environ[plugin_var]
        if required_var not in os.environ:
            print "%s or %s environment variable required" % (required_var,
                                                              plugin_var)
            sys.exit(1)
        if "PLUGIN_DEBUG" in os.environ:
            if 'secret_vars' in entrypoint:
                if required_var in entrypoint['secret_vars']:
                    continue
            print "%s : %s" % (required_var, os.environ[required_var])

# Optional
if 'optional_vars' in entrypoint:
    for optional_var in entrypoint['optional_vars']:
        plugin_var = "PLUGIN_" + optional_var
        if plugin_var in os.environ:
            os.environ[optional_var] = os.environ[plugin_var]
        if "PLUGIN_DEBUG" in os.environ:
            if optional_var in os.environ:
                if 'secret_vars' in entrypoint:
                    if optional_var in entrypoint['secret_vars']:
                        continue
                print "%s : %s" % (optional_var, os.environ[plugin_var])

if subprocess.call(sys.argv[1:]) is not 0:
    sys.exit(1)
