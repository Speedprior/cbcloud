### Scripting for various tasks within Carbon Black Cloud 

#### Parentheses Legibilizer  
A self-contained webpage which takes lucene queries--like Carbon Black uses for search--and makes them more readable. It highlights syntax, emphasizing the boolean conditionals, and simplifies complex conditionals by progressively indenting nested parentheses.




#### Endpoint Sensor Detector    
Allows sysadmins to install a sensor, and then verify connectivity to the back end with just an API key (no Carbon Black Cloud credentials or web console login required).
Configure the script by adding the Org Key, and an API ID + API Key with Device Read permissions into the top two variables.
The script will check for an .msi install log, try running "repcli status," as local checks. It will also read the hostname and IPs off the system, then search for matching devices in Carbon Black Cloud's API, and return any devices that match the hostname and at least one of the IPs assigned to it.
