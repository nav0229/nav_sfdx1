#!/bin/bash
#commit server.key file to GIT repo/branch
	#. ./nav_property
	TODAY=`date '+%m-%d-%Y'.%H.%M.%S`
	sOrgNumber=`date '+'.%S`
echo "Todays Date is = $TODAY "
	ORGname=Dev_Hub
	export GitRepo=nav_sfdx1
	branch="test1"
	repoURL="git@github.com:nav0229/nav_sfdx1.git"
	Permset="Geolocation"
echo "1) ---->Clean up of existing directory structure / existing GIT repo "
	if [ -d "$GitRepo" ]; then rm -Rf $GitRepo; fi
	echo "----------Successfully cleanup directory structure--------------"
echo "2) ---->Going to Clone Artifact Code from GIT branch"
    git clone "$repoURL"
	if [[ $? -ne 0 ]]; then
    echo "---Error-->Check GIT Clone error"
	exit 1
	fi
	cd "$GitRepo"
	git checkout "$branch"
	. ./sfdx_property
	cd ..
	echo " 2.1) ---->Creating DX project area and generate config files "
	sfdx force:project:create -n $GitRepo
	cd "$GitRepo"	
	pwd
	echo " -----------------------------------------------------"
echo "3)----> user authentication using "JWT Authorizing with Dev Hub ""
	echo ""
		echo ""
				read -p "-------------Enter your "DEV-HUB" User Name -->> : " UserName
				echo ""
				echo "VERIFY: Is this correct username << $UserName>>"
				echo ""
				echo -n "Answer 'yes' or 'no': "
				read REPLY
			if [[ $REPLY == "yes" ]]; then
			echo ""
				echo Thank you for confirmation, Now System will initiate a JWT authentication request for you
				echo ""
			else
				echo Terminated.
				cd ..;rm -fR $GitRepo
				exit 0
			fi
	#sfdx force:auth:jwt:grant --clientid ${CONSUMER_KEY} --username ${HUB_USERNAME} --jwtkeyfile ${JWT_KEY_FILE} --setdefaultdevhubusername
	echo "-------------------------------------------------"
	sfdx force:auth:jwt:grant --clientid ${CONSUMER_KEY} --username $UserName --jwtkeyfile ${JWT_KEY_FILE} --setdefaultdevhubusername
	if [[ $? -ne 0 ]]; then
	echo ""
	echo "-------------------------------------------------"
	echo "Error-->Provide correct User name or check JWT Authentication Failure"
	cd ..;rm -fR $GitRepo
	exit 1
	fi
echo "4)---->Working on Creating a New Scratch Org "
	sfdx force:org:create -s -f  ./config/project-scratch-def.json  --setdefaultusername --setalias nav"$sOrgNumber"
	if [[ $? -ne 0 ]]; then
	echo ""
	echo "Error-->Process to create a Scratch Org has been Failed"
	cd ..;rm -fR $GitRepo
	exit 0
	fi
	echo "5)---->Push GIT branch code to Scratch Org "
	#Cleanup script part-2
	cd "$GitRepo"
	rm sfdx_property
	rm server.key
	rm mkso.sh
        rm ../mkso.sh
	cd ..
	sfdx force:source:push
	if [[ $? -ne 0 ]]; then
	echo "Error-->Push command failed for Scratch Org"
	exit 1
	fi
	sfdx force:user:permset:assign -n $Permset
	sfdx force:user:permset:assign -n ProjDash_Owner_Collaborator_CRED
	sfdx force:user:permset:assign -n ProjDash_Manager_CRED
	
#$echo "6)---->Export existing Account Data and convert into JSON "
	#sfdx force:data:tree:export -q "SELECT Id, Name, AccountNumber, BillingAddress from Account WHERE Name='Admin'OR Name='DevOps Admin'" --json  -x Account_output_file
	#sfdx force:data:tree:export -q "SELECT Id, Name, AccountNumber, Phone from Account" -d ./data --json  -x Data_BK_$TODAY
	#sfdx force:data:tree:export -q "SELECT Id, Name, Accomplishments__c, Action_Items__c, Blockers__c, Deadline__c, Description_and_Key_Elements__c, Domain__c, Escalations__c, Funding_Source_and_Needs__c, Key_Project__c, Other_Stakeholders__c, Owner_Name__c, Phase__c, Priority__c, Stakeholders__c, Status__c from ProjDash_Project__c"  -d ./data --json  -x cyber_BK_$TODAY
echo "6)---->Starting Import for Accounts - JSON Data File "
	sfdx force:data:tree:import --sobjecttreefiles ./data/Data-File1-Account.json 
	echo "Import for Accounts have been completed Successfully"
	echo "--------------------------------------"
	echo "Starting import of Project Dashboard Data"
	sfdx force:data:tree:import --sobjecttreefiles ./data/Data-File1-Dashboard.json
	echo "Import has been completed Successfully"
	echo "--------------------------------------"
echo "7)---->List all Scratch Orgs "
	sfdx force:org:list > ../my_scratch_orgs_list.txt
echo "8)---->running command to Open Scratch Orgs ----"
echo " Note:The Lightning Experience-enabled custom domain may take a few more minutes to resolve, Wait for 2.5 minutes before trying to Open New Scratch Org"	
	sleep 2.5m
	sfdx force:org:open
		if [[ $? -ne 0 ]]; then
	echo "-------------NOT ready yet,  Wait for another 2 minutes -------------------------"
	sleep 2m
	echo "----Waiting--------"
	sfdx force:org:open
	fi
	echo "------------------------------------------------------ "
	echo "----------Script has completed---------- "
	
