source ./env
# find "MyProject"
# get my project memberships
export SWAMP_USER_UUID=`cat swamp-user-uuid.txt`
curl -f -b csa-cookie-jar.txt -c csa-cookie-jar.txt \
    https://$CSA/users/$SWAMP_USER_UUID/projects/trial \
      > swamp-myproject.txt
# get UUID for "MyProject"
perl -n -e 'print $1 if (/\"project_uid\":\"([\w-]+)\"/);' \
    < swamp-myproject.txt > swamp-project-uuid.txt
export SWAMP_PROJECT_UUID=`cat swamp-project-uuid.txt`
# get my other project memberships (if any)
curl -f -b csa-cookie-jar.txt -c csa-cookie-jar.txt \
    https://$CSA/users/$SWAMP_USER_UUID/projects > swamp-projects.txt
