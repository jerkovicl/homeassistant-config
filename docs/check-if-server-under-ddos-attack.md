
# How to Check if Your Linux Server is Under DDoS Attack

Whether you’re a blogger, the owner of an eCommerce shop, or a webmaster
for a local service provider, everyone knows that in today’s
internet-driven world, having a strong website can be the difference
between economic success and failure. With businesses growing
increasingly reliant on search engines and web traffic to drive sales,
the ever-present risk from malicious actors online carries with it a
higher price than ever before. One threat in particular has grown more
common in recent years: DDoS attacks.

But what is a DDoS attack, how can they be identified, and what can you
do to safeguard your website against them? In this guide, we’ll take a
look at the common signs of a DDoS attack as well as which steps you can
take to mitigate the damage they cause.

But first:

**What is DDoS?**

**DDoS**, or **Distributed Denial of Service**, is a coordinated attack
using one or more IP addresses designed to cripple a website by making
its server inaccessible. This is done by overloading a server’s
resources and using up all available connections, bandwidth, and
throughput. Just like when driving, your travel-time from point A to
point B will be slower if there’s too much traffic. By flooding a server
with more connections than it can handle, the server becomes bogged
down, making it unable to process legitimate requests. Even hardy
servers can’t handle the number of connections a DDoS can bring.

While there are various means to perform a DDoS attack, ranging from
HTTP floods to Slowloris’ lingering connections, the vast majority
require live connections to your server. Lots of them.

The good news is, because these connections are live, you have the
ability to see them as they are being made. Using a few simple commands,
you can not only determine if a DDoS is happening, but additionally you
can gain the information needed to help mitigate these attacks.

## How to Check for DDoS

If you’re concerned that your server might be under DDoS attack, the
first thing you’ll need to do is take a look at the load on your server.
Something as simple as the uptime or top commands will give you a good
idea of the server’s current load.

But what is an acceptable load?

Well, that depends on your CPU resources or available threads. Typically
though, the rule is one point per thread.

To determine your server’s current load, you can use the *grep processor
/proc/cpuinfo | wc -l* command, which will return the number of logical
processors (threads). During a DDoS attack, you may see load at double,
triple, or even higher over the maximum load you should have.

To start, use the two commands below to return your uptime and server
load.

```bash
grep processor /proc/cpuinfo | wc -l
uptime
```

![Terminal window showing current uptime and load average of 0.10, 0.05,
and 0.06
](https://lh6.googleusercontent.com/uSlW7bxQ_ZWY9vSf8o9-Xf8UiXmEg4-r9mDnZv8rwHUSY1FXQcsauUeJuX5KxNBKvk4gEJFxF5D4e_CUvr1V4u5Lxw3XCFNAZ7zwvSXAK4LOOTHSwjLBZ3I-HATQLUs2iamavsip "load average displays")

The load average displays load in the following intervals: 1 minute
average, 5 minute average, and 15 minute average. In this scenario, a
load average of greater than 7 could be a concern.

Unlike the above example, sometimes your server will respond fine over a
backend connection like IPMI, but will still be slow when connecting
over a public interface. To determine if this is the case, you will want
to check your network traffic. This can be done with one of several
tools including nload, bmon, iftop, vnstat, and ifstat. Your choice will
depend on your operating system, but all of these tools can be installed
via your package manager (apt, yum, etc.).

### How to Check Which IPs are Connecting to Your Server

Since most DDoS attacks require connections to your server, you can
check and see how many, and which, IP addresses are connecting to your
server at once. This can be determined using *netstat,* a command used
to provide all manner of details. In this instance though, we’re only
interested in the specific IPs making connections, the number of IPs,
and possibly the subnets they’re part of. To start, enter the following
command into your terminal:

```bash
netstat -ntu|awk '{print $5}'|cut -d: -f1 -s|sort|uniq -c|sort -nk1 -r
```

![Terminal window showing a list of IPs currently connected to the
server](https://lh4.googleusercontent.com/JTNVeRsWddkAJomW66D8E0Lkm-bieujQGozsaUjfo7F7kF1P8qptS-IPGZzXY8v3sJtHMx2hiWRHkxfyz8HiHu7Ucn73IOlgxkw0OF9E_eusXisGSWvWkbKpTuXwGaxPIrbCCTNl "results")

 When entered correctly, this command will return a descending list of
which IPs are connected to your server and how many connections each one
has. The results may also include artifact data, which will appear as
non-IP info, and can be ignored.

Looking at your results, you will see connections listed ranging
anywhere from 1 to about 50 connections per IP. This can be quite common
for normal traffic. If however, you see some IPs with 100+ connections,
this is something to scrutinize.

Included in the list, you may see known IPs, one or more of the server’s
own IPs, or even your own personal IP with many connections. For the
most part, these can be ignored, as they are there normally. It’s when
you see single, unknown IPs with hundreds or thousands of connections
that you should be concerned, as this can be a sign of an attack.

### Mitigating a DDoS Attack

Once you have an idea of which IPs are attacking your server, blocking
these specific IPs can be done with a few simple commands.

To start, use the following command, replacing **ipaddress** with the
address of the IP you’re trying to block.

`route add ipaddress reject`

Once you’ve blocked a particular IP on the server, you can crosscheck if
the IP has been blocked successfully using:

`route -n |grep ipaddress`

You can also bock an IP address on the server using iptables by entering
the following commands:

`iptables -A INPUT 1 -s IPADDRESS -j DROP/REJECT`

`service iptables restart`

`service iptables save`

After entering this series of commands, you will need to kill all httpd
connections and restart httpd services. This can be done by entering:

`killall -KILL httpd`

`service httpd startssl`

If more than one unknown IP address is making large numbers of
connections, either of these processes can be repeated for all offending
IPs.

### DDoS Using Multiple IPs

While a denial of service attack from a single IP making numerous
connections can be easy to diagnose and fix, DDoS prevention becomes
more complex as attackers use fewer connections spread across a larger
number of attacking IPs. In these cases, you will see fewer individual
connections even when your server is under DDoS. With the rise of the
Internet of Things (IoT), these types of attacks have grown more common.
By hacking into and utilizing “smart” devices, appliances and tools that
feature internet connectivity, malicious actors have built networks of
available IPs, referred to as botnets, capable of being deployed in
coordinated DDoS attacks against specific targets.

So what can you do if you find large numbers of unknown IPs only making
single connections? In this instance, it can be difficult to determine
if this is natural traffic or a coordinated attack.

To start, you’ll want to determine if these connections are coming from
common subnets: common being the same /16 or /24. You can use the next
two commands to list the subnets that contain the connected IPs, and how
many IPs are in each subnet.

To find IPs from the same /16 (xxx.xxx.0.0) subnet, use:

```bash
netstat -ntu|awk '{print $5}'|cut -d: -f1 -s |cut -f1,2 -d'.'|sed 's/$/.0.0/'|sort|uniq -c|sort -nk1 -r
```

![Terminal window listing IPs starting with the same two
octets](https://lh5.googleusercontent.com/o3lNT_4Q9egNduQCYa1dz-f9LYBf875haf6M5GWY1SaNXaCWNSetsP6rmUO8ZQEZJmJm7ATPKUnHhh1XaoiKD6OCVHdbBJI_OskjMGzeIB4yf4Ul59aqlbLJY8bZX8hpNWEt1ktk "IP with two octets")

When entered, this command will display any IP starting with the same
two octets: ie. `192.168.xxx.xxx`.

To find IPs from the same /24 (xxx.xxx.xxx.0) subnet, use:

```bash
netstat -ntu|awk '{print $5}'|cut -d: -f1 -s |cut -f1,2,3 -d'.'|sed 's/$/.0/'|sort|uniq -c|sort -nk1 -r
```

![Terminal window listing IPs starting with the same three
octets](https://lh4.googleusercontent.com/ugF6gkfHYhdOx9BifM6QUUxM5US206nXEibhOatvSEH0Ux3aEhOoMxoKS64KrXJdcC7r9JAm-Jd00godbj-yGfedcrPBX7wUgAE3DVM02CEcSGkSt6_bQEzYuCE7-B1EvDGIs3sL "3 octets")

When entered, this command will display any IP starting with the same
three octets: ie. `192.168.1.xxx`.

Once you have determined if you are in fact under a multiple-IP DDoS
attack, the steps to mitigate it are the same as those used above to
combat single IP attacks, but replicated for many IPs.

These techniques are just a few of the tools available to check for
possible attacks. While there are more advanced tools available, these
methods can provide quick and easy results to determine if you may be
experiencing a DDoS attack. The information these commands provide is
useful even when not under attack, and familiarizing yourself with them
can help strengthen any administrator’s tool belt.

### In Closing

The risks and costs associated with DDoS attacks are greater than ever.
Unfortunately, with the rise of botnets, even when a DDoS attack is
verified, blocking hundreds or thousands of attacking IPs manually can
be incredibly difficult. In these instances, it can be hard to stop an
attack once it’s begun.

For this reason, it is best practice to have a plan in place for
combating DDoS attacks before they happen. In addition to the methods
mentioned here, you may also want to consider signing up for one of the
various DDoS protection services available online. Popular options
include [Akamai](https://www.akamai.com/),
[Verisign](https://www.verisign.com/), and
[Radware](https://www.radware.com/)