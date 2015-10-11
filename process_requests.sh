#!/bin/bash

BASEDIR=$(dirname "$(readlink -f $0)")

TYPEFORM_API_KEY=xxx
TYPEFORM_FORM_ID=pS0B3D

SLACK_API_TOKEN=xoxs-xxx
SLACK_TEAM_NAME=tashkentdevelopers

pushd $BASEDIR >/dev/null

# Load config file
[[ -f config ]] && source config

# Getting number of processed requests
processed_number=0
[[ -f processed_list ]] && processed_number=`wc -l < processed_list`

# Getting rew requests
data=`curl -s "https://api.typeform.com/v0/form/${TYPEFORM_FORM_ID}?key=${TYPEFORM_API_KEY}&completed=true&offset=${processed_number}&limit=100"`

# Extracting emails and seding invites
emails_number=`echo $data | jq '.responses | length'`
for (( i = 0; i < $emails_number; i++ )); do
	email=`echo $data | jq -r ".responses[${i}].answers.email_10536843"`
	firstname=`echo $data | jq -r ".responses[${i}].answers.textfield_10536841"`
	lastname=`echo $data | jq -r ".responses[${i}].answers.textfield_10536842"`

	echo "Inviting $firstname $lastname <$email> - to Slack"

	# Inviting new member
	response=`curl -s "https://${SLACK_TEAM_NAME}.slack.com/api/users.admin.invite" --data "email=${email}&first_name=${firstname}&last_name=${lastname}&token=${SLACK_API_TOKEN}&set_active=true"`

	# Saving processed request
	echo "$email|$first_name|$last_name" >> processed_list

	# Log invition result
	echo "$email : $response" >> log
done

popd >/dev/null
