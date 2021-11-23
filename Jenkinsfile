node{
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID
    def DEPLOYDIR = 'toDeploy'
    def APIVERSION = '51.0'
    def toolbelt = tool 'toolbelt'

    if ((params.PreviousCommitId == '') || (params.LatestCommitId == ''))
	{
		error("Please enter both Previous and Latest commit IDs")
	}
    if (params.PreviousCommitId == params.LatestCommitId)
	{
		error("Previous and Latest Commit IDs can't be same.")
	}
    if (TESTLEVEL=='RunSpecifiedTests')
	{
		if (params.SpecifyTestClass == '')
		{
			error("Please Specify Test classes")
		}
	}
    stage('Clean Workspace') {
        try {
            deleteDir()
        }
        catch (Exception e) {
            println('Unable to Clean WorkSpace.')
        }
    }
    stage('checkout source') {
        checkout scm
    }
    withEnv(["HOME=${env.WORKSPACE}"]) {	
	
	    withCredentials([file(credentialsId: SERVER_KEY_CREDENTIALS_ID, variable: 'server_key_file')]) {

		stage('Authorize to Salesforce') {
			rc = command "${toolbelt}/sfdx auth:jwt:grant --instanceurl https://login.salesforce.com --clientid 3MVG9pRzvMkjMb6lSZXveI54gmUzVSHO1jDFPKhRCPq3v68enpjIxC7lBGs9mi2bh5XEUESdq8Vy1d3_gEsPq --jwtkeyfile ${server_key_file} --username shivam@nagarro.com --setalias shivam@nagarro.com"
		    if (rc != 0) {
			error 'Salesforce org authorization failed.'
		    }
		}
	
        stage('Delta changes')
		{
			script
            {
				rc = command "${toolbelt}/sfdx sfpowerkit:project:diff --revisionfrom 7e19acba8bc2b27a24b298056f583441230efb67 --revisionto a3f16118d9c1981ed1f2ead2f1d99b2bf1eae6c9 --output DeltaChanges --apiversion ${APIVERSION} -x"
            }
        }
        stage('Validate Only') 
		{
			if (Deployment_Type=='Validate Only')
			{
				script
				{
				
					if (TESTLEVEL=='NoTestRun') 
					{
						println TESTLEVEL
						rc = command "${toolbelt}/sfdx force:mdapi:deploy -d todeploy --checkonly --wait 10 --targetusername shivam@nagarro.com "
					}
					else if (TESTLEVEL=='RunLocalTests') 
					{
						println TESTLEVEL
						rc = command "${toolbelt}/sfdx force:mdapi:deploy -d todeploy --checkonly --wait 10 --targetusername shivam@nagarro.com --testlevel ${TESTLEVEL} --verbose --loglevel fatal"
					}
					else if (TESTLEVEL=='RunSpecifiedTests')
					{
						println TESTLEVEL
						def Testclass = SpecifyTestClass.replaceAll('\\s','')
						println Testclass
						rc = command "${toolbelt}/sfdx force:mdapi:deploy -d todeploy --checkonly --wait 10 --targetusername shivam@nagarro.com --testlevel ${TESTLEVEL} -r ${Testclass} --verbose --loglevel fatal"
					}
   
					else (rc != 0) 
					{
						error 'Validation failed.'
					}
				}
			}
   		}

        stage('Deploy and Run Tests') 
		{
			if (Deployment_Type=='Deploy Only')
			{	
				script
				{
					if (TESTLEVEL=='NoTestRun') 
					{
						println TESTLEVEL
						rc = command "${toolbelt}/sfdx force:mdapi:deploy -d todeploy --wait 10 --targetusername shivam@nagarro.com "
					}
					else if (TESTLEVEL=='RunLocalTests') 
					{
						println TESTLEVEL
						rc = command "${toolbelt}/sfdx force:mdapi:deploy -d todeploy --wait 10 --targetusername shivam@nagarro.com --testlevel ${TESTLEVEL} --verbose --loglevel fatal"
					}
					else if (TESTLEVEL=='RunSpecifiedTests') 
					{
						println TESTLEVEL
						def Testclass = SpecifyTestClass.replaceAll('\\s','')
						println Testclass						
						rc = command "${toolbelt}/sfdx force:mdapi:deploy -d todeploy --wait 10 --targetusername shivam@nagarro.com --testlevel ${TESTLEVEL} -r ${Testclass} --verbose --loglevel fatal"
					}
					else (rc != 0) 
					{
						error 'Salesforce deployment failed.'
					}
				}
			}
		}

		}
    }             
}
def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
		return bat(returnStatus: true, script: script);
    }
}