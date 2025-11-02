#!/bin/sh

export LC_ALL=C

DEFFILE=got_defined340.txt
TMPDIR1=tmp340

OUTFILE=compile_tests340.sh
rm -f $OUTFILE
LISTFILE=list_tests340.mk
rm -f $LISTFILE

cat $DEFFILE | (

while read VARNAME ; do

for FILE in $TMPDIR1/$VARNAME-* ; do
#    echo "="$FILE
    if ! echo $FILE | grep '*' >/dev/null ; then
      break
    fi
    FILE=""
done

if [ "$FILE" != "" -a -r $FILE ] ; then
   DRIVER=`echo $FILE | cut -b 4-6`
   TESTNAME=`echo $FILE | cut -f 2 -d '-'`
   echo Add $FILE for $VARNAME
   if [ -r $LISTFILE ] ; then
     echo " \\" >> $LISTFILE
     echo -n "	$TESTNAME" >> $LISTFILE
   else
     echo -n "	$TESTNAME" > $LISTFILE
   fi
#   echo "      # $DRIVER" >> $OUTFILE
   cat $FILE >> $OUTFILE
else
   ADDFILE=`egrep "(\"| )$VARNAME(\"| )" $TMPDIR1/* | \
            egrep "^$TMPDIR1/" | \
            head -n 1 | sed -r "s|^([^:]*):.*$|\1|"`
   if [ "$ADDFILE" == "" ] ; then
     echo Not found $VARNAME anywhere!
     continue
   fi
   DRIVER=`echo $ADDFILE | cut -b 6-8`
   TESTNAME=`echo $ADDFILE | cut -f 2- -d '/' | cut -f 2 -d '-'`
   ADDVAR=`echo $ADDFILE | cut -f 2- -d '/' | cut -f 1 -d '-'`
   if ! egrep "^$ADDVAR\$" $DEFFILE >/dev/null ; then
     echo Add $ADDFILE with $ADDVAR for $VARNAME
     if [ -r $LISTFILE ] ; then
       echo " \\" >> $LISTFILE
       echo -n "	$TESTNAME" >> $LISTFILE
     else
       echo -n "	$TESTNAME" > $LISTFILE
     fi
#     echo "      # $DRIVER" >> $OUTFILE
     cat $ADDFILE >> $OUTFILE
   else
     echo Already loaded $VARNAME with $ADDVAR
   fi
fi

done

echo "" >> $LISTFILE

)

UPTO=`egrep -n '^compile_test()' conftest.sh | cut -f 1 -d ':'`
UPTO=$(($UPTO + 1))

SINCE=`egrep -n '^create_skeleton_headers$' conftest.sh | cut -f 1 -d ':'`
SINCE=$(($SINCE - 3))

echo $UPTO:$SINCE

cat conftest.sh | head -n $UPTO > conftest.new
cat $OUTFILE >> conftest.new
cat conftest.sh | tail -n +$SINCE >> conftest.new

UPTO=`egrep -n '^COMPILE_TESTS =' Makefile | cut -f 1 -d ':'`

SINCE=`egrep -n '^# CFLAGS dependent ' Makefile | cut -f 1 -d ':'`
SINCE=$(($SINCE - 2))

echo $UPTO:$SINCE

cat Makefile | head -n $UPTO > Makefile.new
cat $LISTFILE >> Makefile.new
cat Makefile | tail -n +$SINCE >> Makefile.new

UPTO=`egrep -n '^COMPILE_TESTS =' uvm/Makefile | cut -f 1 -d ':'`

SINCE=`egrep -n '^MODULE_NAME:=' uvm/Makefile | cut -f 1 -d ':'`
SINCE=$(($SINCE - 1))

echo $UPTO:$SINCE

cat uvm/Makefile | head -n $UPTO > uvm/Makefile.new
cat $LISTFILE >> uvm/Makefile.new
cat uvm/Makefile | tail -n +$SINCE >> uvm/Makefile.new
