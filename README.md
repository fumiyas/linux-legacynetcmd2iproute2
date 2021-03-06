Generate Linux iproute command-line from legacy net-tools command-line
======================================================================

  * Copyright: (c) 2013-2016 SATOH Fumiyasu @ OSS Technology Corp., Japan
  * License: GNU General Public License version 3
  * URL: <https://github.com/fumiyas/linux-legacynetcmd2iproute2>
  * Home: <http://fumiyas.github.io/>

Examples
----------------------------------------------------------------------

Show iproute2 command-line:

    $ ./ifconfig2.sh <ifconfig(8)'s arguments>
    ... Show ip(8) command-line ...
    $ ./netstat2.bash <netstat(8)'s arguments>
    ... Show ip(8) or ss(8) command-line ...

Show and run iproute2 command-line:

    $ ./ifconfig2.sh --x <ifconfig(8)'s arguments>
    ... Show and do ip(8) command-line ...
    $ ./netstat2.bash --x <netstat(8)'s arguments>
    ... Show and do ip(8) or ss(8) command-line ...

Run iproute2 command-line:

    $ ./ifconfig2.sh --xx <ifconfig(8)'s arguments>
    ... Do ip(8) command-line ...
    $ ./netstat2.bash --xx <netstat(8)'s arguments>
    ... Do ip(8) or ss(8) command-line ...

or:

    $ sudo install -m 0755 ifconfig2.sh /usr/local/sbin/ifconfig
    $ sudo install -m 0755 netstat2.bash /usr/local/bin/netstat
    $ /usr/local/sbin/ifconfig <ifconfig(8)'s arguments>
    ... Do ip(8) command-line ...
    $ /usr/local/bin/netstat <netstat(8)'s arguments>
    ... Do ip(8) or ss(8) command-line ...

TODO
----------------------------------------------------------------------

  * Add arp2.bash and route2.bash

References
----------------------------------------------------------------------

  * Deprecated Linux networking commands and their replacements | Doug Vitale Tech Blog
    * https://dougvitale.wordpress.com/2011/12/21/deprecated-linux-networking-commands-and-their-replacements/
  * Linux: ifconfig, netstat を iproute2 コマンドラインに変換
    * http://fumiyas.github.io/2013/12/23/linux-legacynetcmd2iproute2.sh-advent-calendar.html

