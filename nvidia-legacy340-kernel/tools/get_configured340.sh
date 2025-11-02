#!/bin/sh

export LC_ALL=C

cat conftest.sh | egrep 'echo .* append_conftest ' | \
  sed -r 's/^ *echo //' | \
  cut -f 2 -d '"' | sed 's/\"//g' | \
  grep -v '\$' | grep -v '(' | \
  cut -f 2 -d ' '\
  > got_append_conftest340.txt


export LC_ALL=C

cat conftest.sh | grep 'compile_check_conftest ' | \
  sed -r 's/^ *compile_check_conftest //' | \
  cut -f 2 -d ' ' | sed 's/\"//g' \
  > got_compile_conftest340.txt

cat got_append_conftest340.txt got_compile_conftest340.txt | \
  egrep '^NV_'| sort | uniq > got_configured340.txt


