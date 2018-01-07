#!/bin/bash
#Blackhawk v1.0
TARGET="$1"
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'
harvesterfile=$(pwd)/output/$TARGET/harvesterfile.txt
emailfile=$(pwd)/output/$TARGET/email.txt
targetfile=$(pwd)/output/$TARGET/target.txt
hostfile=$(pwd)/output/$TARGET/host.txt
sublisterfile=$(pwd)/output/$TARGET/sublister.txt
ipsfile=$(pwd)/output/$TARGET/ip.txt
temp=$(pwd)/output/$TARGET/temp.txt
shodanfile=$(pwd)/output/$TARGET/shodan.txt
maltegofile=$(pwd)/output/$TARGET/$TARGET.csv


if [ "$#" -ne 1 ]; then
    echo -e "$OKORANGE Usage ./Blackhawk.sh example.com ...$RESET"
    exit
fi
echo -e "$OKRED Starting recon using BlackHawk v1.0 $RESET"
mkdir $(pwd)/output/$TARGET/
rm -r $(pwd)/output/$TARGET/*
#Maltego format for input
echo "maltego.Domain, maltego.Website, maltego.IPv4Address, maltego.Service, maltego.Alias, maltego.EmailAddress">>$maltegofile
theharvester -d $TARGET -b all -f $(pwd)/output/$TARGET/$TARGET -n -c -l 50 -h

#parser.py converts harvesters xml file to text files (harvesterfile.txt) for target hosts and email address scraping (email.txt).
#fix theharvester naming issue (example.com.xml, example.org.xml to example.xml)
#fixing harvester incorrect output save file format
IFS='.' read -ra xmlfile <<< "$TARGET"
rm $(pwd)/output/$TARGET/$TARGET
mv $(pwd)/output/"${xmlfile[0]}".xml $(pwd)/output/$TARGET/$TARGET.xml 
python parser.py $(pwd)/output/$TARGET/$TARGET.xml $TARGET
echo -e "$OKBLUE harvester output stored in: $harvesterfile. $RESET"

#sublist3r output
sublist3r -d $TARGET -e baidu,yahoo,google,bing,ask,netcraft,dnsdumpster,virustotal,SSL,passivedns -b -t 8 -o $sublisterfile
echo -e "$OKBLUE sublist3r output stored in: $sublisterfile. $RESET" 

#combine harvester and sublist3r output if harvester completed or continue with sublister output onlu
if [ -f $harvesterfile ];
then
paste -d "\n" $harvesterfile $sublisterfile > $hostfile
else
cp $sublisterfile $hostfile
fi

#remove duplicates 
awk '!a[$0]++' $hostfile >  $temp
rm $hostfile
#remove blanklines
sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' $temp > $hostfile
rm $temp

echo -e "$OKBLUE Unique hosts found stored in: $hostfile. $RESET"

#covert hosts file example.com to hosts and ip (example.com,93.184.216.34)
while IFS='' read -r line || [[ -n "$line" ]]; do
ip=`host $line | grep "address" | cut -d" " -f4`
#the extra filter applied for multiple ips for single domain. Only first ip is taken.
UFS='.' read -ra ips <<< "$ip"
ip=${ips[0]}
echo "$TARGET,$line,$ip,,,">>$maltegofile
echo $ip >> $ipsfile
done < "$hostfile"

#remove duplicates for ip.txt
awk '!a[$0]++' $ipsfile >  $temp
rm $ipsfile
#remove blanklines for ip.txt
sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' $temp > $ipsfile
rm $temp

#email address input from harvester
while IFS='' read -r line || [[ -n "$line" ]]; do
echo "$TARGET,,,,'Email Addresses',$line">>$maltegofile
done < "$emailfile"
echo -e "$OKBLUE Email addresses found stored in $emailfile.$RESET" 

#shodan each subdomain ips and find corresponding ports.
echo -e "$OKGREEN Starting Shodan search on the list of IPs found.$RESET"
python shodan.py $TARGET

#shodan port and banner input
while IFS='' read -r line || [[ -n "$line" ]]; do
UFS=',' read -ra ip_port_banner <<< "$line"
echo "$TARGET,,${ip_port_banner[0]}${ip_port_banner[1]}:${ip_port_banner[0]},">>$maltegofile
done < "$shodanfile"
echo -e "$OKBLUE Shodan output stored in $shodanfile.$RESET" 

#remove duplicates for TARGET.csv
awk '!a[$0]++' $maltegofile>  $temp
rm $maltegofile
#remove blanklines for TARGET.csv
sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' $temp > $maltegofile
rm $temp

echo -e "$OKRED Done!!! Enjoy your Maltego graph by importing $TARGET.csv  $RESET"

