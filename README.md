# Blackhawk 
Reconnaissance script to visualise your target infrastrucuture.
Blackhawk will leverage theharvester and sublist3r to find the sub-domains and corresponding ip addresses.
Then it will use shodan to look for corresponding ports and services running on those addresses.  
Useful for red teamers, pentesters or bug hunters to map their target.  
<b> KISS </b> principle - easy and customizable bash script.  

*N.B: Only reconnaissance and no exploitation is used. However the script does <b> active </b> reconnaissance in the sublist3r and theharvester modules.*   

## Usage:
$./Blackhawk.sh example.com

<b>Demo video:</b>

[![IMAGE ALT TEXT](/img/Demo.JPG)](https://youtu.be/-6ddKIkmM_c "Blackhawk demo")

After the scan is finished import configuration maltego_config.mtz in Maltego to setup maltego graph. And then import $target.csv file to import the data for display. 

<b>ADD the Shodan API key in the shodan.py file </b>

## Features: 
* Identify sub-domains and email addresses of your target domain from search engines and sub domains brute forcing. 
* Identify ports and service banners from shodan (passive scanning) - Requires shodan API key. 
* Display the results in Maltego to visualize the target infrastrucuture. 

## Requirements:
1. theHarvester (https://github.com/laramies/theHarvester) 
2. Sublist3r (https://github.com/aboul3la/Sublist3r)
3. Maltego 
4. Shodan API key

![Design](/img/Design.JPG)

### Setup video:
[![IMAGE ALT TEXT](https://img.youtube.com/vi/372YCtiQIQI/0.jpg)](https://youtu.be/372YCtiQIQI "Blackhawk setup")
