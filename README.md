# Intro
This tool offers an option to annonce multiple BGP routes with different next hop to implement ECMP load balancing

To use this guide you need to have configured BGP connection. Please follow official [guide](https://fastnetmon.com/docs-fnm-advanced/fastnetmon-bgp-unicast-configuration/) for it.

After configuring BGP, please disable any standard actions for BGP. We will use notify script instead because we need custom logic:

```
sudo fcli set main gobgp_announce_host disable
sudo fcli set main gobgp_announce_whole_subnet disable
sudo fcli commit
```


Please install JSON processing library for Perl:
```
sudo apt-get install -y libjson-perl libipc-run-perl git 
```

Finally, you need to download script from GitHub:
```
git clone git@github.com:FastNetMon/selective_bgp_blackhole_traffic_diversion_api.git
cd selective_bgp_blackhole_traffic_diversion_api
sudo cp notify_json.pl /usr/local/bin/notify_json.pl
```

And configure it for your FastNetMon instance to call it when FastNetMon detects an attack.
```
sudo fcli set main notify_script_enabled enable
sudo fcli set main notify_script_format json
sudo fcli set main notify_script_path /usr/local/bin/notify_json.pl
sudo fcli commit
```

After initial setup, we suggest manual check for hosts from each group and test FastNetMon’s behaviour in each case.

To test host from group host_to_blackhole:
```
sudo fcli set blackhole 11.22.33.44
```

To test host from group host_to_scrubbing:
```
sudo fcli set blackhole 10.10.10.10
```

You can debug actions from our script using this command:
```
sudo tail -f /tmp/selective_bgp_blackhole_traffic_diversion_api.log
```
