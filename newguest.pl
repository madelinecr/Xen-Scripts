#!/usr/bin/env perl
use strict;
use warnings;

use File::Copy;

# Global variables
my $imagedir = "/home/sensae/Documents/Perl/vserver/images/";
my $xendir = "/home/sensae/Documents/Perl/vserver/domains/";
my $tmpdir = "/tmp/newguest/";

sub getIPAddr
{
	my $ipaddr;
	while(1)
	{
		print "Enter value: ";
		$ipaddr = <>;
		if($ipaddr =~ /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)
		{
			return $ipaddr;
			last;
		}
		else
		{
			print "Not a properly formatted IP address.\n";
		}
	}
}

# PROGRAM START

# -- Data gathering stage ------------------------------------------------------
# Get a hostname
my $hostname;
while(1)
{
	print "\nPlease enter a hostname for your new guest: ";
	$hostname = <>;
	if($hostname =~ /^[a-zA-Z0-9]+$/)
	{
		chop $hostname;
		last;
	}
	else
	{
		print "Sorry, hostname requires a-z, A-Z, 0-9 no spaces. \n";
	}
}

#Read image directory
print "\nReading contents of the image directory: \n";
opendir(my $dirhandle, $imagedir) || die "Can't open directory: " . $!;

# do not read . or ..
my @dircontents = grep(/^.+\..+$/, readdir($dirhandle));

my $count = 1;
foreach(@dircontents)
{
	print $count, " ", $_, "\n";
	$count++;
}

#Get which image is wanted
my $imageselection;
while(1)
{	
	print "\nPlease make a selection for your new VM: ";
	$imageselection = <>;
	if($imageselection =~ /^[0-9]+$/)
	{
		chop $imageselection;
		last;
	}
	else
	{
		print "Sorry, not a number.";
	}
}

#Get network configuration
my $ipaddr = "192.168.1.50";
my $netmask = "255.255.255.0";
my $dns = "192.168.1.1";
my $gw = "192.168.1.1";

#print "Configure IP address. ";
#$ipaddr = &getIPAddr;
#print $ipaddr;

#print "Configure netmask. ";
#$netmask = &getIPAddr;
#print $netmask;

#print "Configure nameserver address. ";
#$dns = &getIPAddr;
#print $dns;

#print "Configure gateway address. ";
#$gw = &getIPAddr;
#print $gw;

# -- domain filesystem setup stage ---------------------------------------------

#Make a new domain folder and copy over image
print "\nCreating new domain folder.\n";
mkdir $xendir . $hostname || die "Couldn't create new domain folder: " . $!;

my $fromdir = $imagedir . $dircontents[$imageselection - 1];
my $todir = $xendir . $hostname . "/disk.img";
print "Copying from:\n", $fromdir . "\nTo:\n", $todir . "\n";

copy($fromdir, $todir) || die "Couldn't copy image file: " . $!;

# -- image customization stage -------------------------------------------------
mkdir $tmpdir;
system("mount -t ext3 -o loop " . $todir . " " . $tmpdir) == 0 
		|| die "Couldn't mount image file: " . $!;

my $interfaces = $tmpdir . "etc/network/interfaces";
# autoconf network
if(-e $interfaces)
{
	unlink($interfaces);
}
open(my $inthandle, ">>" . $interfaces)
		|| die "Couldn't open interfaces file: " . $!;
my @intcontents = (
	"auto lo",
	"iface lo inet loopback",
	" ",
	"allow-hotplug eth0",
	"iface eth0 inet static",
	"\taddress " . $ipaddr,
	"\tnetmask " . $netmask,
	"\tgateway " . $gw,
	"\tdns-nameservers " . $dns
	);
	
foreach(@intcontents)
{
	print $inthandle $_ . "\n";
}
close($inthandle);

# overwrite hostname file
my $hostfile = $tmpdir . "etc/hostname";
if(-e $hostfile)
{
	unlink($hostfile);
}
open(my $hosthandle, ">>" . $hostfile)
		|| die "Couldn't open hostnames file: " . $!;
print $hosthandle $hostname;
close($hosthandle);

system("umount " . $tmpdir) == 0 || die "Couldn't unmount image: " . $!;

