export SPARK_CONF=~/mobidata/config/spark-config-jlavocat.conf
export SPARK_EXEC=~/mobidata/target/spark-mobidata-1.0-SNAPSHOT.jar 

function spark() {
  spark-submit --properties-file $SPARK_CONF --class $1 --packages com.datastax.spark:spark-cassandra-connector_2.13:3.5.0,com.github.jnr:jnr-posix:3.1.15 --driver-memory 12g --master local $SPARK_EXEC
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
