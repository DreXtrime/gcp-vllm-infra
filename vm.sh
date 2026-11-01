#!/usr/bin/env bash
# Usage: ./vm.sh [up|down|status]
#
# up     – start the instance (bills GPU time)
# down   – stop the instance  (stops GPU billing, keeps disk + IP)
# status – show current instance state

set -euo pipefail

TERRAFORM_DIR="$(dirname "$0")/terraform"

usage() {
  echo "usage: $0 [up|down|status]"
  exit 1
}

[[ $# -eq 1 ]] || usage

case "$1" in
  up)
    echo "Starting instance..."
    terraform -chdir="$TERRAFORM_DIR" apply -var="running=true" -auto-approve
    echo ""
    terraform -chdir="$TERRAFORM_DIR" output instance_ip
    ;;
  down)
    echo "Stopping instance (GPU billing stops, disk and IP are retained)..."
    terraform -chdir="$TERRAFORM_DIR" apply -var="running=false" -auto-approve
    ;;
  status)
    terraform -chdir="$TERRAFORM_DIR" output instance_ip 2>/dev/null || true
    # Pull state from the Terraform state file rather than calling gcloud
    terraform -chdir="$TERRAFORM_DIR" show -json \
      | python3 -c "
import sys, json
state = json.load(sys.stdin)
for r in state.get('values', {}).get('root_module', {}).get('resources', []):
    if r['type'] == 'google_compute_instance':
        v = r['values']
        print(f\"instance : {v['name']}\")
        print(f\"status   : {v['desired_status']}\")
        print(f\"zone     : {v['zone']}\")
"
    ;;
  *)
    usage
    ;;
esac
