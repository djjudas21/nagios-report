# nagios-report
Create Nagios availability reports at the command line

## Information

There are several Perl modules that can query Nagios availability information but I didn't like any of them.
They also required integration work into another script. I decided to create this one as a simple
solution that could print statistics quickly, for when managers want uptime reports.

## Usage

* `cgi`

Define path to the Nagios availability CGI (`avail.cgi`) as a local file path. Defaults to `/usr/lib64/nagios/cgi-bin/avail.cgi`

* `u|user`

Define user that Nagios runs as. Defaults to `nagios`

* `h|host`

Define host to generate availability report for. Required parameter.

* `s|service`

Define service to generate availability report for. Required parameter.

* `t|timeperiod`

Define the time period to report on. Defaults to `lastmonth`. Choose from
`today`, `last24hours`, `yesterday`, `thisweek`, `last7days`, `lastweek`,
`thismonth`, `last31days`, `lastmonth`, `thisyear`, `lastyear`

* `o|output`

Define the output format. Defaults to `dump`. Choose from:
  * `dump` - dumps the whole hash of availability information. Useful for debugging.
  * `uptime` - prints the percentage of uptime
  * `downtime` - prints the duration of downtime

* `v|verbose`

Define verbosity of output. Defaults to `false`. Adds full-sentence output to output formats `uptime` and `downtime` rather than just printing the number.

* `d|dontprinthost`

Define whether to print the hostname in verbose output. Defaults to `true`.

* `r|recipients`

The email address to send the report to. This option may be specified more than once to send multiple copies of the email.
Leave blank to print the output to stdout (which causes cron to send an email instead).

## Integration with BPI

[Nagios BPI](https://exchange.nagios.org/directory/Addons/Components/Nagios-Business-Process-Intelligence-(BPI)/details) is a tool that
can monitor a set of other Nagios services and aggregate the results to give an aggregate state. For example, if either DNS1 or DNS2
is up, then you can say that the DNS service itself is up. This script can be used to good effect with BPI to report aggregate uptime
of your business services.

## Examples

```
$ sudo ./nagios-report.pl -h server.example.co.uk -s Ping -t Today
$VAR1 = 'WARNING';
$VAR2 = {
          'Total' => {
                       'Percent' => '0.000%',
                       'Time' => '0d 0h 0m 0s'
                     },
          'Unscheduled' => {
                             'Percent' => '0.000%',
                             'Time' => '0d 0h 0m 0s'
                           },
          'Scheduled' => {
                           'Percent' => '0.000%',
                           'Time' => '0d 0h 0m 0s'
                         }
        };
$VAR3 = 'CRITICAL';
$VAR4 = {
          'Total' => {
                       'Percent' => '1.935%',
                       'Time' => '0d 0h 27m 52s'
                     },
          'Unscheduled' => {
                             'Percent' => '0.000%',
                             'Time' => '0d 0h 0m 0s'
                           },
          'Scheduled' => {
                           'Percent' => '1.935%',
                           'Time' => '0d 0h 27m 52s'
                         }
        };
$VAR5 = 'All';
$VAR6 = {
          'Total' => {
                       'Percent' => '100.000%',
                       'Time' => '1d 0h 0m 0s'
                     }
        };
$VAR7 = 'OK';
$VAR8 = {
          'Total' => {
                       'Percent' => '98.065%',
                       'Time' => '0d 23h 32m 8s'
                     },
          'Unscheduled' => {
                             'Percent' => '97.731%',
                             'Time' => '0d 23h 27m 20s'
                           },
          'Scheduled' => {
                           'Percent' => '0.333%',
                           'Time' => '0d 0h 4m 48s'
                         }
        };
$VAR9 = 'Undetermined';
$VAR10 = {
           'Total' => {
                        'Percent' => '0.000%',
                        'Time' => '0d 0h 0m 0s'
                      }
         };
$VAR11 = 'UNKNOWN';
$VAR12 = {
           'Total' => {
                        'Percent' => '0.000%',
                        'Time' => '0d 0h 0m 0s'
                      },
           'Unscheduled' => {
                              'Percent' => '0.000%',
                              'Time' => '0d 0h 0m 0s'
                            },
           'Scheduled' => {
                            'Percent' => '0.000%',
                            'Time' => '0d 0h 0m 0s'
                          }
         };
```

```
$ sudo ./nagios-report.pl -h server.example.co.uk -s Ping -t Today -o uptime
98.065%
```

```
$ sudo ./nagios-report.pl -h server.example.co.uk -s Ping -t Today -o uptime -v
Total uptime percentage for service Ping on host server.example.co.uk during period Today is 98.065%
```

```
$ sudo ./nagios-report.pl -h server.example.co.uk -s Ping -t Today -o uptime -v -d
Total uptime percentage for service Ping during period Today is 98.065%
```

```
$ sudo ./nagios-report.pl -h server.example.co.uk -s Ping -t Today -o downtime
0d 0h 27m 52s
```
