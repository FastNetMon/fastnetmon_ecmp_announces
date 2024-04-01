# Intro
This tool offers an option to annonce multiple BGP routes with different next hop to implement ECMP load balancing.

To use this guide you need to have configured BGP connection. Please follow official [guide](https://fastnetmon.com/docs-fnm-advanced/fastnetmon-bgp-unicast-configuration/) for it.

After configuring BGP, please disable any standard actions for BGP. We will use notify script instead because we need custom logic:

```
sudo fcli set main gobgp_announce_host false
sudo fcli set main gobgp_announce_whole_subnet false
sudo fcli commit
```

Then you need to enable add path capability (requires FastNetMon 2.0.364 or newer) for all your BGP peers:
```
sudo fcli set bgp connection_to_my_router ipv4_unicast_add_path true
sudo fcli commit
```


Please install JSON processing library for Perl:
```
sudo apt-get install -y libjson-perl libipc-run-perl git 
```

Finally, you need to download script from GitHub:
```
git clone git@github.com:FastNetMon/fastnetmon_ecmp_announces.git
cd fastnetmon_ecmp_announces
sudo cp notify_json.pl /usr/local/bin/notify_json.pl
sudo chmod +x /usr/local/bin/notify_json.pl
```

And configure it for your FastNetMon instance to call it when FastNetMon detects an attack.
```
sudo fcli set main notify_script_enabled enable
sudo fcli set main notify_script_format json
sudo fcli set main notify_script_path /usr/local/bin/notify_json.pl
sudo fcli commit
```

After initial setup, we suggest manual check to ensure that announces work just fine:
```
sudo fcli set blackhole 11.22.33.44
```


Then you can check that gobgp works as expected this way:
```
gobgp global rib 
   Network              Next Hop             AS_PATH              Age        Attrs
*> 1.2.3.0/24           1.2.3.1                                   00:00:05   [{Origin: ?}]
*  1.2.3.0/24           1.2.3.2                                   00:00:03   [{Origin: ?}]
```

You can debug actions from our script using this command:
```
sudo tail -f /tmp/fastnetmon_ecmp_announces.log
```

You can manually check that script works as expected using this command:
```
echo '{"ip":"1.2.3.4"}' | ./notify_json.pl ban 11.22.33.44
```

And to unban:
```
echo '{"ip":"1.2.3.4"}' | ./notify_json.pl unban 11.22.33.44
```
