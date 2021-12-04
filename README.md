# wg-config-generator

Simple and a bit dirty bash utility to generate wireguard `wg-quick` configs out of `.conf` templates included in the root directory. 

Can be used to git track wireguard configs without trackign the actual keys.


Requires 
- `bash`
- (optional) `qrencode` 
    - ubuntu isntallation with `apt-get install qrencode`


# Generate configs

```bash
bash script_generate_configs.sh
```

Script iterates over all `*.conf` files that are in the main folder and replaces
`<KEY_PUBLIC_*>`, `<KEY_PRIVATE_*>` and `<KEY_PRESHARED_*>` tokens with corresponding keys saved in `keys`. If `keys` does not exist yet, corresponding private, public and preshared wireguard keys will be created and saved in `keys`.

Configuration files with the tokens replaced with the actual keys are exported to `export/*.conf`

## Example
```
[Interface]
# Name = myclient
Address = 10.0.0.2/32
PrivateKey = <KEY_PRIVATE_CLIENT>
DNS = 1.1.1.1

[Peer]
# Name = myserver
Endpoint = 203.0.113.1:51820
PublicKey = <KEY_PUBLIC_SERVER>
AllowedIPs = 10.0.0.1/24
PersistentKeepalive = 25
PresharedKey = <KEY_PRESHARED_ALPHA>
```

could result e.g. in this keys
```
[Interface]
# Name = myclient
Address = 10.0.0.2/32
PrivateKey = UOv3GekXnkOUbHLnAY9GU5Gn76kbatvEIlmVOnBVmlU=
DNS = 1.1.1.1

[Peer]
# Name = myserver
Endpoint = 203.0.113.1:51820
PublicKey = Jo6eQSdpk19RQRbuZe+8/MxL4eZX+UayVLVZrnJvYlQ=
AllowedIPs = 10.0.0.1/24
PersistentKeepalive = 25
PresharedKey = gHA70pL5CGWotUtim6dKCbS5lI+6wDQ0xMIx5w3sdDY=
```

while `keys`:
```
KEY_PUBLIC_SERVER=Jo6eQSdpk19RQRbuZe+8/MxL4eZX+UayVLVZrnJvYlQ=
KEY_PRIVATE_CLIENT=UOv3GekXnkOUbHLnAY9GU5Gn76kbatvEIlmVOnBVmlU=
KEY_PRESHARED_ALPHA=gHA70pL5CGWotUtim6dKCbS5lI+6wDQ0xMIx5w3sdDY=
```

# Generate QR codes of config(s)

Create png for all `export/*.conf` files:
```bash
bash script_generate_qr_codes.sh
```

Create `ANSIUTF8` QR code for a particular `*.conf` file in `export/` 
```bash
bash script_generate_qr_codes.sh
```

Generator of QR codes requires `qrencode` 

# Author
Peter Marko
