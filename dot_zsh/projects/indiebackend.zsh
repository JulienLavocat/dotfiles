#### Indiebackend stack's Terraform
alias dtfd='tf destroy --auto-approve -var-file=dev.tfvars'
alias dtfa='tf apply --auto-approve -var-file=dev.tfvars'
alias dtfr='tf refresh -var-file=dev.tfvars'
alias dtfi='tf init -var-file=dev.tfvars'
alias dtfp='tf plan -var-file=dev.tfvars'


alias stfd='tf destroy --auto-approve -var-file=stack.tfvars'
alias stfa='tf apply --auto-approve -var-file=stack.tfvars'
alias stfr='tf refresh -var-file=stack.tfvars'
alias stfi='tf init -var-file=stack.tfvars'
alias stfp='tf plan -var-file=stack.tfvars'

alias ktfd='tf destroy --auto-approve -var-file=vars.tfvars'
alias ktfa='tf apply --auto-approve -var-file=vars.tfvars'
alias ktfr='tf refresh -var-file=vars.tfvars'
alias ktfi='tf init -var-file=vars.tfvars'
alias ktfp='tf plan -var-file=vars.tfvars'

# Exports
export IDB_HOME="/home/julien/idb"
export IDB_CURRENT_STACK=staging
export IDB_EDITOR=code


# Functions
function idb-stack() {
  export IDB_CURRENT_STACK=$1
  echo "Set current stack to ${IDB_CURRENT_STACK}"
}

function idb-config() {
  export MONGODB_URL="mongodb://root:pass@mongo:27017/idb?authSource=admin"
  export RABBITMQ_URL="amqp://user:pass@rabbitmq"
  export REDIS_URL="redis://default:pass@redis-headless"
  export SMTP_USERNAME="REDACTED"
  export SMTP_PASSWORD="REDACTED"
  export STACK=$IDB_CURRENT_STACK
  export RULES_URL="${RULES_URL:-"rules:9000"}"
}

function idb-dev() {
	idb-config
  yarn prisma db push && yarn start:dev
}

function idb-e2e() {
  idb-config
  yarn test:e2e $2 $3 $4 $5 $6 $7 $8 $9
}

function idb-redis() {
    redis-cli -u "redis://default:pass@redis-headless"
}

function idb-code() {
  cd $IDB_HOME/$1
  code .
}

function idb-pf() {
  echo "Starting port forward on stack: $IDB_CURRENT_STACK"

  # Do not port-forward the rules service
  if [[ -z $1 ]]
  then
    kubefwd -l "app.kubernetes.io/name in (mongodb,rabbitmq,redis,rules-service)" -n $IDB_CURRENT_STACK
  else
    kubefwd -l "app.kubernetes.io/name in (mongodb,rabbitmq,redis)" -n $IDB_CURRENT_STACK
  fi
}

function idb-create-stack() {
	echo "Creating stack $1"
	pwd=$PWD

	cd $IDB_HOME/iac/stack
	terraform workspace select -or-create $1
	terraform apply --auto-approve -var-file=stack.tfvars
	open https://argocd.dev.indiebackend.com/applications?proj=e2e

	cd $pwd
}

# Function to manage Indiebackend's services
# @usage idb [subcommand] (--arguments)
# @usage idb pf [stack]
# @usage idb dev [stack]
# @usage idb update [stack] [service]
# @usage idb update [stack] all
function idb() {
  case "$1" in
    pf)
      [[ -z "$IDB_CURRENT_STACK" ]] && { echo "Missing stack name, please use idb stack <stack name>"; return 2 }
      idb-pf
      return 0
      ;;
    dev)
      [[ -z $IDB_CURRENT_STACK ]] && { echo "Missing stack name, please use idb stack <stack name>"; return 2 }
      idb-dev
      return 0
      ;;
    e2e)
      [[ -z $IDB_CURRENT_STACK ]] && { echo "Missing stack name, please use idb stack <stack name>"; return 2 }
      idb-e2e
      return 0
      ;;
    stack)
      [[ -z "$2" ]] && { echo "Missing stack name, please use idb stack <stack name>"; return 2 }
      idb-stack $2
      return 0
    ;;
    code)
      [[ -z "$2" ]] && { echo "Missing project name, please use idb code <project>"; return 2 }
      idb-code $2
      return 0
    ;;
    redis)
      idb-redis
      return 0
    ;;
		config)
      idb-config
      return 0
    ;;
		create-stack)
			idb-create-stack $2
			return 0
		;;
  esac

  echo "Invalid subcommand, available subcommands are: pf, dev, stack, code, redis"
  return 1
}
