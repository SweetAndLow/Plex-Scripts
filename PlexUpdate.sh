#!/bin/sh
 
USERNAME=$2
PASSWORD=$3
URL="https://plex.tv/downloads?channel=plexpass"
#PMSPARENTPATH="/usr/pbi/plexmediaserver-amd64/share"
PMSPARENTPATH="/usr/local/share"
PMSLIVEFOLDER="plexmediaserver"
PMSBAKFOLDER="plexmediaserver.bak"
 
DOWNLOADPAGE=`curl -m 5 -silent -u $USERNAME:$PASSWORD $URL`
if [ $? -ne 0 ]; then
    echo Error downloading $URL
else
    echo "Download Page Successful"
    DOWNLOADURL=`echo $DOWNLOADPAGE | grep -o 'http[[:print:]]*-freebsd-amd64.tar.bz2'`
    if [ "x$DOWNLOADURL" = "x" ]; then
        echo Could not find a PlexMediaServer-[version]-freebsd-amd64.tar.bz2 download link on page $URL
    else
        echo "Download URL Complete"
        DOWNLOADFILE=`basename $DOWNLOADURL`
        echo "Downladed Filename: $DOWNLOADFILE"
        if [ ! -e $PMSPARENTPATH/$DOWNLOADFILE ]; then
            wget -qP $PMSPARENTPATH $DOWNLOADURL
            if [ $? -ne 0 ]; then
                echo Error downloading $DOWNLOADURL
            elif [ "$1" = "AUTOUPDATE" ]; then
                echo "Download File Complete"
                if [ ! -s $PMSPARENTPATH/$DOWNLOADFILE ]; then
                    echo $DOWNLOADFILE is zero bytes, cannot update with this file.
                else
                    rm -rf $PMSPARENTPATH/$PMSBAKFOLDER
                    service plexmediaserver stop
                    echo "Plexmediaserver Stoping..."
                    mv $PMSPARENTPATH/$PMSLIVEFOLDER/ $PMSPARENTPATH/$PMSBAKFOLDER/
                    mkdir $PMSPARENTPATH/$PMSLIVEFOLDER/
                    tar -vvxj --strip-components 1 --file $PMSPARENTPATH/$DOWNLOADFILE --directory $PMSPARENTPATH/$PMSLIVEFOLDER/
                    if [ $? -ne 0 ]; then
                        rm -rf $PMSPARENTPATH/$PMSLIVEFOLDER/
                        mv $PMSPARENTPATH/$PMSBAKFOLDER/ $PMSPARENTPATH/$PMSLIVEFOLDER/
                        echo Error exctracting $DOWNLOADFILE
                    fi
                    echo "Untar Successful"
                    service plexmediaserver start
                    echo "Plexmediaserver Starting..."
                fi
            fi
        fi
    fi
fi
