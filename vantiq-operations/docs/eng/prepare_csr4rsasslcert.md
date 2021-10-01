## Introduction

This is an instruction for generating a CSR (Certificate Signing Request) to apply for an SSL Server Certificate (RSA).  

The following is a common procedure, and it may differ depending on the intended use. Please contact a Certification Authority for details.

## Prerequisites

For Windows, please install OpenSSL beforehand.  

For Mac, LibreSSL has been installed by default so use it as is.  

## Procedure

Generate a private key for the RSA cryptosystem with the `openssl` command. The key size to be 2048 bits in length because 2048 bits or more is recommended.

```sh:
openssl genrsa -out {wildcard.domain.key} 2048
Generating RSA private key, 2048 bit long modulus
.........+++
.......................................................................................................+++
e is 65537 (0x10001)
```

Prepare to enter the Distinguished Name (DN) and then execute the following command.

```sh:
Country Name (Country Name):JP
State or Province Name (Full State Name) []:Tokyo
Locality Name (Full City Name) []:Minato-ku
Organization Name (Company Name, Organization Name) []:{Your Company name}
Organizational Unit Name (Department, Section) []:{team}
Common Name (FQDN, Domain Name) []:{*.domain.com} # For a Wildcard certificate, "*", for a Specific domain, "sub.domain.com", etc.
Email Address []:
```

Generate a CSR from the private key file created earlier.  

```sh:
openssl req -new -key {wildcard.domain.key} -out {wildcard.domain.csr}
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:JP
State or Province Name (full name) []:Tokyo
Locality Name (eg, city) []:Minato-ku
Organization Name (eg, company) []:{domain} Corporation
Organizational Unit Name (eg, section) []:{team}
Common Name (eg, fully qualified host name) []:{*.domain.com}
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:{password}
```

## How to confirm

It is possible to check the contents of the CSR that have already been created with the following command.  

```sh:
openssl req -in wildcard.domain.csr -text
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=JP, ST=Tokyo, L=Minato-ku, O=My Corporation, OU=my team, CN=*.domain.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:c2:45:bb:22:76:fd:b0:b3:2f:ce:94:d2:5f:68:
                    e9:62:bd:21:71:b8:0a:7c:de:95:bb:70:53:0d:a7:
                    ca:59:51:a6:cc:91:c1:16:8b:6e:31:a2:3d:a2:8b:
(omitted below)
```


## Remarks

The procedure is different from this one when using Elliptic Curve Digital Signature Algorithm (ECDSA) instead of RSA cryptography. Please check with a Certification Authority that can issue Server Certificates.
