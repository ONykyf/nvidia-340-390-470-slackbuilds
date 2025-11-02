#!/bin/sh

export LC_ALL=C

TMPFILE=split_conftest.tmp

TMPDIR=./tmp340
rm -rf $TMPDIR
mkdir $TMPDIR

cat conftest.sh | (
SKIP=yes
IFS=''

while read -r LINE; do

if echo $LINE | egrep '^ *([[:alnum:]]|_)*\) *$' > /dev/null ; then
  SKIP=no
  TESTNAME=`echo $LINE | sed -r 's/^ *(([[:alnum:]]|_)*)\) *$/\1/'`
  VARNAME=""
  echo $TESTNAME
  rm -f $TMPFILE
  echo "$LINE" > $TMPFILE
else
  if [ $SKIP == yes ] ; then
    continue
  fi
  if [ "$VARNAME" == "" ] ; then
    if echo $LINE | egrep 'echo .* append_conftest ' >/dev/null ; then
      VARNAME=`echo $LINE | sed -r 's/^ *echo //' | \
               cut -f 2 -d '"' | cut -f 2 -d ' ' | sed 's/\"//g'`
      echo "->" $VARNAME
    elif echo $LINE | grep 'compile_check_conftest ' >/dev/null ; then
      VARNAME=`echo $LINE | sed -r 's/^ *compile_check_conftest //' | \
               cut -f 2 -d ' ' | sed 's/\"//g'`
      echo "->" $VARNAME
    fi
  fi
  echo "$LINE" >> $TMPFILE
  if echo $LINE | egrep '^ *;;' > /dev/null ; then
    echo "" >> $TMPFILE
    if [ "$VARNAME" == "" ] ; then
      if echo $TESTNAME | grep sanity >/dev/null ; then
        mv $TMPFILE $TMPDIR/sanity-$TESTNAME
      else
        rm -f $TMPFILE
      fi
    else
      mv $TMPFILE $TMPDIR/$VARNAME-$TESTNAME
    fi
    SKIP=yes
  fi
fi

done

)


exit 0

