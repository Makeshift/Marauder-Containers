#!/bin/bash
set +ex

Cyan='\033[0;36m'         # Cyan
Yellow='\033[0;33m'       # Yellow
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
C='\033[0m'       # Text Reset

PROJECT_NAME=${PROJECT_NAME:="${PROJECT_NAME_PREFIX}$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)"}

echo -e "${Yellow}******************************${C}"
echo -e "${Green}Current configuration:"
echo -e "${Cyan}PROJECT_NAME_PREFIX   ${Green}:${C}    ${PROJECT_NAME_PREFIX}"
echo -e "${Cyan}PROJECT_NAME          ${Green}:${C}    ${PROJECT_NAME}"
echo -e "${Cyan}EXPORT_LOCATION       ${Green}:${C}    ${EXPORT_LOCATION}"
echo -e "${Cyan}SA_EMAIL_PREFIX       ${Green}:${C}    ${SA_EMAIL_PREFIX}"
#echo -e "${Cyan}GROUP_NAME            ${Green}:${C}    ${GROUP_NAME}"
echo -e "${Cyan}NUM_OF_SA             ${Green}:${C}    ${NUM_OF_SA}"
echo -e "${Cyan}GROUP_EMAIL           ${Green}:${C}    ${GROUP_EMAIL}"
echo -e "${Yellow}******************************${C}"

echo -e "${Red}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${C}"
echo -e "${Cyan}This script will: ${C}"
echo -e "${Red}*${C} Log you into GCloud"
echo -e "${Red}*${C} Create a project named ${Yellow}${PROJECT_NAME}${C}"
echo -e "${Red}*${C} Enable the Google Drive API on that project"
echo -e "${Red}*${C} Create ${Yellow}${NUM_OF_SA}${C} service accounts for that project"
echo -e "${Red}*${C} Output the credentials for those service accounts in ${Yellow}${EXPORT_LOCATION}${C} (in the container - This is likely mounted to the host somewhere) in the format ${Yellow}${PROJECT_NAME}-##.json${C}"
echo -e "${Red}*${C} Output a ${Yellow}${PROJECT_NAME}-members.csv${C} file that can be used to add those service accounts to a group"
echo -e "${Red}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${C}"
read -p "Type Y to continue " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

if [ -z $GROUP_EMAIL ]; then
    echo -e "${Cyan}Please type in the email address for the group, followed by [${Green}ENTER${Cyan}]:${C} "
    read GROUP_EMAIL
    if [[ $GROUP_EMAIL != *"@"* ]]; then
        echo -e "${Red}The string ${Yellow}${GROUP_EMAIL}${Red} doesn't look like a valid email address. It should be in the format ${Cyan}<${Yellow}group_name${Cyan}>${Green}@${Yellow}your_domain.tld${C}"
        exit 1
    fi
fi

echo -e "${Cyan}Using project name ${Yellow}${PROJECT_NAME}${C}"

echo -e "${Cyan}Logging into Google Cloud${C}"
if ! gcloud auth list --format=text | grep "ACTIVE" > /dev/null; then
    if ! gcloud auth login; then
        echo -e "${Red}Logging in to Google Cloud failed.${C}"
        exit 1
    fi
fi

if ! gcloud projects list --format=text | grep "${PROJECT_NAME}" > /dev/null; then
    echo -e "${Cyan}Creating project with name ${Yellow}${PROJECT_NAME}${C}"
    if ! gcloud projects create $PROJECT_NAME; then
        echo -e "${Red}Creating project ${Yellow}${PROJECT_NAME}${Red} failed.${C}"
        exit 1
    fi
else
    echo -e "${Green}Project ${Yellow}${PROJECT_NAME}${Green} already exists.${C}"
fi

if ! gcloud config set project $PROJECT_NAME; then
    echo -e "${Red}Setting project to ${Yellow}${PROJECT_NAME}${Red} failed.${C}"
    exit 1
fi

if ! gcloud services list | grep "drive.googleapis.com" > /dev/null; then
    echo -e "${Cyan}Enabling the Google Drive api on project ${Yellow}${PROJECT_NAME}${C}"
    if ! gcloud services enable drive.googleapis.com; then
        echo -e "${Red}Enabling Google Drive api on project ${Yellow}${PROJECT_NAME}${Red} failed.${C}"
        exit 1
    fi
    sleep 10s
else
    echo -e "${Green}Google Drive api already enabled on project ${Yellow}${PROJECT_NAME}${C}"
fi

PROJECT_ID=$(gcloud projects list --filter="NAME:${PROJECT_NAME}" --format="value(projectId)")

echo -e "${Cyan}Project ID set to ${Yellow}${PROJECT_ID}${C}"

# echo -e "Enabling the Google Admin api on project $PROJECT_NAME"
# gcloud services enable admin.googleapis.com
# Since gcloud sucks and doesn't have APIs for half the things we need, grab a token for later HTTP requests
# IDENTITY_TOKEN=$(gcloud auth print-identity-token)
# ACCESS_TOKEN=$(gcloud auth print-access-token)
# Create a service account to manage the admin api from
# if ! echo "$PRE_SA_LIST" | grep "marauder-manager" > /dev/null; then
#     echo -e "Creating a service account for managing marauder users"
#     gcloud iam service-accounts create marauder-manager --display-name=marauder-manager
#     gcloud projects add-iam-policy-binding $PROJECT_ID --member "serviceAccount:marauder-manager@${PROJECT_ID}.iam.gserviceaccount.com" --role "roles/owner"
#     gcloud iam service-accounts keys create ${EXPORT_LOCATION}/marauder-manager.json --iam-account=marauder-manager@${PROJECT_ID}.iam.gserviceaccount.com
# else
#      echo -e "Project $PROJECT_NAME already has Marauder management service account".
# fi


PRE_SA_LIST=$(gcloud iam service-accounts list)
# Create CSV header
echo -e "Group Email [Required],Member Email,Member Type,Member Role" > $EXPORT_LOCATION/${PROJECT_NAME}-members.csv
# Create service accounts
for i in $(seq 1 $NUM_OF_SA); do
    name="${SA_EMAIL_PREFIX}${i}"
    filename="${name}-${PROJECT_ID}"
    email="${name}@${PROJECT_ID}.iam.gserviceaccount.com"
    if ! echo "$PRE_SA_LIST" | grep "$email" > /dev/null; then
        echo -e "${Cyan}Creating service account ${Yellow}${name}${C}"
        if gcloud iam service-accounts create $name --display-name=$name; then
            if gcloud iam service-accounts keys create ${EXPORT_LOCATION}/${filename}.json --iam-account=${email}; then
                echo "${GROUP_EMAIL},${email},USER,MEMBER" >> $EXPORT_LOCATION/${PROJECT_NAME}-members.csv
            else
                echo -e "${Red}Failed to create keys for service account with name ${Yellow}${name}${Red} and email ${Yellow}${email}${C}"
            fi
        else
            echo -e "${Red}Failed to create service account with name ${Yellow}${name}${C}"
        fi
    else
        echo -e "${Green}Project ${Yellow}${PROJECT_NAME}${Green} already has a service account user ${Yellow}${email}${Green}, skipping${C}"
    fi

done

echo -e "${Green}All done creating ${Yellow}${NUM_OF_SA}${Green} service accounts! The CSV of members is in ${Yellow}${PROJECT_NAME}-members.csv${C}"