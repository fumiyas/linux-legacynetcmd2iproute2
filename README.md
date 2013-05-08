Convert to Linux iproute2 command-line from legacy networking command-line
======================================================================

  * Copyright: (c) 2013 SATOH Fumiyasu @ OSS Technology Corp., Japan
  * License: GNU General Public License version 3
  * URL: <https://github.com/fumiyas/linux-legacynetcmd2iproute2>
  * Twitter: <https://twitter.com/satoh_fumiyasu>

Examples
----------------------------------------------------------------------

Show iproute2 command-line:

    $ ./ifconfig2.bash <ifconfig(8)'s argument>
    $ ./netstat2.bash <netstat(8)'s arguments>

Show and run iproute2 command-line:

    $ ./ifconfig2.bash --x <ifconfig(8)'s argument>
    $ ./netstat2.bash --x <netstat(8)'s arguments>

Run iproute2 command-line:

    $ ./ifconfig2.bash --xx <ifconfig(8)'s argument>
    $ ./netstat2.bash --xx <netstat(8)'s arguments>

TODO
----------------------------------------------------------------------

  * Add arp2.bash and route2.bash

References
----------------------------------------------------------------------

  * https://dougvitale.wordpress.com/2011/12/21/deprecated-linux-networking-commands-and-their-replacements/

