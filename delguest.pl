#!/usr/bin/env perl
use strict;
use warnings;

use File::Path;

our $imagedir;
our $xendir;
our $xenconfdir;
our $tmpdir;

our $xenkernel;
our $ramdisk;

do "xen_conf.pl";

opendir(my $dirhandle, $xendir) || die "Couldn't open domain dir: " . $!;

print "Please make sure you have stopped all xen guests you wish to delete " . 
		"before continuing\n\n";

my @dircontents = grep(!/^\.+$/, readdir($dirhandle));

my $count = 1;
foreach(@dircontents)
{
	print $count, " ", $_, "\n";
	$count++;
}

my $dircount = @dircontents;

my $domainselection;
while(1)
{
	print "Please select a domain to irrevocably delete: ";
	$domainselection = <>;
	if($domainselection =~ /^[0-9]+$/ && $domainselection <= $dircount)
	{
		chop $domainselection;
		last;
	}
	else
	{
		print "Sorry, not a number or out of bounds.";
	}
}

my $hostname = $dircontents[$domainselection - 1];

print "You have selected " . $hostname . "\n";
print "If you are ABSOLUTELY SURE that you want to delete this domain,\n" . 
		"type yes (default no): ";
my $verify;
while(1)
{
	$verify = <>;
	chomp($verify);
	if(lc($verify) eq "yes")
	{
		print "You have verified.";
		last;
	}
	else
	{
		print "You did not verify your selection. Killing process.\n";
		die;
	}
}

print "Now entering the point of no return. Deleting guest.\n";
print "Deleting " . $xendir . $hostname . "\n";
rmtree($xendir . $hostname);
print "Deleting " . $xenconfdir . $hostname . ".cfg\n";
unlink($xenconfdir . $hostname . ".cfg");
