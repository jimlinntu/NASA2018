#!/usr/bin/env bash
########################################################
# run ./deploy.sh [-d(optional flag)] [username] [key_path] [command] #
########################################################

suffix=".csie.ntu.edu.tw"
flag=false # -d flag 

# open ssh agent
eval $(ssh-agent) > /dev/null
ssh-add > /dev/null

# check if there is -d flag 
if [[ $1 == "-d" ]]; then
	# terminal multiplexer
	flag=true
	shift # shift over -d flag
fi

# parse arguments
username=$1 # username
key_path=$2 # key path

# concatenate command
cmd=""
shift 2 # shift over [username] and [key_path]
while test $# -gt 0;
do
	if [ $# -eq 1 ]
	then
		cmd+="$1"
	else
		cmd+="$1 "
	fi
	shift
done
# login and run command over all hosts
for name in ${username}@linux{1..15}${suffix} ${username}@oasis{1..3}${suffix} ${username}@bsd1${suffix} 
do
	printf "=%0.s" {1..15}
	printf "%s""$name"
	printf "=%0.s" {1..15}
	printf "\\n"
	if [ ${flag} = true ]; then
		# create a new window and run the command
		screen -d -m ssh -i "$key_path" -o StrictHostKeyChecking=no $name "${cmd}" 
	else	
		#printf "${cmd}\n"
		ssh -i "$key_path" -o StrictHostKeyChecking=no "$name" "${cmd}"
	fi
done
# close ssh agent
wait
# WARNING
sleep 5
ssh-agent -k
