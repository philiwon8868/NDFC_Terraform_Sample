import sys
import requests
import json

## Disable Cert Warnings from requests
requests.packages.urllib3.disable_warnings()

# Variable definition
if len(sys.argv) != 2:
   print("Missing argment(s). The program will exit. Syntax: python3 Recalculate.py  <Fabric Name> ")
   sys.exit(0)

fabric1 = sys.argv[1]
url = "https://<NDFC IP>/login"


payload = json.dumps({
  "username": "<user name>",
  "password": "<password>"
})
headers = {
  'Content-Type': 'application/json',
}

print ("Getting auth_token from Nexus Dashboard...")

response = requests.request("POST", url, headers=headers, data=payload, verify=False)

# get token from login response structure
auth = json.loads(response.text)
auth_token = auth['token']

payload={}
headers = {
  'Cookie': 'Cookie'
}

headers['Cookie'] = 'AuthCookie=' + auth_token

# Recalculating the fabric configuration ... "

url = "https://<NDFC IP>/appcenter/cisco/ndfc/api/v1/lan-fabric/rest/control/fabrics/" + fabric1 + "/config-save"

print("Recalculating configuration...")

response = requests.request("POST", url, headers=headers, data=payload, verify=False)

if response.ok:
   print(json.loads(response.text)['status'])

# Deploy the configuration to the fabric ... "

url = "https://<NDFC IP>/appcenter/cisco/ndfc/api/v1/lan-fabric/rest/control/fabrics/" + fabric1 + "/config-deploy"

print("Deploying configuration...")

response = requests.request("POST", url, headers=headers, data=payload, verify=False)

if response.ok:
   print(json.loads(response.text)['status'])
