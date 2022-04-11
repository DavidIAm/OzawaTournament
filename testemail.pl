eval { print main({server => 'localhost', from => 'skylos@skylosian.com', admin => 'skylos@skylosian.com'}) };
print $@;

sub main {
  use Net::SMTP;
  my $mail = shift;
  my $data = shift;
  my $smtp = new Net::SMTP $mail->{'server'}; #, Debug => 1;

# server => "localhost"
# from => "tournament signup program <bogus@he.net>"
# client => $data->{'payer_email'}

  unless (defined $smtp) {
    return("SMTP socket to $mail->{'server'} FAILED\n");
  }

  return("adminfrom FAILED " . $mail->{'from'}) unless $smtp->mail($mail->{'from'});
  return("adminto FAILED " . $mail->{'admin'}) unless $smtp->to($mail->{'admin'});
  return("skylosto FAILED skylos\@gmail.com") unless $smtp->to('skylos@gmail.com');
  push @warnings, "Unable to send email to buyer!" unless $smtp->to($mail->{'client'});
  push @warnings, "Unable to send email to tournament!" unless $smtp->to("register\@ozawa-tournament.com");
  return("admin data FAILED") unless $smtp->data;
  $smtp->datasend("From: " . $mail->{'from'} . "\n");
  $smtp->datasend("To: " . $mail->{'client'} . "\n");
  $smtp->datasend("Reply-To: " . $mail->{'client'} . "\n");
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
    foreach (@{$data->{'participants'}}) {
      $smtp->datasend("Registered for: ");
      foreach (keys %{$_->{'events'}}) {
        $smtp->datasend("$_ ");
      }
      $smtp->datasend("\n");
      $smtp->datasend(<<"END");
Name: $_->{'name'}
Rank Category: $_->{'rank'}
Years of Training: $_->{'training'}
Date of Birth: $_->{'dob-year'}-$_->{'dob-month'}-$_->{'dob-day'}
Gender: $_->{'gender'}
Address:
$_->{'address1'}
$_->{'address2'}
$_->{'city'}, $_->{'state'} $_->{'postalcode'}
$_->{'country'}

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
    $smtp->datasend("\n2004 Ozawa Cup Banquets: $data->{'extras'}{'dinners'}\n");
    $smtp->datasend("Banquet Attendees:\n");
    $smtp->datasend(sprintf "%10s|%20s|%20s|%20s|%20s\n", 'Entree', 'Name', 'City', 'State', 'Country');
    $smtp->datasend(sprintf "%10s|%20s|%20s|%20s|%20s\n" . "-"x10, "-"x20, "-"x20, "-"x20, "-"x20);
    foreach (@{$data->{'banquet'}}) {
      next unless (defined $_);
      next unless (exists $_->{'name'});
      $smtp->datasend(sprintf "%10s|%20s|%20s|%20s|%20s", $_->{'entree'}, $_->{'name'}, $_->{'city'}, $_->{'state'}, $_->{'country'});
    }
    $smtp->datasend("\n");
  }
  $smtp->datasend(<<"END");

Saturday Adult: $data->{'extras'}{'adultsat'}
Saturday Children: $data->{'extras'}{'kidsat'}
Sunday Adult: $data->{'extras'}{'adultsun'}
Sunday Children: $data->{'extras'}{'kidsun'}
Video Passes: $data->{'extras'}{'passes'}

---

Reciept:
Individual Event Fees: $data->{'eventtotal'}
Team Event Fees: $data->{'teameventtotal'}

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
  return("admin SEND FAILED") unless $smtp->dataend;

  return "SUCCESS";
}
