#!/usr/bin/env perl
use strict;
use warnings;

use File::Copy;

# Global variables
my $imagedir = "/Users/Sensae/Desktop/vserver/images/";
my $xendir = "/Users/Sensae/Desktop/vserver/domains/";


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

#Make a new domain folder and copy over image
print "\nCreating new domain folder.\n";
mkdir $xendir . $hostname || die "Can't create new domain folder";

my $fromdir = $imagedir . $dircontents[$imageselection - 1];
my $todir = $xendir . $hostname . "/disk.img";
print "Copying from:\n", $fromdir . "\nTo:\n", $todir . "\n";

copy($fromdir, $todir) || die "Couldn't copy image file.";
