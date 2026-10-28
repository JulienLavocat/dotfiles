export SPARK_HOME=~/spark
path=($SPARK_HOME/sbin $SPARK_HOME/bin $path)
[[ -d /usr/lib/jvm/java-21-openjdk-amd64 ]] && export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
