source ./env


export SWAMP_USER_UUID=`cat swamp-user-uuid.txt`
export SWAMP_PROJECT_UUID=`cat swamp-project-uuid.txt`
# list public packages (including UUIDs)
curl -f https://$CSA/packages/public > swamp-public-packages.txt
# list packages shared with my project
curl -f -b csa-cookie-jar.txt -c csa-cookie-jar.txt \
    https://$CSA/packages/protected/$SWAMP_PROJECT_UUID > \
      swamp-protected-packages.txt
# list package types (C/C++, Java Source Code, etc.)
curl -f https://$CSA/packages/types > swamp-package-types.txt
