#! /bin/sh

set -e

LIGHTNING_DIR=/home/rusty/.lightning
LCLI="lightning-cli --lightning-dir=$LIGHTNING_DIR"

PICTURE_DIR=/home/rusty/lightning-pictures
MSATOSHI=100000
ID=`$LCLI getinfo | sed 's/.*"id" : "\([^"]*\)".*/\1/'`

echo 'Content-type: text/html'
echo ''

echo '<head><title>Lightning Cat Picture Service</title></head>'
echo '<body>'
case "$QUERY_STRING" in
    "")
	LABEL=`od -tx1 -Anone -N16 < /dev/urandom | tr -d ' '`
	RHASH=`$LCLI invoice $MSATOSHI $LABEL | sed 's/.*"\([0-9a-f]*\)".*/\1/'`
	echo "<H1> Lightning Cat Picture Server </h1>"
	echo "Send payment of $MSATOSHI millisatoshi to $ID, receipt $RHASH"
	echo "eg:"
	echo '<pre>lightning-cli sendpay $(lightning-cli getroute '$ID $MSATOSHI" 1 | sed 's/^{ \"route\" : \(.*\) }$/\1/') $RHASH</pre>"
	echo
	echo 'Then <a href="?'$LABEL'">click here</a>'
	;;
    *)
	echo "<H1> Checking payment </H1>"
	if OUT=`$LCLI listinvoice "$QUERY_STRING"`; then
	    case "$OUT" in
		*'"complete" : true'*)
		    echo PAID.
		    echo "<pre>"
		    cat <<EOF


             *     ,%%%%%%%.            *
                  %%%BBBB%%%%    .
                 %%%%B%%%B%%%%
     *           %%%%BBBB%%%%%
                 %%%%B%%%B%%%%
                 '%%%BBBB%%%%'
                   '%%%%%%%'      *    
          |\\___/|     /\\___/\\
          )     (     )    ~( .              '
         =\\     /=   =\\~    /=
           )===(       ) ~ (
          /     \\     /     \\
          |     |     ) ~   (
         /       \\   /     ~ \\
         \\       /   \\~     ~/
  jgs_/\\_/\\__  _/_/\\_/\\__~__/_/\\_/\\_/\\_/\\_/\\_
  |  |  |  |( (  |  |  | ))  |  |  |  |  |  |
  |  |  |  | ) ) |  |  |//|  |  |  |  |  |  |
  |  |  |  |(_(  |  |  (( |  |  |  |  |  |  |
  |  |  |  |  |  |  |  |\\)|  |  |  |  |  |  |
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
( Credit https://user.xmission.com/~emailbox/ascii_cats.htm )
EOF
		    echo "</pre>"
		    ;;
		*'"complete" : false'*)
		    echo "$QUERY_STRING $ID UNPAID"
		    ;;
		*)
		    echo "UNKNOWN ERROR: $OUT"
		    ;;
	    esac
	else
	    echo "Problem finding invoice: $OUT"
	fi
	;;
esac

echo '</body>'
