my_app_id='381130bc-1e58-43fe-a985-59bb76cc098b'
secret_validity_in_days='90'

current_date=$(date -u +"%Y-%m-%dT%H:%M:%S")
client_secret_end_date=$(date -d "+$secret_validity_in_days days" -u +"%Y-%m-%dT%H:%M:%S")
client_secret_name=secret_$current_date
           
# add new secret
my_secret=$(az ad app credential reset --id $my_app_id --append --display-name $client_secret_name --end-date $client_secret_end_date --query password --only-show-errors --output tsv)
echo "::add-mask::$my_secret"
echo "my_secret=$my_secret" >> $GITHUB_OUTPUT
 
# delete expired secrets
for keyId in $(az ad app credential list --id $my_app_id --query "[].keyId" -o tsv); do
  endDateTime=$(az ad app credential list --id $my_app_id --query "[?keyId=='$keyId'].endDateTime" -o tsv)
  if [[ $(date -d "$endDateTime") < $(date -u +%s) ]]; then
    az ad app credential delete --id $my_app_id --key-id $keyId
  fi
done