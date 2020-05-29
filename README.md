# docker-ipsec-xauth

> This repository is based on the work of Lin Song: https://github.com/hwdsl2/docker-ipsec-vpn-server. Differences from the original version are summarized as follows.
> - supports multiple users by default (not need to use 'additional users')
> - supports customized routes pushed from ipsec server

```shell
$ docker pull jqtype/ipsec-xauth
```

or

```shell
$ docker build -t jqtype/ipsec-xauth .
```

## Configuration

```
# Define your own values for these variables
# - DO NOT put "" or '' around values, or add space around =
# - DO NOT use these special characters within values: \ " '
VPN_IPSEC_PSK=your_ipsec_pre_shared_key

# Define VPN users
# - Uncomment and replace with your own values
# - Usernames and passwords must be separated by spaces
VPN_USERS=your_vpn_username_one your_vpn_username_two
VPN_PASSWORDS=your_vpn_password_one your_vpn_password_two

# (Optional) Use alternative DNS servers
# - By default, clients are set to use Google Public DNS
# - Example below shows using Cloudflare's DNS service
# VPN_DNS_SRV1=1.1.1.1
# VPN_DNS_SRV2=1.0.0.1

# (Optional) route added by ipsec connection.
# default: 0.0.0.0/0
# VPN_IPSEC_XAUTH_ROUTES=192.168.111.19/32

# (Optional) log level
# default: none
# VPN_IPSEC_LOG_LEVEL=none

# (Optional) host name: currently not used.
# VPN_HOST_NAME=your_vpn_domain_name
```

## Notes

Please refer to the original repo for further information.
