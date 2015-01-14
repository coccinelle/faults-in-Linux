#!/bin/bash

if [ -z "$DBNAME" ]; then
		DBNAME=faults_in_Linux
fi

if [ -z "$LINUXES" ]; then
		LINUXES=/fast_scratch/linuxes
fi

if [ -z "$VERSION_FILE" ]; then
		VERSION_FILE=versions_ext.txt
fi

