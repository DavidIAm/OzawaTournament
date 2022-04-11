#!/usr/bin/perl

eval { 

require "./cgiutil.pl";

sub getQSval;
sub getFORMval;
sub getresponse;
sub dircat;
sub printlog;
sub divisionlookup {
	my $key = shift;
	my $division = shift;
	my %map = (
		kata => ' in division ',
		kobudo => ' in division ',
		shobu => ' in division ',
		wukf => ' in division ',
		);
	if (exists $map{$key}) {
		return ' in division ' . $division;
	}
	return undef;
}

sub eventlookup {
	my $key = shift;
	my %map = (
		kata => 'Kata',
		kobudo => 'Kobudo', 
		shobu => 'Ippon Shobu Kumite',
		wukf => 'WUKF Kumite',
		seminarA => 'Seminar A',
		seminarB => 'Seminar B',
		seminarC => 'Seminar C',
		seminarD => 'Seminar D',
		seminarE => 'Seminar E',
		seminarF => 'Seminar F',
		seminarG => 'Seminar G',
	);
	return $map{$key} or $key;
}

sub DBPATH { "sessions" }
sub DBFILE { eval $Application->Contents->Item('cartdbfile'); }
# ADD VARIABLE AND VALUE cmd=_notify-validate
# All the callback url's are defined here.

sub REPLYURL { 
  my $woof = shift;
  if ($woof eq 'paypal') {
    return "https://ipnpb.paypal.com/cgi-bin/webscr";
  } else {
    return undef;
  }
}

use Data::Dumper;
use IO::File;
use File::Copy;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;

# ADD VARIABLE AND VALUE cmd=_notify-validate

# Default Agent
$f{'agent'} = 'paypal';
# Command for notification
#$f{'cmd'} = '_notify-validate';

# The log file for sanity's sake.
my $logfile = '/home/ozawacup/cgi-bin/ipn.log';
my $logger = new IO::File(">>" . $logfile);

print("Status: 500 No logfile\n") unless (defined $logger);

printlog scalar localtime time;
printlog "\n";

my $c = 0;
foreach (keys %{$params}) {
  $c ++;
  $f{$_} = getFORMval($_);
  $data->{$_} = getFORMval($_);
  printlog "RECIEVED $_ => $f{$_}\n";
}

unless ($c) {
  printlog "TERMINATING BECAUSE I RECIEVED NO FORM DATA\n";
  print("Status: 511 No Form Data\n\n");
  print("TERMINATING BECAUSE I RECIEVED NO FORM DATA\n");
  exit;
} else {
  printlog "Received $c form entries\n";
  #print("Received $c form entries\n");
}

if ($debug) {
  print("DATA FROM FORM POST\n");
  print("<pre>" . Dumper(\%f) . "</pre>");
}

if (defined REPLYURL($f{'agent'})) {
  $f{_validate_response} = getresponse(REPLYURL($f{'agent'}), %f);
  printlog "Agent $f{'agent'} validate response is $f{_validate_response}\n";

} else {
  $f{_validate_response} = "N/A";
  printlog "Agent $f{'agent'} does not require response validation!\n";
}

##############################################################################

printlog "goingto load" . getFORMval("invoice") . "\n";
$sessionid = getFORMval("invoice");
printlog "sessionid $sessionid\n";

($err, $session) = getDataFromFile($sessionid);

if ($err eq "RESPONSE EXISTS") {
  print "Location: /cgi-bin/thankyou.pl\n\n";
  printlog("Response already exists, no email\n");
  exit;
}

  if ($err) {
    print "Status: 411 Session Error ($sessionid)\n\n";
    printlog "session problem $err\n";
    exit;
  }

if ( $f{_validate_response} != "VERIFIED"
        and
     $f{'notify_version'} !~ /^[123]\./ 
	and
     $f{'notify_version'} ne 'mo1.0' ) {

  # Note to log file
  printlog "Found proper session but the notify failed.  Safety Logging.\n";
  
  open SAFE, ">>/home/ozawacup/cgi-bin/SAFETY_LOG";
  print SAFE Dumper $params;
  close SAFE;
  
  print "Status: 200 Data Recorded in Safety Log\n\n";

  printlog "Safety Log";
  exit;
}

printlog "notification version identified\n";
###############################################################

# Save the data

$session->{'paypal'} = $params;
$session->{'paypalResponse'} = \%f;
$data = $session;

###############################################################

printlog "Check for completed\n";
# We need to decide if we send the e-mail or not.
unless ($f{'payment_status'} eq 'Completed') {
  print("Status: 214 Data recorded but no e-mail, payment status not Completed\n\n");
  exit;
}

###############################################################

printlog "initiate send email\n";
$result = sendemail( { server => "localhost", from => "Ozawa Cup International Karate Tournament <register\@ozawa-tournament.com>", admin => "<jamest\@lvshotokan.com>", scott => "<scottb\@universalrealty.com>", client => $data->{'paypal'}{'payer_email'} }, $data );

print("Status: 211 data recorded and email $result\n\n");

printlog "email result: $result\n";

exit; # make sure no stray code gets executed

###############################################################

sub getresponse {
  my $url = shift;

  $ua = LWP::UserAgent->new;

  $headers = HTTP::Headers->new('Content-Type', 'application/x-www-form-urlencoded', 'User-agent', 'LVSHOTOKAN-PAYPAL-IPN');

  $request = HTTP::Request->new('POST', $url, $headers);

  my $new = [];
printlog("\n-posting--\n");
printlog(join '&', ("cmd=_notify-validate", $buffer) );
printlog("\n---\n");

  $request->content(join '&', ("cmd=_notify-validate", $buffer) );

  $response = $ua->request($request);

  my $serverreply = $response->content;
printlog("\n-reply-". $response->code . " " . $response->message . "-\n");
printlog($response->headers_as_string);
printlog("\n");
printlog("$serverreply");
printlog("\n---\n");

  if ($debug) {
    print("RESPONSE FROM SERVER");
  
    print("<pre>$serverreply</pre>");
  } 
  return $serverreply;
}

sub getFORMval {
  my $key = shift;
  if (defined $params->{$key} and length $params->{$key}) {
    return $params->{$key};
  }
  return undef;
}

sub getQSval {
  my $key = shift;
  if (defined $params->{$key} and length $params->{$key}) {
    return $params->{$key};
  }
  return undef;
}

sub dircat {
  return join '\\', @_;
}

sub printlog {
  if (defined $logger) {
    print $logger @_;
  }
}
 
######################################################
# SENDEMAIL
#
# This sends reciept e-mail to the appropriate people
######################################################
# Parameters:
# ref to mail parameters hash:
#  server => mail server
#  from => from address
#  admin => admin address
#  client => client address
# ref to data hash:
#  key => value
# Text to insert at top of client e-mail
######################################################
sub sendemail {
  use Net::SMTP;
  my $mail = shift;
  my $data = shift;
#foreach ($mail->{'admin'}, $mail->{'scott'}, $mail->{'client'}, 'register@ozawa-tournament.com', 'skylos@gmail.com') 
  my $smtp = new Net::SMTP $mail->{'server'};#, Debug => 1;

  unless (defined $smtp) {
    return("SMTP socket to $mail->{'server'} FAILED\n");
  }

  printlog('sending email from ozawacup@romeo.he.net'."\n");
  push @warnings, 'adminfrom FAILED ozawacup@romeo.he.net' unless $smtp->mail('ozawacup@romeo.he.net');
  foreach ($mail->{'admin'}, $mail->{'scott'}, $mail->{'client'}, 'register@ozawa-tournament.com', 'skylos@gmail.com') {
    unless ($smtp->to($_) ) {
      push @warnings, "Unable to send email to $_!" 
    } else {
      printlog("sending email to $_\n");
    }
  }
  push @warnings, "admin data FAILED" unless $smtp->data;
  $smtp->datasend("From: " . $mail->{'from'} . "\n");
  $smtp->datasend("To: " . $mail->{'client'} . "\n");
  $smtp->datasend("Reply-To: " . $mail->{'admin'} . "\n");
  $smtp->datasend("Subject: Ozawa Cup Registration Confirmation\n");
  $smtp->datasend("\n");
  $smtp->datasend(<<"END");
Thank you for registering online for the Ozawa Cup International Karate Tournament.  We have received your paypal funds.  Below you will find a summary of all the information you entered on our site.

END
  if ($data->{'dojo'}{'name'}) {
    $smtp->datasend(<<"END");
Dojo:
$data->{'dojo'}{'sensei'}
$data->{'dojo'}{'name'}
$data->{'dojo'}{'address1'}
$data->{'dojo'}{'address2'}
$data->{'dojo'}{'city'}, $data->{'dojo'}{'state'} $data->{'dojo'}{'postalcode'}
$data->{'dojo'}{'country'}

END
}
  if (scalar @{$data->{'participants'}}) {
    $smtp->datasend(<<"END");
Participants:

END
    foreach my $participant (@{$data->{'participants'}}) {
      $smtp->datasend(join "\n", map { 'Registered for ' . eventlookup($_) . divisionlookup($_, $participant->{'events'}{$_}) . "\n" } grep { length $participant->{'events'}{$_} > 0 } keys %{$participant->{'events'}});

      $smtp->datasend(<<"END");
Name: $participant->{'name'}
Rank Category: $participant->{'rank'}
Date of Birth: $participant->{'dob-year'}-$participant->{'dob-month'}-$participant->{'dob-day'}
Gender: $participant->{'gender'}
Address:
$participant->{'address1'}
$participant->{'address2'}
$participant->{'city'}, $participant->{'state'} $participant->{'postalcode'}
$participant->{'country'}

END
    }
  }

  if (scalar keys %{$data->{'teams'}}) {
    $smtp->datasend("\nTeams:\n");
    foreach (keys %{$data->{'teams'}}) {
      $ref = $data->{'teams'}{$_};
      $smtp->datasend("$_\n");
      $smtp->datasend("Kata Division: $ref->{'katadiv'}\n") if (defined $ref->{'katadiv'});
      $smtp->datasend("Kumite Division: $ref->{'kumitediv'}\n") if (defined $ref->{'kumitediv'});
      foreach (@{$ref->{'members'}}) {
        $smtp->datasend("$_\n");
      }
    }
  }

  if ($data->{'extras'}{'dinners'}) {
    $smtp->datasend("\n2007 Ozawa Cup Banquets: $data->{'extras'}{'dinners'}\n");
    $smtp->datasend("Banquet Attendees:\n");
    $smtp->datasend(sprintf "%8s|%19s|%19s|%14s|%14s\n", 'Entree', 'Name', 'City', 'State', 'Country');
    $smtp->datasend(sprintf "%8s|%19s|%19s|%14s|%14s\n" . "-"x8, "-"x19, "-"x19, "-"x14, "-"x14);
    foreach (@{$data->{'banquet'}}) {
      next unless (defined $_);
      next unless (exists $_->{'name'});
      $smtp->datasend(sprintf "%10s|%19s|%19s|%14s|%14s", $_->{'entree'}, $_->{'name'}, $_->{'city'}, $_->{'state'}, $_->{'country'});
    }
    $smtp->datasend("\n");
  }
  $smtp->datasend(<<"END");

---

Receipt:
Individual Event Fees: $data->{'eventtotal'}
Team Event Fees: $data->{'teameventtotal'}
Kata Team Event Fees: $data->{'teamkataeventtotal'}
Kumite Team Event Fees: $data->{'teamkumiteeventtotal'}
Kumite Team Special Event Fees: $data->{'teamkumiteeventspecial'}

Video Pass Fees: $data->{'videopasstotal'}
Admission Fees: $data->{'admittotal'}
Seminar Fees: $data->{'seminartotal'}
Banquet Fees: $data->{'dinnertotal'}

Grand Total: $data->{'grandtotal'}
Amount Paid: $data->{'paypal'}{'payment_gross'}

---

END
  if (scalar @warnings) {
    $smtp->datasend("Warnings while sending this message!\n");
    $smtp->datasend(join "\n", @warnings);
    $smtp->datasend("\n");
  }
  printlog("SENDEMAIL: WARNING: $_\n") foreach (@warnings);
  printlog("SEND FAILED") unless $smtp->dataend;


  printlog("SEND SUCCESS") unless $smtp->dataend;
  return "SUCCESS";
}

# URL decoder
sub UrlDecode {
  foreach (@_) {
    $_ =~ s/\+/ /g;
    $_ =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  }
  return @_;
}


# URL encoder
sub UrlEncode {
  $pat='[\x00-\x09\x0B-\x19"#%&+/;<>?\x7F-\xFF]';
  foreach (@_) {
    $_ =~ s/($pat)/sprintf("%%%02lx",unpack('C',$1))/eg;
    $_ =~ s/ /\+/g;
  }
  return @_;
}

};
if ($@) {
print "Content-type: text/plain\n\nERROR\n\n$@";
}

