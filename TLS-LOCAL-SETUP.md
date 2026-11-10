# Laragon HTTPS for local Android testing

The copy at `C:\laragon\www\Backend` is served by Laragon Apache at `https://192.168.1.53` (port 443). Laragon’s local development CA and server certificate live in `C:\laragon\etc\ssl\funeral-local`, outside the web root. The CA private key must stay on this development machine. Its public certificate is bundled only in the Android debug variant at `Frontend/android/app/src/debug/res/raw/funeral_dev_root_ca.pem`; release builds do not trust it.

To recreate the certificates, use Laragon’s OpenSSL executable and the config files in `C:\laragon\etc\ssl\funeral-local`. Add SANs for any new hostnames/IPs before regenerating the server certificate. Import `root-ca.crt` into the Windows Current User Trusted Root Certification Authorities store if Windows tools/browsers need to trust it. Android debug builds trust the bundled root automatically. Remove the root CA from that store and rotate/delete the local key pair when no longer needed.

Apache’s `auto.Backend.test.conf` and default SSL vhost point to `backend-ip.crt` and `backend-ip.key`. The default SSL vhost uses this certificate because clients connecting by IP may not send SNI. The `Backend.test` vhost has `192.168.1.53` as an alias and serves Laravel’s `public` directory. Ensure Windows Firewall allows inbound TCP 443 on the private network.

This is a self-managed development CA, not a public certificate. Do not use these keys or trust settings for production. The Android release variant uses normal system trust and disallows cleartext HTTP; the debug variant allows local HTTP for development tools and trusts the local CA.
