#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Path::Class;
use autodie; # die if problem reading or writing a file.

# Building regex values

my @strings = ( #strings to build the initial regex.
	"test_string"
);


my @statics = ( #extensions to compare to.
	".img",
	".gif",
	".jpg",
	".css",
	".js"
);

my $regex='m"'; # initialize regex.
foreach my $string(@strings){
	$regex .= "$string|"; # modify regex for extra precision.	
}
$regex =~ s/(.$)/\"/; #removes last | operation.

my $regex_static='m"'; # initialize extension regex.
foreach my $string(@strings){
	foreach my $static(@statics){
		$regex_static .= "$string\.*\\$static|"; # modify regex for extra precision.
	}
}
$regex_static =~ s/(.$)/\"/; #removes last | operation.

use File::Find; # importing File::Find.
use Cwd; # importing Cwd.

print "Analysing files for matches...\n\n";
my @results; # initialize the array containing all the information to print into the report.
my $counter=0; # initialize counter for console.

push @results , "\nAnalysing directory: _enter_directory_here\n\n"; 
find(\&wanted,'_enter_directory_here'); # performing find and calling subroutine wanted below.

my $filename = '_name_of_report_file.txt'; # creating report file.

open(my $fh, '>', $filename) or die "Could not open file '$filename' $!"; # opening said report file.
foreach my $result(@results){
	print $fh $result; # writing content into report file.

}
close $fh;
print "Done analysing. Report $filename ready.\n"; # print into console.

sub wanted{ #subroutine that will executing the matching process against every file.
	my $cdir = getcwd."/";
	$counter++;
	print "analysed $counter files\n" if $counter%100 == 0; # print counter every 100 files into console.
	
	if(! -d $_){ # if file perform matching process
		my $cwd = dir($cdir);
		my $file = $cwd->file($_);
		
		# Read in the entire contents of a file
		my $content = $file->slurp();
			
		# openr() returns an IO::File object to read from
		my $file_handle = $file->openr();

		# Read in line at a time
		my $result='';
		my $ln_nbr=0;
		my $matches = 0;
		while( my $line = $file_handle->getline() ) {
			$ln_nbr++;
			if($line =~ $regex){
				chomp $line;
				if($line =~ $regex_static){ # if line matches with string of regex with extension. Then identify it accordingly.
					$result .= "_id1_$ln_nbr:$line\n";
				} else { # if line matches with string of regex only. The identify it accordingly.
					$result .= "_id2_$ln_nbr:$line\n";
				}
				$matches++;
			}
		}
		
		# Match found
		if($matches>0) {
			push @results,"Found match in $cwd\\$_\n$result"."Found $matches matches.\n\n"; # push results into content array
		} 	
	}
}