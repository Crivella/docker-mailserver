FROM ubuntu:22.04

# Packages
RUN apt-get update -q --fix-missing
RUN apt-get -y upgrade
# Workaround from https://bugs.launchpad.net/ubuntu/+source/courier/+bug/1781243
RUN touch /usr/share/man/man5/maildir.courier.5.gz
RUN touch /usr/share/man/man8/deliverquota.courier.8.gz
RUN touch /usr/share/man/man1/maildirmake.courier.1.gz
RUN touch /usr/share/man/man7/maildirquota.courier.7.gz
RUN touch /usr/share/man/man1/makedat.courier.1.gz
# Install apt packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install vim postfix sasl2-bin courier-imap courier-imap-ssl courier-authdaemon  gamin libnet-dns-perl libmail-spf-perl file rsyslog 
RUN apt-get autoclean

# Configures Saslauthd
RUN rm -rf /var/run/saslauthd && ln -s /var/spool/postfix/var/run/saslauthd /var/run/saslauthd
RUN adduser postfix sasl
RUN echo 'NAME="saslauthd"\nSTART=yes\nMECHANISMS="sasldb"\nTHREADS=0\nPWDIR=/var/spool/postfix/var/run/saslauthd\nPIDFILE="${PWDIR}/saslauthd.pid"\nOPTIONS="-n 0 -r -m /var/spool/postfix/var/run/saslauthd"' > /etc/default/saslauthd

# Configures Courier
RUN sed -i -r 's/daemons=5/daemons=0/g' /etc/courier/authdaemonrc
RUN sed -i -r 's/authmodulelist="authpam"/authmodulelist="authuserdb"/g' /etc/courier/authdaemonrc

ENV \
    RELAY_HOST="" \
    EXTRA_NET="" \
    SERVER_USER="postfix" \
    SERVER_PASS="postfix" \
    SERVER_DOMAIN="example.com"

EXPOSE 25 143

# Configures Postfix
ADD postfix/main.cf /tmp/main.cf
ADD postfix/master.cf /etc/postfix/master.cf
ADD postfix/sasl/smtpd.conf /etc/postfix/sasl/smtpd.conf
ADD bin/generate-ssl-certificate /usr/local/bin/generate-ssl-certificate
RUN chmod +x /usr/local/bin/generate-ssl-certificate

# Start-mailserver script
ADD start-mailserver.sh /usr/local/bin/start-mailserver.sh
RUN chmod +x /usr/local/bin/start-mailserver.sh
CMD /usr/local/bin/start-mailserver.sh

