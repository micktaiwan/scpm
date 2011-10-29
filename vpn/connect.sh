# connect.sh

openvpn --tls-client --ca ca.crt --cert client.crt --key client.key --dev tun --remote 193.27.69.234 1194 --verb 2 --cipher BF-CBC --auth-user-pass --pull --comp-lzo --persist-tun --persist-key --proto udp --nobind --ping-restart 60 --ping 10

exit

client
dev tun
remote 193.27.69.234 1194
proto udp
nobind

ca ca.crt
cert client.crt
key client.key
auth-user-pass

ping 10
ping-restart 60
verb 2
comp-lzo
cipher BF-CBC
persist-key
persist-tun

