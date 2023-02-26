Cert-Manager Deployment
=======================

Collection of files to deploy Cert-Manager on a single K3s linux node (tested on Debian).

This will deploy Cert-Manager on K3s with:
  - 'prod-issuer' Which will create and manager Lets Encrypt certificates, using Cloudflare DNS verification.
  - 'selfsigned-issuer' Which will create and manage self signed certificates, using a custom Root Certificate Authority certificate.

Cert-Manager Project:
------------------------

The Cert-Manager project is pulled from the [jetstack/cert-manager](https://cert-manager.io/docs/installation/helm/) helm repository.

You can find more information on their website [https://cert-manager.io](https://cert-manager.io) or in the repository linked above.

Cert-Manager Deployment Variables:
----------------------------------

```yml
  CLOUDFLARE_API_TOKEN='ZN0tr3AL9sEHl19yqjHzpy_fAkET0keNn_ddqg_y'      #This is the cloudflare token to be used by cert-manager.
  CLOUDFLARE_EMAIL_ADDRESS='example@example.com'     #This is the email address that will be associated with your LetsEncrypt certificates.m'.
```

  Variables are provided as part of the 'deploy-k3s.sh' script included in the top level directory of this repository - See the [README.md](https://k3s.autothis.org/) file for more information.

Cert-Manager Deployment Instructions:
-------------------------------------

  Deployment instructions are provided as part of the 'deploy-k3s.sh' script included in the top level directory of this repository - See the [README.md](https://k3s.autothis.org/) file for more information.

Cert-Manager 'prod-issuer' Notes:
---------------------------------------

  ### Creating a Cloudflare API Token
  
  In order for Cert-Manager to generate SSL certificates, you need to provide an API Token for Cloudflare, to allow it to manage DNS entries for the domain you are assigning an SSL certificate for.

  Cloudflare API Token will need the following permissions:
  - Zone - DNS - Edit
  - Zone - Zone - Read

  From the Cloudflare dashboard, go to 'My Profile' > 'API Tokens' and select 'Create Token'.  Pick the template 'Edit Zone DNS' and make sure the under permissions section, that you configure the permissions listed above.  Under 'Zone Resources' select either the specific domain you want to grant these permissions for, or 'All Zones'.
  
  Click 'Continue to Summary', and then 'Create Token'.

  See the [Cert-Manager Documentation](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/) for more information.

Cert-Manager 'selfsigned-issuer' Notes:
---------------------------------------

  ### Retreive 'Root Certificate Authority' Certificate

  As part of the deployment of K3s, you will be provided with a Root Certificate Authority certificate.  For your devices to trust this certificate, it will need to be installed as a Trusted Root Certificate on each device.

  There are 3 methods to retreive the Root Certificate Authority certificate.
  
  #### Method 1:
  You can retreive the Root Certificate Authority certificate by copying the output provided at the end output from running the deploy-k3s.sh script.
  
  #### Method 2:
  You can retrive the Root Certificate Authority certificate by extracting it from the secret 'tls-selfsigned-ca' in the cert-manager namespace, using the kubectl command below:

```
  kubectl get secrets/tls-selfsigned-ca --namespace cert-manager -o 'jsonpath={..data.tls\.crt}' | base64 -d
```

  #### Method 3:
  You can retrive the Root Certificate Authority certificate by extracting it from the secret 'tls-selfsigned-ca' in the cert-manager namespace, using the Kubernetes Dashboard.
  
  To do this, browse to and log into your Kubernetes Dashboard, select the 'cert-manager' namespace from the dropdown list at the top of the page, go to the 'Secrets' section under 'Configs and Storage' on the left hand side.

  Select from the list of Secrets 'tls-selfsigned-ca', and under the data section click the 'eye' icon to view the certificate for 'ca.crt' or 'tls.crt' (these are both the same certificate, so it really doesnt matter which one you pick).

### Install 'Root Certificate Authority' Certificate

  Copy the certificate provided in the "Retreive 'Root Certificate Authority' Certificate" instructions, and put it in a plain text file, with the file extention of '.crt'.

  This '.crt' file can then be provided to a Group Policy, Intune, Ansible Play or other management tool to be installed across a large pool of devices.

  You can also manually install the certificate on varying devices.

  #### Windows:
  Using the GUI you can right click on the '.crt' file in Windows, select 'Install Certificate' from the menu.  Then follow the installation wizard, select 'Local Machine', select 'Place all certificates in the following store' and click 'Browse', pick 'Trusted Root Certificate Authorities' from the drop down list and click 'ok', click 'Next' and then click 'Finish'.

  Using Powershell you can execute the following command, replacing 'C:\Temp\k3s-custom-ca.crt' with the path to the path of your '.crt' file:

```powershell
  Import-Certificate -FilePath "C:\Temp\k3s-custom-ca.crt" -CertStoreLocation Cert:\LocalMachine\Root
```

  #### Debian:
  Using the commands below, and replacing with your own certificate, you can create a file called 'k3s-custom-ca.crt'

```bash
# Create Custom CA Directory for K3s
CUSTOM_CA_LOCATION="/usr/local/share/ca-certificates/k3s"
sudo mkdir $CUSTOM_CA_LOCATION

# Create CA Certificate File
sudo cat << EOF > $CUSTOM_CA_LOCATION/k3s-custom-ca.crt
-----BEGIN CERTIFICATE-----
MIIC/TCCAeWgAwIBAgIRAKcPi+na439dAjc9b1USopgwDQYJKoZIhvcNAQELBQAw
GDEWMBQGA1UEAxMNc2VsZnNpZ25lZC1jYTAeFw0yMzAyMjIxMjQyNTlaFw0yODAy
MjExMjQyNTlaMBgxFjAUBgNVBAMTDXNlbGZzaWduZWQtY2EwggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQDJuiMv14dphKVZOI7AW4JN+ICZp2IvCoQ3pqMq
M/hzV0WZeJxTysPmGUDO8ukQS0oNqp1tlWfupzQi6DYu2tN1rqxKfnEIMT10j2U3
W3R/RIbOW60R2luHk6vg3cd/8J+9rFgiiWvZygzCs4auUcl44ywZhRs974mHXImB
ytLc/UkVaj5xHzn5n29SgR0Pen/QxtH9gTeetanYEi6/5W85Z9tFGigyuaaKvg+O
wtxnYyHwrmHwCyZybpuXiRVhzd5zqwvwV3THjrfIIhucJ+Pko8K+Qfja77INbUza
EMVRxp4Wxa4b9PAgT5INFCKq+jcwfx//Lked/eCkXZXvqHURAgMBAAGjQjBAMA4G
A1UdDwEB/wQEAwICpDAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTtO3Y5a55L
YASXhCZVyhOjKt1I0zANBgkqhkiG9w0BAQsFAAOCAQEAV6vpxSm/jwVuRIYM4PDz
YQnC3DU1P6s3SZRm8ZYY8jsgkk8Z109MSdx6SvUND6muVkCIS6VavgWX4N3NKk5I
m6FoGQuxuCxl9MtfbV0FcOxBFZZyeQ+mqMd2SML5ggnd4UejIyI14Z/BZQemofqr
T1izF6mUu+nMmyOzLuMebhstxkbESKf4GzXfK1HMDStyBoJNUoGJMb8dOqXO3NY/
UG3PnUkD1ZB7Az2swhBYBoEGaowMMfOPe//S5X2qPywa1XwTNkAm6am5AVMNkVqt
reXxao6o8+kfcmuDKMxuMWp10SV0AcUEQwtglyl6jFRCHNAi3NCEdlLmAxZbku1E
/A==
-----END CERTIFICATE-----
EOF

# Update Host CA Certificate Store
sudo update-ca-certificates
```

  #### Firefox:
  While Chrome and Edge honor the Root Certificate Authority certificates installed on the device, Firefox requires additional configuration.

  Depending on how you want to manage custom Root Certificate Authority certificates, you can either:
  
  ##### Method 1:
  Allow all custom Root Certificiate Authority certificates installed on the device by configuring Firefox to accept all certificates in the 'Trusted Root Certificate Authorities' location.
    
  This is done by putting 'about:config' in the address bar of Firefox, and search for 'security.enterprise_roots.enabled'.  You can then toggle the value between 'true' and 'false' (you want to set it to 'true' in this case).

  ##### Method 2:
  Allow a specific custom Root Certificiate Authority certificate by adding your specific Root Certificate Authority certificate to the list of Root Certificate Authorities trusted by Firefox on your device.
    
  In Firefox go to 'Settings' > 'Privacy & Security' > 'Security' > 'Certificates' and click the 'View Certificates' button.  In the 'Authorities' tab, click the 'Import' button and select your '.crt' file and click 'open', then select the 'Trust this CA to identiy websites' tickbox and click 'ok'.
