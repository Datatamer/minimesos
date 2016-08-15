#!/bin/sh
function fullfile {
    echo $(cd $(dirname $1) && pwd)/$(basename $1)
}

function pushjar {
    if [ $# -ne 4 ]; then
        echo "usage: $0 <file> <groupId> <artifactId> <version>"
        return 1
    fi
    mvn deploy:deploy-file -Dfile=$(fullfile $1) \
        -DrepositoryId=tamr-nexus \
        -Durl=https://nexus.tamrdev.com:8091/nexus/content/repositories/thirdparty/ \
        -DgroupId=$2 -DartifactId=$3 -Dversion=$4
    find ~/.gradle -name '*.jar' | grep $(basename $1) | xargs -t -n 1 rm -rf 
}

if [ $# -lt 1 ]; then
    echo "usage: $0 <minimesos-source-dir> [<extra-gradle-targets>]"
    exit 1
fi

srcdir=$(fullfile $1)
version=$($srcdir/gradlew properties | grep version: | awk '{print $2}')
$srcdir/gradlew $2 :minimesos:build :minimesos:jar :minimesos:shadowJar &&\    
pushjar $srcdir/minimesos/build/libs/minimesos-${version}.jar com.github.ContainerSolutions minimesos ${version} &&\
pushjar $srcdir/minimesos/build/libs/minimesos-${version}-all.jar com.github.ContainerSolutions minimesos ${version}-all
