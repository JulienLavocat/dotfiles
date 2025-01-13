export SPARK_CONF=~/mobidata/config/jlavocat/spark-config-atoumod.conf
export SPARK_EXEC=~/mobidata/target/spark-mobidata-1.0.0.jar 

export MOBIDATA_SPARK_PACKAGES=com.datastax.spark:spark-cassandra-connector_2.13:3.5.0,com.github.jnr:jnr-posix:3.1.15,com.jayway.jsonpath:json-path:2.9.0,net.minidev:json-smart:2.5.1,net.minidev:accessors-smart:2.5.1,com.rabbitmq:amqp-client:5.21.0
export MOBIDATA_SPARK_DRIVER_MEMORY=12g
export MOBIDATA_SPARK_JARS=~/.local/bin/spark/jars/postgresql-42.7.3.jar
export MOBIDATA_SPARK_DRIVER_CLASS_PATH=~/.local/bin/spark/jars/postgresql-42.7.3.jar
export MOBIDATA_SPARK_MASTER=spark://localhost:7077
export MOBIDATA_SPARK_DEPLOY_MODE=client

export SPARK_MASTER_HOST=0.0.0.0


function ticks-spark-submit() {
  mvn install &&
  spark-submit --properties-file $SPARK_CONF \
    --class $1 \
    --driver-class-path $MOBIDATA_SPARK_DRIVER_CLASS_PATH \
    --jars $MOBIDATA_SPARK_JARS \
    --packages $MOBIDATA_SPARK_PACKAGES \
    --driver-memory $MOBIDATA_SPARK_DRIVER_MEMORY \
    $SPARK_EXEC > logs.txt
}

function ticks() {
    case "$1" in
        ssh) 
            shift 1
            ssh "jlavocat@ticks0$1.xsalto.net"
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
        submit)
            shift 1
            ticks-spark-submit "$@"
        ;;
        spark)
            if [ "$#" -ne 2 ]; then
                echo "Missing arguments, usage: ticks spark start|stop"
                return
            fi

            shift 1

            if [[ "$1" == "start" ]]; then
                ~/.local/bin/spark/sbin/start-master.sh
                ~/.local/bin/spark/sbin/start-worker.sh spark://localhost:7077
            fi

            if [[ "$1" == "stop" ]]; then
                ~/.local/bin/spark/sbin/stop-master.sh
                ~/.local/bin/spark/sbin/stop-worker.sh
            fi
        ;;
        pf)
            kubectl port-forward svc/mobidata-cassandra-datacenter1-service 9042:9042
        ;;
    esac
    
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
