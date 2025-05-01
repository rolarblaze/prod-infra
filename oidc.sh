#!/bin/bash
set -euo pipefail

# Open in DevContainer or...
#   - Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
#   - Install GitHub CLI: https://cli.github.com/
#   - Install JQ: https://stedolan.github.io/jq/download/

# Usage:
# ./oidc.sh <APP_NAME> <ORG|USER/REPO> <FICS_FILE>
# Example:
# ./oidc.sh prod-infra rolarblaze/prod-infra ./fics.json

IS_CODESPACE=${CODESPACES:-"false"}
if [ "$IS_CODESPACE" == "true" ]; then
    echo "This script doesn't work in GitHub Codespaces. See: https://github.com/Azure/azure-cli/issues/21025"
    exit 0
fi

APP_NAME=$1
export REPO=$2
FICS_FILE=${3:-"./fics.json"}
RESOURCE_GROUP="prod-rg"  # 👈 Change to your actual RG

echo "Checking Azure CLI login status..."
EXPIRED_TOKEN=$(az ad signed-in-user show --query 'id' -o tsv || true)

if [[ -z "$EXPIRED_TOKEN" ]]; then
    az login -o none
fi

ACCOUNT=$(az account show --query '[id,name]')
echo $ACCOUNT

read -r -p "Do you want to use the above subscription? (Y/n) " response
response=${response:-Y}
case "$response" in
    [yY][eE][sS]|[yY])
        ;;
    *)
        echo "Use 'az account set -s' to set the correct subscription and re-run this script."
        exit 0
        ;;
esac

echo "Getting Subscription Id..."
SUB_ID=$(az account show --query id -o tsv)
echo "SUB_ID: $SUB_ID"

echo "Getting Tenant Id..."
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "TENANT_ID: $TENANT_ID"

echo "Configuring application..."
APP_ID=$(az ad app list --filter "displayName eq '$APP_NAME'" --query [].appId -o tsv)

if [[ -z "$APP_ID" ]]; then
    echo "Creating AD app..."
    APP_ID=$(az ad app create --display-name ${APP_NAME} --query appId -o tsv)
    echo "Sleeping 30s for AD app to propagate..."
    sleep 30s
else
    echo "Existing AD app found."
fi

echo "APP_ID: $APP_ID"

echo "Configuring Service Principal..."
SP_ID=$(az ad sp list --filter "appId eq '$APP_ID'" --query [].id -o tsv)
if [[ -z "$SP_ID" ]]; then
    echo "Creating service principal..."
    SP_ID=$(az ad sp create --id $APP_ID --query id -o tsv)
    echo "Sleeping 30s for SP to propagate..."
    sleep 30s

    echo "Creating role assignment..."
    az role assignment create \
      --role Contributor \
      --subscription $SUB_ID \
      --assignee-object-id $SP_ID \
      --assignee-principal-type ServicePrincipal \
      --scope /subscriptions/$SUB_ID/resourceGroups/$RESOURCE_GROUP
    sleep 30s
else
    echo "Existing Service Principal found."
fi

echo "SP_ID: $SP_ID"

echo "Creating Federated Identity Credentials..."
for FIC in $(envsubst < $FICS_FILE | jq -c '.[]'); do
    SUBJECT=$(jq -r '.subject' <<< "$FIC")
    echo "Creating FIC with subject '${SUBJECT}'..."
    az ad app federated-credential create --id $APP_ID --parameters "$FIC" || true
done

echo "✅ Federated Identity setup complete."
echo "Creating GitHub secrets..."

echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUB_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"

echo "🔐 Logging into GitHub CLI..."
gh auth login

gh secret set AZURE_CLIENT_ID -b${APP_ID} --repo $REPO
gh secret set AZURE_SUBSCRIPTION_ID -b${SUB_ID} --repo $REPO
gh secret set AZURE_TENANT_ID -b${TENANT_ID} --repo $REPO
