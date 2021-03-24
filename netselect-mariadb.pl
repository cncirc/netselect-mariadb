#!/usr/bin/env perl

# netselect-mariadb: Utility that can choose the best MariaDB mirror by downloading the full mirror list
#                    and using netselect to find the fastest/closest one
#
# The MIT License
#
# Copyright (c) 2018 Ignacio de Tomás, http://inacho.es
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use strict;
use warnings;

use LWP::Simple;

my $num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "Usage: netselect-mariadb debian_release mariadb_version\n";
    print "  Example: netselect-mariadb stretch 10.2\n\n";
    exit;
}

my $debian_release = $ARGV[0];
my $mariadb_version = $ARGV[1];

my $url = "https://mirmon.mariadb.org/";
my $content = get($url);

if (! defined $content) {
    print "The list of mirrors can not be retrieved from: $url\n";
    exit 1;
}

$content =~ s/<\/TD>\n/<\/TD>/g;

my @hosts = ();
my @urls = ();

while ($content =~ /<TD ALIGN="RIGHT"><A HREF="http:\/\/(.+?)">(.+?)<\/A>.+<TD>ok<\/TD>/g) {
    push(@hosts, $2);
    push(@urls, "http://$1");
}

my $num_hosts = @hosts;

if ($num_hosts == 0) {
    print "The list of mirrors is empty\n";
    exit 1;
}

my $best_host_url = "";
my $hosts_string = join(' ', @hosts);
my $best_host = `netselect $hosts_string`;

if ($? != 0) {
    print "Failed executing netselect\n";
    exit 1;
}

$best_host =~ s/^\s+\d+\s+//;
$best_host =~ s/\n//g;

for (my $i = 0; $i < $num_hosts; $i++) {
    if ($hosts[$i] eq $best_host) {
        $best_host_url = $urls[$i]
    }
}

print "deb [arch=amd64,i386] ${best_host_url}repo/$mariadb_version/debian $debian_release main\n";
print "deb-src ${best_host_url}repo/$mariadb_version/debian $debian_release main\n";
