#!/bin/bash

#omnimed-api-access-identity:[omnimed-apidefinition-access-identity omnimed-parent-springboot omnimed-shared-api omnimed-shared-error-handling omnimed-shared-persistence omnimed-shared-security omnimed-shared-streamdefinition omnimed-shared-test omnimed-streamdefinition-emr omnimed-parent-apidefinition]

cd /home/gcharland/git/Omnimed-solutions

#SOLUTION="omnimed-apidefinition-access-identity"
#
#DEPENDENCY_LIST=(
#        "omnimed-parent-apidefinition"
#        "omnimed-parent-springboot"
#        "omnimed-shared-test"
#    )

SOLUTION="omnimed-api-access-identity"

DEPENDENCY_LIST=(
        "omnimed-apidefinition-access-identity"
        "omnimed-parent-apidefinition"
        "omnimed-parent-springboot"
        "omnimed-shared-api"
        "omnimed-shared-error-handling"
        "omnimed-shared-persistence"
        "omnimed-shared-security"
        "omnimed-shared-streamdefinition"
        "omnimed-shared-test"
        "omnimed-streamdefinition-emr"
    )

hashSentence=$(git --no-pager log -n 1 --pretty=format:%H -- $SOLUTION)

for sol in "${DEPENDENCY_LIST[@]}"; do
    hashSentence=$hashSentence$(git --no-pager log -n 1 --pretty=format:%H -- $sol)
done

hash=$(echo $hashSentence | sha1sum | head -c 11)

echo "Hash sentence was: $hashSentence"
echo "Unique id is: $hash"


# apidefinition
#Hash sentence was: 0adfaa766728468966d6480bd77d447c3913e0016dc367d473bf43f57f285e2ccd20ac50ea16102a6dc367d473bf43f57f285e2ccd20ac50ea16102a6dc367d473bf43f57f285e2ccd20ac50ea16102a
#Unique id is: 6f3bc9ac057
#
# api-access-identity
#Hash sentence was: 0adfaa766728468966d6480bd77d447c3913e0010adfaa766728468966d6480bd77d447c3913e0016dc367d473bf43f57f285e2ccd20ac50ea16102a6dc367d473bf43f57f285e2ccd20ac50ea16102aab1e6c22ac9eae16b7895ca390c8597cd339ed836dc367d473bf43f57f285e2ccd20ac50ea16102aab1e6c22ac9eae16b7895ca390c8597cd339ed836dc367d473bf43f57f285e2ccd20ac50ea16102a6dc367d473bf43f57f285e2ccd20ac50ea16102a6dc367d473bf43f57f285e2ccd20ac50ea16102a6dc367d473bf43f57f285e2ccd20ac50ea16102a
#Unique id is: 15741ce4492

