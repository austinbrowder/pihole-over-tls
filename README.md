# pihole-over-tls

This project provides a self hosted DNS over TLS solution with Pi-hole filtering. It can be run from a cloud provider and has fully automated certificates from a public CA.
Below is a blog that helped me design some of the key pieces of this project. Give it a read.
https://bartonbytes.com/posts/how-to-configure-coredns-for-dns-over-tls/

Pre-Reqs:
- 1 docker host with docker-compose installed
- Public DNS entry that resolves to the public ip address of the docker host that will run the DNS over TLS service we are building.
- Firewall rules and potentially NAT rules to allow traffic hitting your public IP to travel to your docker host on port 853 (DNS over TLS port).

Steps to setup:
1. Clone this repository onto the docker host. My examples assume you have cloned it into your users home directory.
2. Update the DNSHOSTNAME variable in the configure.sh and renew.sh files to be the valid public dns name that resolves to your docker host.
3. Update the HOSTIP variable in the configure.sh file to be the IP address of your docker host. This would be the private IP if running in the cloud.
4. Run `chmod +x` on both configure.sh and renew.sh.
5. Run `./configure.sh` from within the pihole-over-tls project folder cloned in step 1.
6. At this point, you should have a functioning self hosted DNS over TLS service. You can test with with some of the following commands. Make sure you are running from a machine that is external from where your docker host is located.
   - Validate your certificate:
   > openssl s_client -connect \<dockerhostpublicDNSName\>:853 -servername \<dockerhostpublicDNSName\>
   - Test full DNS functionality over TLS:
   > kdig -d @\<dockerhostpublicDNSName\> +tls-ca amazon.com
7. Now, if you're familiar with letsencrypt certificates, you will know that they expire every 90 days. Let's address this by setting up some automation to renew the cert. To do this we will simply setup a cronjob as seen below that will run the certbot container to renew the certificate previously configured by the configure.sh script. Next it will docker-compose recreate to force the containers to use the new certificate. You may need to set this cronjob up with the root user depending on how your docker host is setup.
   > sudo crontab -u root -e
   > 0 2 */15 * * /home/\<yourusername\>/pihole-over-tls/renew.sh &> /home/\<yourusername\>/pihole-over-tls/letsencrypt_renew.log
   - Note: This job will run every 15 days and by default if the certbot detects no certs are due for renewal it will leave the cert as is.
