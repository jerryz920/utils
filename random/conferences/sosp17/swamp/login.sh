source ./env

# log in to CSA
curl -f -c csa-cookie-jar.txt \
    -H "Content-Type: application/json; charset=UTF-8" \
      -X POST \
        -d "{\"username\":\"$SWAMPUSER\",\"password\":\"$SWAMPPASS\"}" \
	  https://$CSA/login > rws-userinfo.txt
# find my user UUID
perl -n -e 'print $1 if (/\"user_uid\":\"([\w-]+)\"/);' \
    < rws-userinfo.txt > swamp-user-uuid.txt
export SWAMP_USER_UUID=`cat swamp-user-uuid.txt`
# look up additional user info (email address, etc.)
curl -f -b csa-cookie-jar.txt -c csa-cookie-jar.txt \
    https://$CSA/users/$SWAMP_USER_UUID > swamp-user-details.txt
