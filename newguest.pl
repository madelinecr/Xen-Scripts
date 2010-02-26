#!/usr/bin/env perl
use strict;
use warnings;

# Global variables
my $imagedir = "/Users/Sensae/Desktop/vserver/images";
my $xendir = "/Users/Sensae/Desktop/vserver/domains";

print "\nPlease enter a hostname for your new guest: ";

my $hostname = <>;

print "\nReading contents of the image directory: \n";
&ReadDir;
print "\nPlease make a selection for your new VM: ";
my $imageselection = <>;

sub ReadDir
{
	opendir(my $dirhandle, $imagedir) || die;

	# do not read . or ..
	my @dircontents = grep(/^.+\..+$/, readdir($dirhandle));

	my $count = 1;
	foreach(@dircontents)
	{
		print $count, " ", $_, "\n";
		$count++;
	}

	print $dircontents[0];
}
