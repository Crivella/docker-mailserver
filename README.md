# docker-mailserver

Simplified version of docker-mailserver to run internally as a relay server.
Intended usage: allow a QNAP device (which must be provided a name and password when adding a SMTP service) to send mails in a intranet where authentication is not required and the DNS name of the device is used as the user.

## override

This image allows user to sue plain and login auth methods.

## details:

- only config files, no *sql database required
- mails are stored in `/var/mail/${domain}/${username}`
- you should use a data volume container for `/var/mail` for data persistence
- email login are full email address (`username1@my-domain.com`)
- user accounts are managed in `./postfix/accounts.cf`
- aliases and forwards/redirects are managed in `./postfix/virtual`

## installation

    docker pull crivella1/docker-mailserver

## build

    docker build -t crivella1/docker-mailserver .

## run

    docker run --name mail -v "$(pwd)/postfix":/tmp/postfix -p "25:25" -p "143:143" -p "587:587" -p "993:993" -h mail.my-domain.com -t crivella1/docker-mailserver

## docker-compose template (recommended)

    mail:
      # image: crivella1/docker-mailserver
      build: .
      hostname: mail
      domainname: my-domain.com
      ports:
      - "25:25"
      - "143:143"
      volumes:
      - ./postfix:/tmp/postfix/

Volumes allow to:

- Manage mail users, passwords and aliases

# usage

    docker-compose up -d mail

# client configuration

    # imap
    username:               <username1@my-domain.com>
    password:               <username1password>
    server:                 <your-server-ip-or-hostname>
    imap port:              143
    imap path prefix:       INBOX
    auth method:            plain login md5 challenge-response

    # smtp
    smtp port:              25
    username:               <username1@my-domain.com>
    password:               <username1password>
    auth method:            md5 challenge-response

