#!/bin/bash
cat SO9ARC-SP-BZ-qso-only.csv | ./get-errors.bash | sort | uniq -c | sort -g
