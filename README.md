# Prerequisites

## Creating app registration used for authentication

On Azure Portal (You will need to [activate](https://portal.azure.com/#blade/Microsoft_Azure_PIM/DirectoryRoleManagementMenuBlade/DirectoryRolesActivation) Application Developer role to do this)

- Create an app registration
- Under Overview -> Managed Application -> Properties, set "User assignment Required" to "Yes". Then, add the users of the application

## Create a storage account

- Create a storage account underneath your Omnia subscription or for your [Omnia Application](https://docs.omnia.equinor.com/)
- Create a blob container under your storage account
- You will need to have 'Storage Blob Data Contributor' role in order to be able to upload to storage account

# First time creation

1. `pip install webviz-config`

That will ensure that user can run webviz CLI (command line interface) commands

2. `git@github.com:ingeknudsen/webviz-subsurface-on-radix.git`

Cloning the repo down to your folder

3. `git clone --depth 1 https://github.com/equinor/webviz-subsurface-testdata`

Cloning the example repo into your folder

4. `cd webviz-subsurface-on-radix`

Navigate to the repo

5. `./hack/publish_app.sh`

Runs the steps for publishing the report to Radix. It requires that webviz and Azure CLI has been installed

# Setting up on Radix

Add the [radixconfig](https://github.com/ingeknudsen/webviz-subsurface-on-radix/blob/master/radixconfig.yaml). Note that the name needs to correspond with the name you give it in Radix. The suggested Radix config uses an OAuth proxy in front of the webviz report. For more info on this please see [this](https://github.com/equinor/radix-example-oauth-proxy) example. In the suggested radixconfig it is important that the `OAUTH2_PROXY_CLIENT_ID` and the `OAUTH2_PROXY_SCOPE` refers to the application id of the application registration you created as a prerequisite.

In the relevant cluster, [playground](https://console.playground.radix.equinor.com/applications) or [production](https://console.radix.equinor.com/applications) create the application. Follow the instructions given in the Radix console. When the application has been registered successfully, you will need to make a commit to the repository, in order to trigger a build of the code. Once the build is successful, you will need to set the correct secret values to have the application run ok. Go to the environment and set the corresponding secrets. For the auth container this will be:

- `OAUTH2_PROXY_CLIENT_SECRET` - On the app registration created in the prerequisites, go to certificate and secret and create a new client secret. Give it any name you want, and copy the value. On the Radix console, set the secret
- `OAUTH2_PROXY_COOKIE_SECRET` - As documented [here](https://github.com/equinor/radix-example-oauth-proxy#client)
- `OAUTH2_PROXY_REDIRECT_URL`- Typically this should be `https://<your app name>.app.<playground or omit in production cluster>.radix.equinor.com/oauth2/callback` (i.e. https://webwiz-subsurface-on-radix.app.radix.equinor.com/oauth2/callback). Go to your app registration -> Authentication and add this to the list of Redirect URIs

For the main container:

- `AZURE_STORAGE_CONNECTION_STRING` - Go to the storage account -> Setting -> Access Keys -> Connection String. Copy value
- `AZURE_STORAGE_CONTAINER_NAME` - The name of the container you created to hold the `webviz_storage` data
- `AZURE_STORAGE_CONTAINER_PATH` - The path inside the container

# CI/CD (Continous Integration/Continous Deployment) on Radix

![Publish Webviz to Radix](./images/Publish_Webviz_App.gif)
