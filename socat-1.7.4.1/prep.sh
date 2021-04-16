
usage() {
    echo "Usage:"
    echo "  $0 -h               Display this help message.";
    echo "  $0 -r               Reset the binary to default configuration.";
    echo "  $0 -f <FROMOPTS>    (Required) Set FROMOPTS for socat.";
    echo "  $0 -t <TOOPTS>      (Required) Set TOOPTS for socat.";
    exit 0;
}

reset() {
    touch socat.c
    make
}

while getopts ":hrf:t:" opt; do
    case "${opt}" in
	h )
	    usage
	    ;;
	r )
	    reset
	    exit 0
	    ;;
	f )
	    FROMOPTS=${OPTARG}
	    ;;
        t )
            TOOPTS=${OPTARG}
            ;;
        * )
            usage
	    ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${FROMOPTS}" ] || [ -z "${TOOPTS}" ]; then
    usage
fi

SZ_FROMOPTS=${#FROMOPTS}
SZ_TOOPTS=${#TOOPTS}

#echo ${FROMOPTS}
#echo ${TOOPTS}

FROM_ID="JX_FROM"
SZ_FROM_ID=${#FROM_ID}
TO_ID="JX_TO"
SZ_TO_ID=${#TO_ID}

NOPBYTES=`printf "%0.s\x90" $(seq 1 2)`

COPY1=`printf "%0.s\x41" $(seq 1 $(($SZ_FROMOPTS - $SZ_FROM_ID - 1)))`
COPY2=`printf "%0.s\x41" $(seq 1 $(($SZ_TOOPTS - $SZ_TO_ID - 1)))`

FROMREPLACE=$FROM_ID$NOPBYTES$COPY1
TOREPLACE=$TO_ID$NOPBYTES$COPY2

#sed -i '' -e "s/$FROMREPLACE/$FROMOPTS`echo -ne '\0'`/g" socat
#sed -i '' -e "s/$TOREPLACE/$TOOPTS`echo -ne '\0'`/g" socat

perl -pi -e "s/$FROMREPLACE/$FROMOPTS\0/g" socat
perl -pi -e "s/$TOREPLACE/$TOOPTS\0/g" socat
#ex -s +'%s/$FROMREPLACE/$FROMOPTS\%x00/g' -cwq socat
#ex -s +'%s/$TOREPLACE/$TOOPTS\%x00/g' -cwq socat

