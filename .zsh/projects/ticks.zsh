export SPARK_CONF=~/mobidata/config/spark-config-jlavocat.conf
export SPARK_EXEC=~/mobidata/target/spark-mobidata-1.0-SNAPSHOT.jar 

export MOBIDATA_SPARK_PACKAGES=com.datastax.spark:spark-cassandra-connector_2.13:3.5.0,com.github.jnr:jnr-posix:3.1.15,com.jayway.jsonpath:json-path:2.9.0,net.minidev:json-smart:2.5.1,net.minidev:accessors-smart:2.5.1
export MOBIDATA_SPARK_DRIVER_MEMORY=12g
export MOBIDATA_SPARK_JARS=postgresql-42.7.1.jar
export MOBIDATA_SPARK_DRIVER_CLASS_PATH=postgresql-42.7.1.jar
export MOBIDATA_SPARK_MASTER=spark://localhost:7077
export MOBIDATA_SPARK_DEPLOY_MODE=cluster

function ticks-spark() {
  mvn install &&
  spark-submit --properties-file $SPARK_CONF \
    --class $1 \
    --driver-class-path $MOBIDATA_SPARK_DRIVER_CLASS_PATH \
    --jars $MOBIDATA_SPARK_JARS \
    --packages $MOBIDATA_SPARK_PACKAGES \
    --driver-memory $MOBIDATA_SPARK_DRIVER_MEMORY \
    --master $MOBIDATA_SPARK_MASTER \
    --deploy-mode $MOBIDATA_SPARK_DEPLOY_MODE \
    $SPARK_EXEC
}

function ticks() {
    case "$1" in
        ssh) 
            shift 1
            sshpass -p "$TICKS_VM_PASSWORD" ssh jlavocat@ticks06.xsalto.net
        ;;
        scp)
            if [ "$#" -ne 3 ]; then
                echo "Missing arguments, usage: ticks scp [source] [dest]"
                return
            fi

            shift 1
            SOURCE=$1
            DEST=$2
            scp -r jlavocat@ticks06.xsalto.net:$1 $2
        ;;
        spark)
            shift 1
            ticks-spark "$@"
        ;;
        pass)
            echo $TICKS_VM_PASSWORD | clipboard
        ;;
    esac
    
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
