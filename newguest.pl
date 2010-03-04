#!/usr/bin/env perl
use strict;
use warnings;

use File::Copy;

# Global variables
my $imagedir = "/home/sensae/Dropbox/Documents/Programming/Perl/vserver/images/";
my $xendir = "/home/sensae/Dropbox/Documents/Programming/Perl/vserver/domains/";
my $tmpdir = "/tmp/newguest";

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
opendir(my $dirhandle, $imagedir) || die "Can't open directory";

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
my $ipaddr;
my $netmask;
print "Configure IP Address. ";
$ipaddr = &getIPAddr;
print $ipaddr;
print "Configure netmask. ";
$netmask = &getIPAddr;
print $netmask;

die;

#Make a new domain folder and copy over image
print "\nCreating new domain folder.\n";
mkdir $xendir . $hostname || die "Couldn't create new domain folder";

my $fromdir = $imagedir . $dircontents[$imageselection - 1];
my $todir = $xendir . $hostname . "/disk.img";
print "Copying from:\n", $fromdir . "\nTo:\n", $todir . "\n";

copy($fromdir, $todir) || die "Couldn't copy image file.";

#image customization stage
mkdir $tmpdir;
system("mount -t ext3 -o loop " . $todir . " " . $tmpdir) == 0 
		|| die "Couldn't mount image file.";



