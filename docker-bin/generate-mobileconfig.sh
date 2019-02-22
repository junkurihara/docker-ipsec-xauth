#!/bin/bash

ENCODED_SHARED_SECRET=`echo "${VPN_IPSEC_PSK}" | tr -d '\n' | base64`

if [ -z "${VPN_DNS_SRV1}" ] && [ -z "${VPN_DNS_SRV2}" ]; then
    VPN_DNS_OPT="<string>8.8.8.8</string><string>8.8.4.4</string>"
elif [ ! -z "${VPN_DNS_SRV1}" ] && [ -z "${VPN_DNS_SRV2}" ]; then
    VPN_DNS_OPT="<string>${VPN_DNS_SRV1}</string>"
elif [ -z "${VPN_DNS_SRV1}" ] && [ ! -z "${VPN_DNS_SRV2}" ]; then
    VPN_DNS_OPT="<string>${VPN_DNS_SRV2}</string>"
elif [ ! -z "${VPN_DNS_SRV1}" ] && [ ! -z "${VPN_DNS_SRV2}" ]; then
    VPN_DNS_OPT="<string>${VPN_DNS_SRV1}</string><string>${VPN_DNS_SRV2}</string>"
fi


if [ ! -d "/data/mobileconfig" ]; then
    mkdir -p /data/mobileconfig
fi

count=1
cuser=$(printf '%s' "$VPN_USERS" | cut -d ' ' -f 1)
cpassword=$(printf '%s' "$VPN_PASSWORDS" | cut -d ' ' -f 1)

while [ -n "$cuser" ] && [ -n "$cpassword" ]; do
    echo "-- Generate mobileconfig for ${cuser}."
    cat > /data/mobileconfig/${cuser}.mobileconfig <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>IPSec</key>
			<dict>
				<key>AuthenticationMethod</key>
				<string>SharedSecret</string>
				<key>LocalIdentifierType</key>
				<string>KeyID</string>
				<key>RemoteAddress</key>
				<string>${VPN_HOST_NAME}</string>
				<key>SharedSecret</key>
				<data>
				${ENCODED_SHARED_SECRET}
				</data>
				<key>XAuthEnabled</key>
				<integer>1</integer>
				<key>XAuthName</key>
				<string>${cuser}</string>
				<key>XAuthPassword</key>
				<string>${cpassword}</string>
			</dict>
			<key>IPv4</key>
			<dict>
				<key>OverridePrimary</key>
				<integer>1</integer>
			</dict>
			<key>PayloadDescription</key>
			<string>Configures VPN settings</string>
			<key>PayloadDisplayName</key>
			<string>VPN</string>
			<key>PayloadIdentifier</key>
			<string>com.apple.vpn.managed.AE00FC91-F91B-4420-970E-222BB01D1F12</string>
			<key>PayloadType</key>
			<string>com.apple.vpn.managed</string>
			<key>PayloadUUID</key>
			<string>AE00FC91-F91B-4420-970E-222BB01D1F12</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>Proxies</key>
			<dict>
				<key>HTTPEnable</key>
				<integer>0</integer>
				<key>HTTPSEnable</key>
				<integer>0</integer>
			</dict>
			<key>UserDefinedName</key>
			<string>IPsec xAuth for ${VPN_HOST_NAME}</string>
			<key>VPNType</key>
			<string>IPSec</string>
			<key>DNS</key>
			<dict>
			  <key>ServerAddresses</key>
			  <array>
			    ${VPN_DNS_OPT}
			  </array>
			  <key>SupplementalMatchDomains</key>
			  <array>
			    <string></string>
			  </array>
			</dict>

			<key>OnDemandEnabled</key>
			<integer>1</integer>
			<key>OnDemandRules</key>
			<array>
			  <dict>
			    <key>Action</key>
			    <string>EvaluateConnection</string>
			    <key>Action</key>
			    <array>
			      <dict>
				<key>InterfaceTypeMatch</key>
				<string>WiFi</string>
			      </dict>
			    </array>
			  </dict>

			  <dict>
			    <key>Action</key>
			    <string>EvaluateConnection</string>
			    <key>Action</key>
			    <array>
			      <dict>
				<key>InterfaceTypeMatch</key>
				<string>Cellular</string>
			      </dict>
			    </array>
			  </dict>
			  <dict>
			    <key>Action</key>
			    <string>Connect</string>
			    <key>InterfaceTypeMatch</key>
			    <string>WiFi</string>
			  </dict>

			  <dict>
			    <key>Action</key>
			    <string>Connect</string>
			    <key>InterfaceTypeMatch</key>
			    <string>Cellular</string>
			  </dict>
			</array>

		</dict>
	</array>
	<key>PayloadDisplayName</key>
	<string>xAuth Experimental</string>
	<key>PayloadIdentifier</key>
	<string>EB596F4E-386C-4CE6-9830-B14CBE0B0C39</string>
	<key>PayloadRemovalDisallowed</key>
	<false/>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>295D7A43-41B8-45D8-A208-F2103E67075E</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
</plist>
EOF
    count=$((count+1))
    cuser=$(printf '%s' "$VPN_USERS" | cut -s -d ' ' -f "$count")
    cpassword=$(printf '%s' "$VPN_PASSWORDS" | cut -s -d ' ' -f "$count")
done


