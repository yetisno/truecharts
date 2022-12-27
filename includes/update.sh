#!/bin/bash

update_apps(){
echo -e "${BWhite}App Updater${Color_Off}"
[[ -z $timeout ]] && echo -e "Default Timeout: 500" && timeout=500 || echo -e "\nCustom Timeout: $timeout"
[[ "$timeout" -le 120 ]] && echo "Warning: Your timeout is set low and may lead to premature rollbacks or skips"

echo ""
echo "Creating list of Apps to update..."

# Render a list of ignored applications, so users can verify their ignores got parsed correctly.
if [[ -z ${ignore[*]} ]]; then
  echo "No apps added to ignore list, continuing..."
else
  echo "ignored applications:"
  for ignored in "${ignore[@]}"
  do
    echo "${ignored}"
  done
fi
echo ""

mapfile -t array < <(cli -m csv -c 'app chart_release query name,update_available,human_version,human_latest_version,container_images_update_available,status' | grep -E ",true(,|$)" | sort)
[[ -z ${array[*]} ]] && echo -e "\nThere are no updates available or middleware timed out" && return 0 || echo -e "\n${#array[@]} update(s) available:"
PIDlist=()

# Draft a list of app names, seperate from actuall execution
# This prevents outputs getting mixed together
for i in "${array[@]}"
do
  app_name=$(echo "$i" | awk -F ',' '{print $1}') #print out first catagory, name.
  echo "$app_name"
done

echo ""
echo "Updating Apps..."

# Create a background task for each update as async solution
for i in "${array[@]}"
do
  executeUpdate "${i}" &
  PIDlist+=($!)
done
echo ""
echo "Waiting for update results..."

# Wait for all the async updates to complete
for p in "${PIDlist[@]}"
do
  wait "${p}" ||:
done

}
export -f update_apps



# This is a combination of stopping previously-stopped apps and apps stuck Deploying after update
after_update_actions(){
SECONDS=0
count=0
sleep 15

# Keep this running and exit the endless-loop based on a timer, instead of a countered-while-loop
# shellcheck disable=SC2050
while [[ "0"  !=  "1" ]]
do
    (( count++ ))
    status=$(cli -m csv -c 'app chart_release query name,update_available,human_version,human_latest_version,status' | grep "^$app_name," | awk -F ',' '{print $2}')
    if [[ "$status"  ==  "ACTIVE" && "$startstatus"  ==  "STOPPED" ]]; then
        [[ "$verbose" == "true" ]] && echo "Returing to STOPPED state.."
        midclt call chart.release.scale "$app_name" '{"replica_count": 0}' &> /dev/null && echo "Stopped"|| echo "FAILED"
        break
    elif [[ "$SECONDS" -ge "$timeout" && "$status"  ==  "DEPLOYING" && "$failed" != "true" ]]; then
        echo -e "Error: Run Time($SECONDS) for $app_name has exceeded Timeout($timeout)\nIf this is a slow starting application, set a higher timeout with -t\nIf this applicaion is always DEPLOYING, you can disable all probes under the Healthcheck Probes Liveness section in the edit configuration\nReverting update.."
        midclt call chart.release.rollback "$app_name" "{\"item_version\": \"$rollback_version\"}" &> /dev/null
        [[ "$startstatus"  ==  "STOPPED" ]] && failed="true" && after_update_actions && unset failed #run back after_update_actions function if the app was stopped prior to update
        break
    elif [[ "$SECONDS" -ge "$timeout" && "$status"  ==  "DEPLOYING" && "$failed" == "true" ]]; then
        echo -e "Error: Run Time($SECONDS) for $app_name has exceeded Timeout($timeout)\nThe application failed to be ACTIVE even after a rollback,\nManual intervention is required\nAbandoning"
        break
    elif [[ "$status"  ==  "STOPPED" ]]; then
        [[ "$count" -le 1 && "$verbose" == "true"  ]] && echo "Verifying Stopped.." && sleep 15 && continue #if reports stopped on FIRST time through loop, double check
        [[ "$count" -le 1  && -z "$verbose" ]] && sleep 15 && continue #if reports stopped on FIRST time through loop, double check
        echo "Stopped" && break #if reports stopped any time after the first loop, assume its extermal services.
    elif [[ "$status"  ==  "ACTIVE" ]]; then
        [[ "$count" -le 1 && "$verbose" == "true"  ]] && echo "Verifying Active.." && sleep 15 && continue #if reports active on FIRST time through loop, double check
        [[ "$count" -le 1  && -z "$verbose" ]] && sleep 15 && continue #if reports active on FIRST time through loop, double check
        echo "Active" && break #if reports active any time after the first loop, assume actually active.
    else
        [[ "$verbose" == "true" ]] && echo "Waiting $((timeout-SECONDS)) more seconds for $app_name to be ACTIVE"
        sleep 15
        continue
    fi
done
}
export -f after_update_actions

# Determine what all the required information for the App to update, check it and execute the update using the SCALE API
executeUpdate(){
  app_name=$(echo "$1" | awk -F ',' '{print $1}') #print out first catagory, name.
  old_app_ver=$(echo "$1" | awk -F ',' '{print $4}' | awk -F '_' '{print $1}' | awk -F '.' '{print $1}') #previous/current Application MAJOR Version
  new_app_ver=$(echo "$1" | awk -F ',' '{print $5}' | awk -F '_' '{print $1}' | awk -F '.' '{print $1}') #new Application MAJOR Version
  old_chart_ver=$(echo "$1" | awk -F ',' '{print $4}' | awk -F '_' '{print $2}' | awk -F '.' '{print $1}') # Old Chart MAJOR version
  new_chart_ver=$(echo "$1" | awk -F ',' '{print $5}' | awk -F '_' '{print $2}' | awk -F '.' '{print $1}') # New Chart MAJOR version
  status=$(echo "$1" | awk -F ',' '{print $2}') #status of the app: STOPPED / DEPLOYING / ACTIVE
  startstatus=$status
  diff_app=$(diff <(echo "$old_app_ver") <(echo "$new_app_ver")) #caluclating difference in major app versions
  diff_chart=$(diff <(echo "$old_chart_ver") <(echo "$new_chart_ver")) #caluclating difference in Chart versions
  old_full_ver=$(echo "$1" | awk -F ',' '{print $4}') #Upgraded From
  new_full_ver=$(echo "$1" | awk -F ',' '{print $5}') #Upraded To
  rollback_version=$(echo "$1" | awk -F ',' '{print $4}' | awk -F '_' '{print $2}')
  printf '%s\0' "${ignore[@]}" | grep -iFxqz "${app_name}" && echo -e "\n$app_name\nIgnored, skipping" && return #If application is on ignore list, skip
  if [[ "$diff_app" == "$diff_chart" || "$update_all_apps" == "true" ]]; then #continue to update
          [[ "$verbose" == "true" ]] && echo "Updating.."
          # shellcheck disable=SC2015
          cli -c 'app chart_release upgrade release_name=''"'"$app_name"'"' &> /dev/null && echo -e "Updated $app_name\n$old_full_ver\n$new_full_ver" && after_update_actions || { echo -e "$app_name: update ${IRed}FAILED${Color_Off}"; return; }
  else
      echo -e "\n$app_name\nMajor Release, update manually"
      return
  fi
}
export -f executeUpdate
