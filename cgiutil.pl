#!/usr/bin/perl

use File::Path;

sub cgidecode;
sub cgiencode;
sub headers;
sub getDataFromFile;

sub cgidecode {
  my @ar = @_;
  foreach (@ar) {
    $_ =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    $_ =~ s/\+/ /g;
  }
  if (wantarray) { 
    return @ar;
  } else {
    return $ar[0];
  }
}


# CGI encoder 
sub cgiencode {
  my @ar = @_;
  $pat='[\x00-\x09\x0B-\x19"#%&+/;<>?\x7F-\xFF]';
  foreach (@ar) {
    $_ =~ s/($pat)/sprintf("%%%02lx",unpack('C',$1))/eg;
    $_ =~ s/ /+/g;
  }
  if (wantarray) { 
    return @ar;
  } else {
    return $ar[0];
  }
}

use Data::Dumper;

sub headers {
my $else = shift;
  foreach (@headers) {
    print "$_\n";
  }
  print "\n";
return if ($else);
  print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">';
  if (scalar @messages) {
    print "Messages: ";
    print "<pre>";
    foreach (@messages) {
      print "$_\n";
    }
    print "<pre>";
    print "\n";
  }
  open FILE, "header.html";
  foreach (<FILE>) { print $_ };
  close FILE;
}

sub getDataFromFile {
  my $sessionid = shift;
  unless ($sessionid) {
    return "NO SESSIONID";
  }
  my $datafile = "/home/ozawacup/cgi-bin/sessions/" . $sessionid . ".dat";
  if ( -f $datafile ) {
    open IN, $datafile or print "Error opening $datafile as input";
    foreach (<IN>) {
      $datalist .= $_;
    }
    close IN;
    $session = $data->{"sessions"}{$cookies->{"sessionid"}} = (eval $datalist);
    unless (defined $session) {
      $session = $data->{"sessions"}{$cookies->{"sessionid"}} = {};
    }

    if (exists $session->{'paypalResponse'}) {
      return "RESPONSE EXISTS";
    }

    return undef, $session;
  } else {
    $data->{"sessions"}{$cookies->{"sessionid"}} = $session = {};
    return undef, $session;
  }
}

sub BEGIN {

  push @headers, "Content-type: text/html";

  if ($ENV{REQUEST_METHOD} eq "GET") {
    $buffer = $ENV{QUERY_STRING};
  } elsif ($ENV{REQUEST_METHOD} eq "POST") {
    read(STDIN,$buffer,$ENV{CONTENT_LENGTH},0);
  }
  
  open OUT, ">>/home/ozawacup/cgi-bin/ipn-raw.log" or print "ERROR: Unable to open ipn-raw.log for output";
  print OUT "Received at " . scalar(localtime time) . "\n";
  print OUT "----\n";
  print OUT "$ENV{REQUEST_METHOD} $ENV{REQUEST_URI} $EVN{SERVER_PROTOCOL}\n";
  foreach (sort keys %ENV) {
    my $name = lc(substr $_, 5); 
    $name =~ s/_/-/g;
    print OUT $name . ": $ENV{$_}\n" if (/^HTTP_/);
  }
  print OUT "\n";
  print OUT $buffer;
  print OUT "----\n";
  close OUT;

  @params = split /\&/, $buffer;
  
  foreach (@params) {
    ($key, $value) = split /\=/;
    $params->{cgidecode($key)} = cgidecode($value);
  }
  # data is now in the script
 
  $cookie = $ENV{HTTP_COOKIE};
  
  foreach (split /; /, $cookie) {
    /^(.+?)=(.+)$/;
    $cookies->{$1} = $2;
  }

  if (exists $cookies->{"sessionid"}) {

    $sessionid = $cookies->{"sessionid"};
    $session = getDataFromFile($sessionid);
    $session = {} unless (defined $session);

  } else {
    $sessionid = time;
    do {
      $sessionid ++;
      $datafile = "/home/ozawacup/cgi-bin/sessions/" . $sessionid . ".dat";
    } until ( ! -f $datafile );
    push @headers, "Set-Cookie: sessionid=$sessionid; ";
    $data->{"sessions"}{$sessionid} = $session = {};
  }
}
  

sub END {
  mkpath "/home/ozawacup/cgi-bin/sessions", 1;
  die "NO SESSION" unless $sessionid;
  if (scalar keys %{$session} > 0) {
	  my $datafile = "/home/ozawacup/cgi-bin/sessions/" . $sessionid . ".dat";
	  open OUT, ">$datafile" or print "ERROR: Unable to open $datafile for output";
	  print OUT Dumper $session; 
	#  print "\n<hr><pre>\n";
	#  print Dumper $session;
	#  print "</pre>";
	  close OUT;
}
}

1;
