#!/usr/bin/perl -w
 
use warnings;
use diagnostics;
use strict;
 
use lib "/kunden/376995_10961/perllib";
use local::lib;
 
use FileHandle;
use List::Compare;
use Data::Printer;

my $error = 0;
my @files;

foreach my $file_nr (0..1) {
  my $command = qq(
  	7z l -slt $ARGV[ $file_nr ] 1>file_$file_nr.log 2>file_$file_nr.error.log
  );

  my $system_return = system($command);
  
  if ( $system_return ) {
    die("[ERROR] 7zip error code not ok! [$system_return]\n");
    $error = 1;
  } else {
	  if ( ( stat( 'file_' . $file_nr . '.error.log' ) )[7] ) {
	    die("[ERROR] see error log for details!\n");
	  } else {
	    my $fh = FileHandle->new( "file_$file_nr.log", "r" );
	    my $act_path = '';

			if ( defined $fh ) {
			  while ( my $line = $fh->getline() ) {
			    if ( $line =~ /^Path = (.+)$/ ) {
			    	$act_path = $1;
			    } elsif ( $line =~ /^(.+) = (.+)$/ ) {
			    	$files[ $file_nr ]{ $act_path }{ $1 } = $2;
			    }
			  }
			  $fh->close;
			} else {
				die("[ERROR] Can't open file_$file_nr.log!\n");
			}
	  }
	}
}

my $lc = List::Compare->new( '--unsorted', $files[0], $files[1] );

print( pp( $lc->get_symmetric_difference() ) );
